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
default[:hadoop][:opsworks]               = false

default[:hadoop][:namenode_port]          = "8020"
default[:hadoop][:resourcemanager_port]        = "8021"

default[:hadoop][:conf_dir]               = "conf.chef"

default[:hadoop][:hadoop_env]['java_home'] = "/usr/lib/jvm/java-7-openjdk-amd64"

# Provide rack info
default[:hadoop][:rackaware][:datacenter] = "default"
default[:hadoop][:rackaware][:rack]       = "rack0"

# Use an alternate yum repo and key
default[:hadoop][:yum_repo_url]           = nil
default[:hadoop][:yum_repo_key_url]       = nil

#default[:hadoop][:core_site]['fs.defaultFS'] = "hdfs://localhost:#{node['hadoop']['namenode_port']}"
#default[:hadoop][:core_site]['io.file.buffer.size'] = 131072

default[:hadoop][:hdfs_site]['dfs.namenode.name.dir'] = "/srv/hadoop/dfs/namenode"
default[:hadoop][:hdfs_site]['dfs.datanode.data.dir'] = "/srv/hadoop/dfs/datanode"

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