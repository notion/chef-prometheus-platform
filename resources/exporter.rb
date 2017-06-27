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

default_action :create

property :git_branch, default: 'master'
property :git_repo, default: nil
property :run_user, default: node['prometheus-platform']['user']
property :run_group, default: node['prometheus-platform']['group']
property :go_compile, default: true
property :path
property :build_options, default: ['go get', 'go build']
property :execstart_options

action :create do # rubocop:disable Metrics/BlockLength
  exporter = new_resource.name

  # Generate/deploy config on prometheus server
  if node['prometheus-platform']['master_host'] == node['fqdn']
    targets =
      node['prometheus-platform']['exporter'][exporter]['targets'].to_a

    unless targets.nil? || targets.empty?
      tmp_config = node.run_state['prometheus-platform']['config']
      tmp_config['scrape_configs']["index_#{name}"] = {
        'job_name' => name,
        'scrape_interval' => '1m',
        'scrape_timeout' => '30s',
        'static_configs' => ['targets' => targets]
      }
    end
  end

  # Install exporter on node if defined as a target in prometheus
  unless node['prometheus-platform']['exporter'][exporter]['targets'].nil?
    targets =
      node['prometheus-platform']['exporter'][exporter]['targets'].to_a
    targets.each do |target| # rubocop:disable Metrics/BlockLength
      not_target = !target.include?(node['fqdn'])
      next if not_target

      directory path do
        owner node['prometheus-platform']['user']
        group node['prometheus-platform']['group']
      end

      # Install dependencies
      if go_compile
        %w(make golang-bin glibc-static).each do |pkg|
          package "install #{pkg} for #{name} exporter" do
            package_name pkg
            retries node['prometheus-platform']['package_retries']
          end
        end
      end

      unless git_repo.nil?
        package 'git'
        # Checkout exporter git source
        exporters_auto_update =
          node['prometheus-platform']['exporters_auto_update']
        git path do
          repository git_repo
          revision git_branch
          user node['prometheus-platform']['user']
          group node['prometheus-platform']['group']
          if exporters_auto_update
            action :sync
          else
            action :checkout
          end
          notifies :run, 'execute[build exporter]', :immediately
        end
      end

      # Get|build exporter
      execute 'build exporter' do
        command <<-EOF
          #{build_options.join(' && ')}
        EOF
        creates "#{new_resource.path}/#{exporter}_exporter"
        if go_compile
          environment(
            'GOPATH' => new_resource.path,
            'GOBIN' => '/usr/lib/golang/bin/'
          )
        end
        cwd new_resource.path
      end

      # Set correct permissions for exporter binary
      file "#{path}/#{name}_exporter" do
        user node['prometheus-platform']['user']
        group node['prometheus-platform']['group']
        mode '0700'
      end

      # Create systemd unit for exporter
      unit = {
        'Unit' => {
          'Description' => 'aerospike exporter',
          'After' => 'network.target'
        },
        'Service' => {
          'Type' => 'simple',
          'User' => run_user,
          'Group' => run_group,
          'Restart' => 'on-failure',
          'ExecStart' =>
            "#{path}/#{name}_exporter \
              #{execstart_options if execstart_options}"
        },
        'Install' => {
          'WantedBy' => 'multi-user.target'
        }
      }
      # Deploy systemd unit
      systemd_unit "#{name}_exporter.service" do
        enabled true
        active true
        masked false
        static false
        content unit
        triggers_reload true
        action [:create, :enable, :start]
        subscribes :restart, 'execute[build exporter]' if exporters_auto_update
      end
    end
  end
end
