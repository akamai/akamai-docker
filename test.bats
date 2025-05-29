#!/usr/bin/env bats

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
  # A2 does not have a --help
  run akamai adaptive-acceleration
  [ "$status" -eq 1 ]
  [[ "$output" =~ "ERROR: missing adaptive-acceleration command." ]]
}

@test "cli: api-gateway: api-gateway is executable" {
  run akamai api-gateway --help
  [ "$status" -eq 0 ]
}

@test "cli: api-gateway: api-keys is executable" {
  run akamai api-keys --help
  [ "$status" -eq 0 ]
}

@test "cli: api-gateway: api-security is executable" {
  run akamai api-security --help
  [ "$status" -eq 0 ]
}

@test "cli: cloudlets is executable" {
  run akamai cloudlets --help
  [ "$status" -eq 0 ]
}

@test "cli: cps is executable" {
  # does not use --help, but help subcommand
  run akamai cps help
  [ "$status" -eq 0 ]
}

@test "cli: dns is executable" {
  run akamai dns --help
  [ "$status" -eq 0 ]
}

@test "cli: eaa is executable" {
  run akamai eaa --help
  [ "$status" -eq 0 ]
}

@test "cli: etp is executable" {
  run akamai etp --help
  [ "$status" -eq 0 ]
}

@test "cli: edgeworkers is executable" {
  run akamai edgeworkers --help
  [ "$status" -eq 0 ]
}

@test "cli: firewall: firewall is executable" {
  run akamai firewall --help
  [ "$status" -eq 0 ]
}

@test "cli: firewall: site-shield is executable" {
  run akamai site-shield --help
  [ "$status" -eq 0 ]
}

@test "cli: image-manager is executable" {
  run akamai image-manager --help
  [ "$status" -eq 0 ]
}

@test "cli: jsonnet is executable" {
  run akamai jsonnet --help
  [ "$status" -eq 0 ]
}

@test "cli: onboard is executable" {
  run akamai onboard --help
  [ "$status" -eq 0 ]
}

@test "cli: property-manager: pipeline is executable" {
  run akamai pipeline --help
  [ "$status" -eq 0 ]
}

@test "cli: property-manager: snippets is executable" {
  run akamai snippets --help
  [ "$status" -eq 0 ]
}

@test "cli: purge is executable" {
  run akamai purge --help
  [ "$status" -eq 0 ]
}

@test "cli: sandbox is executable" {
  run akamai sandbox --help
  [ "$status" -eq 0 ]
}

@test "cli: terraform is executable" {
  run akamai terraform help
  [ "$status" -eq 0 ]
}

@test "cli: gtm is executable" {
  run akamai gtm --help
  [ "$status" -eq 0 ]
}