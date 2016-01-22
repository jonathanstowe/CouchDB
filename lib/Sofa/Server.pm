use v6;

use JSON::Class;
use JSON::Unmarshal;
use JSON::Marshal;

class Sofa::Server does JSON::Class {
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
