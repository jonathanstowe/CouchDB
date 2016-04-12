use v6.c;

use JSON::Class;

class Sofa::Document::Attachment does JSON::Class {
    has Str  $.content-type is json-name('content_type');
    has Str  $.data;
    has Str  $.digest;
    has Int  $.encoded-length is json-name('encoded-length');
    has Str  $.encoding;
    has Int  $.length;
    has Int  $.revpos;
    has Bool $.stub;
}


# vim: expandtab shiftwidth=4 ft=perl6
