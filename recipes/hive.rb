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

mysql_server = node[:opsworks][:layers][:mysql][:instances].values[0][:private_ip]

if node[:opsworks][:instance][:layers].include?('hadoop_hive_metastore') do
  metastore = node[:opsworks][:instance][:private_ip]
else
  metastore = node[:opsworks][:layers][:hadoop_hive_metastore][:instances].values[0][:private_ip]
end

node.default[:hadoop][:hive_site]['javax.jdo.option.ConnectionURL'] = "jdbc:mysql://#{mysql_server}/metastore"
node.default[:hadoop][:hive_site]['hive.metastore.uris'] = "thrift://#{metastore}:9083"
node.default[:hadoop][:hive_site]['hive.zookeeper.quorum'] = node[:opsworks][:layers][:zookeeper][:instances].values.map{|x| x[:private_dns_name]}.sort.join(',')

hive_site_vars = { :options => node[:hadoop][:hive_site] }

template "/etc/hive/conf/hive-site.xml" do
  source "generic-site.xml.erb"
  mode 0644
  owner "root"
  group "root"
  action :create
  variables hive_site_vars
end

execute "create hive home" do
  command "hadoop fs -mkdir -p #{node[:hadoop][:hive_site]['hive.metastore.warehouse.dir']}"
end
execute "chown hive home" do
  command "hadoop fs -chown hive #{node[:hadoop][:hive_site]['hive.metastore.warehouse.dir']}"
end
execute "chmod hive home" do
  command "hadoop fs -chmod 1777 #{node[:hadoop][:hive_site]['hive.metastore.warehouse.dir']}"
end