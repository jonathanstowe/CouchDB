use v6;

class CouchDB::Server::Vendor {
   has $.version;
   has $.name;
   multi method new(%data) {
      %data<version> = Version.new(%data<version>);
      self.bless(|%data);
   }
}
# vim: expandtab shiftwidth=4 ft=perl6
