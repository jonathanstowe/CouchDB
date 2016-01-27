use JSON::Class;
use JSON::Unmarshal;

class Sofa::Database does JSON::Class {
    use Sofa::UserAgent;
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
            $!local-template = URI::Template.new(template => "/{ $!name }" ~ '{/path}{?params*}');
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

    class X::NotAuthorised is Exception {
        has $.name;
        has $.what;
        method message() returns Str {
            "You are not authorised to { $!what } database '{$!name}'";
        }
    }



    method is-valid-name(Str:D $name) {
	    my token valid-db-name {
		    ^<[a .. z]><[a .. z0 .. 9_$()+/-]>*$
	    }
        so ($name ~~ /<valid-db-name>/);
    }

    method !get-exception(Int() $code, Str $name, Str $what) {
        given $code {
            when 400 {
                X::InvalidName.new(:$name);
            }
            when 401 {
                X::NotAuthorised.new(:$name, :$what);
            }
            when 404 {
                X::NoDatabase.new(:$name);
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
        $!changes-supply //= supply {
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
        }
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

    class Document does JSON::Class {
        has Str  $.id;
        has Str  $.rev;
        has Bool $.ok;
    }


    my role DocumentWrapper {
        has Str $.sofa_document_type = _get_doc_name();
        has Str $.sofa_document_id       is json-name('_id');
        has Str $.sofa_document_revision is json-name('_rev');

        sub _get_doc_name() {
            my $n = ::?CLASS.^name.lc.subst(/\:+/,"_", :g);
            $n.subst(/\+.*/,'');
        } 
        method to-json() {
            if not $!sofa_document_type {
                $!sofa_document_type = _get_doc_name();
            }
            nextsame;
        }
    }

    multi method create-document(Sofa::Database:D: %document) returns Document {
        my $response = self.ua.post(path => $!name, content => %document);
        if $response.is-success {
           $response.from-json(Document);
        }
        else {
            self!get-exception($response.code, $!name, 'creating document').throw;
        }
    }

    multi method create-document(Sofa::Database:D: Str $doc-id, %document) returns Document {
        self!put-document(%document, $doc-id, what => "creating document");
    }

    multi method get-document(Sofa::Database:D: Document:D $doc ) {
        samewith($doc.id);
    }

    multi method get-document(Sofa::Database:D: Str $doc-id ) {
        my $path = self.get-local-path(path => $doc-id);
        my $response = self.ua.get(:$path);
        if $response.is-success {
            $response.from-json;
        }
        else {
            self!get-exception($response.code, $!name, 'retrieving document').throw;
        }
    }

    multi method update-document(Sofa::Database:D: Document:D $doc, %document ) returns Document {
        samewith($doc.id, $doc.rev, %document);
    }

    multi method update-document(Sofa::Database:D: Str $doc-id, Str $doc-rev, %document) returns Document {
        self!put-document(%document, $doc-id, $doc-rev);
    }

    method !put-document(%document, Str $doc-id, Str $doc-rev?, :$what = 'updating document') {
        my $path = self.get-local-path(path => $doc-id);
        my %h;
        if $doc-rev.defined {
            %h<If-Match> = $doc-rev;
        }
        my $response = self.ua.put(:$path, content => %document, |%h);
        if $response.is-success {
            $response.from-json(Document);
        }
        else {
            self!get-exception($response.code, $doc-id, $what).throw;
        }
    }

    multi method delete-document(Sofa::Database:D: Document:D $doc ) returns Document {
        samewith($doc.id, $doc.rev);
    }

    multi method delete-document(Sofa::Database:D: Str $doc-id, Str $doc-rev) returns Document {
        my $path = self.get-local-path(path => $doc-id);
        my $response = self.ua.delete(:$path, If-Match => $doc-rev);
        if $response.is-success {
            $response.from-json(Document);
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
