Prometheus Platform
===================

Description
-----------

Prometheus is an Open-source systems monitoring and alerting toolkit originally
built at SoundCloud.

This cookbook is designed to install and configure Prometheus with its
Alertmanager and all exporters listed on [https://prometheus.io/download]().
Others, specific exporters are out of the scope of this cookbook.

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

- a master with Prometheus server, Alertmanager, Pushgateway, Node exporter and
  Statsd exporter
- a worker with Node exporter and Statsd exporter.

This uses kitchen, docker and some monkey-patching.

For more information, see *.kitchen.yml* and *test* directory.

Attributes
----------

Configuration is done by overriding default attributes. All configuration keys
have a default defined in:

[attributes/default.rb](attributes/default.rb).

Please read it to have a comprehensive view of what and how you can configure
this cookbook behavior.

You can also look at the role written for the tests to have an example on how
to configure this cookbook:
[server](test/integration/roles/prometheus-platform-server.json) and
[node](test/integration/roles/prometheus-platform.json).

Recipes
-------

### default

Include all others recipes.

### user

Create user/group used by Prometheus

### install

Install all components with sub-attribute 'install?' as true.

### scrapers

Prepare scrape\_configs configuration from scrapers attributes. Use
cluster-search to create a dynamic "static\_configs".

### config

Generate and deploy configuration for all components.

Also generate the alerting and recording rules for Prometheus.

### service

Deploy systemd units for all components.

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
Copyright (c) 2016-2017 Sam4Mobile, 2017-2018 Make.org

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
