#!/usr/bin/env bats

@test "config_path should exist" {
  [ -d /etc/beaver ]
}

@test "config_file should exist" {
  [ -e /etc/beaver/beaver.conf ]
}

@test "conf.d directory should exist" {
  [ -d /etc/beaver/conf.d ]
}

@test "beaver should be installed" {
  run which beaver
  [ "$status" -eq 0 ]
}

@test "beaver should be running" {
  run pgrep -u root beaver
  [ "$status" -eq 0 ]
}
