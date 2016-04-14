#!/usr/bin/env perl6

use v6.c;

use Test;
use CheckSocket;

use Sofa;
use Sofa::Database::Security;

my $port = %*ENV<COUCH_PORT> // 5984;
my $host = %*ENV<COUCH_HOST> // 'localhost';

my Bool $test-changes = %*ENV<SOFA_TEST_CHANGES>:exists;

if !check-socket($port, $host) {
    plan 1;
    skip-rest "no couchdb available";
    exit;
}

my $sofa;

lives-ok { $sofa = Sofa.new(:$host, :$port) }, "can create an object";

my $name = ('a' .. 'z').pick(8).join('');

my $db;

lives-ok { $db = $sofa.create-database($name) }, "create database";

my $sec;

lives-ok {
    $sec = $db.security();
}, "get security object";

isa-ok $sec, Sofa::Database::Security, "and it is the right soirt of thing";

END {
    if $db.defined {
        $db.delete;
    }
}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
