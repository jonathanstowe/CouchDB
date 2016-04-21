use v6;

use Sofa::Method;
use Sofa::Exception;

class Sofa:auth<github:jonathanstowe>:ver<0.0.1> does Sofa::Exception::Handler {
    use Sofa::UserAgent;
    use Sofa::Database;
    use Sofa::User;
    

    has Sofa::UserAgent $.ua is rw;
    has Int  $.port is rw = 5984;
    has Str  $.host is rw = 'localhost';
    has Bool $.secure = False;

    has Str $.username;
    has Str $.password;

    has Bool $.basic-auth;

    has Sofa::Database @.databases;

    method ua() returns Sofa::UserAgent is rw {
        if not $!ua.defined {
            $!ua = Sofa::UserAgent.new(host => $!host, port => $!port, secure => $!secure);
            if $!username.defined && $!password.defined {
                if $!basic-auth {
                    $!ua.auth($!username, $!password);
                }
                else {
                    my %form = name => $!username, password => $!password;
                    my $res = $!ua.post(path => '_session', :%form);
                    if not $res.is-success {
                        self!get-exception($res.code, '_session', "getting session", Sofa::Exception::Server).throw;
                    }
                }
            }
        }
        $!ua;
    }

    method !db-names() {
        my @db-names;
        my $response = self.ua.get(path => '_all_dbs');
        if $response.is-success {
            @db-names = $response.from-json.list;
        }
        @db-names;
    }

    method databases() {
        my @dbs = self!db-names;
        if @!databases.elems ne @dbs.elems {
            @!databases = ();
            for @dbs -> $name {
                @!databases.push: Sofa::Database.fetch(:$name, ua => self.ua);
            }
        }
        @!databases;
    }

    method create-database(Str $name) {
        my $db;
        if not @.databases.grep({ $_.name eq $name } ) {
            $db = Sofa::Database.create(:$name, ua => self.ua);
            @.databases.push: $db;
        }
        else {
            X::DatabaseExists.new(:$name).throw;
        }
        $db;
    }

    method get-database(Str $name) returns Sofa::Database {
        @.databases.grep({$_.name eq $name}).first;
    }

    has Sofa::Database $.user-db;
    method user-db() returns Sofa::Database {
        if not $!user-db.defined {
            $!user-db = self.get-database('_users');
        }
        $!user-db;
    }

    method users() {
        self.user-db.all-docs(:detail, type => Sofa::User).map(-> $d { $d.doc }).grep({ $_.sofa-document-id !~~ /^_design/});
    }

    proto method add-user(|c) { * }

    multi method add-user(Str :$name!, Str :$password, :@roles) returns Sofa::User {
        my $user = Sofa::User.new(:$name, :$password, :@roles);
        samewith($user);
        $user;
    }

    multi method add-user(Sofa::User:D $user) {
        self.user-db.create-document($user.generate-id, $user);
    }

    method get-user(Str $name) returns Sofa::User {
        my $id = Sofa::User.generate-id($name);
        self.user-db.get-document($id, Sofa::User);
    }

    method update-user(Sofa::User:D $user) {
        self.user-db.update-document($user);
    }

    proto method delete-user(|c) { * }

    multi method delete-user(Str $name) {
        my $user = self.get-user($name);
        samewith($user);
    }

    multi method delete-user(Sofa::User:D $user) {
        self.user-db.delete-document($user);
    }

    method session() handles <is-admin> is sofa-item('Sofa::Session') { * }

    method statistics() is sofa-item('Sofa::Statistics') { * }

    method configuration() is sofa-item('Sofa::Config') { * }
}
# vim: expandtab shiftwidth=4 ft=perl6
