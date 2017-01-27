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

# tar may not be installed by default
package 'tar' do
  retries node[cookbook_name]['package_retries']
end

# Create prefix directories
[
  node[cookbook_name]['prefix_root'],
  node[cookbook_name]['prefix_home'],
  node[cookbook_name]['prefix_bin']
].uniq.each do |dir_path|
  directory "prometheus-platform:#{dir_path}" do
    path dir_path
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
    action :create
  end
end

# Prometheus server
ark 'prometheus' do
  action :install
  url node[cookbook_name]['server_mirror']
  prefix_root node[cookbook_name]['prefix_root']
  prefix_home node[cookbook_name]['prefix_home']
  prefix_bin node[cookbook_name]['prefix_bin']
  has_binaries []
  checksum node[cookbook_name]['checksum']
  version node[cookbook_name]['version']
end

# Prometheus alertmanager
ark 'alertmanager' do
  action :install
  url node[cookbook_name]['alertmanager']['download_url']
  prefix_root node[cookbook_name]['prefix_root']
  prefix_home node[cookbook_name]['prefix_home']
  prefix_bin node[cookbook_name]['prefix_bin']
  has_binaries []
  checksum node[cookbook_name]['alertmanager']['checksum']
  version node[cookbook_name]['alertmanager']['version']
end
