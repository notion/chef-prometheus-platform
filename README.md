Prometheus Platform
=============

Description
-----------

Open-source systems monitoring and alerting toolkit originally
built at SoundCloud.

This cookbook is designed to install and configure Prometheus.

Requirements
------------

### Cookbooks and gems

Declared in [metadata.rb](metadata.rb) and in [Gemfile](Gemfile).

### Platforms

Should works on every Linux distro managed by systemd.
Tested on CentOS 7.

Usage
-----

### Test

This cookbook is fully tested through the installation of 3 nodes
in docker hosts. This uses kitchen, docker and some monkey-patching.

For more information, see *.kitchen.yml* and *test* directory.

Attributes
----------

Configuration is done by overriding default attributes. All configuration keys
have a default defined in [attributes/default.rb](attributes/default.rb).
Please read it to have a comprehensive view of what and how you can configure
this cookbook behavior.

Recipes
-------

### default

Include `user`, `install`, `node_exporter` , `jmx_exporter`, `grafana`,
`config` and `service` recipes.

### user

Create user/group used by Prometheus

### install

Install Prometheus server and alertmanager.

Prometheus server will be installed on the host defined in the following
attribute:

`node['prometheus-platform']['master_host']`

Alertmanager will be installed on the same host of the prometheus server if
the following attribute is set to true value:

`node['prometheus-platform']['has_alertmanager']`

### node_exporter

Install and start prometheus node_exporter on node if node has been
defined as a target in prometheus server (see .kitchen.yml for example).

This recipe also generate node exporter related config to deploy on
prometheus server.

### jmx_exporter

Install and start prometheus jmx_exporter on node if node has been defined
as a jmx target in prometheus server (see .kitchen.yml for example).

This recipe also generate jmx exporter related config to deploy on
prometheus server.

### aerospike_exporter

Install and start prometheus aerospike_exporter on node if node has been defined
as a target in prometheus server (see .kitchen.yml for example).

This recipe also generate aerospike exporter related config to deploy on
prometheus server.

### mysqld_exporter

Install and start prometheus jmx_exporter on node if node has been defined
as a target in prometheus server (see .kitchen.yml for example).

This recipe also generate mysqld exporter related config to deploy on
prometheus server.

### zookeeper_exporter

Install and start prometheus zookeeper_exporter on node if node has been defined
as atarget in prometheus server (see .kitchen.yml for example).

This recipe also generate zookeeper exporter related config to deploy on
prometheus server.

### statsd_exporter

Install and start prometheus statsd_exporter on node if node has been defined
as a target in prometheus server (see .kitchen.yml for example).

This recipe also generate statsd exporter related config to deploy on
prometheus server.

### grafana

Install and start grafana on the host defined in the following attribute:

`node['prometheus-platform']['grafana_host']`

### config

Generate and deploy global config and alertmanager config for prometheus
server.

### service

Deploy systemd units for prometheus_server and alertmanager.

Resources/Providers
-------------------

None

Changelog
---------

Available in [CHANGELOG.md](CHANGELOG.md).

Contributing
------------

Please read carefully [CONTRIBUTING.md](CONTRIBUTING.md) before making a merge
request.

License and Author
------------------

- Author:: Samuel Bernard (<samuel.bernard@s4m.io>)
- Author:: Florian Philippon (<florian.philippon@s4m.io>)

```text
Copyright (c) 2016 Sam4Mobile

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
