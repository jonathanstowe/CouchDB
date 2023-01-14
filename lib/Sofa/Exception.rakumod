use v6;

class Sofa::Exception {

    class X::Sofa::InvalidName is Exception {
        has $.name;
        method message( --> Str ) {
            "'{$!name}' is not a valid DB name";
        }
    }

    class X::Sofa::DatabaseExists is Exception {
        has $.name;
        method message( --> Str ) {
            "Database '{$!name}' already exists";
        }
    }

    class X::Sofa::DocumentConflict is Exception {
        has $.name;
        has $.what;
        method message( --> Str ) {
            "There was a conflict while { $!what } document '{$!name}'";
        }
    }

    class X::Sofa::NoDatabase is Exception {
        has $.name;
        method message( --> Str ) {
            "Database '{$!name}' does not exist";
        }
    }


    class X::Sofa::CantDoBoth is Exception {
        has $.message = "Can't do both of content and form";
    }

    class X::Sofa::NoDocument is Exception {
        has $.name;
        has $.what;
        method message() {
            "Document '{ $!name }' not found while '{ $!what }'";
        }
    }

    class X::Sofa::InvalidPath is Exception {
        has $.name;
        has $.what;
        method message() {
            "Path '{ $!name }' not found while '{ $!what }'";
        }
    }

    class X::Sofa::NotAuthorised is Exception {
        has $.name;
        has $.what;
        method message( --> Str ) {
            "You are not authorised to { $!what } database '{$!name}'";
        }
    }

    class X::Sofa::Forbidden is Exception {
        has $.name;
        has $.what;
        method message( --> Str ) {
            "You are not authorised to { $!what } database '{$!name}'";
        }
    }


    class X::Sofa::NoIdOrName is Exception {
        has $.message = "Cannot put a design document without a name or id";
    }

    class X::Sofa::SofaWTF is Exception {
        has $.message = "Unanticipated response";
    }


    enum ExceptionContext <Server Database Document>;

    role Handler {
        method !get-exception(Int() $code, $name, Str $what, ExceptionContext $context = Database) {
            given $code {
                when 400 {
                    X::Sofa::InvalidName.new(:$name);
                }
                when 401 {
                    X::Sofa::NotAuthorised.new(:$name, :$what);
                }
                when 403 {
                    X::Sofa::Forbidden.new(:$name, :$what);
                }
                when 404 {
                    given $context {
                        when Database {
                            X::Sofa::NoDatabase.new(:$name);
                        }
                        when Document {
                            X::Sofa::NoDocument.new(:$name, :$what);
                        }
                        when Server {
                            X::Sofa::InvalidPath.new(:$name, :$what);
                        }
                    }
                }
                when 409 {
                    X::Sofa::DocumentConflict.new(:$name, :$what);
                }
                when 412 {
                    # This is not actually right as 412 is more context sensitive
                    X::Sofa::DatabaseExists.new(:$name);
                }
                default {
                    say $code;
                    X::Sofa::SofaWTF.new;
                }
            }
        }
    }
}

# vim: expandtab shiftwidth=4 ft=raku
