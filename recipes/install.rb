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

user = node['prometheus-platform']['user']
group = node['prometheus-platform']['group']

# tar may not be installed by default
package 'tar' do
  retries node['prometheus-platform']['package_retries']
end

iam_server = node['prometheus-platform']['master_host'] == node['fqdn']

if iam_server
  # Create prefix directories
  [
    node['prometheus-platform']['prefix_root'],
    node['prometheus-platform']['prefix_home'],
    node['prometheus-platform']['prefix_bin']
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
    url node['prometheus-platform']['server_mirror']
    prefix_root node['prometheus-platform']['prefix_root']
    prefix_home node['prometheus-platform']['prefix_home']
    prefix_bin node['prometheus-platform']['prefix_bin']
    has_binaries []
    checksum node['prometheus-platform']['checksum']
    version node['prometheus-platform']['version']
    owner user
  end

  # Prometheus alertmanager
  if node['prometheus-platform']['has_alertmanager'] && iam_server
    %w(make git golang-bin glibc-static).each do |pkg|
      package pkg do
        retries node['prometheus-platform']['package_retries']
      end
    end
    alertmanager_path =
      node['prometheus-platform']['alertmanager_path']

    alertmanager_repo_path =
      "#{alertmanager_path}/src/github.com/prometheus/alertmanager"
    alertmanager_bin =
      "#{alertmanager_repo_path}/alertmanager"

    directory "#{alertmanager_path}/src/github.com/prometheus/alertmanager" do
      owner user
      group group
      mode '0775'
      recursive true
    end

    git "#{alertmanager_path}/src/github.com/prometheus/alertmanager" do
      repository node['prometheus-platform']['alertmanager_source']
      revision node['prometheus-platform']['alertmanager_rev']
      user user
      group group
      action :checkout
    end

    execute 'set rights for alertmanager' do
      command <<-EOF
        chown -R #{user}:#{group} /opt/alertmanager
      EOF
      cwd "#{alertmanager_path}/src/github.com/prometheus/alertmanager"
      creates 'alertmanager'
    end

    execute 'build alertmanager' do
      command <<-EOF
        export GOPATH=#{alertmanager_path}
        make build
      EOF
      user user
      group group
      cwd "#{alertmanager_path}/src/github.com/prometheus/alertmanager"
      creates 'alertmanager'
    end

    link "#{alertmanager_path}/bin/alertmanager" do
      to alertmanager_bin
    end
  end
end
