#!/usr/bin/env perl6

use v6.c;

use Test;
use CheckSocket;

use Sofa;

plan 3;

my $port = %*ENV<COUCH_PORT> // 5984;
my $host = %*ENV<COUCH_HOST> // 'localhost';

if !check-socket($port, $host) {
    skip-rest "no couchdb available";
    exit;
}

my $sofa;

lives-ok { $sofa = Sofa.new(:$host, :$port) }, "can create an object";

my $stats;

lives-ok { $stats = $sofa.statistics }, "get statistics";

# need to do the run-time lookup to make sure the method is doing it right.
isa-ok $stats, ::('Sofa::Statistics'), "and we got a stats object";


done-testing;

# vim: expandtab shiftwidth=4 ft=perl6
