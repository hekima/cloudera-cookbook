#
# Cookbook Name:: cloudera
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

default[:hadoop][:version]                = "2.2"
default[:hadoop][:release]                = "5.0.0b2"
default[:hadoop][:impala_release]         = "1.2.4"
default[:hadoop][:opsworks]               = false

default[:hadoop][:namenode_port]          = "8020"
default[:hadoop][:resourcemanager_port]   = "8021"
default[:hadoop][:journalnode_port]       = "8485"
default[:hadoop][:zookeeper_port]         = "2181"

default[:hadoop][:conf_dir]               = "conf.chef"

default[:java][:jdk_version]               = '7'

default[:hadoop][:hadoop_env]['JAVA_HOME'] = "/usr/lib/jvm/java-7-openjdk-amd64"

# Provide rack info
default[:hadoop][:rackaware][:datacenter] = "default"
default[:hadoop][:rackaware][:rack]       = "rack0"

# Use an alternate yum repo and key
default[:hadoop][:yum_repo_url]           = nil
default[:hadoop][:yum_repo_key_url]       = nil

default[:hadoop][:hdfs_site]['dfs.nameservices'] = "mycluster"

default[:hadoop][:core_site]['fs.defaultFS'] = "hdfs://#{node[:hadoop][:hdfs_site]['dfs.nameservices']}"
default[:hadoop][:core_site]['dfs.permissions.superusergroup'] = 'hadoop'
default[:hadoop][:core_site]['hadoop.proxyuser.hue.hosts'] = '*'
default[:hadoop][:core_site]['hadoop.proxyuser.hue.groups'] = '*'

default[:hadoop][:hdfs_site]['dfs.namenode.name.dir'] = "/mnt/hadoop/dfs/namenode"
default[:hadoop][:hdfs_site]['dfs.datanode.data.dir'] = "/mnt/hadoop/dfs/datanode"
default[:hadoop][:hdfs_site]['dfs.journalnode.edits.dir'] = "/mnt/hadoop/dfs/journalnode"
default[:hadoop][:hdfs_site]['dfs.ha.automatic-failover.enabled'] = true
default[:hadoop][:hdfs_site]["dfs.client.failover.proxy.provider.#{node[:hadoop][:hdfs_site]['dfs.nameservices']}"] = "org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider"
default[:hadoop][:hdfs_ssh_dir] = '/mnt/hadoop/dfs/ssh'
default[:hadoop][:hdfs_site]['dfs.ha.fencing.methods'] = 'sshfence'
default[:hadoop][:hdfs_site]['dfs.webhdfs.enabled'] = 'true'
default[:hadoop][:hdfs_site]['dfs.ha.fencing.ssh.private-key-files'] = "#{node[:hadoop][:hdfs_ssh_dir]}/hdfs_rsa"
default[:hadoop][:hdfs_site]['dfs.datanode.hdfs-blocks-metadata.enabled'] = 'true'
default[:hadoop][:hdfs_site]['dfs.client.read.shortcircuit'] = 'true'
default[:hadoop][:hdfs_site]['dfs.domain.socket.path'] = '/var/run/hadoop-hdfs/dn._PORT'
default[:hadoop][:hdfs_site]['dfs.client.file-block-storage-locations.timeout'] = '3000'


default[:hadoop][:mapred_site]['mapreduce.framework.name'] = "yarn"

default[:hadoop][:yarn_site]['yarn.nodemanager.aux-services'] = "mapreduce_shuffle"
default[:hadoop][:yarn_site]['yarn.nodemanager.aux-services.mapreduce.shuffle.class'] = "org.apache.hadoop.mapred.ShuffleHandler"
default[:hadoop][:yarn_site]['yarn.application.classpath'] = "$HADOOP_CONF_DIR, $HADOOP_COMMON_HOME/*, $HADOOP_COMMON_HOME/lib/*, $HADOOP_HDFS_HOME/*, $HADOOP_HDFS_HOME/lib/*, $HADOOP_MAPRED_HOME/*, $HADOOP_MAPRED_HOME/lib/*, $HADOOP_YARN_HOME/*, $HADOOP_YARN_HOME/lib/*"
default[:hadoop][:yarn_site]['yarn.log.aggregation.enable'] = true
default[:hadoop][:yarn_site]['yarn.nodemanager.local-dirs'] = "/mnt/hadoop/yarn/local"
default[:hadoop][:yarn_site]['yarn.nodemanager.log-dirs'] = "/mnt/hadoop/yarn/logs"
default[:hadoop][:yarn_site]['yarn.nodemanager.remote-app-log-dir'] = "hdfs://var/log/hadoop-yarn/app"

default[:hadoop][:hue_server][:secretkey] = 'SOMESECRETKEY'
default[:hadoop][:hue_server][:http_host] = '0.0.0.0'
default[:hadoop][:hue_server][:http_port] = '8888'

default[:hadoop][:hive_site]['javax.jdo.option.ConnectionDriverName'] = 'com.mysql.jdbc.Driver'
default[:hadoop][:hive_site]['javax.jdo.option.ConnectionUserName'] = 'hive'
default[:hadoop][:hive_site]['javax.jdo.option.ConnectionPassword'] = 'hivepassword'
default[:hadoop][:hive_site]['datanucleus.autoCreateSchema'] = 'false'
default[:hadoop][:hive_site]['datanucleus.fixedDatastore'] = 'true'
default[:hadoop][:hive_site]['datanucleus.autoStartMechanism'] = 'SchemaTable'
default[:hadoop][:hive_site]['hive.support.concurrency'] = 'true'
default[:hadoop][:hive_site]['hive.zookeeper.client.port'] = node[:hadoop][:zookeeper_port]
default[:hadoop][:hive_site]['hive.server2.thrift.port'] = '10000'
default[:hadoop][:hive_site]['hive.metastore.warehouse.dir'] = '/user/hive/warehouse'
default[:hadoop][:hive_site]['hive.metastore.client.socket.timeout'] = '3600'
default[:hadoop][:hive_site]['hive.exec.scratchdir'] = '/user/hive/tmp'

default[:hadoop][:hive_server_env]['HADOOP_MAPRED_HOME'] = "/usr/lib/hadoop-mapreduce"

default[:hadoop][:impala_env]['IMPALA_CATALOG_PORT'] = "26000"
default[:hadoop][:impala_env]['IMPALA_STATE_STORE_PORT'] = "24000"
default[:hadoop][:impala_env]['IMPALA_BACKEND_PORT'] = "22000"
default[:hadoop][:impala_env]['IMPALA_LOG_DIR'] = "/var/log/impala"
default[:hadoop][:impala_env]['ENABLE_CORE_DUMPS'] = "true"

default[:hadoop][:log4j]['hadoop.root.logger']                                                 = 'INFO,console'
default[:hadoop][:log4j]['hadoop.security.logger']                                             = 'INFO,console'
default[:hadoop][:log4j]['hadoop.log.dir']                                                     = '.'
default[:hadoop][:log4j]['hadoop.log.file']                                                    = 'hadoop.log'
default[:hadoop][:log4j]['hadoop.mapreduce.jobsummary.logger']                                 = '${hadoop.root.logger}'
default[:hadoop][:log4j]['hadoop.mapreduce.jobsummary.log.file']                               = 'hadoop-mapreduce.jobsummary.log'
default[:hadoop][:log4j]['log4j.rootLogger']                                                   = '${hadoop.root.logger}, EventCounter'
default[:hadoop][:log4j]['log4j.threshhold']                                                   = 'ALL'
default[:hadoop][:log4j]['log4j.appender.DRFA']                                                = 'org.apache.log4j.DailyRollingFileAppender'
default[:hadoop][:log4j]['log4j.appender.DRFA.File']                                           = '${hadoop.log.dir}/${hadoop.log.file}'
default[:hadoop][:log4j]['log4j.appender.DRFA.DatePattern']                                    = '.yyyy-MM-dd'
default[:hadoop][:log4j]['log4j.appender.DRFA.layout']                                         = 'org.apache.log4j.PatternLayout'
default[:hadoop][:log4j]['log4j.appender.DRFA.layout.ConversionPattern']                       = '%d{ISO8601} %p %c: %m%n'
default[:hadoop][:log4j]['log4j.appender.console']                                             = 'org.apache.log4j.ConsoleAppender'
default[:hadoop][:log4j]['log4j.appender.console.target']                                      = 'System.err'
default[:hadoop][:log4j]['log4j.appender.console.layout']                                      = 'org.apache.log4j.PatternLayout'
default[:hadoop][:log4j]['log4j.appender.console.layout.ConversionPattern']                    = '%d{yy/MM/dd HH:mm:ss} %p %c{2}: %m%n'
default[:hadoop][:log4j]['hadoop.tasklog.taskid']                                              = 'null'
default[:hadoop][:log4j]['hadoop.tasklog.iscleanup']                                           = 'false'
default[:hadoop][:log4j]['hadoop.tasklog.noKeepSplits']                                        = '4'
default[:hadoop][:log4j]['hadoop.tasklog.totalLogFileSize']                                    = '100'
default[:hadoop][:log4j]['hadoop.tasklog.purgeLogSplits']                                      = 'true'
default[:hadoop][:log4j]['hadoop.tasklog.logsRetainHours']                                     = '12'
default[:hadoop][:log4j]['log4j.appender.TLA']                                                 = 'org.apache.hadoop.mapred.TaskLogAppender'
default[:hadoop][:log4j]['log4j.appender.TLA.taskId']                                          = '${hadoop.tasklog.taskid}'
default[:hadoop][:log4j]['log4j.appender.TLA.isCleanup']                                       = '${hadoop.tasklog.iscleanup}'
default[:hadoop][:log4j]['log4j.appender.TLA.totalLogFileSize']                                = '${hadoop.tasklog.totalLogFileSize}'
default[:hadoop][:log4j]['log4j.appender.TLA.layout']                                          = 'org.apache.log4j.PatternLayout'
default[:hadoop][:log4j]['log4j.appender.TLA.layout.ConversionPattern']                        = '%d{ISO8601} %p %c: %m%n'
default[:hadoop][:log4j]['hadoop.security.log.file']                                           = 'SecurityAuth.audit'
default[:hadoop][:log4j]['log4j.appender.DRFAS']                                               = 'org.apache.log4j.DailyRollingFileAppender '
default[:hadoop][:log4j]['log4j.appender.DRFAS.File']                                          = '${hadoop.log.dir}/${hadoop.security.log.file}'
default[:hadoop][:log4j]['log4j.appender.DRFAS.layout']                                        = 'org.apache.log4j.PatternLayout'
default[:hadoop][:log4j]['log4j.appender.DRFAS.layout.ConversionPattern']                      = '%d{ISO8601} %p %c: %m%n'
default[:hadoop][:log4j]['log4j.category.SecurityLogger']                                      = '${hadoop.security.logger}'
default[:hadoop][:log4j]['log4j.logger.org.apache.hadoop.fs.FSNamesystem.audit']               = 'WARN'
default[:hadoop][:log4j]['log4j.logger.org.jets3t.service.impl.rest.httpclient.RestS3Service'] = 'ERROR'
default[:hadoop][:log4j]['log4j.appender.EventCounter']                                        = 'org.apache.hadoop.log.metrics.EventCounter'
default[:hadoop][:log4j]['log4j.appender.JSA']                                                 = 'org.apache.log4j.DailyRollingFileAppender'
default[:hadoop][:log4j]['log4j.appender.JSA.File']                                            = '${hadoop.log.dir}/${hadoop.mapreduce.jobsummary.log.file}'
default[:hadoop][:log4j]['log4j.appender.JSA.layout']                                          = 'org.apache.log4j.PatternLayout'
default[:hadoop][:log4j]['log4j.appender.JSA.layout.ConversionPattern']                        = '%d{yy/MM/dd HH:mm:ss} %p %c{2}: %m%n'
default[:hadoop][:log4j]['log4j.appender.JSA.DatePattern']                                     = '.yyyy-MM-dd'
default[:hadoop][:log4j]['log4j.logger.org.apache.hadoop.mapred.JobInProgress$JobSummary']     = '${hadoop.mapreduce.jobsummary.logger}'
default[:hadoop][:log4j]['log4j.additivity.org.apache.hadoop.mapred.JobInProgress$JobSummary'] = 'false'

default[:hadoop][:log4j]['log4j.appender.RFA']                                                = 'org.apache.log4j.DailyRollingFileAppender'
default[:hadoop][:log4j]['log4j.appender.RFA.File']                                           = '${hadoop.log.dir}/${hadoop.log.file}'
default[:hadoop][:log4j]['log4j.appender.RFA.MaxFileSize'] 																		= '${hadoop.log.maxfilesize}'
default[:hadoop][:log4j]['log4j.appender.RFA.MaxBackupIndex'] 																= '${hadoop.log.maxbackupindex}'
default[:hadoop][:log4j]['log4j.appender.RFA.layout']                                         = 'org.apache.log4j.PatternLayout'
default[:hadoop][:log4j]['log4j.appender.RFA.layout.ConversionPattern']                       = '%d{ISO8601} %p %c: %m%n'

default[:hadoop][:log4j]['log4j.appender.RFAS']                                               = 'org.apache.log4j.DailyRollingFileAppender '
default[:hadoop][:log4j]['log4j.appender.RFAS.File']                                          = '${hadoop.log.dir}/${hadoop.security.log.file}'
default[:hadoop][:log4j]['log4j.appender.RFAS.layout']                                        = 'org.apache.log4j.PatternLayout'
default[:hadoop][:log4j]['log4j.appender.RFAS.layout.ConversionPattern']                      = '%d{ISO8601} %p %c: %m%n'
default[:hadoop][:log4j]['log4j.appender.RFAS.MaxFileSize'] 																	= '${hadoop.security.log.maxfilesize}'
default[:hadoop][:log4j]['log4j.appender.RFAS.MaxBackupIndex'] 																= '${hadoop.security.log.maxbackupindex}'


default[:hadoop][:hdfs_public_key] = 'SOME_PUBLIC_KEY'
default[:hadoop][:hdfs_private_key] = 'SOME_PRIVATE_KEY'