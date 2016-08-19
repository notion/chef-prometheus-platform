Prometheus Platform
=============

![alt tag](http://bit.ly/2b2UURS)

Description
-----------

Open-source systems monitoring and alerting toolkit originally
built at SoundCloud.

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

Include `search`, `user`, `install` , `config`, `service`


### search

By default, the *search* recipe use a search to find master and nodes.
The search is parametrized by a role name, defined in attribute
`node['prometheus-platform']['master']` which default to
*master-prometheus-platform*.
Node having this role in their expanded runlist will be considered as master.
Node having the *node-prometheus-plaform* role in their expanded runlist will
be considered as a node and the node exporter will be installed on it.

If you do not want to use search, it is possible to define
`node['prometheus-platform']['hosts']` with an array containing the hostname of
the node. In this case, *size* attribute is ignored
and search deactivated.

See [roles](test/integration/roles) for some examples and
[Cluster Search][cluster-search] documentation for more information.

### user

Create user/group used by Prometheus

### install

Install Prometheus server, alertmanager and node exporter.

### config

Generate config for prometheus server, alertmanager and node exporter

### service

Deploy systemd unit files for prometheus server, alertmanager and
node exporter.

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
