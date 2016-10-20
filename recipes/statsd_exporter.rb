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

statsd_exporter = node['prometheus-platform']['exporter']['statsd']

# Generate/deploy config on prometheus server
if node['prometheus-platform']['master_host'] == node['fqdn']
  targets =
    statsd_exporter['targets'].to_a

  unless targets.nil? || targets.empty?
    node.run_state['prometheus-platform']['config']['scrape_configs'] =
      node.run_state['prometheus-platform']['config']['scrape_configs'] +
      ['job_name' => 'statsd',
       'scrape_interval' => '1m',
       'scrape_timeout' => '30s',
       'static_configs' => ['targets' => targets]]
  end
end

# Install statsd_exporter on node if defined as a target in prometheus server
targets = statsd_exporter['targets'].to_a

unless targets.nil? || targets.empty?
  targets.each do |target|
    not_target = !target.include?(node['fqdn'])
    next if not_target

    directory statsd_exporter['path'] do
      owner node['prometheus-platform']['user']
      group node['prometheus-platform']['group']
    end

    # Install dependencies
    %w(make git golang-bin glibc-static).each do |pkg|
      package "install #{pkg} for statsd exporter" do
        package_name pkg
        retries node['prometheus-platform']['package_retries']
      end
    end

    # Checkout statsd exporter source
    git_branch =
      node['prometheus-platform']['exporter']['statsd']['git_branch']
    git statsd_exporter['path'] do
      repository node['prometheus-platform']['exporter']['statsd']['repo']
      revision git_branch
      user node['prometheus-platform']['user']
      group node['prometheus-platform']['group']
      action :checkout
    end

    # Build statsd exporter binary using go
    execute 'build statsd exporter' do
      command <<-EOF
        export GOPATH=#{statsd_exporter['path']}
        go get
        go build
      EOF
      cwd statsd_exporter['path']
      creates 'statsd_exporter'
    end

    file "#{statsd_exporter['path']}/statsd_exporter" do
      user node['prometheus-platform']['user']
      group node['prometheus-platform']['group']
      mode '0700'
    end

    # Create systemd unit for exporter
    exporter_listen =
      node['prometheus-platform']['exporter']['statsd']['addr']
    statsd_listen =
      node['prometheus-platform']['exporter']['statsd']['statsd_addr']
    unit = {
      'Unit' => {
        'Description' => 'statsd exporter',
        'After' => 'network.target'
      },
      'Service' => {
        'Type' => 'simple',
        'User' => node['prometheus-platform']['user'],
        'Group' => node['prometheus-platform']['group'],
        'Restart' => 'on-failure',
        'ExecStart' =>
          "#{statsd_exporter['path']}/statsd_exporter \
            -web.listen-address=#{exporter_listen} \
            -statsd.listen-address=#{statsd_listen}"
      },
      'Install' => {
        'WantedBy' => 'multi-user.target'
      }
    }
    # Deploy systemd unit
    systemd_unit 'statsd_exporter.service' do
      enabled true
      active true
      masked false
      static false
      content unit
      triggers_reload true
      action [:create, :enable, :start]
    end
  end
end
