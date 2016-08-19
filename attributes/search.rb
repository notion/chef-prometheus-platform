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

# Cluster Search (cluster-search) is a simple cookbook library which simplify
# the search of members of a cluster. It relies on Chef search with a size
# guard (to avoid inconsistencies during initial convergence) and allows a
# fall-back to hostname listing if user does not want to rely on searches
# (because of chef-solo for example).

# Role used by the search to find master node of the cluster
default['prometheus-platform']['master']['role'] = 'master-prometheus-platform'
# Master hosts of the cluster, deactivate search if not empty
default['prometheus-platform']['master']['hosts'] = []
# Expected size of the master cluster. Ignored if hosts is not empty
default['prometheus-platform']['master']['size'] = 1

# Role used by the search to find nodes of the cluster
default['prometheus-platform']['node']['role'] = 'node-prometheus-platform'
# Master hosts of the cluster, deactivate search if not empty
default['prometheus-platform']['node']['hosts'] = []
# Expected size of the node cluster. Ignored if hosts is not empty
default['prometheus-platform']['node']['size'] = 1
