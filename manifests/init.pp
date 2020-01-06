# ex: syntax=puppet si ts=4 sw=4 et

class xl2tpd (
    # defaults are in data/
    String $package_name,
    String $service_name,
    Hash $global         = {},
    Hash $conn,
    Boolean $debug          = false,
    $conf_file           = '/etc/xl2tpd/xl2tpd.conf',
) {
    File {
        ensure => present,
        owner => 'root',
        group => 'root',
        mode  => '0644',
    }


    package { $package_name:
        ensure => installed,
    }

    concat {  $conf_file:
        mode  => '0644',
        owner => 'root',
        group => 'root',
    }

    concat::fragment { 'xl2tpd_conf_header':
        content => template('xl2tpd/xl2tpd_conf_header.erb'),
        target  => $conf_file,
        order   => '01',
    }

    $conn.each |$conn_name, $config| {
        $ppp_opt_file = "/etc/ppp/${conn_name}.l2tpd.client"
        if has_key($config, 'lac') {
            $lac_config = $config['lac']
            concat::fragment { "xl2tpd_conf_lac_${conn_name}":
                content => template('xl2tpd/xl2tpd_conf_lac.erb'),
                target  => $conf_file,
                order   => '02',
                require => Package[$package_name],
                notify  => Service[$service_name],
            }
        }
        $ppp_opts = $config['ppp']
        file { $ppp_opt_file:
            content => template('xl2tpd/ppp-options.erb'),
            require => Package[$package_name],
            notify  => Service[$service_name],
        }
    } 

    service { $service_name:
        name       => $service_name,
        ensure     => running,
        pattern    => '/usr/sbin/xl2tpd',
        hasstatus  => false,
        hasrestart => true,
    }
}
