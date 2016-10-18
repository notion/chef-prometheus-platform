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

# Version of mysqld_exporter
default['prometheus-platform']['exporter']['mysqld']['git_branch'] = 'master'

default['prometheus-platform']['exporter']['mysqld']['repo'] =
  'https://github.com/prometheus/mysqld_exporter.git'

# User that will run the exporter
default['prometheus-platform']['exporter']['mysqld']['user'] = 'root'

# Group that will run the exporter
default['prometheus-platform']['exporter']['mysqld']['group'] = 'root'

# Directory where mysqld exporter is installed
default['prometheus-platform']['exporter']['mysqld']['path'] =
  "#{node['prometheus-platform']['prefix_home']}/mysqld_exporter"

# Prometheus mysqld targets
default['prometheus-platform']['exporter']['mysqld']['targets'] = []

# Listening address for mysqld_exporter
default['prometheus-platform']['exporter']['mysqld']['addr'] =
  ':9104'
