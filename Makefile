# Makefile for nulid_ex
#
# This Makefile provides convenient commands for development, testing, and
# publishing the nulid Elixir package. It uses the same commands as the
# GitHub Actions CI/CD workflows to ensure consistency between local
# development and continuous integration.
#
# The Rust version is automatically extracted from the NIF crate's Cargo.toml
# to ensure alignment with the project's rust-version requirement.
#
# Usage:
#   make help          - Show all available targets
#   make ci            - Run all CI checks (fmt-check, clippy, credo, test)
#   make pre-commit    - Run pre-commit checks (fmt, clippy, test)
#   make publish       - Publish to hex.pm

.PHONY: help
help: ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Elixir version - automatically extracted from mix.exs
ELIXIR_VERSION := $(shell grep 'elixir:' mix.exs | sed 's/.*"~> \(.*\)".*/\1/')

# Rust version - automatically extracted from NIF crate's Cargo.toml
RUST_VERSION := $(shell grep 'rust-version = ' native/nulid_nif/Cargo.toml | head -1 | sed 's/.*rust-version = "\(.*\)"/\1/')

.PHONY: install-rust
install-rust: ## Install Rust toolchain with required components
	rustup toolchain install $(RUST_VERSION)
	rustup component add rustfmt clippy --toolchain $(RUST_VERSION)

.PHONY: deps
deps: ## Fetch dependencies
	mix deps.get

.PHONY: compile
compile: ## Compile the project
	mix compile --warnings-as-errors

.PHONY: fmt
fmt: ## Format all code (Elixir + Rust)
	mix format
	cd native/nulid_nif && cargo +$(RUST_VERSION) fmt

.PHONY: fmt-check
fmt-check: ## Check code formatting (Elixir + Rust)
	mix format --check-formatted
	cd native/nulid_nif && cargo +$(RUST_VERSION) fmt --check

.PHONY: clippy
clippy: ## Run clippy lints on NIF crate
	cd native/nulid_nif && cargo +$(RUST_VERSION) clippy -- -D warnings

.PHONY: test
test: ## Run all tests
	mix test

.PHONY: clean
clean: ## Clean build artifacts
	mix clean
	cd native/nulid_nif && cargo clean

.PHONY: ci
ci: fmt-check clippy test ## Run all CI checks

.PHONY: pre-commit
pre-commit: fmt clippy test ## Run pre-commit checks

.PHONY: doc
doc: ## Generate documentation
	mix docs

.PHONY: publish-dry-run
publish-dry-run: ## Dry run of publishing to hex.pm
	mix hex.publish --dry-run

.PHONY: publish
publish: ## Publish to hex.pm (requires HEX_API_KEY)
	mix hex.publish --yes

.PHONY: all
all: ci doc ## Run all checks and build documentation
