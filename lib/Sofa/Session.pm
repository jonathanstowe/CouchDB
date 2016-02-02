use v6.c;

use JSON::Name;
use JSON::Class;

class Sofa::Session does JSON::Class {
    class Info does JSON::Class {
        has Str @.authentication-handlers   is json-name('authentication_handlers');
        has Str $.authentication-db         is json-name('authentication_db');
        has Str $.authentication-method     is json-name('authenticated');
    }
    class UserCtx does JSON::Class {
        has Str  $.name;
        has Str  @.roles;
    }
    has Info    $.info;
    has UserCtx $.user-context   is json-name('userCtx');
    has Bool    $.ok;

    method is-admin() returns Bool {
        $!user-context.defined ?? so $!user-context.roles.grep(/^_admin$/) !! False;
    }

    method is-authenticated() returns Bool {
        $!user-context.defined ?? $!user-context.name.defined !! False;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
