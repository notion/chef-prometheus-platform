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

def h_to_a(obj)
  if obj.is_a?(Hash)
    obj =
      if obj.keys.map { |k| !k.to_s.start_with?('index_') }.any?
        obj.map { |k, v| [k, h_to_a(v)] }.to_h
      else
        obj.values
      end
  end
  obj.is_a?(Array) ? obj.map { |v| h_to_a(v) } : obj
end

prometheus_home = "#{node[cookbook_name]['prefix_home']}/prometheus"
prometheus_config_filename = node[cookbook_name]['config_filename']
prometheus_config = h_to_a(node.run_state[cookbook_name]['config'].to_hash)

template "#{prometheus_home}/#{prometheus_config_filename}" do
  source 'config.yml.erb'
  variables config: prometheus_config
  user node[cookbook_name]['user']
  group node[cookbook_name]['group']
  mode '0600'
end

# Set-up prometheus rules directory
[
  node[cookbook_name]['rules_dir'],
  node[cookbook_name]['launch_config']['storage.local.path']
].each do |dir|
  directory dir do
    owner node[cookbook_name]['user']
    group node[cookbook_name]['group']
  end
end

# Deploy alerting and recording rules from data_bag
data_bag = node[cookbook_name]['data_bag']
unless data_bag['name'].nil?
  content = data_bag_item(
    data_bag['name'],
    data_bag['item']
  )[data_bag['key']]

  rules_dir = node[cookbook_name]['rules_dir']
  template "#{rules_dir}/#{data_bag['item']}.rules" do
    source 'rules.erb'
    user node[cookbook_name]['user']
    group node[cookbook_name]['group']
    mode '0600'
    variables content: content
    notifies :restart, 'systemd_unit[prometheus_server.service]', :delayed
  end
end

# Generate alertmanager config
alert = node[cookbook_name]['alertmanager']
directory alert['launch_config']['storage.path'] do
  owner node[cookbook_name]['user']
  group node[cookbook_name]['group']
end

alertmgr_home = "#{node[cookbook_name]['prefix_home']}/alertmanager"
alertmgr_conffile = node[cookbook_name]['alertmanager']['config_filename']
alertmgr_config = h_to_a(node[cookbook_name]['alertmanager']['config'].to_hash)

template "#{alertmgr_home}/#{alertmgr_conffile}" do
  source 'config.yml.erb'
  variables config: alertmgr_config
  user node[cookbook_name]['user']
  group node[cookbook_name]['group']
  mode '0600'
end
