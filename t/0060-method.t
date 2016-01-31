#!perl6

use v6;

use Test;

use Sofa::Method;

{
    use Sofa::Item;

    class Foo is sofa-path('_foo') {
    }

    class Baz is sofa-path('_baz') {
    }
}

class Bar {
    method bar is sofa-item('Foo') { * }
    method baz is sofa-item('Baz') { * }

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

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
