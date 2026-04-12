[![Hex.pm](https://img.shields.io/hexpm/v/nulid.svg)](https://hex.pm/packages/nulid)
[![Hex Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/nulid)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/kakilangit/nulid_ex/blob/main/LICENSE)

# Nulid

**Nanosecond-Precision Universally Lexicographically Sortable Identifier (NULID) for Elixir**

Elixir bindings for the [nulid](https://crates.io/crates/nulid) Rust crate, powered by [Rustler](https://hex.pm/packages/rustler) NIFs.

A NULID is a 128-bit identifier with:

- **68-bit nanosecond timestamp** for precise chronological ordering
- **60-bit cryptographically secure randomness** for collision resistance
- **26-character Crockford Base32 encoding** that is URL-safe and lexicographically sortable
- **UUID-compatible size** (16 bytes)

## Installation

Add `nulid` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:nulid, "~> 0.1.0"}
  ]
end
```

A Rust toolchain (1.88+) is required to compile the NIF. Install one via [rustup](https://rustup.rs/).

## Usage

### Generating NULIDs

```elixir
# As a 26-character Base32 string
{:ok, nulid} = Nulid.generate()
# => {:ok, "01AN4Z07BY79K47PAZ7R9SZK18"}

# As a 16-byte binary
{:ok, binary} = Nulid.generate_binary()
# => {:ok, <<...16 bytes...>>}
```

### Encoding and Decoding

```elixir
{:ok, binary} = Nulid.generate_binary()

# Binary -> String
{:ok, string} = Nulid.encode(binary)

# String -> Binary
{:ok, ^binary} = Nulid.decode(string)
```

### Inspecting Components

```elixir
{:ok, binary} = Nulid.generate_binary()

{:ok, ns} = Nulid.nanos(binary)    # nanoseconds since epoch
{:ok, ms} = Nulid.millis(binary)   # milliseconds since epoch
{:ok, rand} = Nulid.random(binary) # 60-bit random value
{:ok, false} = Nulid.nil?(binary)  # nil check

{:ok, true} = Nulid.nil?(<<0::128>>)
```

### Monotonic Generator

For guaranteed strictly increasing IDs, even within the same nanosecond:

```elixir
gen = Nulid.Generator.new()

{:ok, id1} = Nulid.Generator.generate(gen)
{:ok, id2} = Nulid.Generator.generate(gen)
{:ok, id3} = Nulid.Generator.generate(gen)

id1 < id2 and id2 < id3
# => true
```

Binary output:

```elixir
gen = Nulid.Generator.new()

{:ok, bin1} = Nulid.Generator.generate_binary(gen)
{:ok, bin2} = Nulid.Generator.generate_binary(gen)

bin1 < bin2
# => true
```

### Distributed Generation

For multi-node deployments, assign each node a unique ID (0-65535):

```elixir
gen = Nulid.Generator.new(node_id: 1)

{:ok, id} = Nulid.Generator.generate(gen)
```

The node ID is embedded in the random bits, guaranteeing cross-node uniqueness even with identical timestamps.

## Why NULID over ULID?

| Feature            | ULID              | NULID            |
| ------------------ | ----------------- | ---------------- |
| **Total Bits**     | 128               | 128              |
| **String Length**   | 26 chars          | 26 chars         |
| **Timestamp Bits** | 48 (milliseconds) | 68 (nanoseconds) |
| **Randomness Bits** | 80               | 60               |
| **Time Precision** | 1 millisecond     | 1 nanosecond     |
| **Lifespan**       | Until 10889 AD    | Until ~11326 AD  |

NULID trades 20 bits of randomness for 20 extra bits of timestamp precision, giving nanosecond-level ordering while still providing 1.15 quintillion unique IDs per nanosecond.

## Development

```bash
# Fetch dependencies
make deps

# Run all CI checks (format, clippy, test)
make ci

# Run tests only
make test

# Format code (Elixir + Rust)
make fmt

# Show all available targets
make help
```

## License

MIT - see [LICENSE](LICENSE) for details.
