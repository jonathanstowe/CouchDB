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

my $session;

lives-ok { $session = $sofa.session }, "get our session";

nok $session.is-authenticated, "not authenticated";
ok  $session.is-admin, "is admin because admin party";
ok  $sofa.is-admin, "and delegate on the Sofa object";
is  $session.info.authentication-method, 'default', "and default authentication-method";
is  $session.info.authentication-db, '_users', "and the authentication db";
# Need this later to check whether we can do some of the tests without authenticating
ok  $session.is-admin-party, "and it's an admin party";


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
