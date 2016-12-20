#!/usr/bin/env perl6

use v6.c;

use JSON::Fast;
use JSON::Class;
use Test;
plan 112;

use CheckSocket;

use Sofa;

my $port = %*ENV<COUCH_PORT> // 5984;
my $host = %*ENV<COUCH_HOST> // 'localhost';


my $username = %*ENV<COUCH_USERNAME>;
my $password = %*ENV<COUCH_PASSWORD>;

my %auth;

# clearly there is a chicken and egg situation with the basic authentican
# but it is completely unavoidable.
if $username.defined && $password.defined {
    %auth = (:$username, :$password, :basic-auth);
}

if !check-socket($port, $host) {
    plan 1;
    skip-rest "no couchdb available";
    exit;
}

my $sofa;

lives-ok { $sofa = Sofa.new(:$host, :$port, |%auth) }, "can create an object";

if $sofa.is-admin {
    my $name = ('a' .. 'z').pick(8).join('');
    my $db ;

    lives-ok { $db = $sofa.create-database($name) }, "create-database('$name')";

    class X::Foo is Exception {
    }

    throws-like { $db.get-design('contacts'); }, X::NoDocument, "get-design throws when it doesn't exist";

    throws-like { $db.put-design(Sofa::Design.new) }, X::NoIdOrName, "put-design throws when there is no name or id";

    my $doc;
    lives-ok { $doc = $db.put-design(Sofa::Design.new(name => 'contacts')) }, "put-design with name in object";
    is $doc.id, '_design/contacts', "and the id was populated properly";
    my $design;
    lives-ok { $design = $db.get-design('contacts') }, "get the new design document";
    isa-ok $design, Sofa::Design, "and we got one back";
    is $design.sofa-document-id, $doc.id, "and it has the right id";
    is $design.name, "contacts", "got the right name";
    is $design.sofa-document-revision, $doc.rev, "got the right revision";
    lives-ok { $db.delete-design($design) }, "delete that one";
    throws-like { $db.get-design('contacts') }, X::NoDocument, "get-design throws again as it doesn't exist";

    lives-ok { $doc = $db.put-design(Sofa::Design.new(),'contacts') }, "put-design with name as argument";
    is $doc.id, '_design/contacts', "and the id was populated properly";
    lives-ok { $design = $db.get-design('contacts'); }, "get the new design document";
    isa-ok $design, Sofa::Design, "and we got one back";
    is $design.sofa-document-id, $doc.id, "and it has the right id";
    is $design.name, "contacts", "got the right name";
    is $design.sofa-document-revision, $doc.rev, "got the right revision";
    lives-ok { $db.delete-design($doc) }, "delete that one (use the Sofa::Document)";
    throws-like { $db.get-design('contacts') }, X::NoDocument, "get-design throws again as it doesn't exist";

    my $data-dir = $*PROGRAM.parent.child('data');
    
    lives-ok { $design = Sofa::Design.from-json($data-dir.child('design-tests.json').slurp) }, "get our test design";
    lives-ok { $db.put-design($design) }, "and put that";

    class DesignTest does JSON::Class {
        has Str $.name;
        has Str $.some-data;
        has Int $.number;
        has Str %.req;
    }

    my @objects;

    for <one two three four five six> -> $name {
        my $dt = DesignTest.new(:$name, some-data => "$name data", number => $++ );
        $db.create-document($dt);
        @objects.append: $dt;
    }

    is $db.all-docs.elems, 7, "now have six documents ( and a design document)";

    my $view-data;

    lives-ok { $view-data = $db.get-view($design, 'by-name') ; }, "get-view";
    is $view-data.total_rows, 6, "got the six rows we expected";
    is $view-data.rows.elems, 6, "and there are six in the rows";

    # Makes it easier to check the rest
    my @rows = $view-data.rows;


    lives-ok { $view-data = $db.get-view($design, 'by-name', 'three') ; }, "get-view (with a single key)";
    is $view-data.total_rows, 6, "got the one row we expected";
    is $view-data.rows.elems, 1, "and there are one in the rows";
    is $view-data.rows[0].value<name>, 'three', "just check we got the row we wanted";
    is $view-data.rows[0].value<number>, 2, "right number";

    lives-ok { $view-data = $db.get-view($design, 'by-name', 'one', 'three') ; }, "get-view (with a single key)";
    is $view-data.total_rows, 6, "got the one row we expected";
    is $view-data.rows.elems, 2, "and there are one in the rows";
    is $view-data.rows[0].value<name>, 'one', "just check we got the row we wanted";
    is $view-data.rows[0].value<number>, 0, "right number";
    is $view-data.rows[1].value<name>, 'three', "just check we got the row we wanted";
    is $view-data.rows[1].value<number>, 2, "right number";

    lives-ok { $view-data = $db.get-view($design, 'by-name', limit => 2 ) ; }, "get-view (with limit => 2)";
    is $view-data.total_rows, 6, "got the total rows we expected";
    is $view-data.rows.elems, 2, "and there are two in the rows";

    for ^$view-data.rows.elems -> $i {
        is-deeply $view-data.rows[$i], @rows[$i], "check the row we expected (row[$i])";
    }

    lives-ok { $view-data = $db.get-view($design, 'by-name', limit => 2, skip => 2 ) ; }, "get-view (with limit => 2, skip => 2)";
    is $view-data.total_rows, 6, "got the total rows we expected";
    is $view-data.rows.elems, 2, "and there are two in the rows";

    for ^$view-data.rows.elems -> $i {
        is-deeply $view-data.rows[$i], @rows[$i + 2], "check the row we expected (row[{ $i + 2}])";
    }

    lives-ok { $view-data = $db.get-view($design, 'by-name', start-key => @rows[2].value<name>) ; }, "get-view (with start-key => {@rows[2].value<name>})";
    is $view-data.rows.elems, 4, "and there are four in the rows";

    for ^$view-data.rows.elems -> $i {
        is-deeply $view-data.rows[$i], @rows[$i + 2], "check the row we expected (row[{ $i + 2}])";
    }

    lives-ok { $view-data = $db.get-view($design, 'by-name', start-key => @rows[2].value<name>, end-key =>  @rows[3].value<name>) ; }, "get-view (with start-key => {@rows[2].value<name>}, end-key => {  @rows[3].value<name> })";

    is $view-data.rows.elems, 2, "and there are four in the rows";

    for ^$view-data.rows.elems -> $i {
        is-deeply $view-data.rows[$i], @rows[$i + 2], "check the row we expected (row[{ $i + 2}])";
    }


    lives-ok { $view-data = $db.get-view($design, 'by-name', :descending) }, "get-view(:descending)";
    my @new-rows = $view-data.rows;
    is-deeply @new-rows, @rows.reverse, "and it looks like it's the same (as anticipated)";


    lives-ok { $view-data = $db.get-view($design.name, 'by-name', :descending) }, "get-view by names (with descending to check we pass the args on)";
    @new-rows = $view-data.rows;
    is-deeply @new-rows, @rows.reverse, "and it looks like it's the same (as anticipated)";

    my $show-data;

    lives-ok { $show-data = $db.get-show($design, 'echo-request', foo => "bar", baz => "Boom"); }, "get-show() returning JSON with some query parameters to pass on with no document specified";
    is $show-data<query><foo>, "bar", "got back the param we sent";
    is $show-data<query><baz>, "Boom", "got back the other param we sent";
    nok $show-data<id>.defined, "and the id isn't defined because we didn't ask for a document";

    lives-ok { $show-data = $db.get-show($design, 'echo-request', @objects[1].sofa-document-id, foo => "bar", baz => "Boom"); }, "get-show() returning JSON with some query parameters to pass on";
    is $show-data<query><foo>, "bar", "got back the param we sent";
    is $show-data<query><baz>, "Boom", "got back the other param we sent";
    ok $show-data<id>.defined, "and the id is defined because we did ask for a document";
    is $show-data<id>, @objects[1].sofa-document-id, "and got back the document id";

    lives-ok { $show-data = $db.get-show($design.name, 'echo-request', foo => "bar", baz => "Boom"); }, "get-show() returning JSON with some query parameters to pass on with no document specified with named design";
    is $show-data<query><foo>, "bar", "got back the param we sent";
    is $show-data<query><baz>, "Boom", "got back the other param we sent";
    nok $show-data<id>.defined, "and the id isn't defined because we didn't ask for a document";

    lives-ok { $show-data = $db.get-show($design.name, 'echo-request', @objects[1].sofa-document-id, foo => "bar", baz => "Boom"); }, "get-show() returning JSON with some query parameters to pass on with named design";
    is $show-data<query><foo>, "bar", "got back the param we sent";
    is $show-data<query><baz>, "Boom", "got back the other param we sent";
    ok $show-data<id>.defined, "and the id is defined because we did ask for a document";
    is $show-data<id>, @objects[1].sofa-document-id, "and got back the document id";

    lives-ok { $show-data = $db.get-show($design, 'html-response'); }, "get-show with non-json data";
    like $show-data, /'Hello, World'/, "and it looks like we got what we expected";
    lives-ok { $show-data = $db.get-show($design.name, 'html-response'); }, "get-show with non-json data (but with a name for the design)";
    like $show-data, /'Hello, World'/, "and it looks like we got what we expected";

    my $list-data;
    lives-ok { $list-data = $db.get-list($design, 'list-names','by-name', something => 'other') }, "get list with our earlier view";
    is-deeply $list-data<names>, [@rows.map({$_.value<name> })], "and we got the view data back we expected";
    is $list-data<query><something>, 'other', "and the query parameter we passed in";

    lives-ok { $list-data = $db.get-list($design.name, 'list-names','by-name', something => 'other') }, "get list with our earlier view (design by name)";
    is-deeply $list-data<names>, [@rows.map({$_.value<name> })], "and we got the view data back we expected";
    is $list-data<query><something>, 'other', "and the query parameter we passed in";

    my $doc-count = $db.all-docs.elems;

    my $update-data;
    lives-ok { $update-data = $db.post-update($design, 'update-request', name => 'seven') }, "simple update with no document";
    is $update-data<what>, 'created', 'got created';
    is $update-data<req><query><name>, 'seven', "and we got the query we sent";

    lives-ok { $update-data = $db.post-update($design, 'update-request', $update-data<req><uuid>, name => 'banana') }, "simple update with the document we created";
    is $update-data<what>, 'updated', 'got updated';
    is $update-data<req><query><name>, 'banana', "and we got the query we sent";

    lives-ok { $update-data = $db.post-update($design, 'update-request', content => { something => 'else' }, name => 'eight') }, "simple update with no document and content";
    is $update-data<what>, 'created', 'got created';
    is $update-data<req><query><name>, 'eight', "and we got the query we sent";
    is from-json($update-data<req><body>)<something>, 'else', "and the body of the request has what we sent (the body is a string)";

    lives-ok { $update-data = $db.post-update($design, 'update-request', form => { something => 'else' }, name => 'nine') }, "simple update with no document and form data";
    is $update-data<what>, 'created', 'got created';
    is $update-data<req><query><name>, 'nine', "and we got the query we sent";
    is $update-data<req><form><something>, 'else', "and the form of the request has what we sent ";

    lives-ok { $update-data = $db.post-update($design.name, 'update-request', form => { something => 'else' }, name => 'ten') }, "simple update with no document and form data (with design name)";
    is $update-data<what>, 'created', 'got created';
    is $update-data<req><query><name>, 'ten', "and we got the query we sent";
    is $update-data<req><form><something>, 'else', "and the form of the request has what we sent ";


    is $db.all-docs.elems, $doc-count + 4, "and we added four documents";
    
    lives-ok { $db.delete }, "delete the database";
}
else {
    skip-rest "need admin to update design documents";
}

done-testing;

# vim: expandtab shiftwidth=4 ft=perl6
