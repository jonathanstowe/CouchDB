#!perl6

use v6;

use Test;

use Sofa::Session;

my $ss = ::('Sofa::Session');

my $session;

lives-ok { $session = $ss.new }, "create a new default Sofa::Session";

nok $session.is-admin, "not admin (because no roles)";
nok $session.is-authenticated, "not authenticated";

my $h = $*PROGRAM.parent.child('data/default-session.json').slurp;

lives-ok { $session = $ss.from-json($h) }, "new from json";

ok $session.is-admin, "and it's an admin (by default of admin party";

is $session.info.authentication-db, '_users', "check authentication-db";
nok $session.is-authenticated, "not authenticated";


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
