#
# Copyright (c) 2016-2017 Sam4Mobile, 2017-2018 Make.org
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

require 'spec_helper'
require 'json'

describe 'Prometheus' do
  it 'is running' do
    expect(service('prometheus')).to be_running
  end

  it 'is launched at boot' do
    expect(service('prometheus')).to be_enabled
  end

  it 'is listening on correct port' do
    expect(port(9090)).to be_listening
  end

  it 'has started successfully' do
    result = `journalctl -u prometheus -o cat`
    expect(result).to include('TSDB started')
    expect(result).to include('Server is ready to receive web requests.')
  end
end

def relabel(job_name)
  <<-YAML.gsub(/^  /, '')
  - job_name: #{job_name}
    relabel_configs:
    - source_labels:
      - __address__
      regex: "([^:]+):(.*)"
      replacement: "\\$1"
      target_label: instance
  YAML
end

describe 'Prometheus Configuration' do
  describe file('/opt/prometheus/prometheus.yml') do
    %w[prometheus node_exporter statsd_exporter pushgateway].each do |job_name|
      its(:content) { should contain "job_name: #{job_name}" }
      next if job_name == 'prometheus'
      its(:content) { should contain relabel(job_name) }
    end
    its(:content) { should contain 'honor_labels: true' }
    its(:content) { should contain 'prometheus-platform-server-centos-7:9100' }
    its(:content) { should contain 'prometheus-platform-client-centos-7:9100' }
    its(:content) { should contain 'prometheus-platform-server-centos-7:9102' }
    its(:content) { should contain 'prometheus-platform-client-centos-7:9102' }
    its(:content) { should contain 'prometheus-platform-server-centos-7:9091' }
  end
end

describe 'Pushgateway' do
  it 'is running' do
    expect(service('pushgateway')).to be_running
  end
  it 'is launched at boot' do
    expect(service('pushgateway')).to be_enabled
  end
  it 'is listening on correct port' do
    expect(port(9091)).to be_listening
  end
  it 'has started successfully' do
    result = `journalctl -u pushgateway -o cat`
    expect(result).to include('Listening on :9091')
  end
end

def targets
  c = `http_proxy="" curl -sS http://localhost:9090/api/v1/targets`
  JSON.parse(c)
end

def waiting_up
  60.times do |i|
    healths = (targets.dig('data', 'activeTargets') || []).map do |active|
      active['health'] != 'up'
    end
    break unless healths.any? || healths.empty?
    puts "Waiting for all targets to be \"up\": #{i * 2}/120s"
    sleep(2)
  end
end

describe 'Targets status' do
  it 'is successful' do
    expect(targets['status']).to eq('success')
  end

  waiting_up
  all_targets = (targets || {})
  %w[prometheus pushgateway node_exporter statsd_exporter].each do |job|
    it "returns healthy #{job} jobs" do
      active = all_targets.dig('data', 'activeTargets') || []
      instances = active.select { |t| t['labels']['job'] == job }
      expect(instances).not_to be_empty
      instances.each do |instance|
        expect(instance['health']).to eq('up')
      end
    end
  end
end
