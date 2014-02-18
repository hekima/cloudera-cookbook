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
#default[:java][:install_flavor]           = "oracle"
#default[:java][:java_home]                = "/usr"

default[:hadoop][:version]                = "0.20"
default[:hadoop][:release]                = "4.5.0"

default[:hadoop][:namenode_port]          = "8020"
default[:hadoop][:jobtracker_port]        = "8021"

default[:hadoop][:conf_dir]               = "conf.chef"
default[:hadoop][:core_site]['hadoop.tmp.dir'] = "/tmp"
default[:hadoop][:core_site]['fs.default.name'] = "hdfs://localhost:#{node['hadoop']['namenode_port']}"

default[:hadoop][:hdfs_site]['dfs.namenode.name.dir'] = "/srv/hadoop/dfs/namenode"
default[:hadoop][:hdfs_site]['dfs.datanode.data.dir'] = "/srv/hadoop/dfs/datanode"
default[:hadoop][:hdfs_site]['fs.checkpoint.dir'] = "/srv/hadoop/dfs/checkpoint"

default[:hadoop][:hdfs_site]['dfs.permissions.superusergroup'] = "hadoop"

default[:hadoop][:hadoop_policy]['security.client.protocol.acl'] = "*"
default[:hadoop][:hadoop_policy]['security.client.datanode.protocol.acl'] = "*"
default[:hadoop][:hadoop_policy]['security.datanode.protocol.acl'] = "*"
default[:hadoop][:hadoop_policy]['security.inter.datanode.protocol.acl'] = "*"
default[:hadoop][:hadoop_policy]['security.namenode.protocol.acl'] = "*"
default[:hadoop][:hadoop_policy]['security.admin.operations.protocol.acl'] = "*"
default[:hadoop][:hadoop_policy]['security.refresh.usertogroups.mappings.protocol.acl'] = "*"
default[:hadoop][:hadoop_policy]['security.refresh.policy.protocol.acl'] = "*"
default[:hadoop][:hadoop_policy]['security.ha.service.protocol.acl'] = "*"
default[:hadoop][:hadoop_policy]['security.zkfc.protocol.acl'] = "*"
default[:hadoop][:hadoop_policy]['security.qjournal.service.protocol.acl'] = "*"
default[:hadoop][:hadoop_policy]['security.mrhs.client.protocol.acl'] = "*"
default[:hadoop][:hadoop_policy]['security.resourcetracker.protocol.acl'] = "*"
default[:hadoop][:hadoop_policy]['security.admin.protocol.acl'] = "*"
default[:hadoop][:hadoop_policy]['security.client.resourcemanager.protocol.acl'] = "*"
default[:hadoop][:hadoop_policy]['security.applicationmaster.resourcemanager.protocol.acl'] = "*"
default[:hadoop][:hadoop_policy]['security.containermanager.protocol.acl'] = "*"
default[:hadoop][:hadoop_policy]['security.resourcelocalizer.protocol.acl'] = "*"
default[:hadoop][:hadoop_policy]['security.job.task.protocol.acl'] = "*"
default[:hadoop][:hadoop_policy]['security.job.client.protocol.acl'] = "*"

default[:hadoop][:hadoop_env]['JAVA_HOME'] = "/usr/lib/jvm/java-6-oracle/"

default[:hadoop][:fair_scheduler] = {}

# Provide rack info
default[:hadoop][:rackaware][:datacenter] = "default"
default[:hadoop][:rackaware][:rack]       = "rack0"

# Use an alternate yum repo and key
default[:hadoop][:yum_repo_url]           = nil
default[:hadoop][:yum_repo_key_url]       = nil

default[:hadoop][:mapred_site]['mapred.fairscheduler.allocation.file'] = "/etc/hadoop/#{node[:hadoop][:conf_dir]}/fair-scheduler.xml"
default[:hadoop][:mapred_site]['mapred.job.tracker'] = "localhost:#{node['hadoop']['jobtracker_port']}"
default[:hadoop][:mapred_site]['mapred.local.dir'] = "/srv/hadoop/mapred/tmp"

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

default[:hadoop][:hadoop_metrics]['dfs.class']																								= 'org.apache.hadoop.metrics.spi.NullContext'
default[:hadoop][:hadoop_metrics]['mapred.class']																							= 'org.apache.hadoop.metrics.spi.NullContext'
default[:hadoop][:hadoop_metrics]['rpc.class']																								= 'org.apache.hadoop.metrics.spi.NullContext'
default[:hadoop][:hadoop_metrics]['ugi.class']																								= 'org.apache.hadoop.metrics.spi.NullContext'

