use v6;

class Sofa:auth<github:jonathanstowe>:ver<0.0.1> {
    use Sofa::UserAgent;
    use Sofa::Database;
    use JSON::Tiny;

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
            @db-names = from-json($response.content).list;
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

   method create-database($name) {
       my $db;
       if not @.databases.grep({ $_ eq $name } ) {
           $db = Sofa::Database.create(:$name, ua => self.ua);
           @.databases.push: $db;
       }
       $db;
   }
}
# vim: expandtab shiftwidth=4 ft=perl6
