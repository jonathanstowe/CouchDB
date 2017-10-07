use v6.c;

module Sofa::Item {
    role MetamodelX::ClassHOW {
        has Str $!sofa-path;
        method sofa-path(--> Str) is rw {
            $!sofa-path;
        }
    }

    multi sub trait_mod:<is>(Mu:U $type, Str :$sofa-path!) is export {
        $type.HOW.sofa-path = $sofa-path;
    }
}


my package EXPORTHOW {
    package SUPERSEDE {
       constant class = Metamodel::ClassHOW but Sofa::Item::MetamodelX::ClassHOW;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
