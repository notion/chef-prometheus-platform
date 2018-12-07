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

cookbook_name = 'prometheus-platform'

# Where to get the tarball for Prometheus server
mirror = 'https://github.com/prometheus/' \
  '%<comp>s/releases/download/v%<version>s'
file = '%<comp>s-%<version>s.linux-amd64.tar.gz'

# Prometheus package and version from https://prometheus.io/download
# Set install? to true to install a component
# For each component, the url field will be added later in the file
#   'url' => url of file, default: "#{mirror}/#{file}"
default[cookbook_name]['components'] = {
  'prometheus' => {
    'install?' => false,
    'version' => '2.5.0',
    'sha' => '6f1203c3ec540346bb346641eb43a74fde2992cda23b6c9e0f876f95a646cda1'
  },
  'alertmanager' => {
    'install?' => false,
    'version' => '0.15.3',
    'sha' => 'b43fd8aba978f19375e37fb7924bcdc7dd45659b1b0f87a2815860001f100f46'
  },
  'blackbox_exporter' => {
    'install?' => false,
    'version' => '0.13.0',
    'sha' => '641ebedf12796a04be8f5dc18eeebe64c2332130d1f0f2453f627996a30855ff'
  },
  'consul_exporter' => {
    'install?' => false,
    'version' => '0.4.0'
  },
  'graphite_exporter' => {
    'install?' => false,
    'version' => '0.4.2'
  },
  'haproxy_exporter' => {
    'install?' => false,
    'version' => '0.9.0',
    'sha' => 'b0d1caaaf245d3d16432de9504575b3af1fec14b2206a468372a80843be001a0'
  },
  'memcached_exporter' => {
    'install?' => false,
    'version' => '0.5.0',
    'sha' => 'bb07f496ceb63dad9793ad4295205547a4bd20b90628476d64fa96c9a25a020f'
  },
  'mysqld_exporter' => {
    'install?' => false,
    'version' => '0.11.0',
    'sha' => 'b53ad48ff14aa891eb6a959730ffc626db98160d140d9a66377394714c563acf'
  },
  'node_exporter' => {
    'install?' => false,
    'version' => '0.17.0',
    'sha' => 'd2e00d805dbfdc67e7291ce2d2ff151f758dd7401dd993411ff3818d0e231489'
  },
  'pushgateway' => {
    'install?' => false,
    'version' => '0.6.0',
    'sha' => 'f264fe51ff904f648656ce2cdca4256878de307f40c61d51eb8700aae94390ce'
  },
  'statsd_exporter' => {
    'install?' => false,
    'version' => '0.8.1',
    'sha' => '950338c793f8e87fcf03c26a5c2bb74ae58c9eabfbeba6873adc1bc0f4719ab9'
  }
}

# User and group of prometheus process
default[cookbook_name]['user'] = 'prometheus'
default[cookbook_name]['group'] = 'prometheus'

# Ark stuff (Installation), shared for all components
default[cookbook_name]['prefix_root'] = '/opt' # base installation dir
default[cookbook_name]['prefix_home'] = '/opt' # where is link to install dir
default[cookbook_name]['prefix_bin'] = '/opt/bin' # where to link binaries

# Default unit file, can be modified/extended for each component
default[cookbook_name]['default']['unit'] = {
  'Unit' => {
    'Description' => 'Prometheus platform: %<comp>s',
    'After' => 'network.target'
  },
  'Service' => {
    'Type' => 'simple',
    'User' => node[cookbook_name]['user'],
    'Group' => node[cookbook_name]['group'],
    'WorkingDirectory' => '%<path>s',
    'SyslogIdentifier' => '%<comp>s',
    'Restart' => 'on-failure',
    'ExecStart' => '%<cli>s'
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}

# Rules dir, will be created and populated by 'rules' attributes
default[cookbook_name]['components']['prometheus']['rules_dir'] = 'rules'

# Prometheus main config
default[cookbook_name]['components']['prometheus']['config'] = {
  'rule_files' => [
    "#{node[cookbook_name]['components']['prometheus']['rules_dir']}/*"
  ],
  'global' => {
    'scrape_interval' => '15s',
    'evaluation_interval' => '15s',
    'external_labels' => {
      'monitor' => 'codelab-monitor'
    }
  },
  'alerting' => {
    'alertmanagers' => [{
      'static_configs' => [{
        'targets' => ["#{node['fqdn']}:9093"]
      }]
    }]
  },
  'scrape_configs' => { # will be converted to array (see below)
    'index_1' =>
    {
      'job_name' => 'prometheus',
      'scrape_interval' => '5s',
      'static_configs' => {
        'index_1' => {
          'targets' => ['localhost:9090', 'localhost:9100']
        }
      }
    }
  }
  # this scrape_configs entry is equivalent and will be rewritten to:
  # 'scrape_configs' => [
  #   {
  #     'job_name' => 'prometheus',
  #     'scrape_interval' => '5s',
  #     'static_configs' => {
  #       'index_1' => {
  #         'targets' => ['localhost:9090', 'localhost:9100']
  #       }
  #     }
  #   }
  # ]

  # Actually, all hash containing a key 'index_xxxx' will be rewritten like
  # that. This is to permit the overriding of default values in role attribute.
}

# Scrape_configs can be configured directly in config or in the following
# attributes which will be interpreted by scraper recipe,
# using cluster-search cookbook

# First default config that will be merged in all scrapers config
default[cookbook_name]['components']['prometheus']['scrapers_default'] = {
  # Example:
  # 'relabel_configs' => [
  #    'source_labels' => ['__address__'],
  #    'regex' => '([^:]+):(.*)',
  #    'replacement' => '$1',
  #    'target_label' => 'instance'
  #  ]
}

# Then scrapers list
default[cookbook_name]['components']['prometheus']['scrapers'] = {
  # Example:
  # 'node_exporter' => {
  #   'scrape_interval' => '60s',
  #   'static_configs' => { # use cluster-search (search on a role)
  #     'role' => 'prometheus-platform',
  #     'port' => '9100'
  #   }
  # }
}

# Prometheus launch configuration, stored in systemd unit
# Use '' if no value is needed
default[cookbook_name]['components']['prometheus']['cli_opts'] = {
  'config.file' => '%<path>s/%<cfile>s',
  'storage.tsdb.path' => '/var/opt/prometheus',
  'storage.tsdb.retention' => '15d'
}

# Extra configuration for systemd unit, will be merged with default
default[cookbook_name]['components']['prometheus']['unit'] = {
  'Service' => {
    'LimitNOFILE' => 65_536
  }
}

# Rules configuration for Prometheus, will be in rules_dir
default[cookbook_name]['components']['prometheus']['rules'] = {
  # file => array of rules where a rule is a string, or an array of string
  # example:
  #   'alerting' => [],
  #   'recording' => []
}

# Alertmanager configuration, empty by default which is non-working
default[cookbook_name]['components']['alertmanager']['config'] = {}

# Alertmanager launch configuration, stored in systemd unit
# Use '' if no value is needed
default[cookbook_name]['components']['alertmanager']['cli_opts'] = {
  'config.file' => '%<path>s/%<cfile>s',
  'storage.path' => '/var/opt/alertmanager'
}

# Simple proc to do a deep merge on hash
deep_merge = proc do |_, old, new|
  old.respond_to?(:merge) ? old.merge(new, &deep_merge) : new
end

# Merge global default with each component default
node[cookbook_name]['components'].each_pair do |comp, config|
  default[cookbook_name]['components'][comp]['url'] = "#{mirror}/#{file}"

  default_unit = node[cookbook_name]['default']['unit'].to_h
  current_unit = config['unit'] || {}
  default[cookbook_name]['components'][comp]['unit'] =
    default_unit.merge(current_unit, &deep_merge)
end

def interpol(conf, keys)
  if conf.is_a?(String)
    conf % keys
  elsif conf.is_a?(Hash)
    conf.map { |k, v| [k, interpol(v, keys)] }.to_h
  else conf
  end
end

def opts_to_str(hash)
  (hash || {}).map { |k, v| "#{' ' * 2}--#{k}#{"=#{v}" unless v.empty?}" }
end

# Fill in previous configurations, replace %<token>s with actual value
node[cookbook_name]['components'].each_pair do |comp, config|
  path = "#{node[cookbook_name]['prefix_home']}/#{comp}"
  cfile = "#{comp}.yml"
  bin = "#{path}/#{comp}"

  keys = {
    path: path,
    cfile: cfile,
    bin: bin,
    comp: comp,
    version: config['version']
  }

  # cli need substitution too
  cli = [bin, opts_to_str(config['cli_opts'])].flatten.join(" \\\n") % keys
  keys[:cli] = cli
  default[cookbook_name]['components'][comp] = interpol(config.to_h, keys)
end

# Should we restart service after config update?
default[cookbook_name]['auto_restart'] = true

# Configure retries for the package resources, default = global default (0)
# (mostly used for test purpose
default[cookbook_name]['package_retries'] = nil
