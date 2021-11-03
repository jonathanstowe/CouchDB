#!/usr/bin/env raku6

use v6.c;

use Test;
plan 65;

use CheckSocket;

use Sofa;

my $port = %*ENV<COUCH_PORT> // 5984;
my $host = %*ENV<COUCH_HOST> // 'localhost';


my $username = %*ENV<COUCH_USERNAME>;
my $password = %*ENV<COUCH_PASSWORD>;

my %auth;

# clearly there is a chicken and egg situation with the basic authentican
# but it is completely unavoidable.
if $username.defined && $password.defined {
    %auth = (:$username, :$password, :basic-auth);
}
if !check-socket($port, $host) {
    skip-rest "no couchdb available";
    exit;
}

my $data-dir = $*PROGRAM.parent.child('data');

my $sofa;

lives-ok { $sofa = Sofa.new(:$host, :$port, |%auth) }, "can create an object";

if $sofa.is-admin {
    my $db-count = $sofa.databases.elems;

    my $name = ('a' .. 'z').pick(8).join('');
    my $db;
    lives-ok { $db = $sofa.create-database($name) }, "create-database('$name')";
    my %doc = ( foo => 1, bar => "baz" );

    # Test first with a Blob
    ok my $doc = $db.create-document(%doc), "create a document";

    my $file = $data-dir.child('sofa.jpg').open(:bin);
    my $data = $file.slurp-rest(:bin);

    my $att;
    lives-ok { $att = $db.add-document-attachment($doc, 'sofa.jpg', 'image/jpeg', $data) }, "add document attachment";

    ok $att.ok, "and it appears to be ok";
    isnt $att.rev, $doc.rev, "and the rev got bumped";

    my $new-doc;

    lives-ok {$new-doc = $db.get-document($doc) }, "get document back";
    is $new-doc<_rev>, $att.rev, "and it has the right rev";
    is $new-doc<_attachments>.keys.elems, 1, "and there is an attachment";
    ok $new-doc<_attachments><sofa.jpg>:exists, "and we have the one we expected";
    is $new-doc<_attachments><sofa.jpg><content_type>, 'image/jpeg', "correct content-type";
    is $new-doc<_attachments><sofa.jpg><length>, $file.path.s, "and the length we expected too";

    my $att-resp;

    lives-ok { $att-resp = $db.get-document-attachment($doc, 'sofa.jpg') }, "get-document-attachment";
    is $att-resp.elems, $new-doc<_attachments><sofa.jpg><length>, "got the size we expected";
    is-deeply $att-resp.list, $data.list, "and got back what we expected";

    lives-ok { $db.delete-document-attachment($att, 'sofa.jpg') }, "delete attachment";

    lives-ok {$new-doc = $db.get-document($doc) }, "get document back";
    is $new-doc<_attachments>.keys.elems, 0, "and there is now no attachment";

    # Testing with the filename does most of the other candiadate

    ok $doc = $db.create-document(%doc), "create a new document";

    my $file-name = $data-dir.child('sofa.jpg').Str;

    lives-ok { $att = $db.add-document-attachment($doc, 'sofa.jpg', 'image/jpeg', $file-name) }, "add document attachment with filename";

    ok $att.ok, "and it appears to be ok";
    isnt $att.rev, $doc.rev, "and the rev got bumped";

    lives-ok {$new-doc = $db.get-document($doc) }, "get document back";
    is $new-doc<_rev>, $att.rev, "and it has the right rev";
    is $new-doc<_attachments>.keys.elems, 1, "and there is an attachment";
    ok $new-doc<_attachments><sofa.jpg>:exists, "and we have the one we expected";
    is $new-doc<_attachments><sofa.jpg><content_type>, 'image/jpeg', "correct content-type";
    is $new-doc<_attachments><sofa.jpg><length>, $file-name.IO.s, "and the length we expected too";

    lives-ok { $att-resp = $db.get-document-attachment($doc, 'sofa.jpg') }, "get-document-attachment";
    is $att-resp.elems, $new-doc<_attachments><sofa.jpg><length>, "got the size we expected";
    is-deeply $att-resp.list, $data.list, "and got back what we expected";
    lives-ok { $db.delete-document-attachment($att, 'sofa.jpg') }, "delete attachment";
    lives-ok {$new-doc = $db.get-document($doc) }, "get document back";
    is $new-doc<_attachments>.keys.elems, 0, "and there is now no attachment";

    # Test for design attachments

    lives-ok { $doc = $db.put-design(Sofa::Design.new(name => 'contacts')) }, "put-design with name in object";
    is $doc.id, '_design/contacts', "and the id was populated prorakuy";


    $file = $data-dir.child('sofa.jpg').open(:bin);
    $data = $file.slurp-rest(:bin);

    lives-ok { $att = $db.add-design-attachment($doc, 'sofa.jpg', 'image/jpeg', $data) }, "add-design-attachment with Document and Blob";

    my $design;
    lives-ok {$design = $db.get-design('contacts') }, "get design back";
    is $design.sofa-document-revision, $att.rev, "and it has the right rev";
    is $design.attachments.keys.elems, 1, "and there is an attachment";
    ok $design.attachments<sofa.jpg>:exists, "and we have the one we expected";
    is $design.attachments.<sofa.jpg>.content-type, 'image/jpeg', "correct content-type";
    is $design.attachments<sofa.jpg>.length, $file.path.s, "and the length we expected too";

    lives-ok { $db.delete-design-attachment($att, 'sofa.jpg') }, "delete-design-attachment with Document";
    lives-ok {$design = $db.get-design('contacts') }, "get design back";
    is $design.attachments.keys.elems, 0, "and there is now no attachment on the design";

    # do it with a Sofa::Design document
    lives-ok { $att = $db.add-design-attachment($design, 'sofa.jpg', 'image/jpeg', $data) }, "add-design-attachment with Design and Blob";

    lives-ok {$design = $db.get-design('contacts') }, "get design back";
    is $design.sofa-document-revision, $att.rev, "and it has the right rev";
    is $design.attachments.keys.elems, 1, "and there is an attachment";
    ok $design.attachments<sofa.jpg>:exists, "and we have the one we expected";
    is $design.attachments.<sofa.jpg>.content-type, 'image/jpeg', "correct content-type";
    is $design.attachments<sofa.jpg>.length, $file.path.s, "and the length we expected too";
    
    $att-resp = Blob;

    lives-ok { $att-resp = $db.get-design-attachment($att, 'sofa.jpg') }, "get-design-attachment with Sofa::Document";
    is $att-resp.elems, $design.attachments<sofa.jpg>.length, "got the size we expected";
    is-deeply $att-resp.list, $data.list, "and got back what we expected";


    $att-resp = Blob;

    lives-ok { $att-resp = $db.get-design-attachment($design, 'sofa.jpg') }, "get-design-attachment with Sofa::Design";
    is $att-resp.elems, $design.attachments<sofa.jpg>.length, "got the size we expected";
    is-deeply $att-resp.list, $data.list, "and got back what we expected";

    $att-resp = Blob;

    lives-ok { $att-resp = $db.get-design-attachment($design.name, 'sofa.jpg') }, "get-design-attachment with design name";
    is $att-resp.elems, $design.attachments<sofa.jpg>.length, "got the size we expected";
    is-deeply $att-resp.list, $data.list, "and got back what we expected";

    lives-ok { $db.delete-design-attachment($att, 'sofa.jpg') }, "delete-design-attachment with Design";
    lives-ok {$design = $db.get-design('contacts') }, "get design back";
    is $design.attachments.keys.elems, 0, "and there is now no attachment on the design";

    END {
        if $db.defined {
            $db.delete;
        }
    }
}
else {
    skip-rest "Not admin, can't test";
}

done-testing;

# vim: expandtab shiftwidth=4 ft=raku6
