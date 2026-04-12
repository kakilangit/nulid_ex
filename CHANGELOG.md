# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-04-12

### Added

- **Initial release** of Elixir bindings for [nulid](https://github.com/kakilangit/nulid)
- Rust NIF powered by [Rustler](https://hex.pm/packages/rustler) for native performance
- Core NULID generation and parsing
  - `Nulid.generate/0` - Generate a NULID as a 26-character Crockford Base32 string
  - `Nulid.generate_binary/0` - Generate a NULID as a 16-byte binary
  - `Nulid.encode/1` - Encode a 16-byte binary to Base32 string
  - `Nulid.decode/1` - Decode a Base32 string to 16-byte binary
- Timestamp and component extraction
  - `Nulid.nanos/1` - Extract nanosecond timestamp
  - `Nulid.millis/1` - Extract millisecond timestamp
  - `Nulid.random/1` - Extract 60-bit random component
  - `Nulid.nil?/1` - Check if a NULID is nil (all zeros)
- Monotonic generator via `Nulid.Generator`
  - `Nulid.Generator.new/1` - Create a new generator (single-node or distributed)
  - `Nulid.Generator.generate/1` - Generate monotonically increasing NULID string
  - `Nulid.Generator.generate_binary/1` - Generate monotonically increasing NULID binary
  - Distributed mode with `:node_id` option (0-65535) for multi-node deployments

[Unreleased]: https://github.com/kakilangit/nulid_ex/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/kakilangit/nulid_ex/releases/tag/v0.1.0
