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

# Cluster Search (cluster-search) is a simple cookbook library which simplify
# the search of members of a cluster. It relies on Chef search with a size
# guard (to avoid inconsistencies during initial convergence) and allows a
# fall-back to hostname listing if user does not want to rely on searches
# (because of chef-solo for example).

# Prometheus package and version
default[cookbook_name]['version'] = '1.4.1'
prometheus_version = node[cookbook_name]['version']
default[cookbook_name]['checksum'] =
  '0511576f19ff060712d19fb343957113f6a47b2d2edcbe4889eaaa844b31f516'
# Where to get the tarball for Prometheus server
default[cookbook_name]['server_mirror_base'] =
  'https://github.com/prometheus/prometheus/releases/download'
prometheus_mirror = node[cookbook_name]['server_mirror_base']
server_package_name = "prometheus-#{prometheus_version}.linux-amd64.tar.gz"
default[cookbook_name]['server_mirror'] =
  "#{prometheus_mirror}/v#{prometheus_version}/#{server_package_name}"

# Alert Manager version
default[cookbook_name]['alertmanager']['version'] = '0.5.1'
alertmgr_version = node[cookbook_name]['alertmanager']['version']
default[cookbook_name]['alertmanager']['checksum'] =
  '9df9f0eb0061c8ead1b89060b851ea389fbdf6c1adc8513b40f6f4b90f4de932'
# Where to get the tarball for Alert Manager
default[cookbook_name]['alertmanager']['base_url'] =
  'https://github.com/prometheus/alertmanager/releases/download'
alertmgr_base_url = node[cookbook_name]['alertmanager']['base_url']
alertmgr_pkg = "alertmanager-#{alertmgr_version}.linux-amd64.tar.gz"
default[cookbook_name]['alertmanager']['download_url'] =
  "#{alertmgr_base_url}/v#{alertmgr_version}/#{alertmgr_pkg}"

# User and group of prometheus process
default[cookbook_name]['user'] = 'prometheus'
default[cookbook_name]['group'] = 'prometheus'

# Where to put installation dir
default[cookbook_name]['prefix_root'] = '/opt'
# Where to link installation dir
default[cookbook_name]['prefix_home'] = '/opt'
# Where to link binaries
default[cookbook_name]['prefix_bin'] = '/opt/bin'

# Prometheus default config filename to load (generated through template)
default[cookbook_name]['config_filename'] = 'prometheus.yml'
config_filename = node[cookbook_name]['config_filename']

prometheus_path = "#{node[cookbook_name]['prefix_home']}/prometheus"
# Path to prometheus binary
default[cookbook_name]['bin'] = "#{prometheus_path}/prometheus"

# Configure retries for the package resources, default = global default (0)
# (mostly used for test purpose
default[cookbook_name]['package_retries'] = nil

# Prometheus config
default[cookbook_name]['config'] = {
  'global' => {
    'scrape_interval' => '15s',
    'evaluation_interval' => '15s',
    'external_labels' => {
      'monitor' => 'codelab-monitor'
    }
  },
  'scrape_configs' => {
    'index_1' => # will be converted to array, allow overriding
    {
      'job_name' => 'prometheus',
      'scrape_interval' => '5s',
      'static_configs' => {
        'index_1' => {
          'targets' => ['localhost:9090', 'localhost:9100']
        }
      }
    }
  }
}

# Prometheus launch configuration, defined in systemd unit
default[cookbook_name]['launch_config'] = {
  'config.file' => "#{prometheus_path}/#{config_filename}",
  'alertmanager.url' => 'http://localhost:9093', # if has_alertmanager
  'storage.local.path' => "#{prometheus_path}/data",
  'storage.local.retention' => '21600h' # default 2 weeks
}

# Initialize run_state attribute
node.run_state[cookbook_name] = {}
node.run_state[cookbook_name]['config'] =
  node[cookbook_name]['config'].to_hash

# Prometheus rules directory
default[cookbook_name]['rules_dir'] = "#{prometheus_path}/rules"

# Alerting and recording rules loaded through a data_bag
default[cookbook_name]['data_bag']['name'] = nil
# Data bag item to load
default[cookbook_name]['data_bag']['item'] = nil
# Key used to load the value in data bag item containing the data
default[cookbook_name]['data_bag']['key'] = nil

# Should we restart service after config update?
default[cookbook_name]['auto_restart'] = true

# Alertmanager config
alertmgr_path = "#{node[cookbook_name]['prefix_home']}/alertmanager"

# Prometheus alertmanager config filename to load (generated through template)
default[cookbook_name]['alertmanager']['config_filename'] =
  'alertmanager.yml'
alert_conf = node[cookbook_name]['alertmanager']['config_filename']

# Alertmanager will not be started if his config is empty
default[cookbook_name]['alertmanager']['config'] = {
  # 'route' => {
  #   'receiver' => 'webhook',
  #   'group_wait' => '30s',
  #   'group_interval' => '5m',
  #   'repeat_interval' => '4h'
  # },
  #   'receivers' => [{
  #   'name' => 'webhook',
  #   'webhook_configs' => [{
  #     'url' => 'localhost:8888'
  #   }]
  # }]
}

# Alertmanager launch configuration, defined in systemd unit
default[cookbook_name]['alertmanager']['launch_config'] = {
  'config.file' => "#{alertmgr_path}/#{alert_conf}",
  'storage.path' => "#{alertmgr_path}/data"
}

# Blacklisted exporters (that should be installed used their own recipe,
# not using the provider)
default[cookbook_name]['blacklisted_exporters'] = %w[jmx node]

# Auto update for exporters
default[cookbook_name]['exporters_auto_update'] = false
