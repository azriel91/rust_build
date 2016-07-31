#!/bin/sh

# Log levels:
#  0 - error
#  1 - warn
#  2 - notice
#  3 - info (default)
#  4 - debug
#
# Example usage (from repository root):
#   LOG_LEVEL=4 ./rust_build/build.sh
LOG_LEVEL_REAL=${LOG_LEVEL:-3}
ERRORS_EXIST=""

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

function exit_with_help() {
  # Note: the following is tab indented because bash heredocs can unindent tabs but not spaces
  help_message=$(cat <<-EOF
		\e[31mThe build contained some errors. Search for \e[1;31m[ERROR]\e[0;31m in the build output to find them.
		For more information, you may enable debug logging by running:
		LOG_LEVEL=4 ./rust_build/build.sh\e[0m
		EOF
		)
  printf "${help_message}\n" 1>&2
  exit 1
}

function fail_if_error() {
  if [ ! -z "${ERRORS_EXIST}" ]; then
    exit_with_help
  fi
}
