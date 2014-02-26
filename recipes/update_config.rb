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

# Setting the core-site.xml
if node[:hadoop][:opsworks]
  node.default[:hadoop][:core_site]['ha.zookeeper.quorum'] = node[:opsworks][:layers][:zookeeper][:instances].keys.sort.map{|x| x + ':' + node[:hadoop][:zookeeper_port]}.join(',')
else
  node.default[:hadoop][:core_site]['ha.zookeeper.quorum'] = "zookeeper1:2181,zookeeper2:2181,zookeeper3:2181"
end
core_site_vars = { :options => node[:hadoop][:core_site] }
template "#{chef_conf_dir}/core-site.xml" do
  source "generic-site.xml.erb"
  mode 0644
  owner "hdfs"
  group "hdfs"
  action :create
  variables core_site_vars
end


# Setting the hdfs-site.xml
if node[:hadoop][:opsworks]
  node.default[:hadoop][:hdfs_site]["dfs.ha.namenodes.#{node[:hadoop][:hdfs_site]['dfs.nameservices']}"] = node[:opsworks][:layers][:hadoop_namenode][:instances].keys.sort.join(",")
  node[:opsworks][:layers][:hadoop_namenode][:instances].each do |instance_name, instance|
    node.default[:hadoop][:hdfs_site]["dfs.namenode.rpc-address.#{node[:hadoop][:hdfs_site]['dfs.nameservices']}.#{instance_name}"] = "hdfs://#{instance_name}:#{node[:hadoop][:namenode_port]}"
    node.default[:hadoop][:hdfs_site]["dfs.namenode.http-address.#{node[:hadoop][:hdfs_site]['dfs.nameservices']}.#{instance_name}"] = "hdfs://#{instance_name}:50070"
  end
  node.default[:hadoop][:hdfs_site]['dfs.namenode.shared.edits.dir'] = "qjournal://#{node[:opsworks][:layers][:hadoop_journalnode][:instances].keys.sort.map{|x| x + ':' + node[:hadoop][:journalnode_port]}.join(';')}/#{node[:hadoop][:hdfs_site]['dfs.nameservices']}"
else
  node.default[:hadoop][:hdfs_site]["dfs.ha.namenodes.#{node[:hadoop][:hdfs_site]['dfs.nameservices']}"] = "namenode1,namenode2"
  node.default[:hadoop][:hdfs_site]["dfs.namenode.rpc-address.#{node[:hadoop][:hdfs_site]['dfs.nameservices']}.namenode1"] = "hdfs://namenode1:#{node[:hadoop][:namenode_port]}"
  node.default[:hadoop][:hdfs_site]["dfs.namenode.rpc-address.#{node[:hadoop][:hdfs_site]['dfs.nameservices']}.namenode2"] = "hdfs://namenode2:#{node[:hadoop][:namenode_port]}"
  node.default[:hadoop][:hdfs_site]["dfs.namenode.http-address.#{node[:hadoop][:hdfs_site]['dfs.nameservices']}.namenode1"] = "hdfs://namenode1:50070"
  node.default[:hadoop][:hdfs_site]["dfs.namenode.http-address.#{node[:hadoop][:hdfs_site]['dfs.nameservices']}.namenode2"] = "hdfs://namenode2:50070"
  node.default[:hadoop][:hdfs_site]['dfs.namenode.shared.edits.dir'] = "qjournal://journalnode1:8485;journalnode2:8485;journalnode3:8485;/#{node[:hadoop][:hdfs_site]['dfs.nameservices']}"
end
hdfs_site_vars = { :options => node[:hadoop][:hdfs_site] }
#hdfs_site_vars[:options]['fs.default.name'] = "hdfs://#{namenode[:ipaddress]}:#{node[:hadoop][:namenode_port]}"
# TODO dfs.secondary.http.address should have port made into an attribute - maybe
#hdfs_site_vars[:options]['dfs.secondary.http.address'] = "#{secondary_namenode[:ipaddress]}:50090" if secondary_namenode

template "#{chef_conf_dir}/hdfs-site.xml" do
  source "generic-site.xml.erb"
  mode 0644
  owner "hdfs"
  group "hdfs"
  action :create
  variables hdfs_site_vars
end

resourcemanager = find_matching_nodes(["hadoop_resourcemanager"]).first

node.default[:hadoop][:mapred_site]['mapred.job.tracker'] = "#{resourcemanager[:fqdn]}:#{node[:hadoop][:resourcemanager_port]}" if resourcemanager
mapred_site_vars = { :options => node[:hadoop][:mapred_site] }

template "#{chef_conf_dir}/mapred-site.xml" do
  source "generic-site.xml.erb"
  mode 0644
  owner "hdfs"
  group "hdfs"
  action :create
  variables mapred_site_vars
end

if node[:hostname].include?('namenode')
  node.default[:hadoop][:yarn_site]['yarn.resourcemanager.hostname'] = node[:hostname]
else
  resourcemanager = search_for_nodes(["hadoop_resourcemanager"], 'fqdn').first
  node.default[:hadoop][:yarn_site]['yarn.resourcemanager.hostname'] = resourcemanager
end
yarn_site_vars = { :options => node[:hadoop][:yarn_site] }
template "#{chef_conf_dir}/yarn-site.xml" do
  source "generic-site.xml.erb"
  mode 0644
  owner "hdfs"
  group "hdfs"
  action :create
  variables yarn_site_vars
end

template "#{chef_conf_dir}/hadoop-env.sh" do
  mode 0755
  owner "hdfs"
  group "hdfs"
  action :create
  variables( :options => node[:hadoop][:hadoop_env] )
end

template "#{chef_conf_dir}/log4j.properties" do
  source "generic.properties.erb"
  mode 0644
  owner "hdfs"
  group "hdfs"
  action :create
  variables( :properties => node[:hadoop][:log4j] )
end

namenode_servers = find_matching_nodes(["hadoop_namenode", "hadoop_secondary_namenode"])
masters = namenode_servers.map { |node| node[:fqdn] }

template "#{chef_conf_dir}/masters" do
  source "master_slave.erb"
  mode 0644
  owner "hdfs"
  group "hdfs"
  action :create
  variables( :nodes => masters )
end

datanode_servers = find_matching_nodes(["hadoop_datanode"])
slaves = datanode_servers.map { |node| node[:fqdn] }

template "#{chef_conf_dir}/slaves" do
  source "master_slave.erb"
  mode 0644
  owner "hdfs"
  group "hdfs"
  action :create
  variables( :nodes => slaves )
end

template "/usr/lib/hadoop-0.20-mapreduce/bin/hadoop-config.sh" do
  source "hadoop_config.erb"
  mode 0755
  owner "root"
  group "root"
  variables(
    :java_home => node[:hadoop][:hadoop_env]['java_home']
  )
end

execute "update hadoop alternatives" do
  command "update-alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/#{node[:hadoop][:conf_dir]} 50"
end

if is_journalnode
  service "hadoop-hdfs-journalnode" do
    action [ :restart, :enable ]
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
      command "hdfs namenode -bootstrapStandby"
    end
  end
  service "hadoop-hdfs-namenode" do
    action [ :restart, :enable ]
  end
  service "hadoop-hdfs-zkfc" do
    action [ :restart, :enable ]
  end
end

if is_resourcemanager
  execute "create yarn log directories" do
    user "hdfs"
    command "hadoop fs -mkdir -p /var/log/hadoop-yarn"
  end

  execute "change permissions of yarn log directories" do
    user "hdfs"
    command "hadoop fs -chown yarn:mapred /var/log/hadoop-yarn"
  end
  service "hadoop-yarn-resourcemanager" do
    action [ :restart, :enable ]
  end
end
