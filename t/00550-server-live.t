#!/usr/bin/env perl6

use v6.c;

use Test;
use CheckSocket;

use Sofa;

plan 4;

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
    my $stats;

    lives-ok { $stats = $sofa.server-details }, "get server details";

    # need to do the run-time lookup to make sure the method is doing it right.
    isa-ok $stats, ::('Sofa::Server'), "and we got a server object";
    isa-ok $stats.version, Version, "and version is a Version";
    diag "testing with { $stats.version }";
}
else {
    skip-rest "need admin to get server details";
}


done-testing;

# vim: expandtab shiftwidth=4 ft=perl6
