#!/usr/bin/env bats

CONFIG="/etc/beaver/beaver.conf"

@test "configuration should contain ssh_options line" {
  run grep "ssh_options: StrictHostKeyChecking=no" $CONFIG
  [ "$status" -eq 0 ]
}

@test "configuration should contain ssh_tunnel line" {
  run grep "ssh_tunnel: logging@logs.example.net" $CONFIG
  [ "$status" -eq 0 ]
}

@test "configuration should contain ssh_remote_host line" {
  run grep "ssh_remote_host: localhost" $CONFIG
  [ "$status" -eq 0 ]
}

@test "configuration should contain ssh_remote_port line" {
  run grep "ssh_remote_port: 6379" $CONFIG
  [ "$status" -eq 0 ]
}

@test "configuration should contain ssh_tunnel_port line" {
  run grep "ssh_tunnel_port: 6379" $CONFIG
  [ "$status" -eq 0 ]
}

@test "configuration should contain redis_url line" {
  run grep "redis_url: redis://localhost:6379/0" $CONFIG
  [ "$status" -eq 0 ]
}
