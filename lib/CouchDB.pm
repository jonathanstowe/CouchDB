use v6;

class CouchDB:auth<github:jonathanstowe>:ver<v0.0.1> {
   use CouchDB::UserAgent;
   use JSON::Tiny;

   has CouchDB::UserAgent $.ua is rw;
   has Int  $.port is rw = 5984;
   has Str  $.host is rw = 'localhost';
   has Bool $.secure = False;

   method ua() returns CouchDB::UserAgent is rw {
      if not $!ua.defined {
         $!ua = CouchDB::UserAgent.new(host => $!host, port => $!port, secure => $!secure);
      }
      $!ua;
   }
}
# vim: expandtab shiftwidth=4 ft=perl6
