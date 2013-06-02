#!/usr/bin/env bats

@test "private key should exist" {
  [ -e /etc/beaver/id_rsa ]
}

@test "public key should exist" {
  [ -e /etc/beaver/id_rsa.pub ]
}
