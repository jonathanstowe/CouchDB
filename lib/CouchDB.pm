use v6;

class CouchDB:auth<github:jonathanstowe>:ver<v0.0.1> {
   use CouchDB::UserAgent;
   use JSON::Tiny;

   has CouchDB::UserAgent $.ua;
   has Int $.port is rw = 5984;

   submethod ua is rw {
      if not $!ua.defined {
         $!ua = CouchDB::UserAgent.new
      }
      $!ua;
   }

}
# vim: expandtab shiftwidth=4 ft=perl6
