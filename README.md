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

When performing the "simple" build, you will see the

<details>
<summary>Full WIT imports</summary>

```wit
package root:component;

world root {
  import wasi:io/poll@0.2.6;
  import wasi:io/error@0.2.6;
  import wasi:io/streams@0.2.6;
  import wasi:cli/environment@0.2.6;
  import wasi:cli/exit@0.2.6;
  import wasi:cli/stdin@0.2.6;
  import wasi:cli/stdout@0.2.6;
  import wasi:cli/stderr@0.2.6;
  import wasi:cli/terminal-input@0.2.6;
  import wasi:cli/terminal-output@0.2.6;
  import wasi:cli/terminal-stdin@0.2.6;
  import wasi:cli/terminal-stdout@0.2.6;
  import wasi:cli/terminal-stderr@0.2.6;

  export test:rust/foo;
}
package wasi:io@0.2.6 {
  interface poll {
    resource pollable {
      block: func();
    }
  }
  interface error {
    resource error;
  }
  interface streams {
    use error.{error};
    use poll.{pollable};

    resource input-stream;

    resource output-stream {
      check-write: func() -> result<u64, stream-error>;
      write: func(contents: list<u8>) -> result<_, stream-error>;
      blocking-flush: func() -> result<_, stream-error>;
      subscribe: func() -> pollable;
    }

    variant stream-error {
      last-operation-failed(error),
      closed,
    }
  }
}


package wasi:cli@0.2.6 {
  interface environment {
    get-environment: func() -> list<tuple<string, string>>;
  }
  interface exit {
    exit: func(status: result);
  }
  interface stdin {
    use wasi:io/streams@0.2.6.{input-stream};

    get-stdin: func() -> input-stream;
  }
  interface stdout {
    use wasi:io/streams@0.2.6.{output-stream};

    get-stdout: func() -> output-stream;
  }
  interface stderr {
    use wasi:io/streams@0.2.6.{output-stream};

    get-stderr: func() -> output-stream;
  }
  interface terminal-input {
    resource terminal-input;
  }
  interface terminal-output {
    resource terminal-output;
  }
  interface terminal-stdin {
    use terminal-input.{terminal-input};

    get-terminal-stdin: func() -> option<terminal-input>;
  }
  interface terminal-stdout {
    use terminal-output.{terminal-output};

    get-terminal-stdout: func() -> option<terminal-output>;
  }
  interface terminal-stderr {
    use terminal-output.{terminal-output};

    get-terminal-stderr: func() -> option<terminal-output>;
  }
}


package test:rust {
  interface foo {
    foo: func() -> string;
  }
}
```

</details>

Performing the more complicated "no-wasi" build will yield a component with trimmed wit imports,
as the unwind machinery is excluded:

<details>
<summary>Trimmed WIT imports</summary>

```wit
package root:component;

world root {
  export test:rust/foo;
}
package test:rust {
  interface foo {
    foo: func() -> string;
  }
}
```

</details>

> [!NOTE]
> While the original WIT interface contains no world named `root`, the bulit component
> does -- this is an artifact of the tooling, as worlds may be combined/modified/resolved
> and rewritten slightly during component building.

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
