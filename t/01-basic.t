#!perl6

use v6;

use lib "lib";

use Test;

use-ok('CouchDB');

use CouchDB;

ok(my $obj = CouchDB.new, "create new object");

isa-ok($obj, CouchDB, "right sort of thing");

ok($obj.^can('ua'), 'can ua');

isa-ok($obj.ua, HTTP::UserAgent, "ua is a HTTP::UserAgent");
isa-ok($obj.ua, CouchDB::UserAgent, "ua is a CouchDB::UserAgent");

is($obj.port, 5984, "got default port");

ok($obj = CouchDB.new(port => 1234), "create with port");
is($obj.port, 1234, "got set port");


done-testing();
# vim: expandtab shiftwidth=4 ft=perl6
