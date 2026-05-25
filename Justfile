just := env_var_or_default("just", just_executable())
cargo := env_var_or_default("CARGO", "cargo")
wasm-tools := env_var_or_default("WASM_TOOLS", "wasm-tools")
wasmtime := env_var_or_default("WASMTIME", "wasmtime")

# If you build as a lib (which cannot contain hyphens, we get a different path)
expected_wasm_path := "target/wasm32-wasip2/release/test_p2.wasm"

@_default:
    {{just}} --list

# Perform a simple build (redirects to build-simple)
build:
    {{just}} build-simple

# Build the component with fully working std (including WASI imports)
[group('build')]
@build-simple:
    {{cargo}} build --release --target=wasm32-wasip2

# NOTE: these tags can be migrated to Cargo.toml/cargo config TOML,
# but they're here to keep them *mostly* in the same place.
#
# Build the component with no extra WASI imports
[group('build')]
@build-no-wasi:
    RUSTFLAGS="-Zunstable-options -Cpanic=immediate-abort" {{cargo}} +nightly \
      build \
      --release \
      -Z build-std=std \
      -Z unstable-options \
      --target=wasm32-wasip2

# Print the WIT of the built component
[group('metadata')]
@print-wit:
    echo '==> printing WIT for component [${{expected_wasm_path}}]...'
    echo ''
    {{wasm-tools}} component wit {{expected_wasm_path}}

[group('run')]
@run:
    {{wasmtime}} run --invoke 'foo()' {{expected_wasm_path}}
