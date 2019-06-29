use JSON::Name;
use Sofa::Method;

use JSON::Class:ver(v0.0.5+);
use Sofa::UserAgent;

use Sofa::Exception;

class Sofa::Database does JSON::Class does Sofa::Exception::Handler {
    use Sofa::Document;
    use Sofa::Document::Wrapper;
    use Sofa::Document::All;
    use Sofa::Design;
    use Sofa::Database::Security;

    sub microsecs-to-dt($val) returns DateTime {
        DateTime.new(($val.Numeric/1000000).Int);
    }

    has Int         $.document-delete-count         is json-name('doc_del_count');
    has Int         $.disk-format-version           is json-name('disk_format_version');
    has Int         $.committed-update-seq          is json-name('commited_update_seq');
    has Str         $.purge-seq                     is json-name('purge_seq');
    has Int         $.doc-count                     is json-name('doc_count');
    has Bool        $.compact-running               is json-name('compact_running');
    has Int         $.disk-size                     is json-name('disk_size');
    has Int         $.data-size                     is json-name('data_size');
    has DateTime    $.instance-start-time           is json-name('instance_start_time') is unmarshalled-by(&microsecs-to-dt);
    has Str         $.update_seq;
    has Str         $.name                is json-name('db_name');

    has Sofa::UserAgent $.ua is rw;
    has Supply          $!changes-supply;
    has Promise         $!delete-promise = Promise.new;

    method get-local-path(*%parts) {
         [ flat $!name, %parts<path>.flat.grep({.defined}) ];
    }

    method is-valid-name(Str:D $name) {
        my token valid-db-name {
            ^<[a .. z]><[a .. z0 .. 9_$()+/-]>*$
        }
        so ($name ~~ /<valid-db-name>/);
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
            X::Sofa::InvalidName.new(:$name).throw;
        }
        $db;
    }

    constant AllDefault = Associative;
    multi method all-docs(Sofa::Database:D: :$detail, Mu:U :$type = AllDefault) {
        my %params;

        if $detail {
            %params<include_docs> = "true";

        }
        my $path = self.get-local-path(path => '_all_docs');
        my $response = self.ua.get(path => $path, params => %params);
        if $response.is-success {
            my $wrapped-type = $type ~~ Associative|Sofa::Document::Wrapper ?? $type !! $type but Sofa::Document::Wrapper;
            my $d := (class {} but Sofa::Document::All::Row.^parameterize($wrapped-type));
            my $c := (class {} but Sofa::Document::All.^parameterize($d));
            $response.from-json($c).rows;
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

        my $response = self.ua.get(:$path, :%params, |%header );
        if $response.is-success {
            $response.from-json;
        }
        else {
            self!get-exception($response.code, $!name, 'getting changes').throw;
        }
    }

    method security() is sofa-item('Sofa::Database::Security') { * };

    method update-security(Sofa::Database::Security $sec) {
        self!put-document($sec, '_security', what => 'updating security');
    }

    proto method create-document(|c) { * }

    multi method create-document(Sofa::Database:D: %document) returns Sofa::Document {
        self!post-document(%document, Str, what => 'creating document');
    }

    multi method create-document(Sofa::Database:D: Str $doc-id, %document) returns Sofa::Document {
        self!put-document(%document, $doc-id, what => "creating document");
    }

    multi method create-document(Sofa::Database:D: JSON::Class $document) returns Sofa::Document {
        sink $document does Sofa::Document::Wrapper unless $document ~~ Sofa::Document::Wrapper;
        self!post-document($document, Str, what => 'creating document');
    }


    multi method create-document(Sofa::Database:D: Str $doc-id, JSON::Class $document) returns Sofa::Document {
        sink $document does Sofa::Document::Wrapper unless $document ~~ Sofa::Document::Wrapper;
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


    subset NamedDesign  of Sofa::Design where  { $_.defined && ( $_.name.defined || $_.sofa-document-id.defined ) };
    subset NoNameDesign of Sofa::Design where  { $_.defined && ( !$_.name.defined and !$_.sofa-document-id.defined ) };

    proto method put-design(|c) { * }

    multi method put-design(Sofa::Database:D: NamedDesign $doc ) returns Sofa::Document {
        self!put-document($doc, $doc.id-or-name, $doc.sofa-document-revision, what => 'putting design document');
    }

    multi method put-design(Sofa::Database:D: NoNameDesign $doc, Str:D $doc-id ) returns Sofa::Document {
        self!put-document($doc, design-id($doc-id), $doc.sofa-document-revision, what => 'putting design document');
    }

    # Because we might not dealing with one we created ourself $!name can't be required
    multi method put-design(NoNameDesign $) {
        X::Sofa::NoIdOrName.new.throw;
    }


    proto method get-design(|c) { * }

    multi method get-design(Sofa::Database:D:  Sofa::Document:D $doc) returns Sofa::Design {
        self.get-design($doc.id);
    }

    multi method get-design(Sofa::Database:D: Str $doc-id) returns Sofa::Design {
        self!get-document(design-id($doc-id), type => Sofa::Design, what => 'getting design');
    }

    proto method add-design-attachment(|c) { * }

    multi method add-design-attachment(Sofa::Database:D: Sofa::Document:D $doc, Str $attachment-name, Str $content-type, $content ) returns Sofa::Document {
        self.add-document-attachment($doc, $attachment-name, $content-type, $content);
    }

    multi method add-design-attachment(Sofa::Database:D: Sofa::Design:D $design, Str $attachment-name, Str $content-type, $content ) returns Sofa::Document {
        self.add-document-attachment($design.sofa-document-id, $design.sofa-document-revision, $attachment-name, $content-type, $content);
    }

    proto method get-design-attachment(|c) { * }

    multi method get-design-attachment(Sofa::Database:D: Sofa::Document:D $doc, Str $attachment-name) {
        self.get-document-attachment($doc, $attachment-name);
    }

    multi method get-design-attachment(Sofa::Database:D: Sofa::Design:D $design, Str $attachment-name) {
        self.get-document-attachment($design.sofa-document-id, $attachment-name);
    }

    multi method get-design-attachment(Sofa::Database:D: Str $design-name, Str $attachment-name) {
        my $design = self.get-design($design-name);
        self.get-design-attachment($design, $attachment-name);
    }

    proto method delete-design-attachment(|c) { * }

    multi method delete-design-attachment(Sofa::Database:D: Sofa::Document:D $doc, Str $attachment-name) returns Sofa::Document {
        self.delete-document-attachment($doc, $attachment-name);
    }

    multi method delete-design-attachment(Sofa::Database:D: Sofa::Design:D $design, Str $attachment-name) returns Sofa::Document {
        self.delete-document-attachment($design.sofa-document-id, $design.sofa-document-revision, $attachment-name);
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

    sub stringify-key($key) returns Str {
        '"' ~ $key.Str ~ '"';
    }

    proto method get-view(|c) { * }

    multi method get-view(Sofa::Database:D: Str $design-name, |c) {
        my $design = self.get-design($design-name);
        self.get-view($design, |c);
    }

    multi method get-view(Sofa::Database:D: Sofa::Design:D $design, Str $view-name, Bool :$descending, Str :$start-key, Str :$end-key, Int :$skip, Int :$limit, *@keys) {
        if $design.views{$view-name}:exists {
            my @design-parts = flat $design.id-or-name.flat, '_view', $view-name;
            my %params;

            my Bool $use-post = False;

            my %content;

            if @keys {
                if @keys.elems == 1 {
                    %params<key> = stringify-key(@keys[0]);
                }
                else {
                    %content<keys> = @keys;
                    $use-post = True;
                }
            }

            if $limit.defined {
                %params<limit> = $limit;
            }
            if $skip.defined {
                %params<skip> = $skip;
            }

            if $start-key.defined {
                %params<startkey> = stringify-key($start-key);
            }
            if $end-key.defined {
                %params<endkey> = stringify-key($end-key);
            }

            if $descending {
                %params<descending> = 'true';
            }

            if $use-post {
                self!post-document(%content, @design-parts, type => ViewResponse, params => %params, what => 'retrieving view', :no-wrapper)
            }
            else {
                self!get-document(@design-parts, type => ViewResponse, params => %params, what => 'retrieving view', :no-wrapper)
            }
        }
        else {
            X::Sofa::NoDocument.new(name => $view-name, what => "getting view").throw;
        }
    }

    proto method get-show(|c) { * }

    multi method get-show(Sofa::Database:D: Str $design-name, |c) {
        my $design = self.get-design($design-name);
        self.get-show($design, |c);
    }

    multi method get-show(Sofa::Database:D: Sofa::Design:D $design, Str $show-name, Str $doc-id?, *%params) {
        if $design.shows{$show-name}:exists {
            my @design-parts = flat $design.id-or-name.flat, '_show', $show-name, $doc-id;
            self!get-document(@design-parts, params => %params, what => 'retrieving show');

        }
        else {
            X::Sofa::NoDocument.new(name => $show-name, what => "getting show").throw;
        }
    }

    proto method get-list(|c) { * }

    multi method get-list(Sofa::Database:D: Str $design-name, |c) {
        my $design = self.get-design($design-name);
        self.get-list($design, |c);
    }

    multi method get-list(Sofa::Database:D: Sofa::Design:D $design, Str $list-name, Str $view-id, *%params) {
        if $design.lists{$list-name}:exists {
            if $design.views{$view-id}:exists {
                my @design-parts = flat $design.id-or-name.flat, '_list', $list-name, $view-id;
                self!get-document(@design-parts, params => %params, what => 'retrieving list');
            }
            else {
                X::Sofa::NoDocument.new(name => $view-id, what => 'getting view for list').throw;
            }
        }
        else {
            X::Sofa::NoDocument.new(name => $list-name, what => "getting list").throw;
        }
    }

    proto method post-update(|c) { * }

    multi method post-update(Sofa::Database:D: Str $design-name, |c) {
        my $design = self.get-design($design-name);
        self.post-update($design, |c);
    }

    multi method post-update(Sofa::Database:D: Sofa::Design:D $design, Str $update-name, Str $doc-id?, :%form!, *%params) {
        if $design.updates{$update-name}:exists {
            my @design-parts = flat $design.id-or-name.flat, '_update', $update-name, $doc-id;
            self!post-document(Str, @design-parts, :no-type, :%form, :%params, what => 'posting update')
        }
        else {
            X::Sofa::NoDocument.new(name => $update-name, what => "posting update").throw;
        }
    }

    multi method post-update(Sofa::Database:D: Sofa::Design:D $design, Str $update-name, Str $doc-id?, :%content, *%params) {
        if $design.updates{$update-name}:exists {
            my @design-parts = flat $design.id-or-name.flat, '_update', $update-name, $doc-id;
            self!post-document(%content, @design-parts, :no-type, params => %params, what => 'posting update')
        }
        else {
            X::Sofa::NoDocument.new(name => $update-name, what => "posting update").throw;
        }
    }

    proto method delete-design(|c) { * }

    multi method delete-design(Sofa::Database:D: Sofa::Document:D $doc) returns Sofa::Document {
        self!delete-document(design-id($doc.id), $doc.rev, what => 'deleting design');
    }
    multi method delete-design(Sofa::Database:D: Sofa::Design:D $doc ) returns Sofa::Document {
        self!delete-document($doc.id-or-name, $doc.sofa-document-revision, what => 'deleting design');
    }


    proto method get-document(|c) { * }

    multi method get-document(Sofa::Database:D: Sofa::Document:D $doc ) {
        self.get-document($doc.id);
    }

    multi method get-document(Sofa::Database:D: Sofa::Document:D $doc, JSON::Class:U $c ) {
        self.get-document($doc.id, $c);
    }

    multi method get-document(Sofa::Database:D: Str $doc-id ) {
        self!get-document($doc-id);
    }

    multi method get-document(Sofa::Database:D: Str $doc-id, JSON::Class:U $c ) {
        self!get-document($doc-id, type => $c);
    }


    proto method update-document(|c) { * }

    multi method update-document(Sofa::Database:D: Sofa::Document:D $doc, %document ) returns Sofa::Document {
        self.update-document($doc.id, $doc.rev, %document);
    }

    multi method update-document(Sofa::Database:D: Str $doc-id, Str $doc-rev, %document) returns Sofa::Document {
        self!put-document(%document, $doc-id, $doc-rev);
    }

    multi method update-document(Sofa::Database:D: Sofa::Document::Wrapper $document) returns Sofa::Document {
        self!put-document($document, $document.sofa-document-id, $document.sofa-document-revision);
    }

    proto method add-document-attachment(|c) { * }

    multi method add-document-attachment(Sofa::Database:D: Sofa::Document:D $doc, Str $attachment-name, Str $content-type, Blob $content) returns Sofa::Document {
        self.add-document-attachment($doc.id, $doc.rev, $attachment-name, $content-type, $content);
    }


    multi method add-document-attachment(Sofa::Database:D: Sofa::Document:D $doc, Str $attachment-name, Str $content-type, Str $file) returns Sofa::Document {
        self.add-document-attachment($doc.id, $doc.rev, $attachment-name, $content-type, $file);
    }

    multi method add-document-attachment(Sofa::Database:D: Str $doc-id, Str $doc-rev, Str $attachment-name, Str $content-type, Str $file) returns Sofa::Document {
        self.add-document-attachment($doc-id, $doc-rev, $attachment-name, $content-type, $file.IO);
    }

    multi method add-document-attachment(Sofa::Database:D: Sofa::Document:D $doc, Str $attachment-name, Str $content-type, IO::Path $file) returns Sofa::Document {
        self.add-document-attachment($doc.id, $doc.rev, $attachment-name, $content-type, $file);
    }

    multi method add-document-attachment(Sofa::Database:D: Str $doc-id, Str $doc-rev, Str $attachment-name, Str $content-type, IO::Path $file) returns Sofa::Document {
        my $handle = $file.open(:r, :bin);
        self.add-document-attachment($doc-id, $doc-rev, $attachment-name, $content-type, $handle);
    }

    multi method add-document-attachment(Sofa::Database:D: Sofa::Document:D $doc, Str $attachment-name, Str $content-type, IO::Handle $file) returns Sofa::Document {
        self.add-document-attachment($doc.id, $doc.rev, $attachment-name, $content-type, $file);
    }

    multi method add-document-attachment(Sofa::Database:D: Str $doc-id, Str $doc-rev, Str $attachment-name, Str $content-type, IO::Handle $file) returns Sofa::Document {
        my $content = $file.slurp-rest(:bin);
        self.add-document-attachment($doc-id, $doc-rev, $attachment-name, $content-type, $content);
    }

    multi method add-document-attachment(Sofa::Database:D: Str $doc-id, Str $doc-rev, Str $attachment-name, Str $content-type, Blob $content) returns Sofa::Document {
        my %headers = Content-Type => $content-type;
        self!put-document($content, [$doc-id, $attachment-name ], $doc-rev, :%headers, what => 'adding attachment');
    }

    proto method get-document-attachment(|c) { * }

    multi method get-document-attachment(Sofa::Database:D: Str $doc-id, Str $attachment-name) {
        my %headers = Accept => '*/*';
        self!get-document([$doc-id, $attachment-name], :%headers, what => 'retrieving attachment');
    }

    multi method get-document-attachment(Sofa::Database:D: Sofa::Document:D $doc, Str $attachment-name) {
        self.get-document-attachment($doc.id, $attachment-name);
    }

    proto method delete-document-attachment(|c) { * }

    multi method delete-document-attachment(Sofa::Database:D: Str $doc-id, Str $doc-rev, Str $attachment-name) {
        self!delete-document([$doc-id, $attachment-name], $doc-rev, what => 'deleting attachment');
    }

    multi method delete-document-attachment(Sofa::Database:D: Sofa::Document:D $doc, Str $attachment-name) {
        self.delete-document-attachment($doc.id, $doc.rev, $attachment-name);
    }



    proto method delete-document(|c) { * }

    multi method delete-document(Sofa::Database:D: Sofa::Document::Wrapper:D $doc) returns Sofa::Document {
        self.delete-document($doc.sofa-document-id, $doc.sofa-document-revision);
    }

    multi method delete-document(Sofa::Database:D: Sofa::Document:D $doc ) returns Sofa::Document {
        self.delete-document($doc.id, $doc.rev);
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
            if $response.is-json {
                if $type ~~ NoType {
                    $response.from-json;
                }
                else {
                    $response.from-json($wrapped-type);
                }
            }
            else {
                $response.content;
            }
        }
        else {
            self!get-exception($response.code, $doc-id.grep({.defined}).join('/'), $what, Sofa::Exception::Document).throw;
        }
    }

    method !post-document($document, $doc-id, Mu:U :$type = Sofa::Document, :%form, Bool :$no-type, :%params, :%headers, :$what = 'creating document') {
        # This shouldn't happen in reality but better catch a mistake
        if $document.defined && %form {
            X::Sofa::CantDoBoth.new.throw;
        }

        my $path = self.get-local-path(path => $doc-id);
        my $response = do if %form {
            self.ua.post(path => $path, :%params, :%form, |%headers);
        }
        else {
            self.ua.post(path => $path, :%params, content => $document, |%headers);
        };
        if $response.is-success {
            my $doc = $no-type ?? $response.from-json !! $response.from-json($type);
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
