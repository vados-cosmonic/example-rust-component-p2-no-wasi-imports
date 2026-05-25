# Example minimal P2 component with no WASI imports

This repository contains a simple Rust WebAssembly component (see: [WebAssembly Component Model][cm]),
that is configured to use the [WebAssembly System Interface ("WASI")][wasi] ([Preview 2][wasi-p2]),
but *without* the default imports that normally are required to perform common tasks like writing to
stdout/stderr and other conveniences in `std`.

[cm]: https://component-model.bytecodealliance.org/
[wasi]: https://wasi.dev
[wasi-p2]: https://github.com/WebAssembly/WASI/blob/main/docs/Preview2.md

## WIT interface

WebAssembly components conform to [WebAssembly Interface Type ("WIT")][wit] interfaces that
describe their behavior.

This component conforms to the following simple WIT interface:

```wit
package test:rust;

interface foo {
    foo: func() -> string;
}

world component {
    export foo;
}
```

## Dependencies

This rust project depends on a few things:

| Dependency                              | Description                                                                             |
|-----------------------------------------|-----------------------------------------------------------------------------------------|
| [Cargo Nightly Toolchain][nightly-rust] | To use features that enable rebuilding the std library                                  |
| [`just`][just]                          | For Makefile-like task execution (can install via `cargo [b]install`)                   |
| [`wasm-tools`][wasm-tools]              | CLI toolkit for inspecting/manipulating components (can install via `cargo [b]install`) |
| [`wasmtime`][wasmtime]                  | Lightweight, secure WebAssembly runtime (can install via `cargo [b]install`)            |

[just]: https://github.com/casey/just
[nightly-rust]: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
[wasm-tools]: https://github.com/bytecodealliance/wasm-tools
[wasmtime]: https://github.com/bytecodealliance/wasmtime

## Build

This component can be built two ways:

```console
just build-simple
just build-no-wasi
```

> [!NOTE]
> Both builds output WASM components with the *same* name, so if you run one build, it will
> overwrite the other.

The simple build is roughly equivalent to a basic `cargo build` that targets WASI P2 (`wasm32-wasip2`),
and the `no-wasi` build makes use of nightly rust and some compiler flags to build a component that does
not

## Inspecting the built components

Once built, the component can be inspected and have it's WIT printed (ensure you have `wasm-tools` installed):

```console
just print-wit
```

## Running the built components

If you have [`wasmtime`][wasmtime] installed, we can run the WebAssembly component:

```console
just run
```

You should see output like the following:

```console
➜ just run
"Hello World!"
```
