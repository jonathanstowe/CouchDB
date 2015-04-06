use v6;

use CouchDB::Server::Vendor;
use JSON::Tiny;

class CouchDB::Server {
   has $.couchdb;
   has $.uuid;
   has $.version;
   has $.vendor;
   multi method new(%data is copy) {
      %data<vendor> = CouchDB::Server::Vendor.new(%data<vendor>);
      %data<version> = Version.new(%data<version>);
      self.bless(|%data);
   }

   multi method new(Str $json) {
      self.new(from-json $json);
   }
}
