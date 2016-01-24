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

my $db-count = $sofa.databases.elems;

ok $db-count > 0, "got at least one database";

# This might not be true on versions where the admindb is separate
ok $sofa.databases.grep(*.name eq '_users'), "and we have the '_users'";
is $sofa.databases.grep(*.name eq '_users').first.name, '_users', "and we have the right name";

my $name = ('a' .. 'z').pick(8).join('');

my $db ;

throws-like { Sofa::Database.fetch(name => $name, ua => $sofa.ua) }, X::NoDatabase, "fetch no-exist database throws";

lives-ok { $db = $sofa.create-database($name) }, "create-database('$name')";

throws-like { $sofa.create-database($name) }, X::DatabaseExists, "create existing throws";

isa-ok $db, Sofa::Database, "and it returned the right sort of thing";
is $db.name, $name, "and the right name is returned";
is $sofa.databases.elems, $db-count + 1, "and we got one more database";

is $db.all-docs.elems, 0, "and because it's new there aren't any rows";

my %doc = ( foo => 1, bar => "baz" );
ok my $doc = $db.create-document(%doc), "create a document";

isa-ok $doc, Sofa::Database::Document, "and got back a Sofa::Database::Document";

ok $doc.ok, "ok is true";
ok $doc.id, "There is a id";
ok $doc.rev, "There is a rev";

is $db.all-docs.elems, 1, "and now there should be a new row";

lives-ok { $db.delete }, "delete the database";

is $sofa.databases.elems, $db-count, "and the number is back to what it was";

throws-like { $db.delete }, X::NoDatabase, "throws on a second attempt to delete";


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
