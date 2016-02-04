use JSON::Name;

use JSON::Class:ver(v0.0.5..*);
use Sofa::UserAgent;

class Sofa::Database does JSON::Class {
    use Sofa::Document;
    use Sofa::Document::Wrapper;
    use Sofa::Design;

    sub microsecs-to-dt($val) returns DateTime {
        DateTime.new(($val.Numeric/1000000).Int);
    }

    has Int         $.doc_del_count;
    has Int         $.disk_format_version;
    has Int         $.committed_update_seq;
    has Int         $.purge_seq;
    has Int         $.doc_count;
    has Bool        $.compact_running;
    has Int         $.disk_size;
    has Int         $.data_size;
    has DateTime    $.instance_start_time is unmarshalled-by(&microsecs-to-dt);
    has Int         $.update_seq;
    has Str         $.name                is json-name('db_name');

    has Sofa::UserAgent $.ua is rw;

    has Supply        $!changes-supply;

    has Promise       $!delete-promise = Promise.new;

    method get-local-path(*%parts) {
         [ flat $!name, %parts<path>.flat.grep({.defined}) ];
    }

    class X::InvalidName is Exception {
        has $.name;
        method message() returns Str {
            "'{$!name}' is not a valid DB name";
        }
    }

    class X::DatabaseExists is Exception {
        has $.name;
        method message() returns Str {
            "Database '{$!name}' already exists";
        }
    }

    class X::DocumentConflict is Exception {
        has $.name;
        has $.what;
        method message() returns Str {
            "There was a conflict while { $!what } document '{$!name}'";
        }
    }
    class X::NoDatabase is Exception {
        has $.name;
        method message() returns Str {
            "Database '{$!name}' does not exist";
        }
    }

    class X::NoDocument is Exception {
        has $.name;
        has $.what;
        method message() {
            "Document '{ $!name }' not found while '{ $!what }'";
        }
    }

    class X::NotAuthorised is Exception {
        has $.name;
        has $.what;
        method message() returns Str {
            "You are not authorised to { $!what } database '{$!name}'";
        }
    }

    class X::NoIdOrName is Exception {
        has $.message = "Cannot put a design document without a name or id";
    }



    method is-valid-name(Str:D $name) {
	    my token valid-db-name {
		    ^<[a .. z]><[a .. z0 .. 9_$()+/-]>*$
	    }
        so ($name ~~ /<valid-db-name>/);
    }

    enum ExceptionContext <Database Document>;

    method !get-exception(Int() $code, $name, Str $what, ExceptionContext $context = Database) {
        given $code {
            when 400 {
                X::InvalidName.new(:$name);
            }
            when 401 {
                X::NotAuthorised.new(:$name, :$what);
            }
            when 404 {
                given $context {
                    when Database {
                        X::NoDatabase.new(:$name);
                    }
                    when Document {
                        X::NoDocument.new(:$name, :$what);
                    }
                }
            }
            when 409 {
                X::DocumentConflict.new(:$name, :$what);
            }
            when 412 {
                # This is not actually right as 412 is more context sensitive
                X::DatabaseExists.new(:$name);
            }
            default {
                die "WTF : $_";
            }
        }
    }

    method fetch(Sofa::Database:U: Str :$name!, Sofa::UserAgent :$ua!) returns Sofa::Database {
        my $db;

        my $response = $ua.get(path => $name);

        if $response.is-success {
            $db = self.from-json($response.content);
            $db.ua = $ua;
        }
        else {
            self!get-exception($response.code, $name, 'fetching').throw;
        }
        $db;
    }

    method create(Sofa::Database:U: Str :$name!, Sofa::UserAgent :$ua!) returns Sofa::Database {
        my $db;

        if self.is-valid-name($name) {
            my $response = $ua.put(path => $name);
            if $response.is-success {
                $db = self.fetch(:$name, :$ua);
            }
            else {
                self!get-exception($response.code, $name, 'creating').throw;
            }
        }
        else {
            X::InvalidName.new(:$name).throw;
        }
        $db;
    }

    multi method all-docs(Sofa::Database:D: :$detail) {
        my %params;

        if $detail {
            %params<include_docs> = "true";

        }
        my $path = self.get-local-path(path => '_all_docs');
        my $response = self.ua.get(path => $path, params => %params);
        if $response.is-success {
            $response.from-json<rows>;
        }
        else {
            self!get-exception($response.code, $!name, 'getting all docs').throw;
        }
    }

    method changes-supply(Sofa::Database:D:) {
        $!changes-supply //= ( supply {
            my $supplier = Supplier.new;

            whenever $supplier.Supply -> $v {
                emit($v);
            }

            my $p = start {
                my $last-seq;
                loop {
                    if $!delete-promise {
                        last;
                    }
                    my $changes = self.get-changes($last-seq,:poll); 
                    for $changes<results>.list -> $result {
                        if !($last-seq.defined && ($last-seq eq $result<seq> )) {
                            $supplier.emit($result);
                        }
                    }
                    $last-seq = $changes<last_seq>;
                }
                $supplier.done;
            }
            whenever $p {
                done;
            }
        }).unique(as => { $_<seq> }, expires => 5);
        $!changes-supply;
    }

    method get-changes(Sofa::Database:D: $last-seq?, :$poll) {
        my %params;

        if $poll {
            %params<feed> = "longpoll";
        }
        my $path = self.get-local-path(path => '_changes', params => %params);

        my %header;

        if $last-seq.defined {
            %header<Last-Event-ID> = $last-seq;
        }

        my $response = self.ua.get(path => $path, params => %params, |%header );
        if $response.is-success {
            $response.from-json;
        }
        else {
            self!get-exception($response.code, $!name, 'getting all docs').throw;
        }
    }


    proto method create-document(|c) { * }

    multi method create-document(Sofa::Database:D: %document) returns Sofa::Document {
        self!post-document(%document, Str, what => 'creating document');
    }

    multi method create-document(Sofa::Database:D: Str $doc-id, %document) returns Sofa::Document {
        self!put-document(%document, $doc-id, what => "creating document");
    }

    multi method create-document(Sofa::Database:D: JSON::Class $document) returns Sofa::Document {
        $document does Sofa::Document::Wrapper unless $document ~~ Sofa::Document::Wrapper;
        self!post-document($document, Str, what => 'creating document');
    }


    multi method create-document(Sofa::Database:D: Str $doc-id, JSON::Class $document) returns Sofa::Document {
        $document does Sofa::Document::Wrapper unless $document ~~ Sofa::Document::Wrapper;
        self!put-document($document, $doc-id, what => 'creating document' );
    }

    sub design-id(Str $doc-id )  {
        my $new-doc-id;
        if $doc-id !~~ /^_design\// {
            $new-doc-id = ['_design', $doc-id];
        }
        else {
            $new-doc-id = $doc-id.split('/');
        }
        $new-doc-id;
    }

    
    subset NamedDesign  of Sofa::Design where  { $_.defined && ( $_.name.defined || $_.sofa_document_id.defined ) };
    subset NoNameDesign of Sofa::Design where  { $_.defined && ( !$_.name.defined and !$_.sofa_document_id.defined ) };

    proto method put-design(|c) { * }

    multi method put-design(Sofa::Database:D: NamedDesign $doc ) returns Sofa::Document {
        self!put-document($doc, $doc.id-or-name, $doc.sofa_document_revision, what => 'putting design document'); 
    }

    multi method put-design(Sofa::Database:D: NoNameDesign $doc, Str:D $doc-id ) returns Sofa::Document {
        self!put-document($doc, design-id($doc-id), $doc.sofa_document_revision, what => 'putting design document'); 
    }

    # Because we might not dealing with one we created ourself $!name can't be required
    multi method put-design(NoNameDesign $) {
        X::NoIdOrName.new.throw;
    }


    proto method get-design(|c) { * }

    multi method get-design(Sofa::Database:D:  Sofa::Document:D $doc) returns Sofa::Design {
        samewith($doc.id);
    }

    multi method get-design(Sofa::Database:D: Str $doc-id) returns Sofa::Design {
        self!get-document(design-id($doc-id), type => Sofa::Design, what => 'getting design');
    }

    class ViewResponse does JSON::Class {
        class Row {
            has Str $.id;
            has Str $.key;
            has     $.value;
        }
        has Int $.offset;
        has Int $.total_rows;
        has Row @.rows;
    }

    proto method get-view(|c) { * }

    multi method get-view(Sofa::Database:D: Sofa::Design:D $design, Str $view-name, *@keys) {
        if $design.views{$view-name}:exists {
            my @design-parts = flat $design.id-or-name.flat, '_view', $view-name;
            my %params;

            my Bool $use-post = False;

            my %content;

            if @keys {
                if @keys.elems == 1 {
                    %params<key> = '"' ~ @keys[0] ~ '"';
                }
                else {
                    %content<keys> = @keys;
                    $use-post = True;
                }
            }
            if $use-post {
                self!post-document(%content, @design-parts, type => ViewResponse, params => %params, what => 'retrieving view', :no-wrapper)
            }
            else {
                self!get-document(@design-parts, type => ViewResponse, params => %params, what => 'retrieving view', :no-wrapper)
            }
        }
        else {
            X::NoDocument.new(name => $view-name, what => "getting view").throw;
        }
    }

    proto method delete-design(|c) { * }

    multi method delete-design(Sofa::Database:D: Sofa::Document:D $doc) returns Sofa::Document {
        self!delete-document(design-id($doc.id), $doc.rev, what => 'deleting design');
    }
    multi method delete-design(Sofa::Database:D: Sofa::Design:D $doc ) returns Sofa::Document {
        self!delete-document($doc.id-or-name, $doc.sofa_document_revision, what => 'deleting design');
    }


    proto method get-document(|c) { * }

    multi method get-document(Sofa::Database:D: Sofa::Document:D $doc ) {
        samewith($doc.id);
    }

    multi method get-document(Sofa::Database:D: Sofa::Document:D $doc, JSON::Class:U $c ) {
        samewith($doc.id, $c);
    }

    multi method get-document(Sofa::Database:D: Str $doc-id ) {
        self!get-document($doc-id);
    }
    
    multi method get-document(Sofa::Database:D: Str $doc-id, JSON::Class:U $c ) {
        self!get-document($doc-id, type => $c);
    }


    proto method update-document(|c) { * }

    multi method update-document(Sofa::Database:D: Sofa::Document:D $doc, %document ) returns Sofa::Document {
        samewith($doc.id, $doc.rev, %document);
    }

    multi method update-document(Sofa::Database:D: Str $doc-id, Str $doc-rev, %document) returns Sofa::Document {
        self!put-document(%document, $doc-id, $doc-rev);
    }

    multi method update-document(Sofa::Database:D: Sofa::Document::Wrapper $document) returns Sofa::Document {
        self!put-document($document, $document.sofa_document_id, $document.sofa_document_revision);
    }


    proto method delete-document(|c) { * }

    multi method delete-document(Sofa::Database:D: Sofa::Document::Wrapper:D $doc) returns Sofa::Document {
        samewith($doc.sofa_document_id, $doc.sofa_document_revision);
    }

    multi method delete-document(Sofa::Database:D: Sofa::Document:D $doc ) returns Sofa::Document {
        samewith($doc.id, $doc.rev);
    }

    multi method delete-document(Sofa::Database:D: Str $doc-id, Str $doc-rev) returns Sofa::Document {
        self!delete-document($doc-id, $doc-rev);
    }

    proto method delete(|c) { * }

    multi method delete(Sofa::Database:U: Str :$name!, :$ua!) returns Bool {
        my $response = $ua.delete(path => $name);
        if not $response.is-success {
            self!get-exception($response.code, $name, 'delete').throw;
        }
        True;
    }

    multi method delete(Sofa::Database:D:) returns Bool {
        my $a = Sofa::Database.delete(name => $!name, ua => $!ua);
        $!delete-promise.keep if $a;
        $a;
    }

    # Hack to be able to determine whether we got a real class
    my class NoType {}

    method !get-document(Sofa::Database:D: $doc-id, Mu:U :$type = NoType, Bool :$no-wrapper, :%params, :%headers, Str :$what = 'retrieving document' ) {
        my $path = self.get-local-path(path => $doc-id);
        my $response = self.ua.get(:$path, :%params, |%headers);

        my $wrapped-type = do if  $type !~~ NoType {
            $no-wrapper ?? $type !! $type ~~ Sofa::Document::Wrapper ?? $type !! $type but Sofa::Document::Wrapper;
        }
        if $response.is-success {
            if $type ~~ NoType {
                $response.from-json;
            }
            else {
                $response.from-json($wrapped-type);
            }
        }
        else {
            self!get-exception($response.code, $doc-id.join('/'), $what, Document).throw;
        }
    }

    method !post-document($document, $doc-id, Mu:U :$type = Sofa::Document, :%params, :%headers, :$what = 'creating document') {
        my $path = self.get-local-path(path => $doc-id);
        my $response = self.ua.post(path => $path, :%params, content => $document, |%headers);
        if $response.is-success {
            my $doc = $response.from-json($type);
            if $document.can('update-rev') && $type ~~ Sofa::Document {
                $document.update-rev($doc);
            }
            $doc;
        }
        else {
            self!get-exception($response.code, $!name, $what).throw;
        }
    }

    method !put-document($document, $doc-id, Str $doc-rev?, :%params, :%headers, :$what = 'updating document') {
        my $path = self.get-local-path(path => $doc-id);
        if $doc-rev.defined {
            if not %headers<If-Match>:exists {
                %headers<If-Match> = $doc-rev;
            }
        }
        my $response = self.ua.put(:$path, :%params, content => $document, |%headers);
        if $response.is-success {
            my $ddoc = $response.from-json(Sofa::Document);
            if $document.can('update-rev') {
                $document.update-rev($ddoc);
            }
            $ddoc;
        }
        else {
            self!get-exception($response.code, $doc-id, $what).throw;
        }
    }

    method !delete-document(Sofa::Database:D: $doc-id, Str $doc-rev, :%params, :%headers, Str :$what = 'deleting document') {
        my $path = self.get-local-path(path => $doc-id);
        if $doc-rev.defined {
            if not %headers<If-Match>:exists {
                %headers<If-Match> = $doc-rev;
            }
        }
        my $response = self.ua.delete(:$path, :%params, |%headers);
        if $response.is-success {
            $response.from-json(Sofa::Document);
        }
        else {
            self!get-exception($response.code, $doc-id, $what).throw;
        }
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
