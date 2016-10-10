use v6.c;

module Sofa::Method {

    use Sofa::Exception;

    role Item[Str:D $sofa-item] does Sofa::Exception::Handler {

        has     $.sofa-path;
        has Mu  $.sofa-item;

        sub load-if-required(Str $f) { 
            my $t = ::($f);
            if !$t && $t ~~ Failure { 
                $t = (require ::($f)) 
            } 
            $t 
        }
        method CALL-ME(Mu:D $self) {
            if not $!sofa-path.defined {
                $!sofa-item = load-if-required($sofa-item);
                $!sofa-path = $!sofa-item.HOW.sofa-path;
                if $self.can('get-local-path') {
                    $!sofa-path = $self.get-local-path(path => $!sofa-path);
                }
            }
            my $response = $self.ua.get(path => $!sofa-path);
            if $response.is-success {
                $response.from-json($!sofa-item);
            }
            else {
                $self!get-exception($response.code, $!sofa-path, "getting $sofa-item", Sofa::Exception::Server).throw;
            }
        }
    }

    multi sub trait_mod:<is>(Method $m, Str :$sofa-item!) is export {
        $m does Item[$sofa-item];
    }
}


# vim: expandtab shiftwidth=4 ft=perl6
