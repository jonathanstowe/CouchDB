#!raku6

use v6.c;

use JSON::Fast;

use Test;

use Sofa::Server;

use-ok('Sofa::Server');


my $json = '{"couchdb":"Welcome","uuid":"99917cabc7d985b15bc7a38e6af09d72","version":"1.6.1","vendor":{"version":"1.6.1","name":"The Apache Software Foundation"}}';

my $json_p = from-json($json);

ok(my $obj = Sofa::Server.new($json), "new from json");

isa-ok($obj, Sofa::Server, "returns the right sort of thing");

is($obj.uuid, $json_p<uuid>, "got the right uuid");
is($obj.couchdb, $json_p<couchdb>, "got the right welcome string");
isa-ok($obj.version, Version, "version is a Version object");
is($obj.version, Version.new($json_p<version>), "and it's the right one");
isa-ok($obj.vendor, Sofa::Server::Vendor, "vendor is the right type");
is($obj.vendor.name, $json_p<vendor><name>, "name is right");
isa-ok($obj.vendor.version, Version, "vendor.version is right type");
is($obj.vendor.version, Version.new($json_p<vendor><version>), "version is right");


done-testing();
# vim: expandtab shiftwidth=4 ft=raku6
