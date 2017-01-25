#
# Copyright (c) 2016-2017 Sam4Mobile
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

# Prometheus package and version
default['prometheus-platform']['version'] = '1.4.1'
prometheus_version = node['prometheus-platform']['version']
default['prometheus-platform']['checksum'] =
  '0511576f19ff060712d19fb343957113f6a47b2d2edcbe4889eaaa844b31f516'
# Where to get the tarball for Prometheus server
default['prometheus-platform']['server_mirror_base'] =
  'https://github.com/prometheus/prometheus/releases/download'
prometheus_mirror = node['prometheus-platform']['server_mirror_base']
server_package_name = "prometheus-#{prometheus_version}.linux-amd64.tar.gz"
default['prometheus-platform']['server_mirror'] =
  "#{prometheus_mirror}/v#{prometheus_version}/#{server_package_name}"

# Prometheus alert manager (will be installed on prometheus server)
default['prometheus-platform']['alertmanager']['enable'] = true
# Alert Manager version
default['prometheus-platform']['alertmanager']['version'] = '0.5.1'
alertmgr_version = node['prometheus-platform']['alertmanager']['version']
default['prometheus-platform']['alertmanager']['checksum'] =
  '9df9f0eb0061c8ead1b89060b851ea389fbdf6c1adc8513b40f6f4b90f4de932'
# Where to get the tarball for Alert Manager
default['prometheus-platform']['alertmanager']['base_url'] =
  'https://github.com/prometheus/alertmanager/releases/download'
alertmgr_base_url = node['prometheus-platform']['alertmanager']['base_url']
alertmgr_pkg = "alertmanager-#{alertmgr_version}.linux-amd64.tar.gz"
default['prometheus-platform']['alertmanager']['download_url'] =
  "#{alertmgr_base_url}/v#{alertmgr_version}/#{alertmgr_pkg}"
# Prometheus alertmanager config filename to load (generated through template)
default['prometheus-platform']['alertmanager']['config_filename'] =
  'alertmanager.yml'

# User and group of prometheus process
default['prometheus-platform']['user'] = 'prometheus'
default['prometheus-platform']['group'] = 'prometheus'
# Where to put installation dir
default['prometheus-platform']['prefix_root'] = '/opt'
# Where to link installation dir
default['prometheus-platform']['prefix_home'] = '/opt'
# Where to link binaries
default['prometheus-platform']['prefix_bin'] = '/opt/bin'

# Prometheus default config filename to load (generated through template)
default['prometheus-platform']['config_filename'] = 'prometheus.yml'

# Path to prometheus binary
default['prometheus-platform']['bin'] =
  "#{node['prometheus-platform']['prefix_home']}/prometheus/prometheus"

# Configure retries for the package resources, default = global default (0)
# (mostly used for test purpose
default['prometheus-platform']['package_retries'] = nil

# Prometheus config
default['prometheus-platform']['config'] = {
  'global' => {
    'scrape_interval' => '15s',
    'evaluation_interval' => '15s',
    'external_labels' => {
      'monitor' => 'codelab-monitor'
    }
  },
  'scrape_configs' =>
    ['job_name' => 'prometheus',
     'scrape_interval' => '5s',
     'static_configs' => ['targets' => ['localhost:9090', 'localhost:9100']]]
}

# Prometheus storage retention (default to 2 weeks)
default['prometheus-platform']['storage_retention'] = '21600h'

# Initialize run_state attribute
node.run_state['prometheus-platform'] = {}
node.run_state['prometheus-platform']['config'] =
  node['prometheus-platform']['config'].to_hash

# Prometheus rules directory
default['prometheus-platform']['rules_dir'] =
  "#{node['prometheus-platform']['prefix_home']}/prometheus/rules"

# Alerting and recording rules loaded through a data_bag
default['prometheus-platform']['data_bag']['name'] = nil
# Data bag item to load
default['prometheus-platform']['data_bag']['item'] = nil
# Key used to load the value in data bag item containing the data
default['prometheus-platform']['data_bag']['key'] = nil

# Should we restart service after config update?
default['prometheus-platform']['auto_restart'] = true

# Alertmanager config
# Alertmanager will not be started if his config is empty
default['prometheus-platform']['alertmanager']['config'] = {
  'route' => {
    'receiver' => 'webhook',
    'group_wait' => '30s',
    'group_interval' => '5m',
    'repeat_interval' => '4h'
  },
  'receivers' => [{
    'name' => 'webhook',
    'webhook_configs' => [{
      'url' => 'localhost:8888'
    }]
  }]
}

# Blacklisted exporters (that should be installed used their own recipe,
# not using the provider)
default['prometheus-platform']['blacklisted_exporters'] = %w(jmx node)

# Auto update for exporters
default['prometheus-platform']['exporters_auto_update'] = false
