#!/usr/bin/env perl6

use v6.c;

use Test;

use Sofa::Exception;

class TestException does Sofa::Exception::Handler {

    # Just call the private method directly
    method test-exception(|c) {
        self!get-exception(|c);
    }
}

my @tests = (
    {
        code    =>  400,
        type    => X::InvalidName
    },
    {
        code    => 401,
        type    =>  X::NotAuthorised
    },
    {
        code    => 404,
        type    => X::NoDatabase,
        context => Sofa::Exception::Database
    },
    {
        code    => 404,
        type    => X::NoDocument,
        context => Sofa::Exception::Document
    },
    {
        code    => 404,
        type    => X::InvalidPath,
        context => Sofa::Exception::Server
    },
    {
        code    => 409,
        type    => X::DocumentConflict,
    },
    {
        code    => 412,
        type    => X::DatabaseExists,
    },
    {
        code    => 999,
        type    => X::SofaWTF,
    }
);

my $test-class = TestException.new;

for @tests -> $test {
    isa-ok $test-class.test-exception($test<code>, 'foo', 'doing something', $test<context> // Sofa::Exception::Database), $test<type>;
}


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
