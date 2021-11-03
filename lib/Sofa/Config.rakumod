
use JSON::Name;
use JSON::Class:ver(v0.0.5+);

use Sofa::Item;

class Sofa::Config does JSON::Class is sofa-path('_config') {
    class Log does JSON::Class {
        has Str $.file;
        has Str $.include_sasl;
        has Str $.level;
    }
    class Cors does JSON::Class {
        has Str $.credentials;
    }
    class CouchHttpdAuth does JSON::Class {
        has Bool $.require-valid-user             is json-name('require_valid_user');
        has Bool $.allow-persistent-cookies       is json-name('allow_persistent_cookies');
        has Int  $.auth-cache-size                is json-name('auth_cache_size')           is unmarshalled-by({ Int($_) });
        has Str  $.authentication-db              is json-name('authentication_db');
        has Int  $.timeout                                                                  is unmarshalled-by({ Int($_) });
        has Int  $.iterations                                                               is unmarshalled-by({ Int($_) });
        has Str  $.authentication-redirect        is json-name('authentication_redirect');
    }
    class Daemons does JSON::Class {
        has Str $.auth_cache;
        has Str $.index_server;
        has Str $.stats_aggregator;
        has Str $.external_manager;
        has Str $.os_daemons;
        has Str $.query_servers;
        has Str $.stats_collector;
        has Str $.httpd;
        has Str $.replicator_manager;
        has Str $.uuids;
        has Str $.compaction_daemon;
        has Str $.vhosts;
    }
    class Ssl does JSON::Class {
        has Str $.port;
        has Str $.verify_ssl_certificates;
        has Str $.ssl_certificate_max_depth;
    }
    class HttpdDesignHandlers does JSON::Class {
        has Str $._compact;
        has Str $._show;
        has Str $._info;
        has Str $._list;
        has Str $._view;
        has Str $._update;
        has Str $._rewrite;
    }
    class ViewCompaction does JSON::Class {
        has Str $.keyvalue_buffer_size;
    }
    class Attachments does JSON::Class {
        has Str $.compressible_types;
        has Str $.compression_level;
    }
    class QueryServers does JSON::Class {
        has Str $.javascript;
        has Str $.coffeescript;
    }
    class QueryServerConfig does JSON::Class {
        has Str $.os_process_limit;
        has Str $.reduce_limit;
    }
    class Stats does JSON::Class {
        has Str $.samples;
        has Str $.rate;
    }
    class Couchdb does JSON::Class {
        has Str $.plugin_dir;
        has Str $.uuid;
        has Str $.max_document_size;
        has Str $.attachment_stream_buffer_size;
        has Str $.file_compression;
        has Str $.uri_file;
        has Str $.util_driver_dir;
        has Str $.database_dir;
        has Str $.max_dbs_open;
        has Str $.delayed_commits;
        has Str $.os_process_timeout;
        has Str $.view_index_dir;
    }
    class DatabaseCompaction does JSON::Class {
        has Str $.checkpoint_after;
        has Str $.doc_buffer_size;
    }
    class Httpd does JSON::Class {
        has Str $.bind_address;
        has Str $.port;
        has Str $.enable_cors;
        has Str $.authentication_handlers;
        has Str $.default_handler;
        has Str $.secure_rewrites;
        has Str $.socket_options;
        has Str $.vhost_global_handlers;
        has Str $.log_max_chunk_size;
        has Str $.allow_jsonp;
    }
    class CouchHttpdOauth does JSON::Class {
        has Str $.use_users_db;
    }
    class Replicator does JSON::Class {
        has Str $.max_replication_retry_count;
        has Str $.worker_batch_size;
        has Str $.verify_ssl_certificates;
        has Str $.retries_per_request;
        has Str $.ssl_certificate_max_depth;
        has Str $.worker_processes;
        has Str $.db;
        has Str $.socket_options;
        has Str $.http_connections;
        has Str $.connection_timeout;
    }
    class HttpdGlobalHandlers does JSON::Class {
        has Str $._active_tasks;
        has Str $._replicate;
        has Str $._db_updates;
        has Str $._stats;
        has Str $._all_dbs;
        has Str $._config;
        has Str $._restart;
        has Str $._log;
        has Str $._uuids;
        has Str $.favicon is json-name('favicon.ico');
        has Str $._oauth;
        has Str $.root is json-name('/');
        has Str $._plugins;
        has Str $._session;
        has Str $._utils;
    }
    class Uuids does JSON::Class {
        has Str $.max_count;
        has Str $.algorithm;
    }
    class CompactionDaemon does JSON::Class {
        has Str $.check_interval;
        has Str $.min_file_size;
    }
    class HttpdDbHandlers does JSON::Class {
        has Str $._all_docs;
        has Str $._compact;
        has Str $._design;
        has Str $._changes;
        has Str $._temp_view;
        has Str $._view_cleanup;
    }
    class Vendor does JSON::Class {
        has Str $.name;
        has Str $.version;
    }
    has Cors $.cors;
    has Log $.log;
    has HttpdDesignHandlers $.httpd_design_handlers;
    has Ssl $.ssl;
    has Daemons $.daemons;
    has CouchHttpdAuth $.couch-httpd-auth is json-name('couch_httpd_auth') handles *;
    has Attachments $.attachments;
    has ViewCompaction $.view_compaction;
    has Stats $.stats;
    has QueryServerConfig $.query_server_config;
    has QueryServers $.query_servers;
    has HttpdGlobalHandlers $.httpd_global_handlers;
    has Replicator $.replicator;
    has CouchHttpdOauth $.couch_httpd_oauth;
    has Httpd $.httpd;
    has DatabaseCompaction $.database_compaction;
    has Couchdb $.couchdb;
    has Uuids $.uuids;
    has Vendor $.vendor;
    has HttpdDbHandlers $.httpd_db_handlers;
    has CompactionDaemon $.compaction_daemon;
}
# vim: expandtab shiftwidth=4 ft=raku6
