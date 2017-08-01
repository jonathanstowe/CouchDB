use v6.c;

use JSON::Name;
use Sofa::Document;
use Sofa::Document::Attachment;

role Sofa::Document::Wrapper {
    use JSON::Class;

    has Str                        $.sofa-document-type = _get_doc_name();
    has Str                        $.sofa-document-id       is json-name('_id')  is json-skip-null;
    has Str                        $.sofa-document-revision is json-name('_rev') is json-skip-null;
    has Sofa::Document::Attachment %.attachments            is json-name('_attachments');

    sub _get_doc_name() {
        my $n = ::?CLASS.^name.lc.subst(/\:+/,"_", :g);
        $n.subst(/\+.*/,'');
    }
    method to-json() {
        self does JSON::Class;
        if not $!sofa-document-type {
            $!sofa-document-type = _get_doc_name();
        }
        self.JSON::Class::to-json();
    }

    method update-rev(Sofa::Document:D $doc) {
        if !$!sofa-document-id.defined || ($doc.id eq $!sofa-document-id ) {
            $!sofa-document-id = $doc.id;
            $!sofa-document-revision = $doc.rev;
        }
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
