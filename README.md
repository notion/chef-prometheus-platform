Prometheus Platform
=============

Description
-----------

Prometheus is an Open-source systems monitoring and alerting toolkit originally
built at SoundCloud.

This cookbook is designed to install and configure Prometheus with its
Alertmanager and Node exporter. Actually, all exporters following the format
of Node exporter should be supported. Others are out of the scope of this
cookbook.

Requirements
------------

### Cookbooks and gems

Declared in [metadata.rb](metadata.rb) and in [Gemfile](Gemfile).

### Platforms

Should works on every Linux distro managed by systemd, possibly with minor
adjustments. Tested on CentOS 7.

Usage
-----

### Test

This cookbook is tested through the installation of 2 nodes in docker hosts:

- a master with Prometheus server, Alertmanager and Node exporter
- a worker with just Node exporter

This uses kitchen, docker and some monkey-patching.

For more information, see *.kitchen.yml* and *test* directory.

Attributes
----------

Configuration is done by overriding default attributes. All configuration keys
have a default defined in:

[attributes/default.rb](attributes/default.rb).
[attributes/node\_exporter.rb](attributes/node_exporter.rb).
[attributes/systemd.rb](attributes/systemd.rb).

Please read it to have a comprehensive view of what and how you can configure
this cookbook behavior.

Recipes
-------

### default

Include `user` and `server` if `master_host == node['fqdn']`.

### client

Include `user` and `node_exporter` recipes.

### server

Include `user`, `install`, `node_exporter`, `config` and `service` recipes.

### user

Create user/group used by Prometheus

### install

Install Prometheus server and Alertmanager.

Prometheus server will be installed on the host defined in the following
attribute:

`node['prometheus-platform']['master_host']`

Alertmanager will be installed on the same host of the Prometheus server if
the following attribute is set to true value:

`node['prometheus-platform']['has_alertmanager']`

### node\_exporter

Install and start Prometheus Node exporter on node if node has been
defined as a target in Prometheus server (see .kitchen.yml for example).

This recipe also generate node exporter related config to deploy on
Prometheus server.

### config

Generate and deploy global config and Alertmanager config for prometheus
server.

Alerting and recording rules are deployed through a data\_bag.

### service

Deploy systemd units for Prometheus server and Alertmanager.

Resources/Providers
-------------------

None.

Changelog
---------

Available in [CHANGELOG.md](CHANGELOG.md).

Contributing
------------

Please read carefully [CONTRIBUTING.md](CONTRIBUTING.md) before making a merge
request.

License and Author
------------------

- Author:: Samuel Bernard (<samuel.bernard@gmail.com>)
- Author:: Florian Philippon (<florian.philippon@gmail.com>)

```text
Copyright (c) 2016-2017 Sam4Mobile, 2017 Make.org

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
