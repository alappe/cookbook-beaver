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

# Generate a ssh keypair and expose the public key on the node so that
# a central logging instance such as a logstash host can grant access.
# This allows for secure tunnelling of the logs to the log host.
private_key = "#{node['beaver']['config_path']}/#{node['beaver']['ssh_key_file']}"
execute 'Create a public key pair to access the central logging host' do
  command "ssh-keygen -P '' -f #{private_key}"
  creates private_key
end

execute 'Change ownership of keys to beaver user/group' do
  command "chown #{node['beaver']['user']}:#{node['beaver']['group']} #{private_key} #{private_key}.pub"
end

if File.file?(private_key)
  public_key = File.open("#{private_key}.pub", 'rb') { |file| file.read }
  node.set['beaver']['public_key'] = public_key
end
