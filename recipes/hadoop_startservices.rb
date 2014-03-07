[Chef::Recipe, Chef::Resource].each { |l| l.send :include, ::Extensions }

# variables needed to guide the execution flow
chef_conf_dir = "/etc/hadoop/#{node[:hadoop][:conf_dir]}"
is_namenode = false
is_resourcemanager = false
is_journalnode = false
first_namenode = false
if node[:hadoop][:opsworks]
  if node[:opsworks][:instance][:layers].include?('hadoop_namenode')
    is_namenode = true
    if node[:opsworks][:layers][:hadoop_namenode][:instances].keys.sort.first == node[:opsworks][:instance][:hostname]
      first_namenode = true
    end
  end
  if node[:opsworks][:instance][:layers].include?('hadoop_resourcemanager')
    is_resourcemanager = true
  end
  if node[:opsworks][:instance][:layers].include?('hadoop_journalnode')
    is_journalnode = true
  end
else
  if node[:hostname].include?('namenode')
    is_namenode = true
    if node[:fqdn].contains? "namenode1"
      first_namenode = true
    end
  end
  if node[:hostname].include?('resourcemanager')
    is_resourcemanager = true
  end
  if node[:hostname].include?('journalnode')
    is_journalnode = true
  end
end

if is_namenode
  if first_namenode
    execute "init namenode" do
      user "hdfs"
      command "hdfs namenode -format -force"
    end
    execute "init ha state in zookeeper" do
      user "hdfs"
      command "hdfs zkfc -formatZK -force"
    end
  else
    execute "init standby namenode" do
      user "hdfs"
      command "hdfs namenode -bootstrapStandby -force"
    end
  end
  service "hadoop-hdfs-namenode" do
    action [ :restart, :enable ]
  end
  service "hadoop-hdfs-zkfc" do
    action [ :restart, :enable ]
  end

  execute "create hdfs home" do
    command "hadoop fs -mkdir -p /user/hdfs"
  end
  execute "chown hdfs home" do
    command "hadoop fs -chown hdfs /user/hdfs"
  end

  execute "create ubuntu home" do
    command "hadoop fs -mkdir -p /user/ubuntu"
  end
  execute "chown ubuntu home" do
    command "hadoop fs -chown ubuntu /user/ubuntu"
  end
end

if is_resourcemanager
  execute "create yarn log directories" do
    command "hadoop fs -mkdir -p /var/log/hadoop-yarn"
  end
  execute "chown yarn log directories" do
    command "hadoop fs -chown yarn /var/log/hadoop-yarn"
  end

  execute "create yarn home" do
    command "hadoop fs -mkdir -p /user/yarn"
  end
  execute "create yarn home" do
    command "hadoop fs -chown yarn /user/yarn"
  end

  execute "change permissions of yarn log directories" do
    user "hdfs"
    command "hadoop fs -chown yarn:mapred /var/log/hadoop-yarn"
  end
  service "hadoop-yarn-resourcemanager" do
    action [ :restart, :enable ]
  end
end
