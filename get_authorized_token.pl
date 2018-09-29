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

if ($#ARGV < 4) {
    print "Usage: get_authorized_token.pl api_url consumer_key consumer_secret request_token request_token_secret\n";
    exit(1);
}

my $api_url = $ARGV[0];
my $consumer_key = $ARGV[1];
my $consumer_secret = $ARGV[2];
my $request_token = $ARGV[3];
my $request_token_secret = $ARGV[4];

my $oauth_credential = TripIt::OAuthCredential->new($consumer_key, $consumer_secret, $request_token, $request_token_secret);
my $t = TripIt::API->new($oauth_credential, $api_url);
my $cred = $t->get_access_token();

print "Authorized token: " . $cred->token() . "\nToken secret:     " . $cred->token_secret() . "\n";
