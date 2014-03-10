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

case node[:platform_family]
when "rhel"
  package "mysql-connector-java"
  execute "copy_connector" do
    command "ln -s /usr/share/java/mysql-connector-java.jar /usr/lib/hive/lib/mysql-connector-java.jar"
  end
when "debian"
  package "libmysql-java"
  execute "copy_connector" do
    command "ln -s /usr/share/java/libmysql-java.jar /usr/lib/hive/lib/libmysql-java.jar"
  end
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

execute "init schema" do
  command "schematool -dbType mysql -initSchema"
end

#execute "create metastore and users" do
#  command "mysql -h #{mysql_server} -u root -p #{node[:mysql][:server_root_password]} -e "\
#          "\"CREATE DATABASE metastore;"\
#          "USE metastore;"\
#          "SOURCE /usr/lib/hive/scripts/metastore/upgrade/mysql/hive-schema-0.12.0.mysql.sql;"\
#          "CREATE USER 'hive'@'#{mysql_server}' IDENTIFIED BY '#{node[:hadoop][:hive_site]['javax.jdo.option.ConnectionPassword']}';"\
#          "REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'hive'@'#{mysql_server}';"\
#          "GRANT SELECT,INSERT,UPDATE,DELETE,LOCK TABLES,EXECUTE ON metastore.* TO 'hive'@'#{mysql_server}';"\
#          "FLUSH PRIVILEGES;\""
#end

service "hive-metastore" do
  action [ :restart, :enable ]
end
