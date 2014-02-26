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

if is_journalnode
  service "hadoop-hdfs-journalnode" do
    action [ :restart, :enable ]
  end
end