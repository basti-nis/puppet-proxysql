# Class: proxysql::repo
# ===========================
#
# Manage the repos where the ProxySQL package might be
#
class proxysql::repo {
  assert_private()

  if $proxysql::manage_repo and !$proxysql::package_source {
    $repo = $proxysql::version ? {
      /^2\.2\./ => $proxysql::params::repo22,
      /^2\.0\./ => $proxysql::params::repo20,
      /^1\.4\./ => $proxysql::params::repo14,
      default   => fail("Unsupported `proxysql::version` ${proxysql::version}")
    }
    case $facts['os']['family'] {
      'Debian': {
        apt::source { 'proxysql_repo':
          * => $repo,
        }
        Class['apt::update'] -> Package[$proxysql::package_name]
      }
      'RedHat': {
        yumrepo { $repo['name']:
          * => $repo,
        }

        $purge_repo = $proxysql::version ? {
          /^2\.2\./ => [ $proxysql::params::repo14['name'], $proxysql::params::repo20['name'] ],
          /^2\.0\./ => [ $proxysql::params::repo14['name'], $proxysql::params::repo22['name'] ],
          /^1\.4\./ => [ $proxysql::params::repo29['name'], $proxysql::params::repo22['name'] ],
        }
        yumrepo { ['proxysql_repo', $purge_repo]:
          ensure => absent,
        }
      }
      default: {
        fail('This operatingsystem is not supported (yet).')
      }
    }
  }
}
