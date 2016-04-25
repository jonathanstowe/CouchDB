#!/usr/bin/env perl6

use v6.c;

use Test;
plan 54;

use CheckSocket;

use Sofa;

my $port = %*ENV<COUCH_PORT> // 5984;
my $host = %*ENV<COUCH_HOST> // 'localhost';

my Bool $test-changes = %*ENV<SOFA_TEST_CHANGES>:exists;


my $username = %*ENV<COUCH_USERNAME>;
my $password = %*ENV<COUCH_PASSWORD>;

my %auth;

# clearly there is a chicken and egg situation with the basic authentican
# but it is completely unavoidable.
if $username.defined && $password.defined {
    %auth = (:$username, :$password, :basic-auth);
}

if !check-socket($port, $host) {
    plan 1;
    skip-rest "no couchdb available";
    exit;
}

my $sofa;

lives-ok { $sofa = Sofa.new(:$host, :$port, |%auth) }, "can create an object";

if $sofa.is-admin {
    my $db-count = $sofa.databases.elems;

    ok $db-count > 0, "got at least one database";

    # This might not be true on versions where the admindb is separate

    my $auth-db = $sofa.session.info.authentication-db;

    ok $sofa.databases.grep(*.name eq $auth-db), "and we have the '$auth-db'";
    is $sofa.databases.grep(*.name eq $auth-db).first.name, $auth-db, "and we have the right name";
    is $sofa.get-database($auth-db).name, $auth-db, "and get-database gives it do us";

    my $name = ('a' .. 'z').pick(8).join('');

    my $db ;

    throws-like { Sofa::Database.fetch(name => $name, ua => $sofa.ua) }, X::NoDatabase, "fetch no-exist database throws";

    nok $sofa.get-database($name).defined, "and get-database doesn't give us one";

    lives-ok { $db = $sofa.create-database($name) }, "create-database('$name')";

    throws-like { $sofa.create-database($name) }, X::DatabaseExists, "create existing throws";

    isa-ok $db, Sofa::Database, "and it returned the right sort of thing";
    is $db.name, $name, "and the right name is returned";
    is $sofa.databases.elems, $db-count + 1, "and we got one more database";

    is $sofa.get-database($name).name, $name, "and now get-database gives us the one we created";

    my @changes;

    if $test-changes {
        ok $db.get-changes(), "get-changes";
        lives-ok { $db.changes-supply.tap({ @changes.push($_); }); }, "tap the changes-supply";
    }
    else {
        skip "SOFA_TEST_CHANGES not set, not testing",2;
    }

    is $db.all-docs.elems, 0, "and because it's new there aren't any rows";

    my %doc = ( foo => 1, bar => "baz" );
    ok my $doc = $db.create-document(%doc), "create a document";

    isa-ok $doc, Sofa::Document, "and got back a Sofa::Document";

    ok $doc.ok, "ok is true";
    ok $doc.id, "There is a id";
    ok $doc.rev, "There is a rev";

    is $db.all-docs.elems, 1, "and now there should be a new row";

    is $db.all-docs[0].id, $doc.id, "and the id is there in the all-docs";


    ok my $new-doc = $db.get-document($doc), "get-document (with doc)";

    is $new-doc<foo>, 1, "got back the foo we sent";
    is $new-doc<bar>, "baz","and got back the bar we sent";
    is $new-doc<_id>, $doc.id, "and the id we expected";
    is $new-doc<_rev>, $doc.rev, "and the rev we expected";

    my $new-rev;
    lives-ok { $new-rev = $db.create-document($new-doc) }, "try  and create that again with the same id";

    is $new-rev.id, $doc.id, "and the doc id is the same";
    isnt $new-rev.rev, $doc.rev, "but the  doc rev is different";

    is $db.all-docs.elems, 1, "and it didn't get added";

    %doc<foo> = 2;
    %doc<bar> = "burp";

    my $new-new-rev;

    throws-like { $db.update-document($doc, %doc) }, X::DocumentConflict, "updating document with an old rev throws";

    lives-ok { $new-new-rev = $db.update-document($new-rev, %doc) }, "update document";

    isnt $new-new-rev.rev, $new-rev.rev, "and the revision got updated";

    ok $new-doc = $db.get-document($new-new-rev), "get-document (with doc)";

    is $new-doc<foo>, 2, "got back the foo we sent";
    is $new-doc<bar>, "burp","and got back the bar we sent";
    is $new-doc<_id>, $new-new-rev.id, "and the id we expected";
    is $new-doc<_rev>, $new-new-rev.rev, "and the rev we expected";


    throws-like { $db.delete-document($doc) }, X::DocumentConflict, "deleting with an older rev throws";
    lives-ok { $db.delete-document($new-new-rev) }, "delete the document";

    is $db.all-docs.elems, 0, "and the document went away";

    my %named-doc = ( zub => "baz", bar => "foo" );

    my $named-doc-doc;

    lives-ok { $named-doc-doc = $db.create-document('flurble', %named-doc) }, "create-document with explicit id";
    is $named-doc-doc.id, 'flurble', "and we got the right one back";
    my $named-doc-back;
    lives-ok { $named-doc-back = $db.get-document('flurble') }, "get it back by name";
    is $named-doc-back<zub>, %named-doc<zub>, "and it looks like the right document";

    lives-ok { $db.delete-document($named-doc-doc.id, $named-doc-doc.rev) }, "delete by id and rev";

    is $db.all-docs.elems, 0, "and the document went away";


    if $test-changes {
        ok @changes.elems > 0, "and we saw some changes on the supply";
        is @changes.classify({ $_<seq> }).values.grep({ $_.elems > 1}).elems, 0, "and there are no duplicates";
    }
    else {
        skip "SOFA_TEST_CHANGES not set, not testing",2;
    }

    lives-ok { $db.delete }, "delete the database";

    is $sofa.databases.elems, $db-count, "and the number is back to what it was";

    throws-like { $db.delete }, X::NoDatabase, "throws on a second attempt to delete";
}
else {
    skip-rest "not admin can't do all tests";
}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
