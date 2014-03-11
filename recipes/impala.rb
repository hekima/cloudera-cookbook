#
# Cookbook Name:: impala
# Attributes:: default
#
# Author:: Cliff Erson (<cerson@me.com>)
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

include_recipe "cloudera::hive"

package "impala"
package "impala-shell"

impala_chef_conf_dir = "/etc/impala/#{node[:hadoop][:conf_dir]}"

directory impala_chef_conf_dir do
  mode 0755
  owner "root"
  group "root"
  action :create
  recursive true
end

execute "create impala config dir" do
  command "mkdir -p #{impala_chef_conf_dir}"
end

execute "copy hadoop config to impala" do
  command "cp -r /etc/hadoop/#{node[:hadoop][:conf_dir]}/* #{impala_chef_conf_dir}/"
end

execute "copy hive config to impala" do
  command "cp -r /etc/hive/#{node[:hadoop][:conf_dir]}/* #{impala_chef_conf_dir}/"
end

execute "update impala alternatives" do
  command "update-alternatives --install /etc/impala/conf impala-conf #{impala_chef_conf_dir} 50"
end