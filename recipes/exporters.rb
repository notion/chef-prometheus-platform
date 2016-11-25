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

blacklisted_exporters =
  node['prometheus-platform']['blacklisted_exporters']

if node['prometheus-platform']['exporter']
  exporters =
    node['prometheus-platform']['exporter']
  exporters.each do |name, conf|
    next if blacklisted_exporters.include? name
    conf.each do |key, value|
      next if key != 'config'
      resource = prometheus_platform_exporter name
      value.each do |attr, val|
        val = [val] unless val.is_a? Array
        resource.send(attr, *val)
      end
    end
  end
end
