# EmbedKit Development Guide

## Build Commands
- Build: `swift build` or `./scripts/build.sh`
- Build (release): `./scripts/build.sh --release`
- Test all: `swift test`
- Test single: `swift test --filter EmbedKitTests.IndexTests/testBM25Search`
- Clean: `swift package clean`

## Code Style
- **Naming**: PascalCase for types; camelCase for functions/properties
- **Imports**: Foundation first, then alphabetical order
- **Documentation**: Use Swift DocC format with XML tags
- **Errors**: Use `EmbedError` enum with descriptive cases
- **Async**: Use Swift concurrency (async/await) with proper error handling
- **Testing**: Name test functions with `test` prefix; make assertions specific

## Project Structure
- **EmbedKit**: Core library functionality
- **EmbedCLI**: Command-line interface
- **Tests**: Mirror source structure with comprehensive test cases

## Dependencies
- MLXEmbedders for embedding generation
- ArgumentParser for CLI functionality

## Platform Requirements
- Swift 6.0+
- macOS 14+, iOS 17+