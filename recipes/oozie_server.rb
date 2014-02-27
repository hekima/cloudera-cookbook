#
# Cookbook Name:: cloudera
# Recipe:: oozie_server
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

[Chef::Recipe, Chef::Resource].each { |l| l.send :include, ::Extensions }

include_recipe "java::default"
include_recipe "cloudera::repo"

package "oozie"

execute "update oozie alternatives" do
  command "update-alternatives --install /etc/oozie/tomcat-conf oozie-tomcat-conf /etc/oozie/tomcat-conf.http 50"
end

service "oozie" do
  action [ :restart, :enable ]
end
