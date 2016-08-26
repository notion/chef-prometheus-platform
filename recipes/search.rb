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

# Use ClusterSearch
::Chef::Recipe.send(:include, ClusterSearch)

node.run_state['prometheus-platform'] = {}

# Looking for the master
master = cluster_search(node['prometheus-platform']['master'])

node.run_state['prometheus-platform']['master'] =
  master['hosts'].include? node['fqdn'] if master

# Looking for nodes to scrap
nodes = cluster_search(node['prometheus-platform']['node'])

node.run_state['prometheus-platform']['node'] =
  nodes['hosts'].include? node['fqdn'] if nodes

node.run_state['prometheus-platform']['nodes_exported'] =
  nodes['hosts'].map { |host| "#{host}:9100" } if nodes
