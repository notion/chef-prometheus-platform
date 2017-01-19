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

# Install jmx_exporter
default['prometheus-platform']['exporter']['jmx']['install'] = false

# Version of jmx_exporter
default['prometheus-platform']['exporter']['jmx']['version'] = '0.6'
version = node['prometheus-platform']['exporter']['jmx']['version']

# Maven repository where jar is hosted
maven_base_url =
  'http://central.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_httpserver'
jar = "jmx_prometheus_httpserver-#{version}-jar-with-dependencies.jar"

default['prometheus-platform']['exporter']['jmx']['repo'] =
  "#{maven_base_url}/#{version}/#{jar}"

# Directory where jmx exporter is installed
default['prometheus-platform']['exporter']['jmx']['path'] =
  "#{node['prometheus-platform']['prefix_home']}/jmx_exporter"

# Java package to install by platform
default['prometheus-platform']['exporter']['jmx']['java'] = {
  'centos' => 'java-1.8.0-openjdk-headless'
}

# Default options for prometheus jmx http server
default['prometheus-platform']['exporter']['jmx']['java_opts'] = nil

# Prometheus jmx targets
default['prometheus-platform']['exporter']['jmx']['targets'] = []

# Prometheus jmx_exporter config for targets
default['prometheus-platform']['exporter']['jmx']['config'] = {}
