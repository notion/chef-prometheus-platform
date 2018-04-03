Changelog
=========

2.0.0
-----

Main:

- feat: breaking change migration to support Prometheus 2.X (actually 2.2.1)
  + update all components to latest version
  + set all flags with double dash
  + put alertmanager discovery in config
  + update storage flags
  + reformat rules in yaml
  + adapt tests to new logs

Tests:

- fix waiting condition on targets
- include .gitlab-ci.yml from test-cookbook
- replace deprecated require\_chef\_omnibus

Misc:

- feat: set default data retention to 15d
- chore: add 2018 to copyright notice

1.1.0
-----

Main:

- add default config for scrapers
- change default data directories to /var/opt
- update default version of components:
  + prometheus to 1.7.2
  + blackbox to 0.9.1
  + alertmanager to 0.9.1

Tests:

- fix rubocop on heredoc delimiters

1.0.0
-----

Initial version:

- with Centos support
- manage all artifacts available on https://prometheus.io/download/
