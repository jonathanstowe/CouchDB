#!perl6

use v6.c;

use Test;

use Sofa::Database::Security;

my $obj;

lives-ok { $obj = Sofa::Database::Security.new }, "create a Sofa::Database::Security object";



done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
