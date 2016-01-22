#!perl6

use v6;
use lib 'lib';

use Test;

use Sofa::Database;

my $json = '{"db_name":"_users","doc_count":1,"doc_del_count":0,"update_seq":1,"purge_seq":0,"compact_running":false,"disk_size":4194,"data_size":2141,"instance_start_time":"1448207878687603","disk_format_version":6,"committed_update_seq":1}';

my $db;

lives-ok { $db = Sofa::Database.from-json($json) }, "create Sofa::Database from JSON";

is $db.db_name, '_users', "got the right db_name";
isa-ok $db.instance_start_time, DateTime, "and instance_start_time is a DT";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
