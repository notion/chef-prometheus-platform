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

if node['prometheus-platform']['grafana_host'] == node['fqdn']

  # Install dependencies
  %w(initscripts fontconfig).each do |pkg|
    package pkg do
      retries node['prometheus-platform']['package_retries']
    end
  end

  # Install grafana with remote rpm file
  package 'grafana' do
    provider Chef::Provider::Package::Rpm
    source node['prometheus-platform']['grafana']['package']
  end

  # Deploy grafana config
  config = node['prometheus-platform']['grafana']['config']
  template '/etc/grafana/grafana.ini' do
    source 'config.ini.erb'
    variables config: node['prometheus-platform']['grafana']['config']
    group 'grafana'
    mode '0640'
    only_if { config.nil? || config.empty? }
  end

  # Start grafana service
  service 'grafana-server' do
    action [:enable, :start]
  end
end
