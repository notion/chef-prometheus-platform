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

auto_restart = node['prometheus-platform']['auto_restart']

# Prometheus Service
p_home = "#{node['prometheus-platform']['prefix_home']}/prometheus"
p_conffile = node['prometheus-platform']['config_filename']

systemd_unit 'prometheus_server.service' do
  enabled true
  active true
  masked false
  static false
  content node[cookbook_name]['prometheus_server']['unit']
  triggers_reload true
  action [:create, :enable, :start]
  subscribes :restart, "template[#{p_home}/#{p_conffile}]" if auto_restart
end

# Alertmanager Service (only if config is non-empty)
alert_action = [:create, :enable, :start]
if node['prometheus-platform']['alertmanager']['config'].empty?
  alert_action = [:create, :disable, :stop]
  auto_restart = false
end

am_home = "#{node['prometheus-platform']['prefix_home']}/alertmanager"
am_conffile = node['prometheus-platform']['alertmanager']['config_filename']

systemd_unit 'prometheus_alertmanager.service' do
  enabled true
  active true
  masked false
  static false
  content node[cookbook_name]['prometheus_alertmanager']['unit']
  triggers_reload true
  action alert_action
  subscribes :restart, "template[#{am_home}/#{am_conffile}]" if auto_restart
end
