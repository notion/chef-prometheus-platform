name 'prometheus-platform'
maintainer 'Sam4Mobile'
maintainer_email 'dps.team@s4m.io'
license 'Apache 2.0'
description 'Cookbook used to install and configure prometheus'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url 'https://gitlab.com/s4m-chef-repositories/prometheus-platform'
issues_url 'https://gitlab.com/s4m-chef-repositories/prometheus-plaform'
version '1.0.0'

depends 'cluster-search'
depends 'ark'
supports 'centos', '>= 7.1'
