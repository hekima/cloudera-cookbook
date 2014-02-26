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


include_recipe "java::default"
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



#if node[:hadoop][:hdfs_site] && node[:hadoop][:hdfs_site]['topology.script.file.name']
#  topology = { :options => node[:hadoop][:topology] }
#  topology_dir = File.dirname(node[:hadoop][:hdfs_site]['topology.script.file.name'])
#
#  directory topology_dir do
#    mode 0755
#    owner "hdfs"
#    group "hdfs"
#    action :create
#    recursive true
#  end

#  template node[:hadoop][:hdfs_site]['topology.script.file.name'] do
#    source "topology.rb.erb"
#    mode 0755
#    owner "hdfs"
#    group "hdfs"
#    action :create
#    variables topology
#  end
#end

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

directory node[:hadoop][:hdfs_ssh_dir] do
  mode 0755
  owner "hdfs"
  group "hdfs"
  action :create
  recursive true
end

file "#{node[:hadoop][:hdfs_site]['dfs.ha.fencing.ssh.private-key-files']}" do
  owner "hdfs"
  group "hdfs"
  mode 0600
  content node[:hadoop][:hdfs_private_key]
end

file "#{node[:hadoop][:hdfs_site]['dfs.ha.fencing.ssh.private-key-files']}.pub" do
  owner "hdfs"
  group "hdfs"
  mode 0644
  content node[:hadoop][:hdfs_public_key]
end

directory "/var/lib/hadoop-hdfs/.ssh" do
  mode 0755
  owner "hdfs"
  group "hdfs"
  action :create
  recursive true
end

execute "add key to hdfs known_hosts" do
  user "hdfs"
  command "cat #{node[:hadoop][:hdfs_site]['dfs.ha.fencing.ssh.private-key-files']}.pub >> /var/lib/hadoop-hdfs/.ssh/authorized_keys"
end