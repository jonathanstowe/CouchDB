#!perl6

use v6;

use Test;

use Sofa::Design;

my $data-dir = $*PROGRAM.parent.child('data');

my $design;

lives-ok { $design = Sofa::Design.new(name => "foo") }, "create a new Sofa::Design";

my $d2;

lives-ok { $d2 = Sofa::Design.from-json($design.to-json) }, "round-trip it";
is $d2.sofa_document_id, '_design/foo', "and the id was populated";

lives-ok { $design = Sofa::Design.from-json($data-dir.child('design-contacts.json').slurp) }, "create one from an existing file";
isa-ok $design, Sofa::Design, "and it's a Sofa::Design";
ok all($design.views.values) ~~ Sofa::Design::View, "and all the views are the right object";
ok $design.views<by_name> ~~ Sofa::Design::View, "and it's the right sort of hash";
ok all($design.attachments.values) ~~ Sofa::Document::Attachment, "and got the attribute object";
is $design.attachments<index.html>.content-type, "text/html", "and one we know is there is right";
is $design.name, "contacts", "and we made the name right";


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
