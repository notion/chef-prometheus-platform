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

# Version of aerospike_exporter
default['prometheus-platform']['exporter']['aerospike']['git_branch'] =
  'master'

default['prometheus-platform']['exporter']['aerospike']['repo'] =
  'https://github.com/fphilippon/asprom.git'

# Directory where aerospike exporter is installed
default['prometheus-platform']['exporter']['aerospike']['path'] =
  "#{node['prometheus-platform']['prefix_home']}/aerospike_exporter"

# Prometheus aerospike targets
default['prometheus-platform']['exporter']['aerospike']['targets'] = []

# Listening address for aerospike_exporter
default['prometheus-platform']['exporter']['aerospike']['listen_addr'] =
  ':9145'

# Aerospike node to scrap
default['prometheus-platform']['exporter']['aerospike']['node'] =
  '127.0.0.1:3000'
