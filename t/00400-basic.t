#!raku

use v6;

use Test;
use HTTP::UserAgent;
use URI::Template;

use-ok('Sofa');

use Sofa;

ok(my $obj = Sofa.new, "create new object");

isa-ok($obj, Sofa, "right sort of thing");

ok($obj.^can('ua'), 'can ua');

isa-ok($obj.ua, HTTP::UserAgent, "ua is a HTTP::UserAgent");
isa-ok($obj.ua, Sofa::UserAgent, "ua is a Sofa::UserAgent");

is($obj.port, 5984, "got default port");
is($obj.host, 'localhost', 'got default host');
is($obj.secure, False, 'got default secure');
is($obj.ua.port, 5984, "got default port on ua");
is($obj.ua.host, 'localhost', 'got default host on ua');
is($obj.ua.secure, False, 'got default secure on ua');
is($obj.ua.base-url, 'http://localhost:5984{/path*}{?params*}', "got correct base-url");
isa-ok($obj.ua.base-template, URI::Template, "got the template");

ok($obj = Sofa.new(port => 1234, host => 'foo.com', secure => True), "create with port");
is($obj.port, 1234, "got set port");
is($obj.host, 'foo.com', 'got set host');
is($obj.secure, True, 'got set secure');
is($obj.ua.port, 1234, "got set port on ua");
is($obj.ua.host, 'foo.com', 'got set host on ua');
is($obj.ua.secure, True, 'got set secure on ua');
is($obj.ua.base-url, 'https://foo.com:1234{/path*}{?params*}', "got correct base-url");
isa-ok($obj.ua.base-template, URI::Template, "got the template");


done-testing();
# vim: expandtab shiftwidth=4 ft=raku
