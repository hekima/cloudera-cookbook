#
# Cookbook Name:: impala_state_store
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

include_recipe "cloudera"
include_recipe "cloudera::impala"
include_recipe "cloudera::update_config"

package "impala-state-store"

execute "create impala actual home" do
  user "hdfs"
  command "hadoop fs -mkdir -p /user/impala"
end
execute "chown impala actual home" do
  user "hdfs"
  command "hadoop fs -chown impala /user/impala"
end

service "impala-state-store" do
  action [ :restart, :enable ]
end