module Extensions
  def search_for_nodes(types = [], attribute = nil)
    nodes = find_matching_nodes(types)
    nodes.map do |node|
      select_attribute(node, attribute)
    end
  end

  # Searches for nodes, working with vanilla chef or with opsworks
  # Expects a list of node types to be queries, and returns every node in the list
  def find_matching_nodes(types)
    Chef::Log.debug("Searching for nodes with within these types: \"#{types}\"")
    if node[:hadoop][:opsworks]
      result_map = {}
      types.each do |type|
        node[:opsworks][:layers][type][:instances].each do |instance_name, instance|
          result_map[instance_name] = instance
        end
      end
      result_map.values
    else
      results = []
      types_query = types.map{ |t| "recipes:cloudera\\:\\:#{t}"}.join(" OR ")
      query = "chef_environment:#{node.chef_environment} AND (#{types_query})"
      Chef::Search::Query.new.search(:node, query) { |o| results << o }
      results
    end
  end

  def select_attribute(node, attribute = nil)
    if attribute
      keys = attribute.split('.')
      value = node
      keys.each do |key|
        value = value[key]
      end
      Chef::Log.debug("Selected attribute: #{attribute.inspect} for node: #{node.name.inspect} with value: #{value.inspect}")
      value
    else
      if node.has_key? 'cloud' and node['cloud'].has_key? 'local_ipv4'
        value = node['cloud']['local_ipv4']
        Chef::Log.debug("Selected attribute: \"cloud.local_ipv4\" for node: #{node.name.inspect} with value: #{value.inspect}")
        value
      else
        value = node['ipaddress']
        Chef::Log.debug("Selected attribute: \"ipaddress\" for node: #{node.name.inspect} with value: #{value.inspect}")
        value
      end
    end
  end
end
