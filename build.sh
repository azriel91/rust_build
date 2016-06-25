#/bin/sh

# Log levels:
#  0 - error
#  1 - warn
#  2 - notice
#  3 - info (default)
#  4 - debug
#
# Example usage (from repository root):
#   LOG_LEVEL=4 ./build-scripts/build.sh
LOG_LEVEL_REAL=${LOG_LEVEL:-3}
ERRORS_EXIST=""

function exit_with_help() {
  # Note: the following is tab indented because bash heredocs can unindent tabs but not spaces
  help_message=$(cat <<-EOF
		\e[31mThe build contained some errors. Search for \e[1;31m[ERROR]\e[0;31m in the build output to find them.
		For more information, you may enable debug logging by running:
		LOG_LEVEL=4 ./build-scripts/build.sh\e[0m
		EOF
		)
  printf "${help_message}\n" 1>&2
  exit 1
}

function log_error() {
  message=$1
  fatal=${2:-true}
  printf "\e[1;31m[ERROR] \e[0;31m${message}\e[0m\n" 1>&2

  ERRORS_EXIST=true
  if $fatal; then exit 1; fi
}

function log_warn() {
  message=$1
  if [[ LOG_LEVEL_REAL -lt 1 ]]; then return; fi
  printf "\e[1;33m[WARN ] \e[0;33m${message}\e[0m\n" 1>&2
}

function log_notice() {
  message=$1
  if [[ LOG_LEVEL_REAL -lt 2 ]]; then return; fi
  printf "\e[1;32m[NTICE] \e[0;32m${message}\e[0m\n" 1>&2
}

function log_info() {
  message=$1
  if [[ LOG_LEVEL_REAL -lt 3 ]]; then return; fi
  printf "\e[1;36m[INFO ] \e[0;36m${message}\e[0m\n" 1>&2
}

function log_debug() {
  message=$1
  if [[ LOG_LEVEL_REAL -lt 4 ]]; then return; fi
  printf "\e[1;34m[DEBUG] \e[0;34m${message}\e[0m\n"
}

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
log_info "Running: ! TERM=dumb cargo fmt -- --write-mode=diff | grep -e \"^\(+\|-\)\|\(Rustfmt failed\)\" -m 1 > /dev/null"
syntax_output=$(TERM=dumb cargo fmt -- --write-mode=diff)
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

# === Fail if any errors exist === #
if [ ! -z "${ERRORS_EXIST}" ]; then
  exit_with_help
fi

log_notice "Build successful"
