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

# Deploy config on master
if node['prometheus-platform']['master_host'] == node['fqdn']

  prometheus_home = "#{node['prometheus-platform']['prefix_home']}/prometheus"
  prometheus_config_filename = node['prometheus-platform']['config_filename']

  template "#{prometheus_home}/#{prometheus_config_filename}" do
    source 'config.yml.erb'
    variables config: node.run_state['prometheus-platform']['config']
    user node['prometheus-platform']['user']
    group node['prometheus-platform']['group']
    mode '0600'
  end

  # Set-up prometheus rules directory
  directory node['prometheus-platform']['rules_dir'] do
    owner node['prometheus-platform']['user']
    group node['prometheus-platform']['group']
  end

  # Deploy alerting and recording rules from data_bag
  data_bag = node['prometheus-platform']['data_bag']
  unless data_bag['name'].nil?
    content = data_bag_item(
      data_bag['name'],
      data_bag['item']
    )[data_bag['key']]

    rules_dir = node['prometheus-platform']['rules_dir']
    template "#{rules_dir}/#{data_bag['item']}.rules" do
      source 'rules.erb'
      user node['prometheus-platform']['user']
      group node['prometheus-platform']['group']
      mode '0600'
      variables content: content
      notifies :restart, 'systemd_unit[prometheus_server.service]',
               :delayed
    end
  end

  # Generate alertmanager config
  if node['prometheus-platform']['has_alertmanager']
    alertmanager_home =
      node['prometheus-platform']['alertmanager_path']
    alertmanager_config_filename =
      node['prometheus-platform']['alertmanager']['config_filename']
    alertmanager_config =
      node['prometheus-platform']['alertmanager']['config'].to_hash
    template "#{alertmanager_home}/#{alertmanager_config_filename}" do
      source 'config.yml.erb'
      variables config: alertmanager_config
      user node['prometheus-platform']['user']
      group node['prometheus-platform']['group']
      mode '0600'
    end
  end
end
