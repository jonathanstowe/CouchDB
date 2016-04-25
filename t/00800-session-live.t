#!/usr/bin/env perl6

use v6.c;

use Test;
plan 8;
use CheckSocket;

use Sofa;

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
    plan 1;
    skip-rest "no couchdb available";
    exit;
}

my $sofa;

lives-ok { $sofa = Sofa.new(:$host, :$port, |%auth) }, "can create an object";

if $sofa.is-admin {
    my $session;
    lives-ok { $session = $sofa.session }, "get our session";

    if %auth.keys.elems == 0 {
        nok $session.is-authenticated, "not authenticated";
        ok  $session.is-admin-party, "and it's an admin party";
    }
    else {
        ok $session.is-authenticated, "authenticated";
        nok  $session.is-admin-party, "and it's not an admin party";
    }

    ok  $session.is-admin, "is admin because admin party";
    ok  $sofa.is-admin, "and delegate on the Sofa object";
    is  $session.info.authentication-method, 'default', "and default authentication-method";
    is  $session.info.authentication-db, '_users', "and the authentication db";
    # Need this later to check whether we can do some of the tests without authenticating
}
else {
    my $session;
    lives-ok { $session = $sofa.session }, "get our session";
    nok  $session.is-admin-party, "and it's not an admin party";
    is  $session.info.authentication-method, Str, "and authentication-method is not defined";
    is  $session.info.authentication-db, '_users', "and the authentication db is what we expected";
    skip-rest "not admin skipping some tests";
    exit;
}


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
