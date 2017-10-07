#!perl6

use v6;

use Test;

use Sofa::Item;

class Foo is sofa-path('_foo') {
}

class Bar is sofa-path('_bar') {
}

# check twice to unearth any unintended cross-dependencies
ok Foo.HOW.^does(Sofa::Item::MetamodelX::ClassHOW) , "the HOW of the class is what we expected";
is Foo.HOW.sofa-path, '_foo', "and the sofa-item is what we expected";

ok Bar.HOW.^does(Sofa::Item::MetamodelX::ClassHOW) , "the HOW of the class is what we expected";
is Bar.HOW.sofa-path, '_bar', "and the sofa-item is what we expected";



done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
