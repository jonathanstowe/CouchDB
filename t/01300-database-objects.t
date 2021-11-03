#!/usr/bin/env raku6

use v6.c;

use Test;
plan 32;

use CheckSocket;

use Sofa;
use JSON::Class;

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

class TestClass does JSON::Class {

    has Str $.foo is rw;
    has Int $.bar is rw;
}

my $sofa;

lives-ok { $sofa = Sofa.new(:$host, :$port, |%auth) }, "can create an object";

if $sofa.is-admin {

    my $name = ('a' .. 'z').pick(8).join('');

    my $db ;

    lives-ok { $db = $sofa.create-database($name) }, "create-database('$name')";

    my $test-obj = TestClass.new(foo => "toot", bar => 42);
    ok my $doc = $db.create-document($test-obj), "create a document";

    is $test-obj.sofa-document-revision, $doc.rev, "got updated with the document revision";
    is $test-obj.sofa-document-id, $doc.id, "and updated with the document id";

    isa-ok $doc, Sofa::Document, "and got back a Sofa::Document";

    ok $doc.ok, "ok is true";
    ok $doc.id, "There is a id";
    ok $doc.rev, "There is a rev";

    my @all-docs;

    lives-ok {
        @all-docs = $db.all-docs(:detail, type => TestClass);
    }, "get all-docs with type";

    is @all-docs.elems, 1, "and now there should be a new row";

    is @all-docs[0].id, $doc.id, "and the id is there in the all-docs";
    isa-ok @all-docs[0].doc, TestClass, "and the doc is the right type";
    is @all-docs[0].doc.foo, $test-obj.foo, "got the expected attribute";
    is @all-docs[0].doc.bar, $test-obj.bar, "got the other expected attribute";


    ok my $new-doc = $db.get-document($doc, TestClass), "get-document (with doc)";

    is $new-doc.foo, "toot", "got back the foo we sent";
    is $new-doc.bar, 42,"and got back the bar we sent";
    is $new-doc.sofa-document-id, $doc.id, "and the id we expected";
    is $new-doc.sofa-document-revision, $doc.rev, "and the rev we expected";
    is $new-doc.sofa-document-type, 'testclass', "and the 'document type'";

    $new-doc.foo = "change-this";
    $new-doc.bar = 78;

    my $updated-doc;
    lives-ok { $updated-doc = $db.update-document($new-doc) }, "update-document with an object";

    is $new-doc.sofa-document-revision, $updated-doc.rev, "and we got the updated revision";
    ok my $new-new-doc = $db.get-document($doc, TestClass), "get-document (with doc)";

    is $new-new-doc.foo, $new-doc.foo, "got back the foo we sent";
    is $new-new-doc.bar, $new-doc.bar,"and got back the bar we sent";
    is $new-new-doc.sofa-document-id, $new-doc.sofa-document-id, "and the id we expected";
    is $new-new-doc.sofa-document-revision, $new-doc.sofa-document-revision, "and the rev we expected";
    is $new-new-doc.sofa-document-type, 'testclass', "and the 'document type'";

    lives-ok { $db.delete-document($new-new-doc) }, "delete document with object";

    is $db.all-docs.elems, 0, "and now there should be no row";

    lives-ok { $db.delete }, "delete the database";
}
else {
    skip-rest "not admin can't do all the tests";
}


done-testing;
# vim: expandtab shiftwidth=4 ft=raku6
