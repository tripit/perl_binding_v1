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

package TripIt::OAuthCredential;
use strict;

use URI;
use Digest::HMAC_SHA1 qw(hmac_sha1);
use Digest::MD5 qw(md5_hex);
use MIME::Base64;

use constant OAUTH_SIGNATURE_METHOD => 'HMAC-SHA1';
use constant OAUTH_VERSION => '1.0';

sub new {
    my $class = shift;
    
    my $self = {
        consumer_key => shift,
        consumer_secret => shift,
        token => shift || '',
        token_secret => shift || '',
        requestor_id => ''
    };
    
    if ($self->{token} ne '' && $self->{token_secret} eq '') {
        $self->{requestor_id} = $self->{token};
        $self->{token} = '';
    }
    
    bless($self, $class);
    return $self;
}

sub consumer_key {
    my $self = shift;
    return $self->{consumer_key};
}

sub consumer_secret {
    my $self = shift;
    return $self->{consumer_secret};
}

sub token {
    my $self = shift;
    return $self->{token};
}

sub token_secret {
    my $self = shift;
    return $self->{token_secret};
}

sub requestor_id {
    my $self = shift;
    return $self->{requestor_id};
}

sub authorize {
    my $self = shift;
    my $request = shift;
    my $args = shift;
    
    $request->header('Authorization' =>
        $self->_generate_authorization_header(
            $request->method(), $request->uri(), $args));
}

sub validate_signature {
    my $self = shift;
    my $url = shift;
    
    my %params = $url->query_form;
    $url->query("");
    chop $url;
    
    my $signature = $params{'oauth_signature'};
    
    return ($signature eq $self->_generate_signature("GET", $url, \%params)); 
}

sub get_session_parameters {
    my $self = shift;
    my $redirect_url = shift;
    my $action = shift;
    
    my $params = $self->_generate_oauth_parameters('GET', $action, {'redirect_url' => $redirect_url});
    $params->{redirect_url} = $redirect_url;
    $params->{action} = $action;
    my @result = ();
    while ((my $k, my $v) = each %$params) {
        push(@result, '"' . _jsonencode($k) . '": "' . _jsonencode($v) . '"');
    }
    return '{' . join(',', @result) . '}';
}

sub _generate_authorization_header {
    my $self = shift;
    my $http_method = shift;
    my $url = shift;
    my $args = shift;
    
    my $realm = URI->new($url->scheme() . '://' . $url->host() . ':' .
        $url->port())->canonical();
    my $base_url = URI->new($url->scheme() . '://' . $url->host() . ':' .
        $url->port() . $url->path())->canonical();
    
    my $oauth_params = $self->_generate_oauth_parameters(
        $http_method, $base_url, $args);
    my @result = ();
    while ((my $k, my $v) = each %$oauth_params) {
        push(@result, _urlencode($k) . '="' . _urlencode($v) . '"');
    }
    return 'OAuth realm="' . $realm . '",' . join(',', @result);
}

sub _generate_oauth_parameters {
    my $self = shift;
    my $http_method = uc(shift);
    my $base_url = shift;
    my $args = shift;
    
    my $oauth_parameters = {
        oauth_consumer_key => $self->{consumer_key},
        oauth_nonce => _generate_nonce(),
        oauth_timestamp => time(),
        oauth_signature_method => OAUTH_SIGNATURE_METHOD,
        oauth_version => OAUTH_VERSION
    };
    
    if ($self->{token} ne '') {
        $oauth_parameters->{oauth_token} = $self->{token};
    }
    if ($self->{requestor_id} ne '') {
        $oauth_parameters->{xoauth_requestor_id} = $self->{requestor_id};
    }
    
    my $oauth_parameters_for_base_string = {%{$oauth_parameters}};
    if (defined $args) {
        while ((my $k, my $v) = each %$args) {
            $oauth_parameters_for_base_string->{$k} = $v;
        }
    }
    
    $oauth_parameters->{oauth_signature} = $self->_generate_signature($http_method, $base_url, $oauth_parameters_for_base_string);
    
    return $oauth_parameters;
}

sub _generate_signature {
    my $self = shift;
    my $method = shift;
    my $base_url = _urlencode(shift);
    my $params = shift;
    
    delete $params->{oauth_signature};
    
    my @parameters;
    foreach my $key (sort(keys(%{$params}))) {
        push(@parameters, _urlencode($key) . '=' .
            _urlencode($params->{$key}));
    }
    my $parameters = _urlencode(join('&', @parameters));
    
    my $signature_base_string = $method . '&' .
        $base_url . '&' . $parameters;
    
    my $key = $self->{consumer_secret} . '&' . $self->{token_secret};
    
    my $signature = encode_base64(hmac_sha1($signature_base_string, $key));
    chomp $signature;
    return $signature;
}

sub _generate_nonce {
    my $random_number = '';
    for (my $i=0; $i < 40; ++$i) {
        $random_number .= (0..9)[rand 10];
    }
    return md5_hex($random_number);
}

sub _urlencode {
    my $str = shift;
    $str =~ s/([^a-zA-Z0-9_\.\-\~])/sprintf('%%%02X', ord($1))/eg;
    return $str;
}

sub _jsonencode {
    my $str = shift;
    my $result = "";
    my $char;
    foreach $char (split(//, $str)) {
        if ($char eq '"') {
            $result .= '\\"';
        } elsif ($char eq '\\') {
            $result .= '\\\\';
        } elsif ($char eq "\b") {
            $result .= '\b';
        } elsif ($char eq "\f") {
            $result .= '\f';
        } elsif ($char eq "\n") {
            $result .= '\n';
        } elsif ($char eq "\r") {
            $result .= '\r';
        } elsif ($char eq "\t") {
            $result .= '\t';
        } else {
            $result .= $char;
        }
    }
    return $result;
}

1;
