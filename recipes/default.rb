#
# Cookbook Name:: cloudera
# Recipe:: default
#
# Author:: Cliff Erson (<cerson@me.com>)
# Author:: Istvan Szukacs (<istvan.szukacs@gmail.com>)
# Author:: Steve Lum (<steve.lum@gmail.com>)
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

[Chef::Recipe, Chef::Resource].each { |l| l.send :include, ::Extensions }

include_recipe "cloudera::repo"


package "hadoop-client"
package "nscd"

service "nscd" do
  action [ :start, :enable ]
end

chef_conf_dir = "/etc/hadoop/#{node[:hadoop][:conf_dir]}"


directory chef_conf_dir do
  mode 0755
  owner "root"
  group "root"
  action :create
  recursive true
end

if(Chef::Config[:solo])
else
  if node.name.include?('namenode1')
    node.default[:hadoop][:core_site]['fs.default.name'] = "hdfs://#{node.name}:#{node[:hadoop][:namenode_port]}"
  else
    namenode = search_for_nodes(["hadoop_namenode"], 'fqdn').first
    node.default[:hadoop][:core_site]['fs.default.name'] = "hdfs://#{namenode}:#{node[:hadoop][:namenode_port]}"
  end
end

core_site_vars = { :options => node[:hadoop][:core_site] }


template "#{chef_conf_dir}/core-site.xml" do
  source "generic-site.xml.erb"
  mode 0644
  owner "hdfs"
  group "hdfs"
  action :create
  variables core_site_vars
end

hdfs_site_vars = { :options => node[:hadoop][:hdfs_site] }
#hdfs_site_vars[:options]['fs.default.name'] = "hdfs://#{namenode[:ipaddress]}:#{node[:hadoop][:namenode_port]}"
# TODO dfs.secondary.http.address should have port made into an attribute - maybe
#hdfs_site_vars[:options]['dfs.secondary.http.address'] = "#{secondary_namenode[:ipaddress]}:50090" if secondary_namenode

template "#{chef_conf_dir}/hdfs-site.xml" do
  source "generic-site.xml.erb"
  mode 0644
  owner "hdfs"
  group "hdfs"
  action :create
  variables hdfs_site_vars
end

resourcemanager = find_matching_nodes(["hadoop_resourcemanager"]).first

node.default[:hadoop][:mapred_site]['mapred.job.tracker'] = "#{resourcemanager[:fqdn]}:#{node[:hadoop][:resourcemanager_port]}" if resourcemanager
mapred_site_vars = { :options => node[:hadoop][:mapred_site] }

template "#{chef_conf_dir}/mapred-site.xml" do
  source "generic-site.xml.erb"
  mode 0644
  owner "hdfs"
  group "hdfs"
  action :create
  variables mapred_site_vars
end

hadoop_policy_vars = { :options => node[:hadoop][:hadoop_policy] }
template "#{chef_conf_dir}/hadoop-policy.xml" do
  source "hadoop-policy.xml.erb"
  mode 0644
  owner "hdfs"
  group "hdfs"
  action :create
  variables hadoop_policy_vars
end

template "#{chef_conf_dir}/hadoop-env.sh" do
  mode 0755
  owner "hdfs"
  group "hdfs"
  action :create
  variables( :options => node[:hadoop][:hadoop_env] )
end

#template node[:hadoop][:mapred_site]['mapred.fairscheduler.allocation.file'] do
#  mode 0644
#  owner "hdfs"
#  group "hdfs"
#  action :create
#  variables node[:hadoop][:fair_scheduler]
#end

template "#{chef_conf_dir}/log4j.properties" do
  source "generic.properties.erb"
  mode 0644
  owner "hdfs"
  group "hdfs"
  action :create
  variables( :properties => node[:hadoop][:log4j] )
end

template "#{chef_conf_dir}/hadoop-metrics.properties" do
  source "generic.properties.erb"
  mode 0644
  owner "hdfs"
  group "hdfs"
  action :create
  variables( :properties => node[:hadoop][:hadoop_metrics] )
end

# Create the master and slave files
if(Chef::Config[:solo])
  namenode_servers = node['ipaddress']
  masters = [ "localhost" ]
else
  namenode_servers = find_matching_nodes(["hadoop_namenode", "hadoop_secondary_namenode"]).first
  masters = namenode_servers.map { |node| node[:fqdn] }
end

template "#{chef_conf_dir}/masters" do
  source "master_slave.erb"
  mode 0644
  owner "hdfs"
  group "hdfs"
  action :create
  variables( :nodes => masters )
end

if(Chef::Config[:solo])
  datanode_servers = node['ipaddress']
  slaves = [ "localhost" ]
else
  datanode_servers = find_matching_nodes(["hadoop_datanode"]).first
  slaves = datanode_servers.map { |node| node[:fqdn] }
end

template "#{chef_conf_dir}/slaves" do
  source "master_slave.erb"
  mode 0644
  owner "hdfs"
  group "hdfs"
  action :create
  variables( :nodes => slaves )
end

if node[:hadoop][:hdfs_site] && node[:hadoop][:hdfs_site]['topology.script.file.name']
  topology = { :options => node[:hadoop][:topology] }
  topology_dir = File.dirname(node[:hadoop][:hdfs_site]['topology.script.file.name'])

  directory topology_dir do
    mode 0755
    owner "hdfs"
    group "hdfs"
    action :create
    recursive true
  end

  template node[:hadoop][:hdfs_site]['topology.script.file.name'] do
    source "topology.rb.erb"
    mode 0755
    owner "hdfs"
    group "hdfs"
    action :create
    variables topology
  end
end

if node[:hadoop][:core_site]['hadoop.tmp.dir']
  hadoop_tmp_dir = node[:hadoop][:core_site]['hadoop.tmp.dir']
else
  hadoop_tmp_dir = "/tmp"
end

directory hadoop_tmp_dir do
  mode 0777
  owner "hdfs"
  group "hdfs"
  action :create
  recursive true
end

template "/usr/lib/hadoop-#{node[:hadoop][:version]}-mapreduce/bin/hadoop-config.sh" do
  source "hadoop_config.erb"
  mode 0755
  owner "root"
  group "root"
  variables(
    :java_home => node[:hadoop][:hadoop_env]['java_home']
  )
end

execute "update hadoop alternatives" do
  command "update-alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/#{node[:hadoop][:conf_dir]} 50"
end
