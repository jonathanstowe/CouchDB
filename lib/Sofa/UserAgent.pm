use v6;
use HTTP::UserAgent;
use URI::Template;
use HTTP::Request::Common;

class Sofa::UserAgent is HTTP::UserAgent {
    has Str  $.host = 'localhost';
    has Int  $.port = 5984;
    has Bool $.secure = False;
    has Str  $.base-url;
    has URI::Template $!base-template;

    method base-url() returns Str {
        if not $!base-url.defined {
            $!base-url = 'http' ~ ($!secure ?? 's' !! '') ~ '://' ~ $!host ~ ':' ~ $!port.Str ~ '/{+path}';
        }
        $!base-url;
    }

    method base-template() returns URI::Template handles <process> {
        if not $!base-template.defined {
            $!base-template = URI::Template.new(template => self.base-url);
        }
        $!base-template;
    }

    multi method get(:$path!) returns HTTP::Message {
        self.get(self.process(:$path));
    }

    multi method put(Str :$path!, Str :$content) returns HTTP::Message {
        self.request(PUT(self.process(:$path), :$content));
    }

    multi method delete(Str :$path!) returns HTTP::Message {
        self.request(DELETE(self.process(:$path)));
    }

}
# vim: expandtab shiftwidth=4 ft=perl6
