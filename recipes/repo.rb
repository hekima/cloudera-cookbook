# TODO This needs to actually use the gpg keys... derp.

case node[:platform_family]
when "rhel"

  include_recipe "yum"

  if node[:hadoop][:yum_repo_url]
    yum_repo_url = node[:hadoop][:yum_repo_url]
  else
    platform_major_version = node[:platform_version].to_i
    case platform_major_version
    when 5
      yum_repo_url = "http://archive.cloudera.com/redhat/cdh/#{node[:hadoop][:release]}"
    when 6
      yum_repo_url = "http://archive.cloudera.com/redhat/6/#{node[:kernel][:machine]}/cdh/#{node[:hadoop][:release]}"
    end
  end

  yum_repository "cloudera-cdh5" do
    name "cloudera-cdh5"
    description "Cloudera's Hadoop"
    url yum_repo_url
    action :add
  end

when "debian"

  include_recipe "apt"

  apt_repository "cloudera-cdh#{node[:hadoop][:release]}" do
    uri "[arch=amd64] http://archive.cloudera.com/cdh5/ubuntu/precise/amd64/cdh"
    key "http://archive.cloudera.com/cdh5/ubuntu/precise/amd64/cdh/archive.key"
    distribution "precise-cdh#{node[:hadoop][:release]}"
    components [ "contrib" ]
    deb_src true
    action :add
  end

#  apt_repository "cloudera-impala#{node[:hadoop][:impala_release]}" do
#    uri "[arch=amd64] http://archive.cloudera.com/impala/ubuntu/precise/amd64/impala/"
#    key "http://archive.cloudera.com/impala/ubuntu/precise/amd64/impala/archive.key"
#    distribution "precise-impala#{node[:hadoop][:impala_release]}"
#    components [ "contrib" ]
#    deb_src true
#    action :add
  end
end
