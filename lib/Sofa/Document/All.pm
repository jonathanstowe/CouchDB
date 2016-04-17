
use v6.c;

use JSON::Name;
use JSON::Class;
use Sofa::Document::Wrapper;

class Sofa::Document::All::Default is Hash does JSON::Class does Sofa::Document::Wrapper {
    method to-json() {
        self.Sofa::Document::Wrapper::to-json();
    }
}

role Sofa::Document::All[::Doc = Sofa::Document::All::Default] does JSON::Class {
    my class Row does JSON::Class {
        my class Value does JSON::Class {
            has Str $.rev;
        }
        has Str   $.id;
        has       $.doc; # This should be typed
        has Str   $.key;
        has Value $.value;
    }
    has Row @.rows;
    has Int $.total-rows   is json-name('total_rows') = 0;
    has Int $.offset                                  = 0;
}

# vim: expandtab shiftwidth=4 ft=perl6
