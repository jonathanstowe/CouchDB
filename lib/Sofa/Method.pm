use v6.c;

module Sofa::Method {

    role Item[Str:D $sofa-item] {

        has     $.sofa-path;
        has Mu  $.sofa-item;

        sub load-if-required(Str $f) { 
            my $t = ::($f); 
            if $t ~~ Failure { 
                $t = (require ::($f)) 
            } 
            $t 
        }
        method CALL-ME(Mu:D $self) {
            if not $!sofa-path.defined {
                $!sofa-item = load-if-required($sofa-item);
                $!sofa-path = $!sofa-item.HOW.sofa-path;
                if $self.can('get-local-path') {
                    $!sofa-path = $self.get-local-path(parts => $!sofa-path);
                }
            }
            my $response = $self.ua.get(path => $!sofa-path);
            if $response.is-success {
                $response.from-json($!sofa-item);
            }
            else {
                # TODO: DTRT here
                die $response;
            }
        }
    }

    multi sub trait_mod:<is>(Method $m, Str :$sofa-item!) is export {
        $m does Item[$sofa-item];
    }
}


# vim: expandtab shiftwidth=4 ft=perl6
