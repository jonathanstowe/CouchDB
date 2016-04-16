
use v6.c;

use JSON::Name;
use JSON::Class;
use Sofa::Document::Wrapper;


role Sofa::Document::All[::Doc = (Hash but Sofa::Document::Wrapper)] does JSON::Class {
    my class Row does JSON::Class {
        class Value does JSON::Class {
            has Str $.rev;
        }
        has Str   $.id;
        has Doc   $.doc;
        has Str   $.key;
        has Value $.value;
    }
    has Row @.rows;
    has Int $.total-rows   is json-name('total_rows') = 0;
    has Int $.offset                                  = 0;
}

# vim: expandtab shiftwidth=4 ft=perl6
