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

# Install jmx_exporter
default[cookbook_name]['exporter']['jmx']['install'] = false

# Version of jmx_exporter
default[cookbook_name]['exporter']['jmx']['version'] = '0.6'
version = node[cookbook_name]['exporter']['jmx']['version']

# Maven repository where jar is hosted
maven_base_url =
  'http://central.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_httpserver'
jar = "jmx_prometheus_httpserver-#{version}-jar-with-dependencies.jar"

default[cookbook_name]['exporter']['jmx']['repo'] =
  "#{maven_base_url}/#{version}/#{jar}"

# Directory where jmx exporter is installed
default[cookbook_name]['exporter']['jmx']['path'] =
  "#{node[cookbook_name]['prefix_home']}/jmx_exporter"

# Java package to install by platform
default[cookbook_name]['exporter']['jmx']['java'] = {
  'centos' => 'java-1.8.0-openjdk-headless'
}

# Default options for prometheus jmx http server
default[cookbook_name]['exporter']['jmx']['java_opts'] = nil

# Prometheus jmx targets
default[cookbook_name]['exporter']['jmx']['targets'] = []

# Prometheus jmx_exporter config for targets
default[cookbook_name]['exporter']['jmx']['config'] = {}
