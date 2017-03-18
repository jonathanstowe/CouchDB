#!perl6

use v6;

use Test;

use Sofa::Method;
use Sofa::Item;

use lib $*PROGRAM.parent.child('lib').Str;

{
    class Foo is sofa-path('_foo') {
    }

    class Baz is sofa-path('_baz') {
    }
}

class Bar {
    method bar is sofa-item('Foo') { * }
    method baz is sofa-item('Baz') { * }
    method zub is sofa-item('Zub') { * }
    method statistics is sofa-item('Sofa::Statistics') { * }

    method ua() {
        (class {
            method get(:$path) {
                (class {
                    method from-json($f) {
                        [ $path, $f ];
                    }
                    method is-success() {
                        True
                    }
                }).new;
            }
        }).new;
    }
}

my $f;

lives-ok { $f = Bar.new }, "make object of class that has a sofa-item method";

my $ret;

lives-ok { $ret = $f.bar }, "run the method (bar)";
is $ret[0], '_foo', "and the path get passed correctly";
isa-ok $ret[1], Foo, "and so did the type";

lives-ok { $ret = $f.baz }, "run the method (baz)";
is $ret[0], '_baz', "and the path get passed correctly";
isa-ok $ret[1], Baz, "and so did the type";

lives-ok { $ret = $f.zub }, "run the method (zub)";
is $ret[0], '_zubber', "and the path get passed correctly";
isa-ok $ret[1], (require ::('Zub')), "and so did the type";

lives-ok { $ret = $f.statistics }, "run the method (statistics)";
is $ret[0], '_stats', "and the path get passed correctly";
isa-ok $ret[1], ::('Sofa::Statistics'), "and so did the type";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
