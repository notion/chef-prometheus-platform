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

# prometheus package
default['prometheus-platform']['version'] = '1.0.1'
prometheus_version = node['prometheus-platform']['version']
default['prometheus-platform']['checksum'] =
  '2ef4f7e416c6fdc07396be9a72f69670733a0c6f72060c8bb42d6ff3410eae96'

# Where to get the tarball for prometheus server
default['prometheus-platform']['server_mirror_base'] =
  'https://github.com/prometheus/prometheus/releases/download/'
prometheus_mirror = node['prometheus-platform']['server_mirror_base']
server_package_name = "prometheus-#{prometheus_version}.linux-amd64.tar.gz"
default['prometheus-platform']['server_mirror'] =
  "#{prometheus_mirror}/v#{prometheus_version}/#{server_package_name}"

# Prometheus alert manager
default['prometheus-platform']['master']['has_alertmanager'] = true
default['prometheus-platform']['master']['alertmanager_path'] =
  '/opt/alertmanager'

default['prometheus-platform']['master']['alertmanager_source'] =
  'https://github.com/prometheus/alertmanager.git'
default['prometheus-platform']['master']['alertmanager_rev'] = 'release-0.3'

# Prometheus alertmanager config filename to load (generated through template)
default['prometheus-platform']['master']['alertmanager']['config_filename'] =
  'alertmanager.yml'

# Prometheus node exporter
default['prometheus-platform']['node_version'] = '0.12.0'
prometheus_node_version = node['prometheus-platform']['node_version']

# Where to get the tarball for prometheus node exporter
default['prometheus-platform']['node_mirror_base'] =
  'https://github.com/prometheus/node_exporter/releases/download/'
node.default['prometheus-platform']['node_checksum'] =
  'd48de5b89dac04aca751177afaa9b0919e5b3d389364d40160babc00d63aac7b'
prometheus_mirror = node['prometheus-platform']['node_mirror_base']
node_package_name =
  "node_exporter-#{prometheus_node_version}.linux-amd64.tar.gz"
default['prometheus-platform']['node_mirror'] =
  "#{prometheus_mirror}/#{prometheus_node_version}/#{node_package_name}"

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

# Prometheus rules directory
default['prometheus-platform']['rules_dir'] =
  "#{node['prometheus-platform']['prefix_home']}/prometheus/rules"

# Alerting and recording rules loaded through a data_bag
default['prometheus-platform']['data_bag']['name'] = nil
# Data bag item to load
default['prometheus-platform']['data_bag']['item'] = nil
# Key used to load the value in data bag item containing the data
default['prometheus-platform']['data_bag']['key'] = nil

# Alertmanager config
# Alertmanager will not be started if his config is empty
default['prometheus-platform']['master']['alertmanager']['config'] = {}
