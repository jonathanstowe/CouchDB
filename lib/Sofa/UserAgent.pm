use v6.c;

use URI::Template;
use HTTP::Request::Common;


use HTTP::UserAgent ();

class Sofa::UserAgent is HTTP::UserAgent {
    has Str             $.host              = 'localhost';
    has Int             $.port              = 5984;
    has Bool            $.secure            = False;
    has Str             $.base-url;
    has URI::Template   $!base-template;
    has                 %.default-headers   = (Accept => "application/json", Content-Type => "application/json");

    subset FromJSON of Mu where { $_.can('from-json') };
    subset ToJSON   of Mu where { $_.can('to-json') };
    subset LikeJSONClass of Mu where all(FromJSON,ToJSON);

    role CouchResponse {
        multi method from-json() {
            from-json(self.content);
        }
        multi method from-json(FromJSON $c) {
            $c.from-json(self.content);
        }

    }

    method base-url() returns Str {
        if not $!base-url.defined {
            $!base-url = 'http' ~ ($!secure ?? 's' !! '') ~ '://' ~ $!host ~ ':' ~ $!port.Str ~ '{/path*}{?params*}';
        }
        $!base-url;
    }

    method base-template() returns URI::Template handles <process> {
        if not $!base-template.defined {
            $!base-template = URI::Template.new(template => self.base-url);
        }
        $!base-template;
    }

    proto method get(|c) { * }

    multi method get(:$path!, :$params, *%headers) returns CouchResponse {
        self.request(GET(self.process(:$path, :$params), |%!default-headers, |%headers)) but CouchResponse;
    }

    proto method put(|c) { * }

    multi method put(:$path!, :$params, Str :$content, *%headers) returns CouchResponse {
        self.request(PUT(self.process(:$path, :$params), :$content, |%!default-headers, |%headers)) but CouchResponse;
    }

    multi method put(:$path!, :$params, :%content, *%headers) returns CouchResponse {
        samewith(:$path, :$params, content => to-json(%content), |%headers);
    }

    multi method put(:$path!, :$params, ToJSON :$content, *%headers) returns CouchResponse {
        samewith(:$path, :$params, content => $content.to-json, |%headers);
    }

    proto method post(|c) { * }

    multi method post(:$path!, :$params, Str :$content, *%headers) returns CouchResponse {
        self.request(POST(self.process(:$path, :$params), :$content, |%!default-headers)) but CouchResponse;
    }

    multi method post(:$path!, :$params, :%content, *%headers) returns CouchResponse {
        samewith(:$path, :$params, content => to-json(%content), |%headers);
    }

    multi method post(:$path!, :$params,  ToJSON :$content, *%headers) returns CouchResponse {
        samewith(:$path, :$params, content => $content.to-json, |%headers);
    }

    proto method delete(|c) { * }

    multi method delete(:$path!, :$params, *%headers) returns CouchResponse {
        self.request(DELETE(self.process(:$path, :$params), |%!default-headers, |%headers)) but CouchResponse;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
