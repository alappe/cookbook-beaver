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

include_recipe "python"

python_pip 'beaver' do 
  version node['beaver']['version']
  action :install
end

directory node['beaver']['config_path'] do
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

directory ::File.join(node['beaver']['config_path'], "conf.d") do
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

if node['beaver']['generate_keypair']
  include_recipe 'beaver::generate_keypair'
end

service 'beaver' do
  provider Chef::Provider::Service::Upstart
  supports :start => true, :restart => true, :stop => true, :status => true
  action :nothing
end

template "#{node['beaver']['config_path']}/#{node['beaver']['config_file']}" do
  source 'beaver.conf.erb'
  owner 'root'
  group 'root'
  mode 00644
  variables(
    :beaver => node['beaver']['configuration'],
    :files => node['beaver']['files']
  )
  notifies :restart, "service[beaver]"
end

template "/etc/init/beaver.conf" do
  source "beaver-upstart.erb"
  owner 'root'
  group 'root'
  mode 00644
  variables(
    :config_path => node['beaver']['config_path'],
    :config_file => node['beaver']['config_file'],
    :log_path => node['beaver']['log_path'],
    :log_file => node['beaver']['log_file']
  )
end

service 'beaver' do
  action [:enable, :start]
end
