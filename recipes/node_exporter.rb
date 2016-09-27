#
# Copyright (c) 2016 Sam4Mobile
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

node_exporter = node['prometheus-platform']['exporter']['node']

# Generate prometheus scrape config
if node['prometheus-platform']['master_host'] == node['fqdn']
  targets =
    node_exporter['targets'].map { |target| "#{target}:9100" }.to_a

  unless targets.nil? || targets.empty?
    node.run_state['prometheus-platform']['config']['scrape_configs'] =
      node.run_state['prometheus-platform']['config']['scrape_configs'] +
      ['job_name' => 'node',
       'scrape_interval' => '5s',
       'static_configs' => ['targets' => targets]]
  end
end

# Install prometheus node_exporter on node if defined as a target in
# prometheus server
node_exporter['targets'].each do |target|
  next unless target == node['fqdn']
  [
    node['prometheus-platform']['prefix_root'],
    node['prometheus-platform']['prefix_home'],
    node['prometheus-platform']['prefix_bin']
  ].uniq.each do |dir_path|
    directory "prometheus-platform-node:#{dir_path}" do
      path dir_path
      owner 'root'
      group 'root'
      mode '0755'
      recursive true
      action :create
    end
  end

  ark 'prometheus_node' do
    action :install
    url node['prometheus-platform']['node_mirror']
    prefix_root node['prometheus-platform']['prefix_root']
    prefix_home node['prometheus-platform']['prefix_home']
    prefix_bin node['prometheus-platform']['prefix_bin']
    has_binaries []
    checksum node['prometheus-platform']['node_checksum']
    version node['prometheus-platform']['node_version']
    owner node['prometheus-platform']['user']
    group node['prometheus-platform']['group']
  end

  systemd_unit 'prometheus_node.service' do
    enabled true
    active true
    masked false
    static false
    content node[cookbook_name]['prometheus_node']['unit']
    triggers_reload true
    action [:create, :enable, :start]
  end
end
