use JSON::Class;
use JSON::Name;
class CouchDB::Config does JSON::Class {
    class CouchDB::Config::Log does JSON::Class {
        has Str $.file;
        has Str $.include_sasl;
        has Str $.level;
    }
    class CouchDB::Config::Cors does JSON::Class {
        has Str $.credentials;
    }
    class CouchDB::Config::CouchHttpdAuth does JSON::Class {
        has Str $.require_valid_user;
        has Str $.allow_persistent_cookies;
        has Str $.auth_cache_size;
        has Str $.authentication_db;
        has Str $.timeout;
        has Str $.iterations;
        has Str $.authentication_redirect;
    }
    class CouchDB::Config::Daemons does JSON::Class {
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
    class CouchDB::Config::Ssl does JSON::Class {
        has Str $.port;
        has Str $.verify_ssl_certificates;
        has Str $.ssl_certificate_max_depth;
    }
    class CouchDB::Config::HttpdDesignHandlers does JSON::Class {
        has Str $._compact;
        has Str $._show;
        has Str $._info;
        has Str $._list;
        has Str $._view;
        has Str $._update;
        has Str $._rewrite;
    }
    class CouchDB::Config::ViewCompaction does JSON::Class {
        has Str $.keyvalue_buffer_size;
    }
    class CouchDB::Config::Attachments does JSON::Class {
        has Str $.compressible_types;
        has Str $.compression_level;
    }
    class CouchDB::Config::QueryServers does JSON::Class {
        has Str $.javascript;
        has Str $.coffeescript;
    }
    class CouchDB::Config::QueryServerConfig does JSON::Class {
        has Str $.os_process_limit;
        has Str $.reduce_limit;
    }
    class CouchDB::Config::Stats does JSON::Class {
        has Str $.samples;
        has Str $.rate;
    }
    class CouchDB::Config::Couchdb does JSON::Class {
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
    class CouchDB::Config::DatabaseCompaction does JSON::Class {
        has Str $.checkpoint_after;
        has Str $.doc_buffer_size;
    }
    class CouchDB::Config::Httpd does JSON::Class {
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
    class CouchDB::Config::CouchHttpdOauth does JSON::Class {
        has Str $.use_users_db;
    }
    class CouchDB::Config::Replicator does JSON::Class {
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
    class CouchDB::Config::HttpdGlobalHandlers does JSON::Class {
        has Str $._active_tasks;
        has Str $._replicate;
        has Str $._db_updates;
        has Str $._stats;
        has Str $._all_dbs;
        has Str $._config;
        has Str $._restart;
        has Str $._log;
        has Str $._uuids;
        has Str $.httpdglobalhandlersfavicon.ico is json-name('favicon.ico');
        has Str $._oauth;
        has Str $.httpdglobalhandlers/ is json-name('/');
        has Str $._plugins;
        has Str $._session;
        has Str $._utils;
    }
    class CouchDB::Config::Uuids does JSON::Class {
        has Str $.max_count;
        has Str $.algorithm;
    }
    class CouchDB::Config::CompactionDaemon does JSON::Class {
        has Str $.check_interval;
        has Str $.min_file_size;
    }
    class CouchDB::Config::HttpdDbHandlers does JSON::Class {
        has Str $._all_docs;
        has Str $._compact;
        has Str $._design;
        has Str $._changes;
        has Str $._temp_view;
        has Str $._view_cleanup;
    }
    class CouchDB::Config::Vendor does JSON::Class {
        has Str $.name;
        has Str $.version;
    }
    has CouchDB::Config::Cors $.cors;
    has CouchDB::Config::Log $.log;
    has CouchDB::Config::HttpdDesignHandlers $.httpd_design_handlers;
    has CouchDB::Config::Ssl $.ssl;
    has CouchDB::Config::Daemons $.daemons;
    has CouchDB::Config::CouchHttpdAuth $.couch_httpd_auth;
    has CouchDB::Config::Attachments $.attachments;
    has CouchDB::Config::ViewCompaction $.view_compaction;
    has CouchDB::Config::Stats $.stats;
    has CouchDB::Config::QueryServerConfig $.query_server_config;
    has CouchDB::Config::QueryServers $.query_servers;
    has CouchDB::Config::HttpdGlobalHandlers $.httpd_global_handlers;
    has CouchDB::Config::Replicator $.replicator;
    has CouchDB::Config::CouchHttpdOauth $.couch_httpd_oauth;
    has CouchDB::Config::Httpd $.httpd;
    has CouchDB::Config::DatabaseCompaction $.database_compaction;
    has CouchDB::Config::Couchdb $.couchdb;
    has CouchDB::Config::Uuids $.uuids;
    has CouchDB::Config::Vendor $.vendor;
    has CouchDB::Config::HttpdDbHandlers $.httpd_db_handlers;
    has CouchDB::Config::CompactionDaemon $.compaction_daemon;
}
# vim: expandtab shiftwidth=4 ft=perl6
