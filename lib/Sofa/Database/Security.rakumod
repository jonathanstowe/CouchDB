use v6;

use JSON::Name;
use JSON::Class;
use Sofa::Item;

class Sofa::Database::Security does JSON::Class is sofa-path('_security') {

    role Group does JSON::Class {
        has  Str @.names;
        has  Str @.roles;
    }

    class Admins does Group {
    }

    class Members does Group {
    }

    has Admins  $.admins;

    method admins( --> Admins ) is rw {
        if not $!admins.defined {
            $!admins = Admins.new;
        }
        $!admins;
    }

    has Members $.members;

    method members( --> Members ) is rw {
        if not $!members.defined {
            $!members = Members.new;
        }
        $!members;
    }
}

# vim: expandtab shiftwidth=4 ft=raku
