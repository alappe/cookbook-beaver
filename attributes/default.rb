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
  'version' => '31',
  'user' => 'root',
  'group' => 'root',
  'log_path' => '/var/log',
  'log_file' => 'beaver.log',
  'pid_file' => '/var/run/beaver.pid',
  'generate_keypair' => false,
  'ssh_key_file' => 'logger',
  'use_virtualenv' => false,
  'virtualenv_path' => '/opt/beaver',
  'config_path' => '/etc/beaver',
  'config_file' => 'beaver.conf',
  'configuration' => {
    'confd_path' => '/etc/beaver/conf.d',
    'logstash_version' => 1,
    'respawn_delay' => 3,
    'max_failure' => 7
  },
  'files' => [],
  'default_tail_format' => 'json_event'
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
else
  default['beaver']['files'] = [
    {
      'path' => '/var/log/*log',
      'type' => 'syslog',
      'tags' => 'syslog',
      'exclude' => 'beaver\.log'
    }
  ]
end

# Beaver only supports Python 2 at present.
default['poise-python']['beaver']['provider'] = 'system'
default['poise-python']['beaver']['version'] = '2'
