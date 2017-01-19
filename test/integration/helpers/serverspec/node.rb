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

require 'spec_helper'

describe 'Prometheus node exporter' do
  it 'is running' do
    expect(service('prometheus_node')).to be_running
  end

  it 'is launched at boot' do
    expect(service('prometheus_node')).to be_enabled
  end

  it 'is listening on correct port' do
    expect(port(9100)).to be_listening
  end

  it 'has started successfully' do
    result = `journalctl -u prometheus_node -o cat`
    expect(result).to include('Listening on :9100')
  end
end
