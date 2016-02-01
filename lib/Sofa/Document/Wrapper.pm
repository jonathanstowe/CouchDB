use v6.c;

use JSON::Name;
use Sofa::Document;

role Sofa::Document::Wrapper {
    use JSON::Class;

    has Str $.sofa_document_type = _get_doc_name();
    has Str $.sofa_document_id       is json-name('_id') is json-skip-null;
    has Str $.sofa_document_revision is json-name('_rev') is json-skip-null;

    sub _get_doc_name() {
        my $n = ::?CLASS.^name.lc.subst(/\:+/,"_", :g);
        $n.subst(/\+.*/,'');
    } 
    method to-json() {
        self does JSON::Class;
        if not $!sofa_document_type {
            $!sofa_document_type = _get_doc_name();
        }
        self.JSON::Class::to-json();
    }

    method update-rev(Sofa::Document:D $doc) {
        if !$!sofa_document_id.defined || ($doc.id eq $!sofa_document_id ) {
            $!sofa_document_id = $doc.id;
            $!sofa_document_revision = $doc.rev;
        }
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
