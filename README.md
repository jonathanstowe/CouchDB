# Sofa

Perl 6 interface for CouchDB

[![Build Status](https://travis-ci.org/jonathanstowe/Sofa.svg?branch=master)](https://travis-ci.org/jonathanstowe/Sofa)

## Synopsis

```

use Sofa;

# use the default of port 5984 on localhost

my $sofa = Sofa.new; 

my $db = $sofa.create-database('test-db');

my $doc-info = $db.create-document({ foo => "bar });

...

$db.delete-document($doc-info);

$db.delete;

```

## Description

This provides access to [CouchDB](http://couchdb.apache.org/) and allows
the creation, retrieval, update and deletion of documents within a
database. Creation, retrieval, update and deletion of couchdb design
documents and the use of the views, lists, shows and updates in them,
and the creation, retrieval, update and deletion of attachments on both
normal and design documents.


