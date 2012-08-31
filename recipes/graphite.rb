if Chef::Config[:solo]
  graphite_hosts = []
else
  graphite_hosts = search(:node, "role:#{node['ganglia']['server_role']} AND chef_environment:#{node.chef_environment}").map do |node|
    node[:graphite][:carbon][:line_receiver_interface]
  end
end

if graphite_hosts.empty?
  graphite_hosts << "localhost"
end

template "/usr/local/sbin/ganglia_graphite.rb" do
  source "ganglia_graphite.rb.erb"
  mode "744"
  variables :graphite_host => graphite_hosts.first
end

cron "ganglia_graphite" do
  command [
    "flock /tmp/ganglia_graphite.lock -c '",
      "(/usr/local/sbin/ganglia_graphite.rb 2>&1)",
      "| logger -i -t ganglia_graphite",
    "'"
  ].join(' ')
end
