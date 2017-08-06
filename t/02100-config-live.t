#!/usr/bin/env perl6

use v6.c;

use Test;
use CheckSocket;

use Sofa;

plan 3;

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
    skip-rest "no couchdb available";
    exit;
}

my $sofa;

lives-ok { $sofa = Sofa.new(:$host, :$port, |%auth) }, "can create an object";

if $sofa.is-admin {
    if $sofa.server-details.version >= v2.0.0 {
        skip-rest "can't do per-node configuration for v2 yet";
    }
    else {
        my $stats;

        lives-ok { $stats = $sofa.configuration }, "get configuration";

        # need to do the run-time lookup to make sure the method is doing it right.
        isa-ok $stats, ::('Sofa::Config'), "and we got a config object";
    }
}
else {
    skip-rest "need admin to get config";
}


done-testing;

# vim: expandtab shiftwidth=4 ft=perl6
