#
# Cookbook Name:: cloudera
# Recipe:: hive_metastore
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

include_recipe "cloudera::repo"
include_recipe "cloudera::hive"

package "hive-metastore"

mysql_server = node[:opsworks][:layers][:mysql][:instances].values[0][:private_ip]

execute "create hive actual home" do
  user "hdfs"
  command "hadoop fs -mkdir -p /user/hive"
end
execute "chown hive actual home" do
  user "hdfs"
  command "hadoop fs -chown hive /user/hive"
end
execute "create hive home" do
  user "hdfs"
  command "hadoop fs -mkdir -p #{node[:hadoop][:hive_site]['hive.metastore.warehouse.dir']}"
end
execute "chown hive home" do
  user "hdfs"
  command "hadoop fs -chown hive #{node[:hadoop][:hive_site]['hive.metastore.warehouse.dir']}"
end
execute "chmod hive home" do
  user "hdfs"
  command "hadoop fs -chmod 1777 #{node[:hadoop][:hive_site]['hive.metastore.warehouse.dir']}"
end

case node[:platform_family]
when "rhel"
  package "mysql-connector-java"
when "debian"
  package "libmysql-java"
end

execute "copy_connector" do
  command "ln -sf /usr/share/java/mysql-connector-java.jar /usr/lib/hive/lib/mysql-connector-java.jar"
end

case node[:platform_family]
when "rhel"
  template "/etc/init.d/hadoop-hive-metastore" do
    source "hadoop_hive_metastore.erb"
    mode 0755
    owner "root"
    group "root"
    variables(
      :JAVA_HOME => node[:hadoop][:hadoop_env]['JAVA_HOME']
    )
  end
end

execute "create user and database" do
  command "mysql -h #{mysql_server} -u root -p#{node[:mysql][:server_root_password]} -e "\
          "\"CREATE DATABASE IF NOT EXISTS metastore;"\
          "USE metastore;"\
          "GRANT ALL PRIVILEGES ON metastore.* TO 'hive'@'%' IDENTIFIED BY '#{node[:hadoop][:hive_site]['javax.jdo.option.ConnectionPassword']}';"\
          "FLUSH PRIVILEGES;\""
end

execute "init schema" do
  command "/usr/lib/hive/bin/schematool -dbType mysql -initSchema"
  not_if "/usr/lib/hive/bin/schematool -dbType mysql -info"
end

execute "upgrade schema" do
  command "/usr/lib/hive/bin/schematool -dbType mysql -upgradeSchema"
  only_if "/usr/lib/hive/bin/schematool -dbType mysql -info"
end

execute "update privileges" do
  command "mysql -h #{mysql_server} -u root -p#{node[:mysql][:server_root_password]} -e "\
          "\"REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'hive'@'%';"\
          "GRANT SELECT,INSERT,UPDATE,DELETE,LOCK TABLES,EXECUTE ON metastore.* TO 'hive'@'%';"\
          "FLUSH PRIVILEGES;\""
end

service "hive-metastore" do
  action [ :restart, :enable ]
end
