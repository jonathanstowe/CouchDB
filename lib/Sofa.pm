use v6;

class Sofa:auth<github:jonathanstowe>:ver<v0.0.1> {
   use Sofa::UserAgent;
   use JSON::Tiny;

   has Sofa::UserAgent $.ua is rw;
   has Int  $.port is rw = 5984;
   has Str  $.host is rw = 'localhost';
   has Bool $.secure = False;

   method ua() returns Sofa::UserAgent is rw {
      if not $!ua.defined {
         $!ua = Sofa::UserAgent.new(host => $!host, port => $!port, secure => $!secure);
      }
      $!ua;
   }
}
# vim: expandtab shiftwidth=4 ft=perl6
