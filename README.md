# Rust Build

Build scripts to aid Rust development.

## build.sh

This is a convenience build script which essentially wraps the following commands, but also provides basic diagnostics and coloured output:

```bash
# Syntax validation
! TERM=dumb cargo fmt -- --write-mode=diff | \
  grep -e "^\(+\|-\)\|\(Rustfmt failed\)" -m 1 > /dev/null \
  && echo pass || echo fail

# Compile and test
cargo build
cargo test
```
