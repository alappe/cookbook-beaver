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
  'generate_keypair' => false,
  'ssh_key_file' => 'logger',
  'config_path' => '/etc/beaver',
  'config_file' => 'beaver.conf',
  'configuration' => {
    'respawn_delay' => 3,
    'max_failure' => 7
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
