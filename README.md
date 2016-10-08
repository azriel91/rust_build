# Rust Build

Build scripts to aid Rust development.

## build.sh

This is a convenience build script which essentially wraps the following commands, but also provides basic diagnostics and coloured output:

```bash
# Inside the crate directory
# Syntax validation
! TERM=dumb cargo fmt -- --config-path=rust_build --write-mode=diff 2>&1 | \
  grep -e "^\(\+\|-\)\|\(Rustfmt failed\)" -m 1 > /dev/null \
  && echo pass || echo fail

# Compile and test
cargo build
cargo test
```
