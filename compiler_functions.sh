#!/bin/sh

is_stable() {
  return $(! rustc --version | grep -q 'beta\|nightly')
}

is_beta() {
  return $(rustc --version | grep -qF 'beta')
}

is_nightly() {
  return $(rustc --version | grep -qF 'nightly')
}
