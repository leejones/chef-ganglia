graphite_hosts = search(:node, "role:#{node['ganglia']['server_role']} AND chef_environment:#{node.chef_environment}").map {|node| node.ipaddress}
if graphite_hosts.empty?
  graphite_hosts << "localhost"
end

template "/usr/local/sbin/ganglia_graphite.rb" do
  source "ganglia_graphite.rb.erb"
  mode "744"
  variables :graphite_host => graphite_hosts.first
end

cron "ganglia_graphite" do
  command "/usr/local/sbin/ganglia_graphite.rb"
end
