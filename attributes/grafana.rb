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

# Cluster Search (cluster-search) is a simple cookbook library which simplify
# the search of members of a cluster. It relies on Chef search with a size
# guard (to avoid inconsistencies during initial convergence) and allows a
# fall-back to hostname listing if user does not want to rely on searches
# (because of chef-solo for example).

# Define host where grafana will be installed
default['prometheus-platform']['grafana_host'] = 'localhost'

default['prometheus-platform']['grafana']['repo_url'] =
  'https://grafanarel.s3.amazonaws.com/builds'
repo_url = node['prometheus-platform']['grafana']['repo_url']
default['prometheus-platform']['grafana']['package'] =
  "#{repo_url}/grafana-3.1.1-1470047149.x86_64.rpm"

default['prometheus-platform']['grafana']['config'] = {}
