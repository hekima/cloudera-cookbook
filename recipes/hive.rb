#
# Cookbook Name:: cloudera
# Recipe:: hive
#
# Author:: Istvan Szukacs (<istvan.szukacs@gmail.com>)
# Copyright 2012, Riot Games
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "cloudera"
include_recipe "cloudera::update_config"

package "hive"

mysql_server = node[:opsworks][:layers][:mysql][:instances].values
if mysql_server.empty?
  mysql_server = 'localhost'
else
  mysql_server = mysql_server.first[:private_ip]
end
hive_chef_conf_dir = "/etc/hive/#{node[:hadoop][:conf_dir]}"

directory hive_chef_conf_dir do
  mode 0755
  owner "root"
  group "root"
  action :create
  recursive true
end

if node[:opsworks][:instance][:layers].include?('hive_metastore')
  metastore = node[:opsworks][:instance][:private_ip]
else
  metastore = node[:opsworks][:layers][:hive_metastore][:instances].values;
  if metastore.empty?
    metastore = 'localhost'
  else
    metastore = metastore.first[:private_ip]
  end
end

node.default[:hadoop][:hive_site]['javax.jdo.option.ConnectionURL'] = "jdbc:mysql://#{mysql_server}/metastore"
node.default[:hadoop][:hive_site]['hive.metastore.uris'] = "thrift://#{metastore}:9083"
node.default[:hadoop][:hive_site]['hive.zookeeper.quorum'] = node[:opsworks][:layers][:zookeeper][:instances].values.map{|x| x[:private_dns_name]}.sort.join(',')

hive_site_vars = { :options => node[:hadoop][:hive_site] }

template "#{hive_chef_conf_dir}/hive-site.xml" do
  source "generic-site.xml.erb"
  mode 0644
  owner "root"
  group "root"
  action :create
  variables hive_site_vars
end

execute "update hadoop alternatives" do
  command "update-alternatives --install /etc/hive/conf hive-conf #{hive_chef_conf_dir} 50"
end