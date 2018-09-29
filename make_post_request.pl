#!/usr/bin/env perl
#
# Copyright 2008-2018 Concur Technologies, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

use strict;

use TripIt::API;
use TripIt::OAuthCredential;
use Data::Dumper;

my $trip_xml = "<Request><Trip>" .
               "<start_date>2009-12-09</start_date>" .
               "<end_date>2009-12-27</end_date>" .
               "<primary_location>New York, NY</primary_location>" .
               "</Trip></Request>";
my $trip_xml2 = "<Request><Trip>" .
               "<start_date>2010-12-09</start_date>" .
               "<end_date>2010-12-27</end_date>" .
               "<primary_location>Boston, MA</primary_location>" .
               "</Trip></Request>";

if ($#ARGV < 4) {
    print "Usage: make_post_request.pl api_url consumer_key consumer_secret access_token access_token_secret\n";
    exit(1);
}

my $api_url = $ARGV[0];
my $consumer_key = $ARGV[1];
my $consumer_secret = $ARGV[2];
my $access_token = $ARGV[3];
my $access_token_secret = $ARGV[4];

my $oauth_credential = TripIt::OAuthCredential->new($consumer_key, $consumer_secret, $access_token, $access_token_secret);
my $t = TripIt::API->new($oauth_credential, $api_url);
my $r = $t->create($trip_xml);
print "RESPONSE: " . Dumper($r) . "\n";
my $id = $r->{Trip}->[0]->{id}->[0];
$r = $t->replace_trip($id, $trip_xml2);
print "\nRESPONSE: " . Dumper($r) . "\n";
