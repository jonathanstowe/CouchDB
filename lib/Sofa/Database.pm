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

    has URI::Template $!local-template;

    has Supply        $!changes-supply;

    has Promise       $!delete-promise = Promise.new;

    method local-template() returns URI::Template {
        if not $!local-template.defined {
            # may want to be + in our template
            $!local-template = URI::Template.new(template => "{ $!name }" ~ '{/path*}{?params*}');
        }
        $!local-template;
    }

    method get-local-path(*%parts) returns Str {
        self.local-template.process(|%parts);
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
        my $path = self.get-local-path(path => '_all_docs', params => %params);
        my $response = self.ua.get(path => $path);
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

        my $response = self.ua.get(path => $path, |%header );
        if $response.is-success {
            $response.from-json;
        }
        else {
            self!get-exception($response.code, $!name, 'getting all docs').throw;
        }
    }




    multi method create-document(Sofa::Database:D: %document) returns Sofa::Document {
        my $response = self.ua.post(path => $!name, content => %document);
        if $response.is-success {
           $response.from-json(Sofa::Document);
        }
        else {
            self!get-exception($response.code, $!name, 'creating document').throw;
        }
    }

    multi method create-document(Sofa::Database:D: Str $doc-id, %document) returns Sofa::Document {
        self!put-document(%document, $doc-id, what => "creating document");
    }

    multi method create-document(Sofa::Database:D: JSON::Class $document) returns Sofa::Document {
        $document does Sofa::Document::Wrapper unless $document ~~ Sofa::Document::Wrapper;
        my $response = self.ua.post(path => $!name, content => $document);
        if $response.is-success {
           my $doc = $response.from-json(Sofa::Document);
           $document.update-rev($doc);
           $doc;
        }
        else {
            self!get-exception($response.code, $!name, 'creating document').throw;
        }
    }

    multi method create-document(Sofa::Database:D: Str $doc-id, JSON::Class $document) returns Sofa::Document {
        $document does Sofa::Document::Wrapper unless $document ~~ Sofa::Document::Wrapper;
        my $doc-info = self!put-document($document, $doc-id, what => 'creating document' );
        $document.update-rev($doc-info);
        $doc-info;
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

    multi method put-design(Sofa::Database:D: NamedDesign $doc ) returns Sofa::Document {
        my $doc-info = self!put-document($doc, $doc.id-or-name, $doc.sofa_document_revision, what => 'putting design document'); 
        $doc.update-rev($doc-info);
        $doc-info;
    }

    multi method put-design(Sofa::Database:D: NoNameDesign $doc, Str:D $doc-id ) returns Sofa::Document {
        my $doc-info = self!put-document($doc, design-id($doc-id), $doc.sofa_document_revision, what => 'putting design document'); 
        $doc.update-rev($doc-info);
        $doc-info;
    }

    # Because we might not dealing with one we created ourself $!name can't be required
    multi method put-design(NoNameDesign $) {
        X::NoIdOrName.new.throw;
    }

    proto method delete-design(|c) { * }
    # just for consistency
    multi method delete-design(Sofa::Database:D: Sofa::Document:D $doc) returns Sofa::Document {
        self!delete-document(design-id($doc.id), $doc.rev);
    }
    multi method delete-design(Sofa::Database:D: Sofa::Design:D $doc ) returns Sofa::Document {
        self!delete-document($doc.id-or-name, $doc.sofa_document_revision );
    }

    proto method get-design(|c) { * }

    multi method get-design(Sofa::Database:D:  Sofa::Document:D $doc) returns Sofa::Design {
        samewith($doc.id);
    }

    multi method get-design(Sofa::Database:D: Str $doc-id) returns Sofa::Design {
        self!get-document(design-id($doc-id), type => Sofa::Design);
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

    # Hack to be able to determine whether we got a real class
    my class NoType {}

    method !get-document(Sofa::Database:D: $doc-id, Mu:U :$type = NoType ) {
        my $path = self.get-local-path(path => $doc-id);
        my $response = self.ua.get(:$path);

        my $wrapped-type = do if  $type !~~ NoType {
            $type ~~ Sofa::Document::Wrapper ?? $type !! $type but Sofa::Document::Wrapper;
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
            self!get-exception($response.code, $doc-id.join('/'), 'retrieving document', Document).throw;
        }
    }

    multi method update-document(Sofa::Database:D: Sofa::Document:D $doc, %document ) returns Sofa::Document {
        samewith($doc.id, $doc.rev, %document);
    }

    multi method update-document(Sofa::Database:D: Str $doc-id, Str $doc-rev, %document) returns Sofa::Document {
        self!put-document(%document, $doc-id, $doc-rev);
    }

    multi method update-document(Sofa::Database:D: Sofa::Document::Wrapper $document) returns Sofa::Document {
        my $doc = self!put-document($document, $document.sofa_document_id, $document.sofa_document_revision);
        $document.update-rev($doc);
        $doc;
    }

    method !put-document($document, $doc-id, Str $doc-rev?, :$what = 'updating document') {
        my $path = self.get-local-path(path => $doc-id);
        my %h;
        if $doc-rev.defined {
            %h<If-Match> = $doc-rev;
        }
        my $response = self.ua.put(:$path, content => $document, |%h);
        if $response.is-success {
            $response.from-json(Sofa::Document);
        }
        else {
            self!get-exception($response.code, $doc-id, $what).throw;
        }
    }

    multi method delete-document(Sofa::Database:D: Sofa::Document::Wrapper:D $doc) returns Sofa::Document {
        samewith($doc.sofa_document_id, $doc.sofa_document_revision);
    }

    multi method delete-document(Sofa::Database:D: Sofa::Document:D $doc ) returns Sofa::Document {
        samewith($doc.id, $doc.rev);
    }

    multi method delete-document(Sofa::Database:D: Str $doc-id, Str $doc-rev) returns Sofa::Document {
        self!delete-document($doc-id, $doc-rev);
    }

    method !delete-document(Sofa::Database:D: $doc-id, Str $doc-rev) {
        my $path = self.get-local-path(path => $doc-id);
        my $response = self.ua.delete(:$path, If-Match => $doc-rev);
        if $response.is-success {
            $response.from-json(Sofa::Document);
        }
        else {
            self!get-exception($response.code, $doc-id, 'deleting document').throw;
        }
    }


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
    
}

# vim: expandtab shiftwidth=4 ft=perl6
