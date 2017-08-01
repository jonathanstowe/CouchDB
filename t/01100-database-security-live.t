#!/usr/bin/env perl6

use v6.c;

use Test;
plan 20;
use CheckSocket;

use Sofa;
use Sofa::Database::Security;

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

my Bool $test-changes = %*ENV<SOFA_TEST_CHANGES>:exists;

if !check-socket($port, $host) {
    skip-rest "no couchdb available";
    exit;
}

my $sofa;

lives-ok { $sofa = Sofa.new(:$host, :$port, |%auth) }, "can create an object";

my $session;

lives-ok { $session = $sofa.session }, "get session";

if $session.is-admin {
    my $name = ('a' .. 'z').pick(8).join('');

    my $db;

    lives-ok { $db = $sofa.create-database($name) }, "create database";

    my $sec;

    lives-ok {
        $sec = $db.security();
    }, "get security object";

    isa-ok $sec, Sofa::Database::Security, "and it is the right soirt of thing";

    ok $sec.members.defined, "members defined";
    is $sec.members.names.elems, 0, "no names";
    is $sec.members.roles.elems, 0, "no roles";
    ok $sec.admins.defined, "admins defined";
    is $sec.admins.names.elems, 0, "no names";
    is $sec.admins.roles.elems, 0, "no roles";


    my $json = $*PROGRAM.parent.child('data/security.json').slurp;

    lives-ok { $sec = Sofa::Database::Security.from-json($json) }, "load one we prepared earlier";

    lives-ok { $db.update-security($sec) }, "update security with the one from the file";

    lives-ok {
        $sec = $db.security();
    }, "retrieve new security object";

    ok $sec.members.defined, "members defined";
    is $sec.members.names.elems, 2, "2 names";
    is $sec.members.roles.elems, 1, "one role";
    ok $sec.admins.defined, "admins defined";
    is $sec.admins.names.elems, 1, "one name";
    is $sec.admins.roles.elems, 1, "one role";



    END {
        if $db.defined {
            $db.delete;
        }
    }
}
else {
    skip-rest "not admin so can't run tests";
}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
