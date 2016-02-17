# == Class: gerrit::config::firewall
#
# This class configures the firewall for Gerrit
#
# === Parameters
#
# This class accepts no parameters directly
#
# === Variables
#
# The following variables are required
#
# [*manage_firewall*]
#   Should the module insert firewall rules for the webUI and SSH?
#   (NOTE: this requires a module compatible with puppetlabs/firewall)
#
# [*options*]
#   A variable hash for configuration settings of Gerrit. The base class
#   will take the default options from gerrit::params and combine it
#   with anything in override_options (if defined) and use that as the
#   hash that is passed
#
# === Authors
#
# Andrew Grimberg <agrimberg@linuxfoundation.org>
#
# === Copyright
#
# Copyright 2015 Andrew Grimberg
#
class gerrit::config::firewall (
  $manage_firewall,
  $options
) {
  validate_bool($manage_firewall)
  validate_hash($options)

  if ($manage_firewall) {
    if ( has_key($options, 'httpd') ) {
      if ( has_key($options['httpd'], 'listenUrl') ) {
        validate_string($options['httpd']['listenUrl'])
        $listenUrl = $options['httpd']['listenUrl']
      }
      else {
        # set the listenUrl to the default
        $listenUrl = 'http://*:8080'
      }
    }
    else {
        # set the listenUrl to the default
        $listenUrl = 'http://*:8080'
    }

    if ( has_key($options, 'sshd') ) {
      if ( has_key($options['sshd'], 'listenAddress') ) {
        validate_string($options['sshd']['listenAddress'])
        $listenAddress = $options['sshd']['listenAddress']
      }
      else {
        # set the listenAddress to the default
        $listenAddress = '*:29418'
      }
    }
    else {
      # set the listenAddress to the default
      $listenAddress = '*:29418'
    }

    $listenUrl_arr = split($listenUrl, '[:/]')
    $listenUrl_port = $listenUrl_arr[4]
    $listenUrl_addr = $listenUrl_arr[3]

    case $listenUrl_addr {
      '*':      { $listenUrl_destination = undef }
      default:  { $listenUrl_destination = $listenUrl_addr }
    }

    $listenAddress_arr = split($listenAddress, ':')
    $listenAddress_port = $listenAddress_arr[1]
    $listenAddress_addr = $listenAddress_arr[0]

    case $listenAddress_addr {
      '*':      { $listenAddress_destination = undef }
      default:  { $listenAddress_destination = $listenAddress_addr }
    }

    unless $options['src_ips'] and $options['src_ips'].size > 0 {
        firewall{'050 gerrit webui access':
          proto       => 'tcp',
          state       => ['NEW'],
          action      => 'accept',
          dport       => [$listenUrl_port],
          destination => $listenUrl_destination,
        }

        firewall{'050 gerrit ssh access':
          proto       => 'tcp',
          state       => ['NEW'],
          action      => 'accept',
          dport       => [$listenAddress_port],
          destination => $listenAddress_destination,
        }
    } else {
      $options['src_ips'].each |String $src| {
        firewall{"050 gerrit webui access ${src}":
          proto       => 'tcp',
          state       => ['NEW'],
          action      => 'accept',
          source      => $src,
          dport       => [$listenUrl_port],
          destination => $listenUrl_destination,
      }

        firewall{"050 gerrit ssh access ${src}":
          proto       => 'tcp',
          state       => ['NEW'],
          action      => 'accept',
          source      => $src,
          dport       => [$listenUrl_port],
          destination => $listenUrl_destination,
        }
      }
    }
  }
}
