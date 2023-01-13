#!raku

use v6.c;

use Test;

use Sofa::Database::Security;

my $obj;

lives-ok { $obj = Sofa::Database::Security.new }, "create a Sofa::Database::Security object";

ok $obj.members.defined, "members defined";
is $obj.members.names.elems, 0, "no names";
is $obj.members.roles.elems, 0, "no roles";
ok $obj.admins.defined, "admins defined";
is $obj.admins.names.elems, 0, "no names";
is $obj.admins.roles.elems, 0, "no roles";

my $json;
lives-ok { $json = $obj.to-json }, "to-json the empty one";

lives-ok { $obj = Sofa::Database::Security.from-json($json) }, "and quick round-trip";

$json = $*PROGRAM.parent.child('data/security.json').slurp;

lives-ok { $obj = Sofa::Database::Security.from-json($json) }, "load one we prepared earlier";

ok $obj.members.defined, "members defined";
is $obj.members.names.elems, 2, "2 names";
is $obj.members.roles.elems, 1, "one role";
ok $obj.admins.defined, "admins defined";
is $obj.admins.names.elems, 1, "one name";
is $obj.admins.roles.elems, 1, "one role";




done-testing;
# vim: expandtab shiftwidth=4 ft=raku
