# pmlatex

`pmlatex` connects a LaTeX document prepared with `pmlatex.sty` to Medusa.
It creates a bibliography record, inserts its Medusa ID into the source,
uploads an already compiled PDF, updates bibliography metadata, and links
records cited by the document. It does not compile LaTeX or generate a PDF.

## Ruby and dependencies

Maintenance verification targets **Ruby 2.6.10 and Ruby 4.0.9**. The gem requires
Ruby >= 2.6.10; other versions have not been verified. Ruby 2.6 is end-of-life
and retained for existing installations.

Runtime dependencies are `medusa_rest_client` (~> 1.0) and `optimist` (~> 3.0).
The verified versions are Medusa REST Client 1.5.2 and Optimist 3.2.1. The client
is served by the [university gem repository](https://dream.misasa.okayama-u.ac.jp/rubygems/),
not RubyGems.org; its dependencies come from RubyGems.org. Keep this HTTPS source
available when installing or updating dependencies. A pmlatex Release packages
pmlatex itself, not its dependency gems or `pmlatex.sty`.

## Download a verified Release

Distribution is being moved to public [GitHub Releases](https://github.com/misasa/pmlatex/releases).
The former GitHub Packages publishing workflow has been removed. Ordinary pushes
and pull requests run verification only. No Release was published as part of
this maintenance work; until the first public Release exists, the download
helper fails clearly. It never substitutes an unverified source build.

From this checkout, use Bash, curl, `shasum` and the POSIX `link` utility on macOS or Jenkins. Downloading
requires no GitHub token, `gh` login, Ruby, or gem installation.

```sh
# Latest stable public Release; use a fresh output directory.
bash script/download_release.sh --output-dir ./downloads

# Pin a future published version (example only; 1.3.5 is not published here).
bash script/download_release.sh --version 1.3.5 --output-dir ./downloads-1.3.5
```

The helper downloads `pmlatex-VERSION.gem` and `pmlatex-VERSION.gem.sha256`,
checks both the SHA-256 and manifest filename, then saves the verified files.
Existing files, including dangling symlinks, cause a failure. A competing writer
also stops the save; if saving the second asset fails, the verified first asset
may remain. Retry in a fresh directory. The default follows
GitHub's latest stable Release, excluding drafts and prereleases. An optional
`v` prefix is accepted for a pinned stable three-part version. Asset URLs are:

```text
https://github.com/misasa/pmlatex/releases/download/vVERSION/pmlatex-VERSION.gem
https://github.com/misasa/pmlatex/releases/download/vVERSION/pmlatex-VERSION.gem.sha256
```

For a separate, explicitly requested transfer to a university Web server:

```sh
export PMLATEX_DEPLOY_DEST='user@server.example.edu:/absolute/web/path'
bash script/download_release.sh --version 1.3.5 --output-dir ./transfer-1.3.5 --deploy
```

Use the real destination and existing noninteractive SSH credentials/known host.
The destination parent must already exist. Only simple `user@host:/absolute/path`
syntax is supported; use an SSH config alias for a custom port. The helper first
reserves a new `vVERSION` directory with an atomic remote `mkdir`, then copies
both verified files. It refuses an existing version directory. A failed transfer
can leave a partial directory; inspect it before explicitly removing it to retry.
Setting the environment variable alone does not deploy. The helper does not
configure a Web server or update a gem index.

## Install on macOS with Homebrew Ruby 4

These commands assume Ruby 4 already exists at `/opt/homebrew/opt/ruby/bin/ruby`.
They select a dedicated gem directory without modifying system Ruby or shell
startup files. Replace the filename below with an actual downloaded Release.
The `--source` option supplies the university client repository for dependency
installation; RubyGems.org must also remain an available source.

```sh
(
  set -eu
  export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
  export GEM_HOME="${PMLATEX_GEM_HOME:-$HOME/.local/share/pmlatex/ruby-4.0}"
  export GEM_PATH="$GEM_HOME"
  command -v ruby
  ruby -v
  gem install --no-document --clear-sources --source https://rubygems.org \
    --source https://dream.misasa.okayama-u.ac.jp/rubygems/ \
    ./downloads/pmlatex-1.3.5.gem
  "$GEM_HOME/bin/pmlatex" --help
)
```

Do not add the former HTTP server to your permanent gem sources. For an update,
download a new Release into a fresh directory and install that local gem with
the same environment. `gem update pmlatex` does not fetch GitHub Releases.
New versions retain older installed versions; reinstalling the same version
replaces that version's files. Select the same `PATH`, `GEM_HOME` and `GEM_PATH`
when running the installed command later. Recheck the interpreter after a
Homebrew Ruby upgrade; this directory is intended for Ruby 4.0.

To run the installed command later, select the same environment and put its
executable directory on PATH. Replace `--help` with the command you intend to run.

```sh
(
  set -eu
  export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
  export GEM_HOME="${PMLATEX_GEM_HOME:-$HOME/.local/share/pmlatex/ruby-4.0}"
  export GEM_PATH="$GEM_HOME"
  export PATH="$GEM_HOME/bin:$PATH"
  pmlatex --help
)
```

To remove all pmlatex versions and its executable from that dedicated directory,
while keeping dependency gems and the source checkout:

```sh
(
  set -eu
  export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
  export GEM_HOME="${PMLATEX_GEM_HOME:-$HOME/.local/share/pmlatex/ruby-4.0}"
  export GEM_PATH="$GEM_HOME"
  gem uninstall pmlatex --all --executables
)
```

## Medusa configuration

`medusa_rest_client` reads `.orochirc` in the current directory first, then
`~/.orochirc`. Use the configuration and credentials supplied by your Medusa
administrator. For example, the configuration shape is:

```yaml
uri: https://your-medusa.example.edu/stone/
user: your-account
password: your-password
```

Store real credentials outside the repository and restrict file permissions.
The client loads this configuration even for `--help`. If no readable
configuration exists, it may write a default `~/.orochirc`; an unreadable or
invalid file may also trigger that fallback. Configure it before first use.
The offline test suite uses temporary credentials and never contacts Medusa.

## Commands and file changes

The following examples use `pmlatex` from the dedicated environment above.
In a development checkout, prefix the command with `bundle exec`.
Commands accept `report`, `report.tex`, or `report.pdf` as the same basename.
All four commands require both `report.tex` and `report.pdf` to exist, including
`update` and `scan`. The PDF must already have been compiled.

| Command | Behavior and side effects |
|---|---|
| `pmlatex add report` | Create a bibliography record from title, authors and date; copy the source to `report.tex.backup`; insert `\BibliographySisyphus{ID}` into `report.tex`. Reject an already paired document. Does not upload the PDF or automatically run scan. |
| `pmlatex scan report` | Find cited records in the source, recursively included files and paths found in `report.log` if present; link them to the bibliography. Write `report.ss` when any citations resolve. |
| `pmlatex commit report` | Upload `report.pdf` to the parsed bibliography ID. For an attachment with the same filename, prompt to replace, cancel (`n`), or append (`append`). An empty reply means replace and deletes the old attachment before upload. |
| `pmlatex update report` | Compare title, authors, year and month with the record. Prompt before saving changed metadata; an empty reply means yes. Leave the source unchanged. |

Typical first registration:

```sh
pmlatex add report
# Recompile report.tex using your existing TeX toolchain after ID insertion.
pdflatex report
pmlatex scan report
pmlatex commit report
```

For revisions, compile the PDF, then use `pmlatex commit report` and, when
metadata changed, `pmlatex update report`. Inspect the confirmation before
replacing a remote attachment. `commit --message MESSAGE` additionally invokes
an existing SVN commit command; this legacy option is not part of offline
verification. Use `pmlatex --help` or `pmlatex commit --help` for option details.

The parser expects conventional, line-oriented `\title`, `\author`, `\date`,
`\input`, `\include`, `\cite`, `\citep`, `\citeyearpar`, `\citeauthor`, and
`\refdream` commands. It is a limited text parser rather than a TeX engine.
See [DEVELOPMENT.md](DEVELOPMENT.md) for preserved limitations, including citation
lists, input paths, backup overwrites and partial failures. Real Medusa operations
and PDF compilation have not been exercised by this maintenance verification.

## Development and verification

Use RSpec 3.13 and Rake; WebMock blocks HTTP in unit tests. Lockfiles are ignored
for this gem so the two Ruby versions can resolve compatible dependencies
independently. Do not share a Bundler 4 lockfile with Bundler 2.4. The packaged
gem contains only `lib/**/*.rb`, `bin/pmlatex`, this README and the license.

Ruby 4, from this checkout:

```sh
(
  set -eu
  export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
  export BUNDLE_PATH="$PWD/vendor/bundle4"
  export BUNDLE_USER_HOME="$PWD/vendor/bundler-home4"
  ruby -v
  bundle install
  bundle exec rake verify
)
```

`rake verify` runs the complete randomized suite, strictly builds the gem in
`pkg/`, checks its archive contents/metadata, installs it into a disposable
gem directory, and exercises the installed parser, renderer and all help
commands outside the checkout. It exposes exactly Bundler's resolved dependency
versions via temporary symlinks; no user gems are installed or replaced and the
smoke test does not fetch dependencies. `.orochirc` and output files are also
isolated. Package validation is not a live-server integration test.

Use Ruby 2.6.10 with Bundler 2.4.22 in a separate checkout and dependency directory.
This Mac's system Ruby lacks usable native extension headers. The verified local
procedure below therefore uses its bundled BigDecimal 1.4.1 and Pry 0.14.2 via
a development-only Gemfile; runtime requirements are unchanged. Execute this in
the separate checkout. Do not upgrade system RubyGems.

```sh
(
  set -eu
  export PATH="/usr/bin:/bin:$PATH"
  export GEM_HOME="$PWD/vendor/tools2"
  export GEM_PATH="$GEM_HOME"
  export BUNDLE_PATH="$PWD/vendor/bundle2"
  export BUNDLE_USER_HOME="$PWD/vendor/bundler-home2"
  /usr/bin/ruby -v
  /usr/bin/ruby /usr/bin/gem install bundler --version 2.4.22 --no-document \
    --clear-sources --source https://rubygems.org
  mkdir -p vendor/check2
  cat > vendor/check2/Gemfile <<'RUBY'
eval_gemfile '../../Gemfile'
gem 'bigdecimal', '= 1.4.1'
gem 'pry', '~> 0.14.0'
RUBY
  export BUNDLE_GEMFILE="$PWD/vendor/check2/Gemfile"
  /usr/bin/ruby "$GEM_HOME/bin/bundle" _2.4.22_ install
  /usr/bin/ruby "$GEM_HOME/bin/bundle" _2.4.22_ exec rake verify
)
```

The old system RubyGems may print a Bundler compatibility warning; the pinned
Bundler is intentional. CI resolves dependencies without these Mac-only pins,
using Ubuntu 24.04, Ruby 2.6.10 / 4.0.9, and matching Bundler/RubyGems versions.
Local passes do not establish a successful hosted Actions run. The Dockerfile
uses Ruby 4.0.9 and the same verification task, but its image has not been built
or tested in this maintenance session.

## Release procedure (maintainers)

1. Review and merge the maintenance changes, then confirm the hosted verification
   jobs pass on both Ruby versions. No tags or Releases are created by ordinary
   master pushes or pull requests.
2. Choose a new, unused stable three-part version, update `lib/pmlatex/version.rb`,
   and merge it into master. The source version is now **1.3.5**, increased from
   1.3.4 for the Ruby compatibility fix. No tag or Release has been created for
   this update. The existing `1.3.4` tag prevents reusing that older version.
   On 2026-10-27, public tags were `1.2.1`, `1.3.0`, `1.3.1`, `1.3.3`, `1.3.4`,
   with no public Releases. Recheck remote tags, all Releases including drafts,
   and historical registry versions before tagging or publishing 1.3.5.
3. Only after separate release authorization, create an annotated `vVERSION` tag
   on the intended master commit and push that tag. This task has done neither.
4. The tag workflow waits for both verification jobs. Its release job validates
   version, tag, event/checkout commit, master ancestry and existing Releases,
   then strictly builds and verifies the installed gem. Only this job receives
   `contents: write`.
5. The job creates a draft with the gem and SHA-256 assets, downloads them again,
   compares bytes and checksum, then publishes. It never overwrites existing
   Releases/assets. Failure can leave an unpublished draft; inspect it before
   deciding how to retry. A successful Release cannot be republished by rerunning.
6. Confirm unauthenticated download using `script/download_release.sh`. A server
   transfer requires its own explicit `--deploy` invocation.

This workflow does not publish to RubyGems.org or GitHub Packages, and does not
create tags. Keep the repository public for unauthenticated downloads.

## License

GPL-3.0-or-later, as stated in [LICENSE.txt](LICENSE.txt). The former MIT gemspec
metadata has been corrected to match that existing license notice.
