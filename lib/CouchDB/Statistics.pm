use JSON::Class;
use JSON::Name;
class CouchDB::Statistics does JSON::Class {
    class CouchDB::Statistics::HttpdRequestMethods::COPY does JSON::Class {
        has Any $.current;
        has Any $.min;
        has Any $.sum;
        has Any $.mean;
        has Any $.stddev;
        has Str $.description;
        has Any $.max;
    }
    class CouchDB::Statistics::HttpdRequestMethods::HEAD does JSON::Class {
        has Any $.current;
        has Any $.min;
        has Any $.sum;
        has Any $.mean;
        has Any $.stddev;
        has Str $.description;
        has Any $.max;
    }
    class CouchDB::Statistics::HttpdRequestMethods::POST does JSON::Class {
        has Any $.current;
        has Any $.min;
        has Any $.sum;
        has Any $.mean;
        has Any $.stddev;
        has Str $.description;
        has Any $.max;
    }
    class CouchDB::Statistics::HttpdRequestMethods::GET does JSON::Class {
        has Rat $.current;
        has Int $.min;
        has Rat $.sum;
        has Rat $.mean;
        has Rat $.stddev;
        has Str $.description;
        has Int $.max;
    }
    class CouchDB::Statistics::HttpdRequestMethods::DELETE does JSON::Class {
        has Any $.current;
        has Any $.min;
        has Any $.sum;
        has Any $.mean;
        has Any $.stddev;
        has Str $.description;
        has Any $.max;
    }
    class CouchDB::Statistics::HttpdRequestMethods::PUT does JSON::Class {
        has Any $.current;
        has Any $.min;
        has Any $.sum;
        has Any $.mean;
        has Any $.stddev;
        has Str $.description;
        has Any $.max;
    }
    class CouchDB::Statistics::HttpdRequestMethods does JSON::Class {
        class CouchDB::Statistics::HttpdRequestMethods::COPY does JSON::Class {
            has Any $.current;
            has Any $.min;
            has Any $.sum;
            has Any $.mean;
            has Any $.stddev;
            has Str $.description;
            has Any $.max;
        }
        class CouchDB::Statistics::HttpdRequestMethods::HEAD does JSON::Class {
            has Any $.current;
            has Any $.min;
            has Any $.sum;
            has Any $.mean;
            has Any $.stddev;
            has Str $.description;
            has Any $.max;
        }
        class CouchDB::Statistics::HttpdRequestMethods::POST does JSON::Class {
            has Any $.current;
            has Any $.min;
            has Any $.sum;
            has Any $.mean;
            has Any $.stddev;
            has Str $.description;
            has Any $.max;
        }
        class CouchDB::Statistics::HttpdRequestMethods::GET does JSON::Class {
            has Rat $.current;
            has Int $.min;
            has Rat $.sum;
            has Rat $.mean;
            has Rat $.stddev;
            has Str $.description;
            has Int $.max;
        }
        class CouchDB::Statistics::HttpdRequestMethods::DELETE does JSON::Class {
            has Any $.current;
            has Any $.min;
            has Any $.sum;
            has Any $.mean;
            has Any $.stddev;
            has Str $.description;
            has Any $.max;
        }
        class CouchDB::Statistics::HttpdRequestMethods::PUT does JSON::Class {
            has Any $.current;
            has Any $.min;
            has Any $.sum;
            has Any $.mean;
            has Any $.stddev;
            has Str $.description;
            has Any $.max;
        }
        has CouchDB::Statistics::HttpdRequestMethods::COPY $.COPY;
        has CouchDB::Statistics::HttpdRequestMethods::HEAD $.HEAD;
        has CouchDB::Statistics::HttpdRequestMethods::POST $.POST;
        has CouchDB::Statistics::HttpdRequestMethods::GET $.GET;
        has CouchDB::Statistics::HttpdRequestMethods::PUT $.PUT;
        has CouchDB::Statistics::HttpdRequestMethods::DELETE $.DELETE;
    }
    class CouchDB::Statistics::Httpd::Requests does JSON::Class {
        has Rat $.current;
        has Int $.min;
        has Rat $.sum;
        has Rat $.mean;
        has Rat $.stddev;
        has Str $.description;
        has Int $.max;
    }
    class CouchDB::Statistics::Httpd::ClientsRequestingChanges does JSON::Class {
        has Any $.current;
        has Any $.min;
        has Any $.sum;
        has Any $.mean;
        has Any $.stddev;
        has Str $.description;
        has Any $.max;
    }
    class CouchDB::Statistics::Httpd::BulkRequests does JSON::Class {
        has Any $.current;
        has Any $.min;
        has Any $.sum;
        has Any $.mean;
        has Any $.stddev;
        has Str $.description;
        has Any $.max;
    }
    class CouchDB::Statistics::Httpd::TemporaryViewReads does JSON::Class {
        has Any $.current;
        has Any $.min;
        has Any $.sum;
        has Any $.mean;
        has Any $.stddev;
        has Str $.description;
        has Any $.max;
    }
    class CouchDB::Statistics::Httpd::ViewReads does JSON::Class {
        has Any $.current;
        has Any $.min;
        has Any $.sum;
        has Any $.mean;
        has Any $.stddev;
        has Str $.description;
        has Any $.max;
    }
    class CouchDB::Statistics::Httpd does JSON::Class {
        class CouchDB::Statistics::Httpd::Requests does JSON::Class {
            has Rat $.current;
            has Int $.min;
            has Rat $.sum;
            has Rat $.mean;
            has Rat $.stddev;
            has Str $.description;
            has Int $.max;
        }
        class CouchDB::Statistics::Httpd::ClientsRequestingChanges does JSON::Class {
            has Any $.current;
            has Any $.min;
            has Any $.sum;
            has Any $.mean;
            has Any $.stddev;
            has Str $.description;
            has Any $.max;
        }
        class CouchDB::Statistics::Httpd::BulkRequests does JSON::Class {
            has Any $.current;
            has Any $.min;
            has Any $.sum;
            has Any $.mean;
            has Any $.stddev;
            has Str $.description;
            has Any $.max;
        }
        class CouchDB::Statistics::Httpd::TemporaryViewReads does JSON::Class {
            has Any $.current;
            has Any $.min;
            has Any $.sum;
            has Any $.mean;
            has Any $.stddev;
            has Str $.description;
            has Any $.max;
        }
        class CouchDB::Statistics::Httpd::ViewReads does JSON::Class {
            has Any $.current;
            has Any $.min;
            has Any $.sum;
            has Any $.mean;
            has Any $.stddev;
            has Str $.description;
            has Any $.max;
        }
        has CouchDB::Statistics::Httpd::Requests $.requests;
        has CouchDB::Statistics::Httpd::ClientsRequestingChanges $.clients_requesting_changes;
        has CouchDB::Statistics::Httpd::BulkRequests $.bulk_requests;
        has CouchDB::Statistics::Httpd::TemporaryViewReads $.temporary_view_reads;
        has CouchDB::Statistics::Httpd::ViewReads $.view_reads;
    }
    class CouchDB::Statistics::Couchdb::OpenDatabases does JSON::Class {
        has Rat $.current;
        has Int $.min;
        has Rat $.sum;
        has Rat $.mean;
        has Rat $.stddev;
        has Str $.description;
        has Int $.max;
    }
    class CouchDB::Statistics::Couchdb::DatabaseReads does JSON::Class {
        has Any $.current;
        has Any $.min;
        has Any $.sum;
        has Any $.mean;
        has Any $.stddev;
        has Str $.description;
        has Any $.max;
    }
    class CouchDB::Statistics::Couchdb::DatabaseWrites does JSON::Class {
        has Any $.current;
        has Any $.min;
        has Any $.sum;
        has Any $.mean;
        has Any $.stddev;
        has Str $.description;
        has Any $.max;
    }
    class CouchDB::Statistics::Couchdb::AuthCacheHits does JSON::Class {
        has Any $.current;
        has Any $.min;
        has Any $.sum;
        has Any $.mean;
        has Any $.stddev;
        has Str $.description;
        has Any $.max;
    }
    class CouchDB::Statistics::Couchdb::AuthCacheMisses does JSON::Class {
        has Any $.current;
        has Any $.min;
        has Any $.sum;
        has Any $.mean;
        has Any $.stddev;
        has Str $.description;
        has Any $.max;
    }
    class CouchDB::Statistics::Couchdb::OpenOsFiles does JSON::Class {
        has Rat $.current;
        has Int $.min;
        has Rat $.sum;
        has Rat $.mean;
        has Rat $.stddev;
        has Str $.description;
        has Int $.max;
    }
    class CouchDB::Statistics::Couchdb::RequestTime does JSON::Class {
        has Rat $.current;
        has Rat $.min;
        has Rat $.sum;
        has Rat $.mean;
        has Rat $.stddev;
        has Str $.description;
        has Rat $.max;
    }
    class CouchDB::Statistics::Couchdb does JSON::Class {
        class CouchDB::Statistics::Couchdb::OpenDatabases does JSON::Class {
            has Rat $.current;
            has Int $.min;
            has Rat $.sum;
            has Rat $.mean;
            has Rat $.stddev;
            has Str $.description;
            has Int $.max;
        }
        class CouchDB::Statistics::Couchdb::DatabaseReads does JSON::Class {
            has Any $.current;
            has Any $.min;
            has Any $.sum;
            has Any $.mean;
            has Any $.stddev;
            has Str $.description;
            has Any $.max;
        }
        class CouchDB::Statistics::Couchdb::DatabaseWrites does JSON::Class {
            has Any $.current;
            has Any $.min;
            has Any $.sum;
            has Any $.mean;
            has Any $.stddev;
            has Str $.description;
            has Any $.max;
        }
        class CouchDB::Statistics::Couchdb::AuthCacheHits does JSON::Class {
            has Any $.current;
            has Any $.min;
            has Any $.sum;
            has Any $.mean;
            has Any $.stddev;
            has Str $.description;
            has Any $.max;
        }
        class CouchDB::Statistics::Couchdb::AuthCacheMisses does JSON::Class {
            has Any $.current;
            has Any $.min;
            has Any $.sum;
            has Any $.mean;
            has Any $.stddev;
            has Str $.description;
            has Any $.max;
        }
        class CouchDB::Statistics::Couchdb::OpenOsFiles does JSON::Class {
            has Rat $.current;
            has Int $.min;
            has Rat $.sum;
            has Rat $.mean;
            has Rat $.stddev;
            has Str $.description;
            has Int $.max;
        }
        class CouchDB::Statistics::Couchdb::RequestTime does JSON::Class {
            has Rat $.current;
            has Rat $.min;
            has Rat $.sum;
            has Rat $.mean;
            has Rat $.stddev;
            has Str $.description;
            has Rat $.max;
        }
        has CouchDB::Statistics::Couchdb::OpenDatabases $.open_databases;
        has CouchDB::Statistics::Couchdb::DatabaseWrites $.database_writes;
        has CouchDB::Statistics::Couchdb::DatabaseReads $.database_reads;
        has CouchDB::Statistics::Couchdb::AuthCacheHits $.auth_cache_hits;
        has CouchDB::Statistics::Couchdb::AuthCacheMisses $.auth_cache_misses;
        has CouchDB::Statistics::Couchdb::OpenOsFiles $.open_os_files;
        has CouchDB::Statistics::Couchdb::RequestTime $.request_time;
    }
    class CouchDB::Statistics::HttpdStatusCodes::201 does JSON::Class {
        has Any $.current;
        has Any $.min;
        has Any $.sum;
        has Any $.mean;
        has Any $.stddev;
        has Str $.description;
        has Any $.max;
    }
    class CouchDB::Statistics::HttpdStatusCodes::304 does JSON::Class {
        has Any $.current;
        has Any $.min;
        has Any $.sum;
        has Any $.mean;
        has Any $.stddev;
        has Str $.description;
        has Any $.max;
    }
    class CouchDB::Statistics::HttpdStatusCodes::202 does JSON::Class {
        has Any $.current;
        has Any $.min;
        has Any $.sum;
        has Any $.mean;
        has Any $.stddev;
        has Str $.description;
        has Any $.max;
    }
    class CouchDB::Statistics::HttpdStatusCodes::403 does JSON::Class {
        has Any $.current;
        has Any $.min;
        has Any $.sum;
        has Any $.mean;
        has Any $.stddev;
        has Str $.description;
        has Any $.max;
    }
    class CouchDB::Statistics::HttpdStatusCodes::301 does JSON::Class {
        has Any $.current;
        has Any $.min;
        has Any $.sum;
        has Any $.mean;
        has Any $.stddev;
        has Str $.description;
        has Any $.max;
    }
    class CouchDB::Statistics::HttpdStatusCodes::404 does JSON::Class {
        has Any $.current;
        has Any $.min;
        has Any $.sum;
        has Any $.mean;
        has Any $.stddev;
        has Str $.description;
        has Any $.max;
    }
    class CouchDB::Statistics::HttpdStatusCodes::200 does JSON::Class {
        has Rat $.current;
        has Int $.min;
        has Rat $.sum;
        has Rat $.mean;
        has Rat $.stddev;
        has Str $.description;
        has Int $.max;
    }
    class CouchDB::Statistics::HttpdStatusCodes::500 does JSON::Class {
        has Rat $.current;
        has Int $.min;
        has Rat $.sum;
        has Rat $.mean;
        has Rat $.stddev;
        has Str $.description;
        has Int $.max;
    }
    class CouchDB::Statistics::HttpdStatusCodes::412 does JSON::Class {
        has Any $.current;
        has Any $.min;
        has Any $.sum;
        has Any $.mean;
        has Any $.stddev;
        has Str $.description;
        has Any $.max;
    }
    class CouchDB::Statistics::HttpdStatusCodes::400 does JSON::Class {
        has Rat $.current;
        has Int $.min;
        has Rat $.sum;
        has Rat $.mean;
        has Rat $.stddev;
        has Str $.description;
        has Int $.max;
    }
    class CouchDB::Statistics::HttpdStatusCodes::405 does JSON::Class {
        has Any $.current;
        has Any $.min;
        has Any $.sum;
        has Any $.mean;
        has Any $.stddev;
        has Str $.description;
        has Any $.max;
    }
    class CouchDB::Statistics::HttpdStatusCodes::409 does JSON::Class {
        has Any $.current;
        has Any $.min;
        has Any $.sum;
        has Any $.mean;
        has Any $.stddev;
        has Str $.description;
        has Any $.max;
    }
    class CouchDB::Statistics::HttpdStatusCodes::401 does JSON::Class {
        has Any $.current;
        has Any $.min;
        has Any $.sum;
        has Any $.mean;
        has Any $.stddev;
        has Str $.description;
        has Any $.max;
    }
    class CouchDB::Statistics::HttpdStatusCodes does JSON::Class {
        class CouchDB::Statistics::HttpdStatusCodes::201 does JSON::Class {
            has Any $.current;
            has Any $.min;
            has Any $.sum;
            has Any $.mean;
            has Any $.stddev;
            has Str $.description;
            has Any $.max;
        }
        class CouchDB::Statistics::HttpdStatusCodes::304 does JSON::Class {
            has Any $.current;
            has Any $.min;
            has Any $.sum;
            has Any $.mean;
            has Any $.stddev;
            has Str $.description;
            has Any $.max;
        }
        class CouchDB::Statistics::HttpdStatusCodes::202 does JSON::Class {
            has Any $.current;
            has Any $.min;
            has Any $.sum;
            has Any $.mean;
            has Any $.stddev;
            has Str $.description;
            has Any $.max;
        }
        class CouchDB::Statistics::HttpdStatusCodes::403 does JSON::Class {
            has Any $.current;
            has Any $.min;
            has Any $.sum;
            has Any $.mean;
            has Any $.stddev;
            has Str $.description;
            has Any $.max;
        }
        class CouchDB::Statistics::HttpdStatusCodes::301 does JSON::Class {
            has Any $.current;
            has Any $.min;
            has Any $.sum;
            has Any $.mean;
            has Any $.stddev;
            has Str $.description;
            has Any $.max;
        }
        class CouchDB::Statistics::HttpdStatusCodes::404 does JSON::Class {
            has Any $.current;
            has Any $.min;
            has Any $.sum;
            has Any $.mean;
            has Any $.stddev;
            has Str $.description;
            has Any $.max;
        }
        class CouchDB::Statistics::HttpdStatusCodes::200 does JSON::Class {
            has Rat $.current;
            has Int $.min;
            has Rat $.sum;
            has Rat $.mean;
            has Rat $.stddev;
            has Str $.description;
            has Int $.max;
        }
        class CouchDB::Statistics::HttpdStatusCodes::500 does JSON::Class {
            has Rat $.current;
            has Int $.min;
            has Rat $.sum;
            has Rat $.mean;
            has Rat $.stddev;
            has Str $.description;
            has Int $.max;
        }
        class CouchDB::Statistics::HttpdStatusCodes::412 does JSON::Class {
            has Any $.current;
            has Any $.min;
            has Any $.sum;
            has Any $.mean;
            has Any $.stddev;
            has Str $.description;
            has Any $.max;
        }
        class CouchDB::Statistics::HttpdStatusCodes::400 does JSON::Class {
            has Rat $.current;
            has Int $.min;
            has Rat $.sum;
            has Rat $.mean;
            has Rat $.stddev;
            has Str $.description;
            has Int $.max;
        }
        class CouchDB::Statistics::HttpdStatusCodes::405 does JSON::Class {
            has Any $.current;
            has Any $.min;
            has Any $.sum;
            has Any $.mean;
            has Any $.stddev;
            has Str $.description;
            has Any $.max;
        }
        class CouchDB::Statistics::HttpdStatusCodes::409 does JSON::Class {
            has Any $.current;
            has Any $.min;
            has Any $.sum;
            has Any $.mean;
            has Any $.stddev;
            has Str $.description;
            has Any $.max;
        }
        class CouchDB::Statistics::HttpdStatusCodes::401 does JSON::Class {
            has Any $.current;
            has Any $.min;
            has Any $.sum;
            has Any $.mean;
            has Any $.stddev;
            has Str $.description;
            has Any $.max;
        }
        has CouchDB::Statistics::HttpdStatusCodes::201 $.httpdstatuscodes201 is json-name('201');
        has CouchDB::Statistics::HttpdStatusCodes::403 $.httpdstatuscodes403 is json-name('403');
        has CouchDB::Statistics::HttpdStatusCodes::202 $.httpdstatuscodes202 is json-name('202');
        has CouchDB::Statistics::HttpdStatusCodes::304 $.httpdstatuscodes304 is json-name('304');
        has CouchDB::Statistics::HttpdStatusCodes::301 $.httpdstatuscodes301 is json-name('301');
        has CouchDB::Statistics::HttpdStatusCodes::200 $.httpdstatuscodes200 is json-name('200');
        has CouchDB::Statistics::HttpdStatusCodes::404 $.httpdstatuscodes404 is json-name('404');
        has CouchDB::Statistics::HttpdStatusCodes::500 $.httpdstatuscodes500 is json-name('500');
        has CouchDB::Statistics::HttpdStatusCodes::401 $.httpdstatuscodes401 is json-name('401');
        has CouchDB::Statistics::HttpdStatusCodes::409 $.httpdstatuscodes409 is json-name('409');
        has CouchDB::Statistics::HttpdStatusCodes::405 $.httpdstatuscodes405 is json-name('405');
        has CouchDB::Statistics::HttpdStatusCodes::400 $.httpdstatuscodes400 is json-name('400');
        has CouchDB::Statistics::HttpdStatusCodes::412 $.httpdstatuscodes412 is json-name('412');
    }
    has CouchDB::Statistics::HttpdRequestMethods $.httpd_request_methods;
    has CouchDB::Statistics::Couchdb $.couchdb;
    has CouchDB::Statistics::Httpd $.httpd;
    has CouchDB::Statistics::HttpdStatusCodes $.httpd_status_codes;
}
# vim: expandtab shiftwidth=4 ft=perl6
