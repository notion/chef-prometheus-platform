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
if node.run_state['prometheus-platform']['master']
  # Generate prometheus config
  prometheus_home = "#{node['prometheus-platform']['prefix_home']}/prometheus/"
  prometheus_config_filename = node['prometheus-platform']['config_filename']
  prometheus_config = node['prometheus-platform']['config'].to_hash

  nodes_exported =
    node.run_state['prometheus-platform']['nodes_exported']

  prometheus_config['scrape_configs'] =
      ['job_name' => 'prometheus_node_exporter',
       'scrape_interval' => '5s',
       'static_configs' => ['targets' => nodes_exported]]

  template "#{prometheus_home}/#{prometheus_config_filename}" do
    source 'config.yml.erb'
    variables config: prometheus_config
    user node['prometheus-platform']['user']
    group node['prometheus-platform']['group']
    mode '0600'
  end

  # Set-up prometheus rules directory
  directory node['prometheus-platform']['rules_dir'] do
    owner node['prometheus-platform']['user']
    group node['prometheus-platform']['group']
  end

  # Deploy alerting  and recording rules from data_bag
  data_bag = node['prometheus-platform']['data_bag']
  unless data_bag['name'].nil?
    content = data_bag_item(
      data_bag['name'],
      data_bag['item']
    )[data_bag['key']]

    rules_dir = node['prometheus-platform']['rules_dir']
    file "#{rules_dir}/#{data_bag['item']}.rule" do
      user node['prometheus-platform']['user']
      group node['prometheus-platform']['group']
      mode '0600'
      content content
    end
  end

  # Generate alertmanager config
  if node['prometheus-platform']['master']['has_alertmanager']
    alertmanager_home =
      node['prometheus-platform']['master']['alertmanager_path']
    alertmanager_config_filename =
      node['prometheus-platform']['master']['alertmanager']['config_filename']
    alertmanager_config =
      node['prometheus-platform']['master']['alertmanager']['config'].to_hash
    template "#{alertmanager_home}/#{alertmanager_config_filename}" do
      source 'config.yml.erb'
      variables config: alertmanager_config
      user node['prometheus-platform']['user']
      group node['prometheus-platform']['group']
      mode '0600'
    end
  end
end
