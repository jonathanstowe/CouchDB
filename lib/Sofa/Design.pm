
use v6.c;

use JSON::Name;
use JSON::Class;

use Sofa::Document::Wrapper;

class Sofa::Design does JSON::Class does Sofa::Document::Wrapper {

    class View does JSON::Class {
        has Str $.map     is json-skip-null;
        has Str $.reduce  is json-skip-null;
    }

    has Str  $.name;

    has Str  $.language = "javascript";
    has View %.views;
    has Str  %.lists;
    has Str  %.shows;
    has Str  %.updates;
    has Str  %.filters;

    has Str  @.rewrites;
    has Str  $.validate-doc-update  is json-name('validate_doc_update') is json-skip-null;

    method to-json() {
        if not $!sofa_document_id.defined  && $!name.defined {
            $!sofa_document_id = '_design/' ~ $!name;
        }
        self.Sofa::Document::Wrapper::to-json();
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
