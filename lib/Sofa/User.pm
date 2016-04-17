use v6.c;

use JSON::Name;
use JSON::Class;
use Sofa::Document::Wrapper;

class Sofa::User does JSON::Class does Sofa::Document::Wrapper {
    has Str $.name;
    has Str $.password          is rw is json-skip-null;
    has Str $.salt              is json-skip-null;
    has Str $.derived-key       is json-name('derived_key') is json-skip-null;
    has Int $.iterations        is json-skip-null;
    has Str $.type          =   'user';
    has Str $.password-scheme   is json-name('password_scheme') is json-skip-null;
    has Str @.roles;

    method to-json() {
        self.Sofa::Document::Wrapper::to-json();
    }

    method generate-id() returns Str {
        my Str $s;
        if $!name.defined {
            $s = "org.couchdb.user:%s".sprintf($!name);
        }
        $s;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
