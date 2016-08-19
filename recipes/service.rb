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

systemd_unit 'prometheus_server.service' do
  enabled true
  active true
  masked false
  static false
  content node[cookbook_name]['prometheus_server']['unit']
  triggers_reload true
  action [:create, :enable, :start]
  only_if { node.run_state['prometheus-platform']['master'] }
end

systemd_unit 'prometheus_node.service' do
  enabled true
  active true
  masked false
  static false
  content node[cookbook_name]['prometheus_node']['unit']
  triggers_reload true
  action [:create, :enable, :start]
  only_if { node.run_state['prometheus-platform']['node'] }
end

# Start alertmanager only if config has been done
unless node['prometheus-platform']['master']['alertmanager']['config'].empty?
  systemd_unit 'prometheus_alertmanager.service' do
    enabled true
    active true
    masked false
    static false
    content node[cookbook_name]['prometheus_alertmanager']['unit']
    triggers_reload true
    action [:create, :enable, :start]
    only_if { node['prometheus-platform']['master']['has_alertmanager'] }
  end
end
