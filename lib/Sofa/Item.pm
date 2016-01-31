use v6.c;

module Sofa::Item {
    class MetamodelX::ClassHOW is Metamodel::ClassHOW {
        has Str $.sofa-path is rw;
    }

    multi sub trait_mod:<is>(Mu:U $type, Str :$sofa-path!) is export {
        $type.HOW.sofa-path = $sofa-path;
    }
}


my package EXPORTHOW {
    package SUPERSEDE {
       constant class = Sofa::Item::MetamodelX::ClassHOW;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
