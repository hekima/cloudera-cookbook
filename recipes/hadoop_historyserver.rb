#
# Cookbook Name:: cloudera
# Recipe:: hadoop_historyserver
#
# Author:: Cliff Erson (<cerson@me.com>)
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

# This should be run after the namenodes, resourcemanager, historyserver, journalnodes and zookeeper
# are started
#include_recipe "cloudera::update_config"

package "hadoop-mapreduce-historyserver"

case node[:platform_family]
when "rhel"
  template "/etc/init.d/hadoop-#{node[:hadoop][:version]}-historyserver" do
    mode 0755
    owner "root"
    group "root"
    variables(
      :JAVA_HOME => node[:hadoop][:hadoop_env]['JAVA_HOME']
    )
  end
end

execute "create history home" do
  user "hdfs"
  command "hadoop fs -mkdir -p /user/history"
end
execute "chown hive home" do
  user "hdfs"
  command "hadoop fs -chown mapred:hadoop /user/history"
end
execute "chmod hive home" do
  user "hdfs"
  command "hadoop fs -chmod 1777 /user/history"
end

service "hadoop-mapreduce-historyserver" do
  action [ :restart, :enable ]
end

