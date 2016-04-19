use v6;

use Sofa::Method;

class Sofa:auth<github:jonathanstowe>:ver<0.0.1> {
    use Sofa::UserAgent;
    use Sofa::Database;
    use Sofa::User;
    

    has Sofa::UserAgent $.ua is rw;
    has Int  $.port is rw = 5984;
    has Str  $.host is rw = 'localhost';
    has Bool $.secure = False;

    has Sofa::Database @.databases;

    method ua() returns Sofa::UserAgent is rw {
        if not $!ua.defined {
            $!ua = Sofa::UserAgent.new(host => $!host, port => $!port, secure => $!secure);
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

   method add-user(Sofa::User:D $user) {
       self.user-db.create-document($user.generate-id, $user);
   }

   method update-user(Sofa::User:D $user) {
       self.user-db.update-document($user);
   }

   method delete-user(Sofa::User:D $user) {
       self.user-db.delete-document($user);
   }

   method session() handles <is-admin> is sofa-item('Sofa::Session') { * }

   method statistics() is sofa-item('Sofa::Statistics') { * }

   method configuration() is sofa-item('Sofa::Config') { * }
}
# vim: expandtab shiftwidth=4 ft=perl6
