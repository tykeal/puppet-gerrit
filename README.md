# Gerrit Module

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with gerrit](#setup)
    * [What gerrit affects](#what-gerrit-affects)
    * [Setup requirements](#setup-requirements)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

[![Build Status](https://travis-ci.org/tykeal/puppet-gerrit.png)](https://travis-ci.org/tykeal/puppet-gerrit)

This module installs and configures a Gerrit system. It is intended to
work with Puppet >= v3.7 as that is what it is developed against.

## Module Description

The Gerrit module provides an easy way of standing up a
[Gerrit](https://code.google.com/p/gerrit/) server, an open source web
based code review system.

The optional MySQL integration works with the puppetlabs-mysql module to
export a database configuration for automatic pick-up and creation of
the database. The module does not presently probe to see if the database
has been created as this is not a feature of the puppetlabs-mysql module
like it is in the puppetlabs-postgresql module. As such, if the exported
DB has not been picked up yet this module will fail to initialize Gerrit
until the database is available.

The module may optionally modify the firewall for the web and ssh
services.

You may optionally manage your Gerrit site Header, Footer and CSS as
well as the static resources.

You may optionally install and configure the plugins that ship with
Gerrit. The default is to install the full list of plugins that v2.9.3
shipped. One of these plugins (replication) requires a separate config
file, no default configuration file is created so the plugin will load
and then do nothing until a configuration file is managed in and the
plugin is either restarted or the Gerrit service is restarted.

## Setup

### What gerrit affects

* The gerrit service will be installed and managed
* May optionally install java (NOTE: java is required for Gerrit to work)
* May optionally install git (NOTE: git is required for Gerrit to work)
* Gerrit site Header, Footer and CSS may be optionally managed. If they
  are not managed then dummy files will be put in place (also optional)
  so that adding managed files later will not require a restart.
* May optionally install gitweb
* May optionally manage the firewall rules for access to Gerrit
  resources
* May optionally handle setting up the database (potential cross-system
  dependencies)

### Setup Requirements

* `puppetlabs/git` is required for the optional git installation. If you
  wish to manage git via a different module / method make sure to set
  $manage_git to false
* `puppetlabs/java` >= v1.2.0 is required for the optional java
  installation. If you wish to use manage java via a different module /
  method make sure to set $manage_java to false
* `puppetlabs/mysql` >= 3.0.0 is required for the optional MySQL management
  as well as having store configs enabled.
* `puppetlabs/firewall` >= 1.2.0 is required for the optional firewall
  management

## Usage

This module is designed to do automatic hiera lookups a fairly common
setup might look like the following. A note about the database password,
if you feel uncomfortable about having your passwords in the clear in
your hiera, it is recommendend that you look into hiera-eyaml and
hiera-eyaml-gpg

```hiera
---

# The DB tag that will be used to pickup our MySQL export
gerrit::db_tag: 'myenv-db'

# Use a version newer than the default of 2.9.3
gerrit::version: '2.11'

# Manage a replication.config
gerrit::extra_configs:
  replication_config:
    config_file: '/opt/gerrit/etc/replication.config'
    mode: '0644'
    options:
      'remote.github':
        url: 'git@github.com:exampleco/${name}.git'
        push:
          - '+refs/heads/*:refs/heads/*'
          - '+refs/tags/*:refs/tags/*'
        timeout: '5'
        threads: '5'
        authGroup: 'GitHub Replication'
        remoteNameStyle: 'dash'

# Manage the gerrit system itself
gerrit::override_options:
  auth:
    type: 'OPENID'
  cache:
    directory: 'cache'
  database:
    type: 'MYSQL'
    hostname: 'mysql.exampleco.com'
    database: 'gerrit'
    username: 'gerrit'
  gerrit:
    basePath: '/srv/gerrit'
    canonicalWebUrl: 'https://gerrit.exampleco.com/r'
  gitweb:
    cgi: '/var/www/git/gitweb.cgi'
  httpd:
    listenUrl: 'proxy-https://*:8080/r'
  sendemail:
    smtpServer: 'localhost'
    from: 'ExampleCo Code Review <gerrit@exampleco.com>'
  sshd:
    listenAddress: '*:29418'
  user:
    email: 'gerrit@exampleco.com'
  commentlink.bugzilla:
    match: '([Bb][Uu][Gg]\\s*[:-]?\\s*)(\\d+)'
    link: 'https://bugs.exampleco.com/show_bug.cgi?id=$2'

gerrit::override_secure_options:
  database:
    password: 'My$up3r@wes0mePASSw0rd'
```

```puppet
include ::gerrit
```

## Reference

#### `db_tag`

The tag to be used by exported database resource records so that a
collecting system may easily pick up the database resource

#### `download_location`

Base location for downloading the Gerrit war from. Defaults to the
official Gerrit download location

#### `extra_configs`

A hash that is used to add additional configuration files to the Gerrit
system. The hash is a hash of hashes where the top level keys are the
resource identifier for a configuration file and each `config_file`
option is the fully qualified filename that should be written out.

The hash is formatted as follows:

```puppet
extra_configs               => {
  configID1                 => {
    config_file             => 'fully_qualified_file_name',
    mode                    => '0644',
    options                 => {
      'section1'            => {
        'option1'           => 'basic string option',
        'option2'           => [
          'option2 array entry 1',
          'option2 array entry 2'
        ],
      },
      'section2.subsection' => {
        'option3' => 'option 3 in [section2 "subsection"]'
      },
    },
  },
  configID2                 => {
    config_file             => 'another_fully_qualified_file_name',
    mode                    => '0644',
    options                 => {
      'section1'            => {
        'option1'           => 'one more option string',
      },
    }
  }
}
```

This is most useful when managing the replication.config file for the
replication plugin a hiera config would look something like this:

```hiera
gerrit::extra_configs:
  replication_config:
    config_file: '/opt/gerrit/etc/replication.config'
    mode: '0644'
    options:
      'remote.github':
        url: 'git@github.com:exampleco/${name}.git'
        push:
          - '+refs/heads/*:refs/heads/*'
          - '+refs/tags/*:refs/tags/*'
        timeout: '5'
        threads: '5'
        authGroup: 'GitHub Replication'
        remoteNameStyle: 'dash'
```

#### `gerrit_home`

The home directory for the gerrit user / installation path. Default
value: /opt/gerrit

#### `gerrit_site_options`

Override options for installation of the 3 Gerrit site files. The format
of this option hash is as follows:

```puppet
gerrit_site_options       => {
  'GerritSite.css'        => 'a valid file resource source',
  'GerritSiteHeader.html' => 'a valid file resource source',
  'GerritSiteFooter.html' => 'a valid file resource source',
}
```

If an option is not present then the default "blank" file will be used.

This hash is only used if `manage_site_skin` is true (default)

#### `gerrit_version`

The version of the Gerrit war that will be downloaded. Default 2.9.3

#### `install_default_plugins`

Should the default plugins be installed? If true (default) then use the
`plugin_list` array to specify which plugins specifically should be
installed.

#### `install_git`

Should this module make sure that git is installed? (NOTE: a git
installation is required for Gerrit to be able to operate. If this is
true (default) then a module named ::git will be included.
`puppetlabs/git` is the expected module but any module that can be
blindly included and use APL to configure it that matches on the include
will work.)

#### `install_gitweb`

Should this module make sure that gitweb is installed? (NOTE: This will
use the system package manager to isntall gitweb but will do no extra
configuration as it will be expected to be managed via gerrit)

#### `install_java`

Should this module make sure that a JRE is installed? (NOTE: a JRE
installation is required for Gerrit to operate. If this is true
(default) then a module named ::java will be included. `puppetlabs/java`
is the expected module but any module that can be blindly included and
use APL to configure it that matches on the include will work.)

#### `manage_database`

Should the database be managed. The default option of true means that if
a MySQL or PostgresQL database is detected in the options then resources
will be exporte via the `puppetlabs/{mysql/postgresql}` module API. A
`db_tag` (see above) needs to be set as well so that a system picking up
the resource can acquire the appropriate exported resources.

NOTE: PostgreSQL resource exports do not presently work.

#### `manage_firewall`

Should the module insert firewall rules for the webUI and SSH? Default
setting: true

NOTE: This requires a module compatible with the `puppetlabs/firewall`
API

#### `manage_site_skin`

Should the Gerrit site theming be managed by the module? If true
(default) then passing an options hash to `gerrit_site_options` (see
above) will override the default "blank" skin files that get pushed.

#### `manage_static_site`

Should the ~gerrit/static structure be managed by the module? Default
setting: false

If true then `static_source` (see below) is required.

#### `override_options`

A variable hash for configuration settings of Gerrit. These options are
mreged into the default option define and then written to
`~gerrit/etc/gerrit.config`. The default Gerrit options are as follows:

```puppet
default_options => {
  'auth'        => {
    'type'      => 'OpenID',
  },
  'container'   => {
    'user'      => 'gerrit',
    'javaHome'  => '/usr/lib/jvm/jre',
  },
  'gerrit'      => {
    'basePath'  => '/srv/gerrit',
  },
  'index'       => {
    'type'      => 'LUCENE',
  },
}
```

#### `override_secure_options`

Similar to `override_options`, this hash is used for setting the options
in the `~gerrit/etc/secure.config` file. The defult secure options are
as follows:

```puppet
default_secure_options        => {
  'auth'                      => {
    'registerEmailPrivateKey' => 'GENERATE',
    'restTokenPrivateKey'     => 'GENERATE',
  },
}
```

The special `GENERATE` keywords will be replaced by host fqdn stable
random strings. The option is only valid on the two default keys and
will not operate on any other keys passed in. This is done to mimic a
manual installation as those strings are generated normally for you.

They may, of course, be overriden by this override hash.

#### `plugin_list`

An array specifying the default plugins that should be installed. The
names are specified without the .jar. The current plugins auto-installed
are the ones that ship with v2.9.3 the list is as follows:

```puppet
plugin_list => [
  'commit-message-length-validator',
  'download-commands',
  'replication',
  'reviewnotes'
]
```

#### `refresh_service`

Should the gerrit service be refreshed on modifications to either the
gerrit.config or sercure.config? Default: true

#### `service_enabled`

Determines the mode that the service is configured for:

true: (default) service is ensured started and enabled for reboot

false: service is ensured stopped and disabled for reboot

manual: service is configured as a manual service, refreshes will behave
per normal when a service is configured with `enable => manual`. The
service is not specified specifically started or stopped.

#### `static_source`

A File resource source that will be recursively pushed if
`manage_static_site` is set to true. All files in the source will be
pushed to the ~gerrit/site.

## Limitations

Tested against RedHat / CentOS v7
