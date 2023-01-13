#!raku

use v6.c;

use Test;

use Sofa::User;

my $obj;

my $name = ('a' .. 'z').pick(8).join('');

lives-ok { $obj = Sofa::User.new(:$name) }, "create a new one";

is $obj.name, $name, "got name";
is $obj.generate-id, "org.couchdb.user:$name", "and generate-id works okay";

my $json;

lives-ok { $json = $obj.to-json }, "to-json";

lives-ok { $obj = Sofa::User.from-json($json) }, "and back again";

is $obj.name, $name, "got name";
is $obj.generate-id, "org.couchdb.user:$name", "and generate-id works okay";



done-testing;
# vim: expandtab shiftwidth=4 ft=raku
