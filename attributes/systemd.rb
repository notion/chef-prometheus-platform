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

# Cluster Search (cluster-search) is a simple cookbook library which simplify
# the search of members of a cluster. It relies on Chef search with a size
# guard (to avoid inconsistencies during initial convergence) and allows a
# fall-back to hostname listing if user does not want to rely on searches
# (because of chef-solo for example).

# Systemd service units, include config
# Master
prometheus_home = "#{node['prometheus-platform']['prefix_home']}/prometheus"
has_alertmanager = node['prometheus-platform']['has_alertmanager']
storage_retention = node['prometheus-platform']['storage_retention']

default['prometheus-platform']['prometheus_server']['start_cmd'] =
  "#{node['prometheus-platform']['bin']} -config.file \
    #{prometheus_home}/#{node['prometheus-platform']['config_filename']} \
    #{'-alertmanager.url=http://localhost:9093' if has_alertmanager} \
    #{"-storage.local.retention=#{storage_retention}" if storage_retention}"

start_cmd = node['prometheus-platform']['prometheus_server']['start_cmd']

default['prometheus-platform']['prometheus_server']['unit'] = {
  'Unit' => {
    'Description' => 'Prometheus server',
    'After' => 'network.target'
  },
  'Service' => {
    'Type' => 'simple',
    'User' => node['prometheus-platform']['user'],
    'Group' => node['prometheus-platform']['group'],
    'WorkingDirectory' => prometheus_home,
    'LimitNOFILE' => 655_36,
    'SyslogIdentifier' => 'prometheus-server',
    'Restart' => 'on-failure',
    'ExecStart' => start_cmd
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}

# Node exporter
prometheus_node_exporter_home =
  "#{node['prometheus-platform']['prefix_home']}/prometheus_node"
prometheus_node_start_cmd = "#{prometheus_node_exporter_home}/node_exporter"

default['prometheus-platform']['prometheus_node']['unit'] = {
  'Unit' => {
    'Description' => 'Prometheus node exporter',
    'After' => 'network.target'
  },
  'Service' => {
    'Type' => 'simple',
    'User' => node['prometheus-platform']['user'],
    'Group' => node['prometheus-platform']['group'],
    'WorkingDirectory' => prometheus_node_exporter_home,
    'SyslogIdentifier' => 'prometheus-node',
    'Restart' => 'on-failure',
    'ExecStart' => prometheus_node_start_cmd
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}

# Alertmanager
prometheus_alertmanager_home =
  node['prometheus-platform']['alertmanager_path']
alertmanager_config_file =
  node['prometheus-platform']['alertmanager']['config_filename']
prometheus_alertmanager_start_cmd =
  "#{prometheus_alertmanager_home}/bin/alertmanager \
  -config.file=#{prometheus_alertmanager_home}/#{alertmanager_config_file}"

default['prometheus-platform']['prometheus_alertmanager']['unit'] = {
  'Unit' => {
    'Description' => 'Prometheus alert manager',
    'After' => 'network.target'
  },
  'Service' => {
    'Type' => 'simple',
    'User' => node['prometheus-platform']['user'],
    'Group' => node['prometheus-platform']['group'],
    'WorkingDirectory' => prometheus_alertmanager_home,
    'SyslogIdentifier' => 'prometheus-node',
    'Restart' => 'on-failure',
    'ExecStart' => prometheus_alertmanager_start_cmd
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
