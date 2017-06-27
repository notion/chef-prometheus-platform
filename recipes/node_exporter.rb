#
# Copyright (c) 2016-2017 Sam4Mobile, 2017 Make.org
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

node_exporter = node[cookbook_name]['exporter']['node']

# Generate prometheus scrape config
if node[cookbook_name]['master_host'] == node['fqdn']
  targets =
    node_exporter['targets'].map { |target| "#{target}:9100" }.to_a

  unless targets.nil? || targets.empty?
    node.run_state[cookbook_name]['config']['scrape_configs']['index_node'] = {
      'job_name' => 'node',
      'scrape_interval' => '5s',
      'static_configs' => ['targets' => targets]
    }
  end
end

# Install prometheus node_exporter on node if defined as a target in
# prometheus server
node_exporter['targets'].each do |target| # rubocop:disable Metrics/BlockLength
  next unless target == node['fqdn']
  [
    node[cookbook_name]['prefix_root'],
    node[cookbook_name]['prefix_home'],
    node[cookbook_name]['prefix_bin']
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

  # Install prometheus_node exporter
  ark 'prometheus_node' do
    action :install
    url node[cookbook_name]['node_mirror']
    prefix_root node[cookbook_name]['prefix_root']
    prefix_home node[cookbook_name]['prefix_home']
    prefix_bin node[cookbook_name]['prefix_bin']
    has_binaries []
    checksum node[cookbook_name]['node_checksum']
    version node[cookbook_name]['node_version']
    owner node[cookbook_name]['user']
    group node[cookbook_name]['group']
  end

  # Deploy systemd unit
  systemd_unit 'prometheus_node.service' do
    enabled true
    active true
    masked false
    static false
    content node[cookbook_name]['prometheus_node']['unit']
    triggers_reload true
    action %i[create enable start]
  end
end
