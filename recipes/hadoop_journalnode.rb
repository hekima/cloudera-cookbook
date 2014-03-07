#
# Cookbook Name:: cloudera
# Recipe:: hadoop_journalnode
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

package "hadoop-hdfs-journalnode"


case node[:platform_family]
when "rhel"
  template "/etc/init.d/hadoop-#{node[:hadoop][:version]}-journalnode" do
    mode 0755
    owner "root"
    group "root"
    variables(
      :JAVA_HOME => node[:hadoop][:hadoop_env]['JAVA_HOME']
    )
  end
end

node[:hadoop][:hdfs_site]['dfs.journalnode.edits.dir'].split(',').each do |dir|
  directory dir do
    mode 0755
    owner "hdfs"
    group "hdfs"
    action :create
    recursive true
  end
end