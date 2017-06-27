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

cookbook_name = 'prometheus-platform'

# Systemd service units, include config
# Master
prometheus_home = "#{node[cookbook_name]['prefix_home']}/prometheus"
launch_config = node[cookbook_name]['launch_config']

start_cmd =
  "#{node[cookbook_name]['bin']} "\
  "#{launch_config.map { |k, v| "-#{k}=#{v}" }.join(' ')}"

default[cookbook_name]['prometheus_server']['unit'] = {
  'Unit' => {
    'Description' => 'Prometheus server',
    'After' => 'network.target'
  },
  'Service' => {
    'Type' => 'simple',
    'User' => node[cookbook_name]['user'],
    'Group' => node[cookbook_name]['group'],
    'WorkingDirectory' => prometheus_home,
    'LimitNOFILE' => 65_536,
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
  "#{node[cookbook_name]['prefix_home']}/prometheus_node"
prometheus_node_start_cmd = "#{prometheus_node_exporter_home}/node_exporter"

default[cookbook_name]['prometheus_node']['unit'] = {
  'Unit' => {
    'Description' => 'Prometheus node exporter',
    'After' => 'network.target'
  },
  'Service' => {
    'Type' => 'simple',
    'User' => node[cookbook_name]['user'],
    'Group' => node[cookbook_name]['group'],
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
alertmgr_home = "#{node[cookbook_name]['prefix_home']}/alertmanager"
alert_launch  = node[cookbook_name]['alertmanager']['launch_config']
alertmgr_start_cmd =
  "#{alertmgr_home}/alertmanager "\
  "#{alert_launch.map { |k, v| "-#{k}=#{v}" }.join(' ')}"

default[cookbook_name]['prometheus_alertmanager']['unit'] = {
  'Unit' => {
    'Description' => 'Prometheus alert manager',
    'After' => 'network.target'
  },
  'Service' => {
    'Type' => 'simple',
    'User' => node[cookbook_name]['user'],
    'Group' => node[cookbook_name]['group'],
    'WorkingDirectory' => alertmgr_home,
    'SyslogIdentifier' => 'prometheus-alertmanager',
    'Restart' => 'on-failure',
    'ExecStart' => alertmgr_start_cmd
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
