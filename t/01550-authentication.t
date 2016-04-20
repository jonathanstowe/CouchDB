#!/usr/bin/env perl6

use v6.c;

use Test;
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
    pass "got admin";

    my $username =  ('a' .. 'z').pick(8).join('');
    my $password =  ('a' .. 'z').pick(8).join('');

    my $auth-client;

    lives-ok { $auth-client = Sofa.new(:$host, :$port, :$username, :$password, :basic-auth); }, "new client with basic auth credentials";
    my $session;

    throws-like { $session = $auth-client.session() }, X::NotAuthorised, "get session for a non-existent user";

    lives-ok { $sofa.add-user(name => $username, :$password) }, "create a new user";

    lives-ok { $session = $auth-client.session() }, "get session for now existent user";
    ok $session.is-authenticated, "and the session is authenticated";

    LEAVE {
        try $sofa.delete-user($username);
    }
}
else {
    skip "not admin can't do the tests";
}


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
