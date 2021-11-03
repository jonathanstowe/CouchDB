use v6.c;
use JSON::Class:ver(v0.0.5+);

class Sofa::Document does JSON::Class {
    has Str  $.id;
    has Str  $.rev;
    has Bool $.ok;
}

# vim: expandtab shiftwidth=4 ft=raku6
