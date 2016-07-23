#!/bin/sh

# Checks if pre-requisites are installed

base_dir=$(dirname "${0}")
source "${base_dir}/log_functions.sh"

# Cargo
which cargo 2>&1
if [ $? -eq 1 ] ; then
  log_error "Cargo must be installed. This should come with your Rust distribution."
  log_error "Instructions can be found at https://www.rust-lang.org/downloads.html"
fi

# Rustfmt
cargo --list | grep "\Wfmt$" > /dev/null 2>&1
if [ $? -eq 1 ] ; then
  log_error "rustfmt must be installed. Instructions can be found at https://github.com/rust-lang-nursery/rustfmt"
fi
