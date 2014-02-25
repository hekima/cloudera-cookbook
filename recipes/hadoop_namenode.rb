#
# Cookbook Name:: cloudera
# Recipe:: hadoop_namenode
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

include_recipe "cloudera"

# This should be run after the namenodes, resourcemanager, historyserver, journalnodes and zookeeper
# are started
#include_recipe "cloudera::update_config"

package "hadoop-hdfs-namenode"
package "hadoop-hdfs-zkfc"

node[:hadoop][:mapred_site]['mapred.local.dir'].split(',').each do |dir|
  directory dir do
    mode 0755
    owner "mapred"
    group "mapred"
    action :create
    recursive true
  end
end

case node[:platform_family]
when "rhel"
  template "/etc/init.d/hadoop-#{node[:hadoop][:version]}-namenode" do
    mode 0755
    owner "root"
    group "root"
    variables(
      :java_home => node[:hadoop][:hadoop_env]['java_home']
    )
  end
end

node[:hadoop][:hdfs_site]['dfs.namenode.name.dir'].split(',').each do |dir|
  directory dir do
    mode 0755
    owner "hdfs"
    group "hdfs"
    action :create
    recursive true
  end
end

first_namenode = false
if node[:hadoop][:opsworks]
  if node[:opsworks][:layers][:hadoop_namenode].keys.first == node[:opsworks][:instance][:hostname]
    first_namenode = true
  end
else
  if node[:fqdn].contains? "namenode1"
    first_namenode = true
  end
end

if first_namenode
  execute "init namenode" do
    command "service hadoop-hdfs-namenode init"
    returns [0,1]
  end
else
  execute "init standby namenode" do
    user "hdfs"
    command "hdfs namenode -bootstrapStandby"
  end
end