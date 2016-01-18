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

include_recipe 'python'

user node['beaver']['user'] do
  action :create
  comment 'Beaver System User'
  home node['beaver']['config_path']
  system true
  not_if { node['beaver']['user'] == 'root' }
end

group node['beaver']['group'] do
  action :create
  not_if { node['beaver']['group'] == 'root' }
end

group node['beaver']['group'] do
  action :modify
  members node['beaver']['user']
  append true
  not_if { node['beaver']['group'] == 'root' }
end

python_virtualenv '/opt/beaver' do
  interpreter 'python'
  owner 'root'
  group 'root'
  action :create
  only_if {node['beaver']['use_virtualenv']}
end

python_pip 'setuptools-venv' do
  package_name 'setuptools'
  virtualenv '/opt/beaver'
  action :upgrade
  only_if {node['beaver']['use_virtualenv']}
end

python_pip 'beaver' do
  version node['beaver']['version']
  virtualenv node['beaver']['virtualenv_path'] if node['beaver']['use_virtualenv']
  action :install
end

directory node['beaver']['config_path'] do
  owner node['beaver']['user']
  group node['beaver']['group']
  mode '0755'
  action :create
  recursive true
end

directory ::File.join(node['beaver']['config_path'], 'conf.d') do
  owner node['beaver']['user']
  group node['beaver']['group']
  mode '0755'
  action :create
end

file "#{node['beaver']['log_path']}/#{node['beaver']['log_file']}" do
  action :create
  owner node['beaver']['user']
  group node['beaver']['group']
end

file "#{node['beaver']['pid_file']}" do
  action :create
  owner node['beaver']['user']
  group node['beaver']['group']
end

include_recipe 'beaver::generate_keypair' if node['beaver']['generate_keypair']

log_files = node['beaver']['files'].map do |each|
  path = each['path']
  options = each.reject { |key, _value| key == 'path' }
  {
    'path' => path,
    'options' => options
  }
end

template "#{node['beaver']['config_path']}/#{node['beaver']['config_file']}" do
  source 'beaver.conf.erb'
  owner node['beaver']['user']
  group node['beaver']['group']
  mode '0644'
  variables(
    :beaver => node['beaver']['configuration'],
    :files => log_files
  )
  notifies :restart, 'service[beaver]'
end

systemd = node['init_package'] == 'systemd'
upstart = !systemd && node['platform'] == 'ubuntu' && node['platform_version'].to_f >= 12.04

execute 'beaver systemd reload' do
  command 'systemctl daemon-reload'
  action :nothing
  only_if { systemd }
end

template 'beaver init script' do
  owner 'root'
  group 'root'
  variables node['beaver']
  notifies :restart, 'service[beaver]'

  if systemd
    path '/lib/systemd/system/beaver.service'
    source 'beaver.service.erb'
    mode '0644'
    notifies :run, 'execute[beaver systemd reload]', :immediately
  elsif upstart
    path '/etc/init/beaver.conf'
    source 'beaver-upstart.erb'
    mode '0644'
  else
    path '/etc/init.d/beaver'
    source 'beaver-init.erb'
    mode '0755'
  end
end

service 'beaver' do
  provider Chef::Provider::Service::Upstart if upstart
  supports :start => true, :restart => true, :stop => true, :status => true
  action [:enable, :start]
end
