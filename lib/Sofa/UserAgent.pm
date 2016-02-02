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

    multi method get(:$path!, *%headers) returns CouchResponse {
        self.request(GET(self.process(:$path), |%!default-headers, |%headers)) but CouchResponse;
    }

    multi method put(Str :$path!, Str :$content, *%headers) returns CouchResponse {
        self.request(PUT(self.process(:$path), :$content, |%!default-headers, |%headers)) but CouchResponse;
    }

    multi method put(Str :$path!, :%content, *%headers) returns CouchResponse {
        samewith(:$path, content => to-json(%content), |%headers);
    }

    multi method put(Str :$path!, ToJSON :$content, *%headers) returns CouchResponse {
        samewith(:$path, content => $content.to-json, |%headers);
    }

    multi method post(Str :$path!, Str :$content, *%headers) returns CouchResponse {
        self.request(POST(self.process(:$path), :$content, |%!default-headers)) but CouchResponse;
    }

    multi method post(Str :$path!, :%content, *%headers) returns CouchResponse {
        samewith(:$path, content => to-json(%content), |%headers);
    }

    multi method post(Str :$path!, ToJSON :$content, *%headers) returns CouchResponse {
        samewith(:$path, content => $content.to-json, |%headers);
    }

    multi method delete(Str :$path!, *%headers) returns CouchResponse {
        self.request(DELETE(self.process(:$path), |%!default-headers, |%headers)) but CouchResponse;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
