#!/usr/bin/env bats

@test "private key should exist" {
  [ -e /etc/beaver/logger ]
}

@test "public key should exist" {
  [ -e /etc/beaver/logger.pub ]
}
