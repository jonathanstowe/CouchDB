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

## Installation

To test this properly you will need a couchdb instance that you have
administrative access to, though some tests can be performed without
access to a couchdb server at all about two thirds will be skipped.
For convenience it will default to attempting to using an instance
on the local host and default port (5984) without any admin controls,
but the connection and authentication information can be provided
through environment variables that should be set before running the
tests:

	* COUCH_PORT - set the port to connect to. Default is 5984
	* COUCH_HOST - the host to connect to. Default is 'localhost'
	* COUCH_USERNAME - the name of a configured admin user
	* COUCH_PASSWORD - the password of the above admin user

The tests need to have admin privileges because they need to create
databases and manipulate the design documents thereof which both require
the admin privileges.  None of the tests will manipulate an existing
database (except for the authentication database which it does to test
the creation of new users and the authentication of them.) Of course
you probably don't want to run the tests against a production server
anyway, but I can't check whether that is the case for you.

If you are testing with v2.0.0 or later of CouchDB you may have
needed to set the admin user and password as part of the setup of the
server, in which case you will need to set ```COUCH_USERNAME``` and
```COUCH_PASSWORD``` at minimum for the tests.

If you have a working Rakudo Perl 6 installation then you should be
able to install using *zef* (being sure to set the environment
variables described above as required:)

	zef install Sofa

Or if you have a local copy of the source code:

	zef install .

Though I haven't tested it, I don't see any reason why this shouldn't
also work with some equally capable installer such as "zef".

## Support

This module supports most of the common features that you may need
to create an application that uses CouchDB, but if you feel that
it omits something you really must have then please feel free to
suggest or even send a patch. I'd probably prefer any greater
degree of abstraction implemented in a separate module however.

The module should work with both v1.6.1 and v2.0.0 (or greater)
CouchDB servers though it currently doesn't properly support
some of the v2 specific features such as Mango queries and the
clustering API, and also the node specific ```statistics``` and
```config``` APIs.

Please send any suggestions/patches/feedback to
https://github.com/jonathanstowe/Sofa/issues.

## Licence and Copyright

This is free software, please see the [LICENCE](LICENCE) file for details.

© Jonathan Stowe 2015, 2016, 2017
