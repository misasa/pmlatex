# pmlatex Maintenance Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans inline. User waived further process confirmations.

**Goal:** Make existing pmlatex testable and distributable without feature changes.
**Architecture:** Preserve lib/ and bin/ unless a demonstrated Ruby incompatibility requires a minimal substitution. Offline specifications use real TeX parsing and disposable files, with Medusa mocked only at its service boundary. Reuse scalebar's release tooling with pmlatex-specific package checks.
**Tech Stack:** Ruby 2.6.10 / 4.0.9, Bundler, RSpec, Rake, GitHub Actions.
**Spec:** docs/superpowers/specs/2026-10-27-maintenance-design.md

## Global Constraints

- No tags, pushes, actual publication, live Medusa mutation, or functional fixes.
- Set version 1.3.5 (subsequent user-approved patch increase from 1.3.4); verify exact Ruby versions separately.
- GPL-3.0-or-later metadata; runtime-only gem file allowlist.
- Execute in this checkout on a maintenance branch; user waived procedural questions.

## Review Focus

- Missing source/PDF must fail before remote calls (Task 1).
- Confirmation refusal must not destroy or save remote records (Task 1).
- Installed code must load from the temporary gem installation (Task 2).
- Release version/commit collisions must stop publication (Task 3).
- Checksum mismatch and existing output must stop downloads (Task 3).

### Task 1: Offline test audit and Ruby compatibility

Files: spec/spec_helper.rb, spec/pmlatex/*_spec.rb, spec/fixtures/, Gemfile, Gemfile.lock, .gitignore, pmlatex.gemspec.
Interface: bundle exec rspec; dependencies resolved independently per interpreter.
- [x] Install development tools into ignored local directories; run original suite and record failures.
- [x] Replace shared tmp state with per-example directories, forbid external HTTP, restore global options.
- [x] Strengthen parsing, author, insertion, add/commit/update/scan contracts using real files and boundary doubles; add a synthetic log expectation alongside the tracked fixtures; remove inert legacy feature scaffolding.
- [x] Run randomized suites on both Rubies. If Ruby 4 removed an API, prove the incompatibility and use only its equivalent replacement; document deferred issues.

### Task 2: Package verification

Files: pmlatex.gemspec, Rakefile, script/verify_package.rb, spec/package_spec.rb.
Interface: bundle exec rake verify; pkg/pmlatex-1.3.5.gem.
- [x] Add package contract assertions, run against old gemspec to observe failures.
- [x] Set Ruby floor, actual GPL metadata, bounded development dependencies and explicit runtime file list.
- [x] Build strictly; inspect/install the archive in a disposable gem directory and verify source/version/help/parsing using installed code outside the checkout.
- [x] Run verify on both interpreters; keep user and system gems unchanged.

### Task 3: Release/download workflow and documentation

Files: .github/workflows/, script/verify_release.rb, script/download_release.sh, spec/tooling_spec.rb, README.md, DEVELOPMENT.md, Dockerfile.
Interface: vVERSION tag gated workflow; public gem + checksum; optional PMLATEX_DEPLOY_DEST.
- [x] Add tooling tests for version/tag/ancestry/collision checks and fixture-based download success, tampering, missing assets and existing destinations; observe missing-tool failures.
- [x] Adapt scalebar release helper/workflow; test offline with simulated git repos and command fixtures.
- [x] Document usage and side effects, isolated Mac installation/removal, development on both Rubies, audit findings, limits and explicit future release procedure. Mark legacy Dockerfile status.
- [x] Validate shell/YAML syntax, both complete suites, strict builds and installed smoke checks; request one fresh reviewer per executing-plans skill and resolve material findings.
