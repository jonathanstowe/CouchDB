
use v6;

use JSON::Name;
use JSON::Class;

role Sofa::Document::All::Row[::Doc] does JSON::Class {
        my class Value does JSON::Class {
            has Str $.rev;
        }
        has Str   $.id;
        has Doc   $.doc;
        has Str   $.key;
        has Value $.value;
}

role Sofa::Document::All[::RealRow] does JSON::Class {
    has RealRow @.rows;
    has Int     $.total-rows   is json-name('total_rows')   = 0;
    has Int     $.offset                                    = 0;
}

# vim: expandtab shiftwidth=4 ft=raku
