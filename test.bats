#!/usr/bin/env bats

akamai_command_installed() {
  akamai list | grep -qw -- "$1"
}

@test "httpie: http is executable" {
  run http --help
  [ "$status" -eq 0 ]
}

@test "jq is executable" {
  run jq --help
  [ "$status" -eq 0 ]
}

@test "terraform is executable" {
  run terraform -help
  [ "$status" -eq 0 ]
}

@test "cli: akamai is executable" {
  run akamai help
  [ "$status" -eq 0 ]
}

@test "cli: adaptive-acceleration is executable" {
  run akamai_command_installed adaptive-acceleration
  [ "$status" -eq 0 ]
  # A2 does not have a --help
  run akamai adaptive-acceleration
  [ "$status" -eq 1 ]
  [[ "$output" =~ "ERROR: missing adaptive-acceleration command." ]]
}

@test "cli: api-gateway: api-gateway is executable" {
  run akamai_command_installed api-gateway
  [ "$status" -eq 0 ]
  run akamai api-gateway --help
  [ "$status" -eq 0 ]
}

@test "cli: api-gateway: api-keys is executable" {
  run akamai_command_installed api-keys
  [ "$status" -eq 0 ]
  run akamai api-keys --help
  [ "$status" -eq 0 ]
}

@test "cli: api-gateway: api-security is executable" {
  run akamai_command_installed api-security
  [ "$status" -eq 0 ]
  run akamai api-security --help
  [ "$status" -eq 0 ]
}

@test "cli: appsec is executable" {
  run akamai_command_installed appsec
  [ "$status" -eq 0 ]
  run akamai appsec --help
  [ "$status" -eq 0 ]
}

@test "cli: cloudlets is executable" {
  run akamai_command_installed cloudlets
  [ "$status" -eq 0 ]
  run akamai cloudlets --help
  [ "$status" -eq 0 ]
}

@test "cli: cps is executable" {
  run akamai_command_installed cps
  [ "$status" -eq 0 ]
  # does not use --help, but help subcommand
  run akamai cps help
  [ "$status" -eq 0 ]
}

@test "cli: dns is executable" {
  run akamai_command_installed dns
  [ "$status" -eq 0 ]
  run akamai dns --help
  [ "$status" -eq 0 ]
}

@test "cli: eaa is executable" {
  run akamai_command_installed eaa
  [ "$status" -eq 0 ]
  run akamai eaa --help
  [ "$status" -eq 0 ]
}

@test "cli: etp is executable" {
  run akamai_command_installed etp
  [ "$status" -eq 0 ]
  run akamai etp --help
  [ "$status" -eq 0 ]
}

@test "cli: edgekv is executable" {
  run akamai_command_installed edgekv
  [ "$status" -eq 0 ]
  run akamai edgekv --help
  [ "$status" -eq 0 ]
}

@test "cli: edgeworkers is executable" {
  run akamai_command_installed edgeworkers
  [ "$status" -eq 0 ]
  run akamai edgeworkers --help
  [ "$status" -eq 0 ]
}

@test "cli: firewall: firewall is executable" {
  run akamai_command_installed firewall
  [ "$status" -eq 0 ]
  run akamai firewall --help
  [ "$status" -eq 0 ]
}

@test "cli: firewall: site-shield is executable" {
  run akamai_command_installed site-shield
  [ "$status" -eq 0 ]
  run akamai site-shield --help
  [ "$status" -eq 0 ]
}

@test "cli: image-manager is executable" {
  run akamai_command_installed image-manager
  [ "$status" -eq 0 ]
  run akamai image-manager --help
  [ "$status" -eq 0 ]
}

@test "cli: video-manager is executable" {
  run akamai_command_installed video-manager
  [ "$status" -eq 0 ]
  run akamai video-manager --help
  [ "$status" -eq 0 ]
}

@test "cli: jsonnet is executable" {
  run akamai_command_installed jsonnet
  [ "$status" -eq 0 ]
  run akamai jsonnet --help
  [ "$status" -eq 0 ]
}

@test "cli: onboard is executable" {
  run akamai_command_installed onboard
  [ "$status" -eq 0 ]
  run akamai onboard --help
  [ "$status" -eq 0 ]
}

@test "cli: property-manager: pipeline is executable" {
  run akamai_command_installed pipeline
  [ "$status" -eq 0 ]
  run akamai pipeline --help
  [ "$status" -eq 0 ]
}

@test "cli: property-manager: snippets is executable" {
  run akamai_command_installed snippets
  [ "$status" -eq 0 ]
  run akamai snippets --help
  [ "$status" -eq 0 ]
}

@test "cli: purge is executable" {
  run akamai_command_installed purge
  [ "$status" -eq 0 ]
  run akamai purge --help
  [ "$status" -eq 0 ]
}

@test "cli: sandbox is executable" {
  run akamai_command_installed sandbox
  [ "$status" -eq 0 ]
  run akamai sandbox --help
  [ "$status" -eq 0 ]
}

@test "cli: terraform is executable" {
  run akamai_command_installed terraform
  [ "$status" -eq 0 ]
  run akamai terraform help
  [ "$status" -eq 0 ]
}

@test "cli: gtm is executable" {
  run akamai_command_installed gtm
  [ "$status" -eq 0 ]
  run akamai gtm --help
  [ "$status" -eq 0 ]
}

@test "cli: test-center is executable" {
  run akamai_command_installed test-center
  [ "$status" -eq 0 ]
  run akamai test-center --help
  [ "$status" -eq 0 ]
}