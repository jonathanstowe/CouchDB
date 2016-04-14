use v6.c;

use JSON::Name;
use JSON::Class;

class Sofa::Database::Security does JSON::Class {

    role Group does JSON::Class {
        has  @.names;
        has  @.roles;
    }

    class Admins does Group {
    }

    class Members does Group {
    }

    has Admins  $.admins;
    has Members $.members;
}

# vim: expandtab shiftwidth=4 ft=perl6
