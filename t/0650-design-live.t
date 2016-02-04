#!/usr/bin/env perl6

use v6.c;

use Test;
use CheckSocket;

use Sofa;

my $port = %*ENV<COUCH_PORT> // 5984;
my $host = %*ENV<COUCH_HOST> // 'localhost';

if !check-socket($port, $host) {
    plan 1;
    skip-rest "no couchdb available";
    exit;
}

my $sofa;

lives-ok { $sofa = Sofa.new(:$host, :$port) }, "can create an object";

my $name = ('a' .. 'z').pick(8).join('');

my $db ;

lives-ok { $db = $sofa.create-database($name) }, "create-database('$name')";

class X::Foo is Exception {
}

throws-like { $db.get-design('contacts'); }, X::NoDocument, "get-design throws when it doesn't exist";

throws-like { $db.put-design(Sofa::Design.new) }, X::NoIdOrName, "put-design throws when there is no name or id";

my $doc;
lives-ok { $doc = $db.put-design(Sofa::Design.new(name => 'contacts')) }, "put-design with name in object";
is $doc.id, '_design/contacts', "and the id was populated properly";
my $design;
lives-ok { $design = $db.get-design('contacts') }, "get the new design document";
isa-ok $design, Sofa::Design, "and we got one back";
is $design.sofa_document_id, $doc.id, "and it has the right id";
is $design.name, "contacts", "got the right name";
is $design.sofa_document_revision, $doc.rev, "got the right revision";
lives-ok { $db.delete-design($design) }, "delete that one";
throws-like { $db.get-design('contacts') }, X::NoDocument, "get-design throws again as it doesn't exist";

lives-ok { $doc = $db.put-design(Sofa::Design.new(),'contacts') }, "put-design with name as argument";
is $doc.id, '_design/contacts', "and the id was populated properly";
lives-ok { $design = $db.get-design('contacts'); }, "get the new design document";
isa-ok $design, Sofa::Design, "and we got one back";
is $design.sofa_document_id, $doc.id, "and it has the right id";
is $design.name, "contacts", "got the right name";
is $design.sofa_document_revision, $doc.rev, "got the right revision";
lives-ok { $db.delete-design($doc) }, "delete that one (use the Sofa::Document)";
throws-like { $db.get-design('contacts') }, X::NoDocument, "get-design throws again as it doesn't exist";

my $data-dir = $*PROGRAM.parent.child('data');

lives-ok { $design = Sofa::Design.from-json($data-dir.child('design-tests.json').slurp) }, "get our test design";
lives-ok { $db.put-design($design) }, "and put that";

class DesignTest does JSON::Class {
    has Str $.name;
    has Str $.some-data;
    has Int $.number;
}

for <one two three four five six> -> $name {
    my $dt = DesignTest.new(:$name, some-data => "$name data", number => $++ );
    $db.create-document($dt);
}

is $db.all-docs.elems, 7, "now have six documents ( and a design document)";

my $view-data;

lives-ok { $view-data = $db.get-view($design, 'by-name') ; }, "get-view";
is $view-data.total_rows, 6, "got the six rows we expected";
is $view-data.rows.elems, 6, "and there are six in the rows";


lives-ok { $view-data = $db.get-view($design, 'by-name', 'three') ; }, "get-view (with a single key)";
is $view-data.total_rows, 6, "got the one row we expected";
is $view-data.rows.elems, 1, "and there are one in the rows";
is $view-data.rows[0].value<name>, 'three', "just check we got the row we wanted";
is $view-data.rows[0].value<number>, 2, "right number";

lives-ok { $view-data = $db.get-view($design, 'by-name', 'one', 'three') ; }, "get-view (with a single key)";
is $view-data.total_rows, 6, "got the one row we expected";
is $view-data.rows.elems, 2, "and there are one in the rows";
is $view-data.rows[0].value<name>, 'one', "just check we got the row we wanted";
is $view-data.rows[0].value<number>, 0, "right number";
is $view-data.rows[1].value<name>, 'three', "just check we got the row we wanted";
is $view-data.rows[1].value<number>, 2, "right number";

lives-ok { $db.delete }, "delete the database";

done-testing;

# vim: expandtab shiftwidth=4 ft=perl6
