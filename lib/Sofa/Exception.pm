use v6.c;

class Sofa::Exception {

    class X::InvalidName is Exception {
        has $.name;
        method message() returns Str {
            "'{$!name}' is not a valid DB name";
        }
    }

    class X::DatabaseExists is Exception {
        has $.name;
        method message() returns Str {
            "Database '{$!name}' already exists";
        }
    }

    class X::DocumentConflict is Exception {
        has $.name;
        has $.what;
        method message() returns Str {
            "There was a conflict while { $!what } document '{$!name}'";
        }
    }

    class X::NoDatabase is Exception {
        has $.name;
        method message() returns Str {
            "Database '{$!name}' does not exist";
        }
    }

    class X::NoDocument is Exception {
        has $.name;
        has $.what;
        method message() {
            "Document '{ $!name }' not found while '{ $!what }'";
        }
    }

    class X::NotAuthorised is Exception {
        has $.name;
        has $.what;
        method message() returns Str {
            "You are not authorised to { $!what } database '{$!name}'";
        }
    }

    class X::NoIdOrName is Exception {
        has $.message = "Cannot put a design document without a name or id";
    }

    class X::SofaWTF is Exception {
        has $.message = "Unanticipated response";
    }


    enum ExceptionContext <Server Database Document>;

    role Handler {
        method !get-exception(Int() $code, $name, Str $what, ExceptionContext $context = Database) {
            given $code {
                when 400 {
                    X::InvalidName.new(:$name);
                }
                when 401 {
                    X::NotAuthorised.new(:$name, :$what);
                }
                when 404 {
                    given $context {
                        when Database {
                            X::NoDatabase.new(:$name);
                        }
                        when Document {
                            X::NoDocument.new(:$name, :$what);
                        }
                    }
                }
                when 409 {
                    X::DocumentConflict.new(:$name, :$what);
                }
                when 412 {
                    # This is not actually right as 412 is more context sensitive
                    X::DatabaseExists.new(:$name);
                }
                default {
                    X::SofaWTF.new;
                }
            }
        }
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
