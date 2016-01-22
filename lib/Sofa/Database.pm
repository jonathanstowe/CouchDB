use JSON::Class;
use JSON::Name;
use JSON::Unmarshal;

class Sofa::Database does JSON::Class {
    use Sofa::UserAgent;
    sub microsecs-to-dt($val) returns DateTime {
        DateTime.new(($val.Numeric/1000000).Int);
    }

    has Int         $.doc_del_count;
    has Int         $.disk_format_version;
    has Int         $.committed_update_seq;
    has Int         $.purge_seq;
    has Int         $.doc_count;
    has Bool        $.compact_running;
    has Int         $.disk_size;
    has Int         $.data_size;
    has DateTime    $.instance_start_time is unmarshalled-by(&microsecs-to-dt);
    has Int         $.update_seq;
    has Str         $.name                is json-name('db_name');

    has Sofa::UserAgent $.ua is rw;


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

    class X::NoDatabase is Exception {
        has $.name;
        method message() returns Str {
            "Database '{$!name}' does not exist";
        }
    }

    class X::NotAuthorised is Exception {
        has $.name;
        has $.what;
        method message() returns Str {
            "You are not authorised to { $!what } database '{$!name}'";
        }
    }



    method is-valid-name(Str:D $name) {
	    my token valid-db-name {
		    ^<[a .. z]><[a .. z0 .. 9_$()+/-]>*$
	    }
        so ($name ~~ /<valid-db-name>/);
    }

    method fetch(Sofa::Database:U: Str :$name!, Sofa::UserAgent :$ua!) returns Sofa::Database {
        my $db;

        my $response = $ua.get(path => $name);

        if $response.is-success {
            $db = self.from-json($response.content);
            $db.ua = $ua;
        }
        else {
            given $response.code {
                when 404 {
                    X::NoDatabase.new(:$name).throw;
                }
                default {
                    die "WTF : $_";
                }
            }
        }

        $db;
    }

    method create(Sofa::Database:U: Str :$name!, Sofa::UserAgent :$ua!) returns Sofa::Database {
        my $db;

        if self.is-valid-name($name) {
            my $response = $ua.put(path => $name);
            if $response.is-success {
                $db = self.fetch(:$name, :$ua);
            }
            else {
                given $response.code {
                    when 400 {
                        X::InvalidName.new(:$name).throw;
                    }
                    when 401 {
                        X::NotAuthorised.new(:$name, what => 'create').throw;
                    }
                    when 412 {
                        X::DatabaseExists.new(:$name).throw;
                    }
                }
                die $response;
            }
        }
        else {
            X::InvalidName.new(:$name).throw;
        }
        $db;
    }

    multi method delete(Sofa::Database:U: Str :$name!, :$ua!) returns Bool {
        my $response = $ua.delete(path => $name);
        if not $response.is-success {
            given $response.code {
                when 404 {
                    X::NoDatabase.new(:$name).throw;
                }
                when 401 {
                    X::NotAuthorised.new(:$name, what => 'delete').throw;
                }
            }
        }
        True;
    }

    multi method delete(Sofa::Database:D:) returns Bool {
        Sofa::Database.delete(name => $!name, ua => $!ua);
    }
    
}

# vim: expandtab shiftwidth=4 ft=perl6
