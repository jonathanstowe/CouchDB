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


class TestClass does JSON::Class {

    has Str $.foo is rw;
    has Int $.bar is rw;
}

my $sofa;

lives-ok { $sofa = Sofa.new(:$host, :$port) }, "can create an object";

my $name = ('a' .. 'z').pick(8).join('');

my $db;

lives-ok { $db = $sofa.create-database($name) }, "create the database";

my @all-docs;

lives-ok { @all-docs = $db.all-docs }, "all-docs with no data";
is @all-docs.elems, 0, "and empty as no documents";

lives-ok { @all-docs = $db.all-docs(:detail) }, "all-docs with no data (:detail)";
is @all-docs.elems, 0, "and empty as no documents";

lives-ok { @all-docs = $db.all-docs(:detail, type => TestClass) }, "all-docs with no data (:detail and type)";
is @all-docs.elems, 0, "and empty as no documents";

my $test-obj = TestClass.new(foo => "toot", bar => 42);

my $doc;
lives-ok { $doc = $db.create-document($test-obj) }, "create a new document";

lives-ok { @all-docs = $db.all-docs }, "all-docs with some data";
is @all-docs.elems, 1, "and there is now a  document";

@all-docs = ();

lives-ok { @all-docs = $db.all-docs(:detail) }, "all-docs with data (:detail)";
is @all-docs.elems, 1, "and empty as some documents";
is @all-docs[0].doc<_id>, $doc.id, "got the _id";
is @all-docs[0].doc<_rev>, $doc.rev, "got the _rev";
is @all-docs[0].doc<foo>, $test-obj.foo, "and the document looks good";
is @all-docs[0].doc<bar>, $test-obj.bar, "and the other attribute";

@all-docs = ();

lives-ok { @all-docs = $db.all-docs(:detail, type => TestClass) }, "all-docs with some data (:detail and type)";
is @all-docs.elems, 1, "and there should be some documents";
is @all-docs[0].doc.sofa-document-id, $doc.id, "got the _id";
is @all-docs[0].doc.sofa-document-revision, $doc.rev, "got the _rev";
is @all-docs[0].doc.foo, $test-obj.foo, "and the document looks good";
is @all-docs[0].doc.bar, $test-obj.bar, "and the other attribute";


END {
    if $db.defined {
        $db.delete;
    }
}

done-testing;

# vim: expandtab shiftwidth=4 ft=perl6
