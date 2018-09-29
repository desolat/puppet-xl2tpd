# ex: syntax=puppet si ts=4 sw=4 et

class xl2tpd (
    $package_name,
    $version,
    $service_name,
    $min_dynamic_ip = '192.168.254.10',
    $max_dynamic_ip = '192.168.254.250',
    $tunnel_ip      = '192.168.254.1',
    $dns_servers    = [ '8.8.4.4', '8.8.8.8' ],
    $mtu            = '1300',
    $mru            = '1300',
    $debug          = false,
    $pppoptfile     = '/etc/xl2tpd/ppp-options',
    $conffile       = '/etc/xl2tpd/xl2tpd.conf',
) {
    File {
        ensure => present,
        owner => 'root',
        group => 'root',
        mode  => '0644',
    }


    package { 'xl2tpd':
        name   => $package_name,
        ensure => $version,
    }

    file { $conffile:
        content => template('xl2tpd/xl2tpd.conf.erb'),
        require => Package['xl2tpd'],
    }

    file { $pppoptfile:
        content => template('xl2tpd/ppp-options.erb'),
        require => Package['xl2tpd'],
    }

    service { 'xl2tpd':
        name       => $service_name,
        ensure     => running,
        pattern    => '/usr/sbin/xl2tpd',
        hasstatus  => false,
        hasrestart => true,
        subscribe  => File[$conffile, $pppoptfile],
    }
}
