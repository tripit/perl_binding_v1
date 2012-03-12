#
# Copyright 2008-2012 Concur Technologies, Inc.
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

package TripIt::API;
use strict;

use TripIt::OAuthCredential;

use URI;
use LWP::UserAgent;
use HTTP::Request::Common;
use XML::Simple;

use constant API_VERSION => 'v1';

sub new {
    my $class = shift;
    
    my $credential = shift;
    my $api_url = shift || 'https://api.tripit.com';
    
    my $self = {
        credential => $credential,
        api_url => $api_url
    };
    
    bless($self, $class);
    return $self;
}

sub credential {
    my $self = shift;
    return $self->{credential};
}

sub get_request_token {
    my $self = shift;
    my $request_token = _parse_query_string($self->_do_request('/oauth/request_token'));
    return $self->{credential} = TripIt::OAuthCredential->new(
        $self->{credential}->consumer_key(),
        $self->{credential}->consumer_secret(),
        $request_token->{oauth_token},
        $request_token->{oauth_token_secret}
    ); 
}

sub get_access_token {
    my $self = shift;
    my $request_token = _parse_query_string($self->_do_request('/oauth/access_token'));
    return $self->{credential} = TripIt::OAuthCredential->new(
        $self->{credential}->consumer_key(),
        $self->{credential}->consumer_secret(),
        $request_token->{oauth_token},
        $request_token->{oauth_token_secret}
    ); 
}

sub get_trip {
    my $self = shift;
    my $id = shift;
    my $filter = shift;
    if (!defined $filter) {
        $filter = {};
    }
    $filter->{id} = $id;
    return $self->_do_request('get', 'trip', $filter);
}

sub get_air {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('get', 'air', {'id' => $id});
}

sub get_lodging {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('get', 'lodging', {'id' => $id});
}

sub get_car {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('get', 'car', {'id' => $id});
}

sub get_profile {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('get', 'profile', {'id' => $id});
}

sub get_rail {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('get', 'rail', {'id' => $id});
}

sub get_transport {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('get', 'transport', {'id' => $id});
}

sub get_cruise {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('get', 'cruise', {'id' => $id});
}

sub get_restaurant {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('get', 'restaurant', {'id' => $id});
}

sub get_activity {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('get', 'activity', {'id' => $id});
}

sub get_note {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('get', 'note', {'id' => $id});
}

sub get_map {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('get', 'map', {'id' => $id});
}

sub get_directions {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('get', 'directions', {'id' => $id});
}

sub get_points_program {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('get', 'points_program', {'id' => $id});
}

sub delete_trip {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('delete', 'trip', {'id' => $id});
}

sub delete_air {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('delete', 'air', {'id' => $id});
}

sub delete_lodging {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('delete', 'lodging', {'id' => $id});
}

sub delete_car {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('delete', 'car', {'id' => $id});
}

sub delete_profile {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('delete', 'profile', {'id' => $id});
}

sub delete_rail {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('delete', 'rail', {'id' => $id});
}

sub delete_transport {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('delete', 'transport', {'id' => $id});
}

sub delete_cruise {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('delete', 'cruise', {'id' => $id});
}

sub delete_restaurant {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('delete', 'restaurant', {'id' => $id});
}

sub delete_activity {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('delete', 'activity', {'id' => $id});
}

sub delete_note {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('delete', 'note', {'id' => $id});
}

sub delete_map {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('delete', 'map', {'id' => $id});
}

sub delete_directions {
    my $self = shift;
    my $id = shift;
    return $self->_do_request('delete', 'directions', {id => $id});
}

sub replace_trip {
    my $self = shift;
    my $id = shift;
    my $xml = shift;
    return $self->_do_request('replace', 'trip', undef, {'id' => $id, 'xml' => $xml});
}

sub replace_air {
    my $self = shift;
    my $id = shift;
    my $xml = shift;
    return $self->_do_request('replace', 'air', undef, {'id' => $id, 'xml' => $xml});
}

sub replace_lodging {
    my $self = shift;
    my $id = shift;
    my $xml = shift;
    return $self->_do_request('replace', 'lodging', undef, {'id' => $id, 'xml' => $xml});
}

sub replace_car {
    my $self = shift;
    my $id = shift;
    my $xml = shift;
    return $self->_do_request('replace', 'car', undef, {'id' => $id, 'xml' => $xml});
}

sub replace_profile {
    my $self = shift;
    my $id = shift;
    my $xml = shift;
    return $self->_do_request('replace', 'profile', undef, {'id' => $id, 'xml' => $xml});
}

sub replace_rail {
    my $self = shift;
    my $id = shift;
    my $xml = shift;
    return $self->_do_request('replace', 'rail', undef, {'id' => $id, 'xml' => $xml});
}

sub replace_transport {
    my $self = shift;
    my $id = shift;
    my $xml = shift;
    return $self->_do_request('replace', 'transport', undef, {'id' => $id, 'xml' => $xml});
}

sub replace_cruise {
    my $self = shift;
    my $id = shift;
    my $xml = shift;
    return $self->_do_request('replace', 'cruise', undef, {'id' => $id, 'xml' => $xml});
}

sub replace_restaurant {
    my $self = shift;
    my $id = shift;
    my $xml = shift;
    return $self->_do_request('replace', 'restaurant', undef, {'id' => $id, 'xml' => $xml});
}

sub replace_activity {
    my $self = shift;
    my $id = shift;
    my $xml = shift;
    return $self->_do_request('replace', 'activity', undef, {'id' => $id, 'xml' => $xml});
}

sub replace_note {
    my $self = shift;
    my $id = shift;
    my $xml = shift;
    return $self->_do_request('replace', 'note', undef, {'id' => $id});
}

sub replace_map {
    my $self = shift;
    my $id = shift;
    my $xml = shift;
    return $self->_do_request('replace', 'map', undef, {'id' => $id, 'xml' => $xml});
}

sub list_trip {
    my $self = shift;
    my $filter = shift;
    return $self->_do_request('list', 'trip', $filter);
}

sub list_object {
    my $self = shift;
    my $filter = shift;
    return $self->_do_request('list', 'object', $filter);
}

sub list_points_program {
    my $self = shift;
    return $self->_do_request('list', 'points_program', undef);
}

sub create {
    my $self = shift;
    my $xml = shift;
    return $self->_do_request('create', undef, undef, {xml => $xml});
}

sub crs_load_reservations {
    my $self = shift;
    my $xml = shift;
    my $company_key = shift;
    
    my $args = {xml => $xml};
    
    if (defined $company_key) {
        $args->{company_key} = $company_key;
    }
    
    return $self->_do_request('crsLoadReservations', undef, undef, $args);
}

sub crs_delete_reservations {
    my $self = shift;
    my $record_locator = shift;
    
    return $self->_do_request('crsDeleteReservations', undef, {record_locator => $record_locator}, undef);
}

sub _do_request {
    my $self = shift;
    my $verb = shift;
    my $entity = shift;
    my $url_args = shift;
    my $post_args = shift;
    
    my $should_parse_xml = 1;
    my $url = URI->new($self->{api_url});
    
    my $base_url;
    
    if (($verb eq '/oauth/request_token') ||
        ($verb eq '/oauth/access_token'))
    {
        $should_parse_xml = 0;
        $url->path($verb);
    }
    else {
        if (defined $entity) {
            $url->path('/' . API_VERSION . '/' . $verb . '/' . $entity); 
        }
        else {
            $url->path('/' . API_VERSION . '/' . $verb);
        }
    }
    
    my $args;
    if (defined $url_args) {
        $args = $url_args;
        $url->query_form($url_args);
    }
    
    my $request;
    if (defined $post_args) {
        $args = $post_args;
        $request = POST $url, $post_args;
    }
    else {
        $request = GET $url;
    }
    
    $self->{credential}->authorize($request, $args);
    
    my $ua = LWP::UserAgent->new();
    my $response = $ua->request($request);
    
    if ($response->code() == 200) {
        if ($should_parse_xml) {
            return XML::Simple->new(ForceArray => 1)->XMLin($response->content());
        } else {
            return $response->content();
        }
    } else {
        die $response->message();
    }
}

sub _parse_query_string {
    my $str = shift;
    my $params = {};
    foreach my $pair (split('&', $str)) {
        (my $k, my $v) = split('=', $pair, 2);
        $params->{$k} = $v;
    }
    return $params;
}

1;
