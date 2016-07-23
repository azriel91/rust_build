#!/bin/sh

# Generates a crate and initializes it with rust_build as a subrepo

base_dir=$(dirname "${0}")
source "${base_dir}/log_functions.sh"
source "${base_dir}/prerequisite_checks.sh"

crate_name="${1}"
crate_git_remote="${2}"

if [[ ! "${crate_git_remote}" =~ [.]git$ ]]; then
  log_error "Usage: crate.sh <crate_name> <remote_url>"
fi

cargo new "${crate_name}"
git add "${crate_name}"
git commit -m "Cargo generated crate: ${crate_name}"
git subrepo init "${crate_name}" -r "${crate_git_remote}" -b "master"
git subrepo push "${crate_name}"
