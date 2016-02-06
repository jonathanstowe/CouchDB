#!/usr/bin/env perl6

# I made this when I was testing the library as I kept dumping empty
# databases onto the server.  You probably want to confirm what it was
# doing before you use this on a server you are about.

use Sofa;

my $host = 'localhost';
my $port = 5984;

multi sub MAIN(Str :$host = 'localhost', Int :$port = 5984, Bool :$dry-run = False, :@exclude-db?) {
    my $sofa = Sofa.new(:$host, :$port);

    if $sofa.is-admin {
        my Int $deleted-count = 0;
        my @exc = (<_users contacts _replicator>, @exclude-db).flat;
        for $sofa.databases.grep({$_.name  ~~ none(@exc)}) -> $db {
            $deleted-count++;
            if $dry-run {
                say "would have deleted : ", $db.name;
            }
            else {
                say "deleting : ", $db.name;
                $db.delete ;
            }
        }
        say $deleted-count ?? "Deleted { $deleted-count } databases" !! 'Nothing to delete';
    }
    else {
        $*ERR.say("Not admin, can't delete databases");
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
