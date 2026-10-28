# Development and regression verification

## Ruby minimum requirement correction for 1.3.5

The installation requirement is **Ruby >= 2.6.0**. Commit `8312451`
(2026-10-27, preparation of 1.3.5) introduced `>= 2.6.10` alongside tests and
documentation tied to the tested Mac interpreter. That conflated the verification
target with the minimum installation requirement. This correction follows
[scalebar PR #7](https://github.com/misasa/scalebar/pull/7): it fixes existing
package metadata and keeps **1.3.5**. `lib/pmlatex/version.rb`, all runtime code,
command behavior, runtime dependency constraints and the Ruby 2.6.10 / 4.0.9 CI
matrix are unchanged. No Windows job is added.

The correction starts at `origin/master` commit `811658d`. Its baseline suite
passed on both Mac interpreters: **96 examples, 0 failures**. Replacing the
single old Ruby-floor example with six independent admission examples first
produced exactly three failures (2.6.0, 2.6.1 and 2.6.6). After correcting the
gemspec and the fixed expectation in `script/verify_package.rb`, the examples
reject 2.5.9 and admit 2.6.0, 2.6.1, 2.6.6, 2.6.10 and 4.0.9.

Local verification on 2026-10-29 uses the existing dependency directories and
the Mac-only Ruby 2 workaround documented below, without updating dependencies:

| Interpreter | Tools | Result of `bundle exec rake verify` |
|---|---|---|
| macOS system Ruby 2.6.10 | Bundler 2.4.22, RubyGems 3.0.3.1 | 101 examples, 0 failures; strict build; isolated install, parser/log/renderer and all five CLI help paths |
| Homebrew Ruby 4.0.9 | Bundler 4.0.23, RubyGems 4.0.23 | 101 examples, 0 failures; strict build; isolated install, parser/log/renderer and all five CLI help paths |

Both strict builds produce `pmlatex-1.3.5.gem` with Ruby requirement `>= 2.6.0`.
The final `pkg/pmlatex-1.3.5.gem` is verified under both interpreters, with a
SHA-256 manifest at `pkg/pmlatex-1.3.5.gem.sha256`. Builder versions can produce
different archive hashes; preserve the exact verified gem/checksum pair.
The final archive's `bin/` and `lib/` contents are byte-identical to master.
Local evidence and per-interpreter archives are retained under ignored
`pkg/compatibility-1.3.5/`; neither generated gems nor lockfiles are committed.

**Ruby 2.6.0 itself was not executed.** Metadata admission, source inspection
and Ruby 2.6.10 syntax checks do not establish Ruby 2.6.0 runtime certification.
Other interpreters, a fresh dependency resolution on 2.6.0, Docker, actual TeX/PDF
compilation and live Medusa behavior remain unverified. The existing suite
tests command operations using doubles and blocks HTTP; no registration,
update, deletion or upload against a live Medusa service is performed.
Hosted CI results must be checked on the PR separately from these Mac results.

### Runtime dependency audit

The installed gemspecs and runtime sources were inspected. Medusa REST Client
1.5.2 and Optimist 3.2.1 both declare `required_ruby_version >= 0`, with no native
extensions. Optimist has no runtime gem dependencies. The client depends on
ActiveResource, rails-observers, Pry (~> 0.9) and GLI (~> 2.12). The complete
resolved Ruby 2.6.10 runtime closure is below; all 18 gemspecs admit Ruby 2.6.0
and none declares native extensions:

| Gem | Resolved version | Declared Ruby requirement |
|---|---|---|
| medusa_rest_client | 1.5.2 | >= 0 |
| optimist | 3.2.1 | >= 0 |
| activeresource | 6.1.4 | >= 2.6.0 |
| activemodel | 6.1.7.10 | >= 2.5.0 |
| activesupport | 6.1.7.10 | >= 2.5.0 |
| activemodel-serializers-xml | 1.0.3 | >= 0 |
| builder | 3.3.0 | >= 0 |
| concurrent-ruby | 1.3.8 | >= 2.3 |
| i18n | 1.14.8 | >= 2.3.0 |
| tzinfo | 2.0.6 | >= 1.9.3 |
| zeitwerk | 2.6.18 | >= 2.5 |
| minitest | 5.25.4 | >= 2.6, < 4.0 |
| rails-observers | 0.1.5 | >= 2.2.2 |
| pry | 0.14.2 | >= 2.0 |
| coderay | 1.1.3 | >= 1.8.6 |
| method_source | 1.1.0 | >= 0 |
| gli | 2.22.2 | >= 0 |
| ostruct | 0.6.3 | >= 2.5.0 |

Ruby 2.6.10 compiled 908 Ruby source files from pmlatex and this closure;
generator ERB templates named `.rb` were excluded because they are not executable
Ruby source. pmlatex uses existing File/IO, regexp, string/encoding, Time, Math
and Open3 APIs. The client's `String#match?` and Optimist's regexp matching are
available in Ruby 2.6.0; optional DidYouMean support is guarded. ActiveSupport's
`ruby2_keywords` use is guarded by `respond_to?`. No concrete requirement for
Ruby 2.6.1 or later was identified in the inspected implementation or this closure.
The source check cannot rule out interpreter patch-level bugs or unexercised paths.
See the [Ruby 2.6.0 String API](https://docs.ruby-lang.org/en/2.6.0/String.html)
and [ActiveResource 6.1.4 metadata](https://rubygems.org/gems/activeresource/versions/6.1.4).

The Ruby 4 closure was also inspected. It uses ActiveResource 6.2.0 (Ruby >= 2.7),
ActiveModel/ActiveSupport 8.1.4 (>= 3.2), I18n 1.15.2 (>= 3.1), and other newer
transitive gems. Those resolved versions cannot be copied into a Ruby 2.6
environment; resolve dependencies for each interpreter. Older compatible
versions satisfy the unchanged client constraints, as the Ruby 2 closure shows.
The local BigDecimal 1.4.1 / Pry 0.14.2 workaround remains development-only.
Future versions allowed by the broad dependency ranges are not certified by
this audit. No dependency update or constraint change is needed for this fix.

## Same-version 1.3.5 redistribution

This is a correction to an existing installation constraint, with no new feature
or runtime behavior change, so the source version remains **1.3.5**. A local
rebuild does not update any distributed copy. This task changes no GitHub
Release, tag, university gem, repository index or installed user gem.

Before any separately authorized replacement, preserve the old gem, metadata
and checksum; record the corrected source commit and old/new SHA-256 values.
The filename and name/version/platform tuple remain the same while bytes and
Ruby metadata change. Distribute and verify the new gem and SHA-256 together.
An existing GitHub Release may restrict asset replacement; check its current
policy and permissions. If replacement is allowed, coordinate both assets to
avoid a download seeing a new gem with an old checksum. Keep tags unchanged,
and record the corrected source commit because tag source archives still point
to the old source. The ordinary release workflow and `verify_release.rb` refuse
existing Releases/assets; rerunning them is not a replacement mechanism.

For the university gem repository, have its administrator identify the serving
software and supported replacement procedure. Replacing only the `.gem` can leave
the old Ruby floor in quick gemspecs, dependency/compact indexes or caches.
Regenerate all applicable metadata/indexes from the retained gem set and deploy
them consistently with the replacement archive. Check repository, proxy, mirror,
client gem and quick-spec caches. The download helper's `--deploy` refuses an
existing version directory and does not update a gem index.

Existing installations and version-only lockfiles cannot distinguish the two
1.3.5 archives; `gem update` has no higher version to select and Bundler may
reuse cached bytes. Download the corrected gem/checksum into a fresh directory,
verify SHA-256 and the embedded Ruby requirement, then explicitly reinstall
the local archive in the intended interpreter/gem environment, for example
`gem install --local --no-document PATH/pmlatex-1.3.5.gem` with dependencies
already available. A lockfile containing the old checksum needs a reviewed
refresh after authenticating the replacement; do not bypass a mismatch.

## Scope and evidence

Baseline: `22a903e`. This maintenance work preserves command operations, bibliography
semantics, parsing and generated document content. The only command-logic change is
`File.exists?` to `File.exist?` in `Scan.process_file`: Ruby 4 no longer provides
the old alias, while Ruby 2.6 supports both. The new scan tests reached this
previously untested path and failed with `NoMethodError` before the substitution.
A subsequent user-requested English help revision changes only banner strings
and option descriptions in App/Add/Commit/Update/Scan. Argument parsing,
confirmation handling, and file/server operations are unchanged. The source
version is 1.3.5, increased from 1.3.4 at the user's request for the Ruby
compatibility fix.

Original suite on Ruby 4.0.9: **30 examples, 0 failures, 1 pending**, with one
RSpec old-syntax deprecation and a swallowed missing-include warning. A green
baseline did not mean scan worked on Ruby 4: its sole process-file example was
skipped. The original log fixtures are present and tracked; the initial file
listing omitted them because search respected ignore rules.

Before the Ruby minimum requirement correction above, the replacement suite had
**96 examples, no failures or pending examples** in local maintenance verification
on Ruby 2.6.10 and 4.0.9. Both interpreters also
strictly built the gem and passed isolated installed-package verification.
Hosted CI, Docker, live Medusa operations, real SVN commits, SSH deployment,
actual Release upload/download and TeX/PDF compilation have not been run here.
Tooling transport and deployment tests use local command fixtures only.

## Audit of the original suite

| Original examples | Defect or useful coverage | Replacement and regression detected |
|---|---|---|
| Add (5) | Replaced the Tex parser and save with null doubles; metadata and backup content were unchecked. The negative scan expectation was useful. | Real source parsed, complete original backup and inserted source compared, all remote metadata fields checked. Remote save/reload and no implicit scan verified. Missing source/PDF and existing ID rejected before creation. |
| Commit (3) | Checked parser lookup and initial upload only; parser was replaced. | Real source ID controls remote lookup/upload; matching attachment replacement, empty/y confirmation, refusal, append, unrelated attachments and missing prerequisites exercised. |
| Update (1) | Matching metadata caused an immediate return; test only expected parser invocation. | Real parsed metadata compared and saved after y/empty reply; refusal preserves every field, author-only changes are detected, equal string/numeric dates avoid a prompt; missing ID/source/PDF fail before lookup. |
| Scan (3, including one pending) | Log include assertion useful. Recursion test swallowed a missing file, then only asserted no exception. Process-file example skipped, with unconfigured FactoryGirl/live-server scaffolding. | Real included files, ordered recursive IDs, missing includes with parent continuation, failed lookups, unique linking and full ss contents. Log-only citations, existing links, no-citation/no-output and absent bibliography cases tested. This exposed the removed File.exists? alias. |
| TexLog (6) | Repeated membership assertions, empty/nil boundaries useful; no order/dedup assertion. | Original real log plus a synthetic literal log verifies path order and deduplication; empty, nil and missing-file behavior retained. |
| Tex (11) | from_file had no assertion. Author comparison useful but partial. Citation tests checked counts only. | Historical report title/ID/authors/includes asserted; exact citation IDs/categories and comment exclusions; full author lists; fixed date; three ID insertion anchors and complete saved contents; missing-anchor failure. |
| OverPic (1) | Any String, including empty output, passed. | Complete existing default isoclock output; independent quarter-circle coordinate expectations and literal horizontal tick geometry/formatting. |
| Legacy feature and steps | Turnip/FactoryGirl/browser-style steps were not configured or run by RSpec. Some setup could contact a live server if enabled. | Removed inert scaffolding; behavior is covered by executable RSpec examples without a live server. |

All examples use disposable directories; no shared `tmp` deletion, lingering
working-directory change, null output singleton or shared global option state.
RSpec randomizes order, verifies partial doubles and treats deprecations as
errors. WebMock forbids HTTP. The real client reads temporary `.orochirc` during
load; test subprocesses also use an isolated HOME/current directory.

## Expectations and boundaries

Tests protect two distinct types of behavior:

- Contract tests use literal IDs, fixed dates and manually checked source/file
  contents: an `Example report` dated 2014-04-05 produces year 2014, month 4,
  volume 14, a backup identical to the original and the created server ID in the
  source. Missing inputs must fail before remote operations.
- Characterizations preserve current parser/output policies rather than declare
  them correct. Metadata at byte zero is not recognized, comma-separated
  citation keys remain one lookup ID, and isoclock formatting is preserved.

Only external Medusa operations and interactive STDIN are substituted. Local
Tex loading, author parsing, source insertion/saving, backups, citation recursion,
log parsing, output rendering and ss writing remain real. Boundary records use
explicit fields; save/reload/upload assertions test requests that would reach
the service. These doubles do not establish compatibility with a live server,
its permissions, association API or authentication settings.

CLI tests use the caller's Ruby via `RbConfig.ruby`; all five help paths and
missing-input errors are exercised in actual subprocesses. A temporary
configuration prevents user credential reads/default writes. Only early-exit
paths are used; no remote mutation is attempted.

The final review found that the first replacement update fixture used the same
author IDs before and after the update. It now uses old ID 3 and new ID 7, and
checks all fields on refusal. A memory-only mutation removing the author-ID
assignment failed three examples (both yes/default confirmations and the
author-only update); the original code passes all eight update examples.

The review also exposed working-directory configuration leakage during helper
load and a download race in which `ln` treated a new destination directory as a
container. Three regression examples failed first, then passed after isolating
the load working directory and replacing `ln` with POSIX `link`. These changes
affect test/tooling behavior only.

## Packaging and tooling

The gemspec includes an explicit allowlist: runtime Ruby files, executable,
README and license only. Tests, workflow/scripts, lockfiles, generated output,
credentials and vendor directories are excluded. Metadata now matches the
existing GPL-3.0-or-later notice instead of the former MIT declaration.
Development dependencies are bounded. The unsupported old HTTP gem source is
replaced with HTTPS and scoped to `medusa_rest_client` in the Gemfile.
Bundler may warn that the university server lacks a dependency API; its full
index endpoint worked during local verification. Availability of that external
server remains a build/install prerequisite for local development and users.
GitHub Actions runners cannot reach that server (bundle install times out), so
the workflow sets `MEDUSA_REST_CLIENT_FROM_GITHUB=1`, and the Gemfile then takes
`medusa_rest_client` from the public GitHub repository at a pinned tag instead.
Update that tag in the Gemfile when the CI client version should change.

The old lockfile described pmlatex 1.2.2 / medusa_rest_client 0.2.0 despite the
baseline gemspec specifying 1.3.4 / ~> 1.0. It is removed from tracking and ignored;
compatible lockfiles are generated independently by each Ruby environment.

`rake verify` runs RSpec, a strict build, and `script/verify_package.rb`.
The verifier checks archive membership, name/version, Ruby requirement, license
and executable metadata. It installs the archive without dependency fetching in
a disposable gem home with symlinks to exactly the already resolved dependency
specifications/directories, excluding the source pmlatex. It then checks the
actual loaded feature path, installed version and install directory, literal
metadata/log parsing and tick output, plus all help commands outside the checkout.
No user/system gem installation is changed. macOS's `/var` to `/private/var`
symlink is normalized when comparing installation roots.

Release preflight tests operate in disposable Git repositories, not this
repository's tags. They check valid output, mismatched tag/commit (including a tag on an older commit), absent or unrelated master
ancestry, legacy version-tag reuse, drafts and paginated asset collisions,
and malformed API data. Download tests simulate curl/ssh/scp and exercise latest
and pinned versions, bytes/checksum, manifest safety, missing assets, unsupported
versions, existing files/symlinks, explicit deployment only, failed remote directory reservation without copying,
and failed copying without a success report or loss of verified local files. They do not
establish live transport success or test the hosted GitHub job end to end.

The workflow runs both Rubies for master pushes, PRs and v-prefixed tags.
Only an explicit tag push can enter the release job after both test/build/smoke
jobs pass. The job rejects source/tag/event/checkout mismatch, commits outside
origin/master, old unprefixed version tags and existing Releases/assets. It
uploads a draft, re-downloads both assets, compares bytes and checksum, then
publishes. No regular push publishes a gem, no tags are created by automation,
and the former unconditional GitHub Packages workflow is removed.

The source version is now 1.3.5, a user-requested patch increase from 1.3.4 for
the Ruby compatibility fix. No tag or Release has been created for this update.
Public Git tags already include 1.3.4, which must not be republished. Recheck
version availability before a separately authorized tag/publication step.
Public tags on 2026-10-27 were 1.2.1, 1.3.0, 1.3.1, 1.3.3, 1.3.4 and the public
Releases API returned an empty list. Public API evidence does not rule out
private drafts or older university/GitHub registry uploads. Recheck those with
maintainer access before choosing a release number.

## Ruby environments

| Environment | Resolved dependency highlights | Verification |
|---|---|---|
| macOS Ruby 4.0.9, Bundler 4.0.23 | Medusa client 1.5.2, Optimist 3.2.1, ActiveResource 6.2.0, ActiveSupport 8.1.4, Pry 0.16.1 | Full suite, strict build, isolated installed package |
| macOS system Ruby 2.6.10, isolated Bundler 2.4.22 | Medusa client 1.5.2, Optimist 3.2.1, ActiveResource 6.1.4, ActiveSupport 6.1.7.10, Pry 0.14.2, bundled BigDecimal 1.4.1 | Full suite, strict build, isolated installed package |
| Hosted Ubuntu 24.04, same exact Ruby versions | Independent resolution, RubyGems/Bundler 3.4.22/2.4.22 for Ruby 2 and 4.0.23/4.0.23 for Ruby 4 | Configured, not run in this session |

Fresh dependency resolution for this Mac's system Ruby initially selected native
BigDecimal 4.1.3 and io-console 0.9.4 via Pry 0.16.1/Reline. The installed SDK lacks
Ruby's `ruby/config.h`, so native extension compilation failed. The documented
Mac-only development Gemfile selects its existing default BigDecimal 1.4.1 and
Pry 0.14.2 (without Reline/io-console). Runtime gem requirements and CI are not
constrained by this workaround. Do not treat that local pinned environment as
proof of every possible Ruby 2 dependency combination. An Ubuntu CI build is
required before merging/releasing; it can compile native dependencies normally.

Official ruby-builder assets for Ruby 2.6.10 and 4.0.9 on Ubuntu 24.04 x64 were
confirmed available on 2026-10-27. Recheck availability if runner setup fails.
CI uses [ruby/setup-ruby](https://github.com/ruby/setup-ruby) and
[actions/checkout](https://github.com/actions/checkout); prebuilt assets are at
[ruby-builder 2.6.10](https://github.com/ruby/ruby-builder/releases/tag/ruby-2.6.10)
and [ruby-builder 4.0.9](https://github.com/ruby/ruby-builder/releases/tag/ruby-4.0.9).
The optional Dockerfile has been updated to the Ruby 4 verification task; no
Docker image build is claimed.

## Preserved functional limitations

These are separate future work, not silently fixed by this maintenance patch.

| Existing behavior | Implication / possible future work |
|---|---|
| Metadata regexes require a preceding newline and accept limited brace nesting/multiline syntax. Include/input regexes are greedy within one line. | Put metadata after a document header and use one include/input command per line. A more complete TeX parser needs a separate behavior contract. |
| Invalid dates (including TeX macros) fall back to the current time; absent author metadata can fail in direct author parsing. | Use explicit dates/authors. Define missing/invalid metadata behavior before changing defaults. |
| Citation lists such as `\cite{one,two}` stay one ID; only full-line `%` comments are excluded. | Cite individual IDs. Define comma-list splitting and comment semantics separately. |
| Included paths are resolved from the process working directory; recursive includes have no cycle guard. | Run from the document directory; avoid cycles. Define path/cycle handling before changing recursion. |
| Missing includes and citation lookup/link failures may be reported and skipped while the command still succeeds. | Output/status is not proof that every requested link exists. Improve failure accounting separately. |
| `scan` with no resolved IDs leaves any old ss file intact; existing ss output is overwritten when IDs resolve. | Review stale output manually. Define file replacement/deletion policy separately. |
| `add` creates the remote record before backing up/saving local source; `.backup` is overwritten if it exists. | A later failure can leave a remote record without a local ID. Define transactional/recovery behavior separately. |
| `commit` deletes the matching remote attachment before uploading its replacement; empty input means yes. EOF handling is limited. | Upload failures may lose the old attachment; define safer replacement and interaction behavior separately. |
| `update` may create authors before metadata confirmation; empty input means yes. | Refusal prevents the bib save but is not a guarantee that no authors were created. |
| `commit --message` invokes an interpolated shell SVN command. | It is outside this verification; review argument quoting and SVN side effects as separate work. |
| Client configuration is read at load time, even for help, and may write defaults on failure. | The tests isolate configuration. Changing CLI/config initialization order is separate functional work. |
| `pmlatex.sty`, LaTeX packages and live Medusa services are external. | This task verifies Ruby/local file contracts, not compiled PDFs or a live upload/link round trip. |

## Additional test audit

A follow-up audit added four failure-path examples without changing runtime or
distribution code: a tag on an older commit despite matching event/checkout,
an existing but unrelated master reference, failed remote directory creation
(no copy attempted), and failed file transfer (nonzero exit, no deployment
success report, verified local files preserved). All transport is simulated.

## English command help revision

The global help and all four subcommand help screens now use consistent English
and describe each command's prerequisites and side effects. The text explains
backup replacement, attachment confirmation/defaults, the SVN side effect of
`commit --message`, author creation before update confirmation, and scan's ss
output/failure boundaries. Examples include compiling the initial PDF before
`add` and recompiling after ID insertion.

Only string contents changed in the five Ruby files for this revision; a Ruby
lexer comparison against the pre-revision files confirmed that all tokens outside
string contents were identical. All five actual help outputs were inspected,
and existing subprocess tests verify help exits successfully. No wording-only
snapshot tests were added. The existing complete suite and installed-package
help checks run on both maintenance Rubies.
