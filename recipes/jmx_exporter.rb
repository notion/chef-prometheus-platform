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

jmx_exporter = node['prometheus-platform']['exporter']['jmx']

# Generate/deploy config on prometheus server
if node['prometheus-platform']['master_host'] == node['fqdn']
  targets =
    jmx_exporter['targets'].to_a

  unless targets.nil? || targets.empty?
    node.run_state['prometheus-platform']['config']['scrape_configs'] =
      node.run_state['prometheus-platform']['config']['scrape_configs'] +
      ['job_name' => 'jmx',
       'scrape_interval' => '1m',
       'scrape_timeout' => '30s',
       'static_configs' => ['targets' => targets]]
  end
end

# Install jmx_exporter on node if defined as a target in prometheus server
targets_config = jmx_exporter['config']
unless targets_config.nil? || targets_config.empty?
  targets_config.each do |target| # rubocop:disable Metrics/BlockLength
    next unless target['name'] == node['fqdn']
    # Java is needed by jmx_exporter
    java_package = jmx_exporter['java'][node['platform']]
    package java_package do
      unless java_package.to_s.empty?
        retries node['prometheus-platform']['package_retries']
      end
    end

    directory "directory for #{target['name']}" do
      path jmx_exporter['path']
      owner node['prometheus-platform']['user']
      group node['prometheus-platform']['group']
    end

    # Download jar
    jmx_exporter_path = jmx_exporter['path']
    binary = 'jmx-exporter.jar'

    remote_file "jmx binary for #{target['name']}" do
      path "#{jmx_exporter_path}/#{binary}"
      source jmx_exporter['repo']
      owner node['prometheus-platform']['user']
      group node['prometheus-platform']['group']
    end

    # Generate config for prometheus jmx exporter
    java_opts = jmx_exporter['java_opts']

    template "#{jmx_exporter_path}/#{target['name']}-#{target['app']}.yml" do
      source 'config.yml.erb'
      variables config: target['options']
      user node['prometheus-platform']['user']
      group node['prometheus-platform']['group']
      mode '0600'
    end

    # Create systemd unit for exporter
    unit = {
      'Unit' => {
        'Description' => 'jmx exporter',
        'After' => 'network.target'
      },
      'Service' => {
        'Type' => 'simple',
        'User' => node['prometheus-platform']['user'],
        'Group' => node['prometheus-platform']['group'],
        'Restart' => 'on-failure',
        'ExecStart' =>
          "/usr/bin/java #{java_opts if java_opts} -jar \
            #{jmx_exporter_path}/#{binary} \
            #{target['scrape_port']} \
            #{jmx_exporter_path}/#{target['name']}-#{target['app']}.yml"
      },
      'Install' => {
        'WantedBy' => 'multi-user.target'
      }
    }
    # Deploy systemd unit
    systemd_unit "jmx_exporter_#{target['name']}-#{target['app']}.service" do
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
