#!/bin/sh

base_dir=$(dirname "${0}")
source "${base_dir}/log_functions.sh"

# === Ensure applications are installed === #
# Cargo
cargo > /dev/null 2>&1
if [ $? -eq 127 ] ; then
  log_error "Cargo must be installed. This should come with your Rust distribution."
  log_error "Instructions can be found at https://www.rust-lang.org/downloads.html"
fi
# Rustfmt
cargo --list | grep "\Wfmt$" > /dev/null 2>&1
if [ $? -eq 1 ] ; then
  log_error "rustfmt must be installed. Instructions can be found at https://github.com/rust-lang-nursery/rustfmt"
fi

# === Code format === #
log_info "Verifying source meets code formatting standards"
log_info "Running: ! TERM=dumb cargo fmt -- --config-path=\"${base_dir}\" --write-mode=diff | grep -e \"^\(+\|-\)\|\(Rustfmt failed\)\" -m 1 > /dev/null"
syntax_output=$(TERM=dumb cargo fmt -- --config-path="${base_dir}" --write-mode=diff)
log_debug "${syntax_output}"
# we negate the result of the next command because a positive grep result indicates a failure
! echo "${syntax_output}" | grep -e "^\(+\|-\)\|\(Rustfmt failed\)" -m 1 > /dev/null
syntax_check_result=$?
if [ "${syntax_check_result}" -ne "0" ]; then
  log_error "Code format check failed. Please adhere to the rustfmt coding standards" false
  log_error "More info can be found at https://github.com/rust-lang-nursery/rustfmt" false
else
  log_notice "Code format check successful"
fi

# === Compile === #
log_info "Compiling project"
log_info "Running: cargo build"
cargo build
compile_result=$?
if [ "${compile_result}" -ne "0" ]; then
  log_error "Compilation failed, please scroll up to find details of the failure"
else
  log_notice "Compilation successful"
fi

# === Test === #
log_info "Compiling tests"
log_info "Running: cargo test"
cargo test
test_result=$?
if [ "${test_result}" -ne "0" ]; then
  log_error "Tests failed, please scroll up to find details of the failure"
else
  log_notice "Tests successful"
fi

fail_if_error

log_notice "Build successful"
