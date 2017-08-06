use v6.c;

use JSON::Name;
use JSON::Class:ver(v0.0.5+);

use Sofa::Item;

class Sofa::Server does JSON::Class is sofa-path('') {
    class Vendor {
        has Version $.version is unmarshalled-by('new');
        has Str $.name;
    }
    has Str     $.couchdb;
    has Str     $.uuid;
    has Version $.version is unmarshalled-by('new');
    has Vendor  $.vendor;

    multi method new(Str $json) {
        self.from-json($json);
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
