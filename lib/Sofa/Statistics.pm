
use JSON::Name;
use JSON::Class:ver(v0.0.5+);
use JSON::Unmarshal;
use Sofa::Item;

class Sofa::Statistics does JSON::Class is sofa-path('_stats') {

    sub rat-safe($value) returns Rat {
        my Rat $ret;
        if $value.defined {
            $ret = Rat($value);
        }
        $ret;
    }
    class Item does JSON::Class {
        has Rat $.current is unmarshalled-by(&rat-safe);
        has Rat $.min is unmarshalled-by(&rat-safe);
        has Rat $.sum is unmarshalled-by(&rat-safe);
        has Rat $.mean is unmarshalled-by(&rat-safe);
        has Rat $.stddev is unmarshalled-by(&rat-safe);
        has Str $.description;
        has Rat $.max is unmarshalled-by(&rat-safe);
    }
    class HttpdRequestMethods does JSON::Class {
        has Item $.COPY;
        has Item $.HEAD;
        has Item $.POST;
        has Item $.GET;
        has Item $.PUT;
        has Item $.DELETE;
    }
    class Httpd does JSON::Class {
        has Item $.requests;
        has Item $.clients_requesting_changes;
        has Item $.bulk_requests;
        has Item $.temporary_view_reads;
        has Item $.view_reads;
    }
    class Couchdb does JSON::Class {
        has Item $.open_databases;
        has Item $.database_writes;
        has Item $.database_reads;
        has Item $.auth_cache_hits;
        has Item $.auth_cache_misses;
        has Item $.open_os_files;
        has Item $.request_time;
    }
    class HttpdStatusCodes does JSON::Class {
        has Item $.status-code201 is json-name('201');
        has Item $.status-code403 is json-name('403');
        has Item $.status-code202 is json-name('202');
        has Item $.status-code304 is json-name('304');
        has Item $.status-code301 is json-name('301');
        has Item $.status-code200 is json-name('200');
        has Item $.status-code404 is json-name('404');
        has Item $.status-code500 is json-name('500');
        has Item $.status-code401 is json-name('401');
        has Item $.status-code409 is json-name('409');
        has Item $.status-code405 is json-name('405');
        has Item $.status-code400 is json-name('400');
        has Item $.status-code412 is json-name('412');
    }
    has HttpdRequestMethods $.httpd_request_methods;
    has Couchdb $.couchdb;
    has Httpd $.httpd;
    has HttpdStatusCodes $.httpd_status_codes;
}
# vim: expandtab shiftwidth=4 ft=perl6
