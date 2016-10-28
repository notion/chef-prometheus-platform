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

aerospike_exporter = node['prometheus-platform']['exporter']['aerospike']

# Generate/deploy config on prometheus server
if node['prometheus-platform']['master_host'] == node['fqdn']
  targets =
    aerospike_exporter['targets'].to_a

  unless targets.nil? || targets.empty?
    node.run_state['prometheus-platform']['config']['scrape_configs'] =
      node.run_state['prometheus-platform']['config']['scrape_configs'] +
      ['job_name' => 'aerospike',
       'scrape_interval' => '1m',
       'scrape_timeout' => '30s',
       'static_configs' => ['targets' => targets]]
  end
end

# Install aerospike_exporter on node if defined as a target in prometheus
targets = aerospike_exporter['targets'].to_a

unless targets.nil? || targets.empty?
  targets.each do |target| # rubocop:disable Metrics/BlockLength
    not_target = !target.include?(node['fqdn'])
    next if not_target

    directory aerospike_exporter['path'] do
      owner node['prometheus-platform']['user']
      group node['prometheus-platform']['group']
    end

    # Install dependencies
    %w(make git golang-bin glibc-static).each do |pkg|
      package "install #{pkg} for aerospike exporter" do
        package_name pkg
        retries node['prometheus-platform']['package_retries']
      end
    end

    # Checkout aerospike exporter source
    git_branch =
      node['prometheus-platform']['exporter']['aerospike']['git_branch']
    git aerospike_exporter['path'] do
      repository node['prometheus-platform']['exporter']['aerospike']['repo']
      revision git_branch
      user node['prometheus-platform']['user']
      group node['prometheus-platform']['group']
      action :checkout
    end

    # Build aerospike exporter binary using go
    execute 'build aerospike exporter' do
      command <<-EOF
        export GOPATH=/usr/lib/golang
        export GOROOT=#{aerospike_exporter['path']}
        go get
        unset GOPATH
        unset GOROOT
        make
      EOF
      cwd aerospike_exporter['path']
      creates 'aerospike_exporter'
    end

    file "#{aerospike_exporter['path']}/aerospike_exporter" do
      user node['prometheus-platform']['user']
      group node['prometheus-platform']['group']
      mode '0700'
    end

    # Create systemd unit for exporter
    exporter_listen =
      node['prometheus-platform']['exporter']['aerospike']['listen_addr']
    as_node =
      node['prometheus-platform']['exporter']['aerospike']['node']
    unit = {
      'Unit' => {
        'Description' => 'aerospike exporter',
        'After' => 'network.target'
      },
      'Service' => {
        'Type' => 'simple',
        'User' => node['prometheus-platform']['user'],
        'Group' => node['prometheus-platform']['group'],
        'Restart' => 'on-failure',
        'ExecStart' =>
          "#{aerospike_exporter['path']}/aerospike_exporter \
            -listen #{exporter_listen} \
            -node #{as_node}"
      },
      'Install' => {
        'WantedBy' => 'multi-user.target'
      }
    }
    # Deploy systemd unit
    systemd_unit 'aerospike_exporter.service' do
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
