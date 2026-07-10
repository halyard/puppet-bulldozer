# @summary Configure bulldozer container
#
# @param datadir sets where to store the config file
# @param hostname is the hostname
# @param aws_access_key_id sets the AWS key to use for Route53 challenge
# @param aws_secret_access_key sets the AWS secret key to use for the Route53 challenge
# @param email sets the contact address for the certificate
# @param github_integration_id sets the integration ID for the GitHub app
# @param github_webhook_secret sets the webook secret for validating webhooks
# @param github_private_key sets the private key for the GitHub app
# @param container_ip sets the IP address for the docker container
class bulldozer (
  String $datadir,
  String $hostname,
  String $aws_access_key_id,
  String $aws_secret_access_key,
  String $email,
  String $github_integration_id,
  String $github_webhook_secret,
  String $github_private_key,
  String $container_ip = '172.17.0.3',
) {
  file { $datadir:
    ensure => directory,
  }

  file { "${datadir}/bulldozer.yml":
    ensure  => file,
    content => template('bulldozer/bulldozer.yml.erb'),
    notify  => Service['container@bulldozer'],
  }

  docker::container { 'bulldozer':
    image => 'palantirtechnologies/bulldozer:latest',
    args  => [
      "-v ${datadir}:/secrets",
    ],
    cmd   => '',
  }

  nginx::site { $hostname:
    proxy_target          => "http://${container_ip}:8080",
    aws_access_key_id     => $aws_access_key_id,
    aws_secret_access_key => $aws_secret_access_key,
    email                 => $email,
  }
}
