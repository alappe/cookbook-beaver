#
# Cookbook Name:: beaver
# Recipe:: default
#
# Copyright 2013, kaeufli.ch
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

default['beaver'] = {
  'version' => '29',
  'log_path' => '/var/log',
  'log_file' => 'beaver.log',
  'config_path' => '/etc/beaver',
  'config_file' => 'beaver.conf',
  'respawn_delay' => 3,
  'max_failure' => 7,
  'sincedb_path' => '/tmp/beaver.db',
  'transport' => 'redis',
  'format' => 'json',
  'redis' => {
    'url' => 'redis://127.0.0.1:6379/0',
    'namespace' => 'logstash:beaver'
  },
  'mqtt' => {
    'host' => 'localhost',
    'port' => 1883,
    'clientid' => 'mosquitto',
    'keepalive' => 60,
    'topic' => '/logstash'
  },
  'rabbitmq' => {
    'host' => 'localhost',
    'port' => 5672,
    'vhost' => '/',
    'username' => 'guest',
    'password' => 'guest',
    'queue' => 'logstash-queue',
    'exchange_type' => 'direct',
    'exchange_durable' => 0,
    'key' => 'logstash-key',
    'exchange' => 'logstash-exchange'
  },
  'sqs_aws' => {
    'access_key' => '',
    'secret_key' => '',
    'region' => 'us-east-1',
    'queue' => ''
  },
  'udp' => {
    'host' => '127.0.0.1',
    'port' => 9999
  },
  'zeromq' => {
    'address' => 'tcp://localhost:2120',
    'hwm' => '',
    'bind' => 'bind'
  },
  'use_tunnel' => false,
  'ssh' => {
    'tunnel' => nil,
    'key_file' => 'id_rsa',
    'tunnel_port' => 6379,
    'remote_host' => '127.0.0.1',
    'remote_port' => 6379,
    'generate_keypair' => false
  },
  'files' => []
}

if node['platform_family'] == 'debian'
  default['beaver']['files'] = [
    {
      'path' => '/var/log/syslog',
      'type' => 'syslog',
      'tags' => 'sys,syslog'
    }, {
      'path' => '/var/log/auth.log',
      'type' => 'syslog',
      'tags' => 'auth'
    }
  ]
end
