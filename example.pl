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
use TripIt::WebAuthCredential;
use Data::Dumper;

if ($#ARGV < 4) {
    print "Usage: example.pl api_url consumer_key consumer_secret access_token access_token_secret\n";
    exit(1);
}
 
my $api_url = $ARGV[0];
my $oauth_consumer_key = $ARGV[1];
my $oauth_consumer_secret = $ARGV[2];
my $oauth_access_token = $ARGV[3];
my $oauth_access_token_secret = $ARGV[4];

# Create an OAuth Credential Object
my $oauth_cred = TripIt::OAuthCredential->new($oauth_consumer_key, $oauth_consumer_secret, $oauth_access_token, $oauth_access_token_secret);

# Create a new TripIt object
my $t = TripIt::API->new($oauth_cred, $api_url);

# Create a new trip
print("Create a new test trip to New York:\n");
my $xml="<Request><Trip><start_date>2009-12-17</start_date><end_date>2009-12-27</end_date><display_name>Test: New York, NY, December 2009</display_name><is_private>true</is_private><primary_location>New York, NY</primary_location></Trip></Request>";
my $r = $t->create($xml);
print(Dumper($r));

print("Get my list of travel objects in upcoming trips: \n");
$r = $t->list_trip();
print(Dumper($r));
# The first trip in the list
print(Dumper($r->{Trip}->[0]));
