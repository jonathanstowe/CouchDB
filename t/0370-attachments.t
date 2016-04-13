#!/usr/bin/env perl6

use v6.c;

use Test;
use CheckSocket;

use Sofa;

my $port = %*ENV<COUCH_PORT> // 5984;
my $host = %*ENV<COUCH_HOST> // 'localhost';

my Bool $test-changes = %*ENV<SOFA_TEST_CHANGES>:exists;

if !check-socket($port, $host) {
    plan 1;
    skip-rest "no couchdb available";
    exit;
}

my $data-dir = $*PROGRAM.parent.child('data');

my $sofa;

lives-ok { $sofa = Sofa.new(:$host, :$port) }, "can create an object";

my $db-count = $sofa.databases.elems;

my $name = ('a' .. 'z').pick(8).join('');
my $db;
lives-ok { $db = $sofa.create-database($name) }, "create-database('$name')";
my %doc = ( foo => 1, bar => "baz" );
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





END {
    if $db.defined {
        $db.delete;
    }
}

done-testing;

# vim: expandtab shiftwidth=4 ft=perl6
