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

require 'master'
require 'grafana'

# Waiting for nodes to be up through Prometheus API
(1..10).each do |try|
  curl = 'http_proxy="" curl -s'
  url = 'http://localhost:9090/api/v1/query?query=up'
  up_nodes = `#{curl} "#{url}"`
  break if
    up_nodes.include?(
      'prometheus-platform-kitchen-1'
    ) && up_nodes.include?(
      'prometheus-platform-kitchen-2'
    )
  puts "Rest waiting to Schema Registry to be ready… (##{try}/5)"
  sleep(5)
end

describe 'With Prometheus API' do
  curl = 'http_proxy="" curl -s'
  url = 'http://localhost:9090/api/v1/query?query=up'

  it 'We can get the list of up nodes' do
    up_nodes = `#{curl} "#{url}"`
    expect(up_nodes).to include('prometheus-platform-kitchen-1')
    expect(up_nodes).to include('prometheus-platform-kitchen-2')
  end
end
