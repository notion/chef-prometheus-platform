#
# Copyright (c) 2017-2018 Make.org
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

# This recipes creates the server scrape_configs configuration
# It uses search to simplify the cookbook configuration

# Use ClusterSearch
::Chef::Recipe.send(:include, ClusterSearch)

sdefault = node[cookbook_name]['components']['prometheus']['scrapers_default']
scrapers_config = node[cookbook_name]['components']['prometheus']['scrapers']

scrape_configs = scrapers_config.to_h.map do |job_name, config|
  rewritten_config = { 'job_name' => job_name }
  config = sdefault.to_h.merge(config)
  unless config['static_configs'].nil?
    port = config['static_configs']['port'] || 80
    scrapers = cluster_search(config['static_configs']) do |n|
      "#{n['fqdn']}:#{port}"
    end
    unless scrapers.nil?
      config = config.merge(
        'static_configs' => [
          'targets' => scrapers['hosts']
        ]
      )
    end
  end
  rewritten_config.merge(config)
end

# Simplified deep merge (only hash)
merge_proc = proc do |_, old, new|
  old.respond_to?(:merge) ? old.merge(new, &merge_proc) : new
end

config = {
  'components' => {
    'prometheus' => {
      'scrape_configs' => scrape_configs
    }
  }
}

config = (node.run_state[cookbook_name] || {}).merge(config, &merge_proc)
node.run_state[cookbook_name] = config
