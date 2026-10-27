# Maintenance scope

Approved by the user on 2026-10-27. Preserve command behavior and generated content.
Audit and strengthen offline tests, verify Ruby 2.6.10 and locally available Ruby
4.0.9, repair dependency/package metadata, replace automatic GitHub Packages
publication with tested GitHub Releases, and document installation/development.
No tags, pushes or publication in this task. No speculative functional fixes.

Reuse scalebar's distribution pattern: explicit stable vVERSION tag, both Ruby
checks before release, strict gem build, isolated installation smoke test, draft
upload and byte verification before publication, gem plus SHA-256 assets, public
download helper with optional explicitly requested deployment. The initial
version was 1.3.4; the user subsequently requested a patch increase to 1.3.5
for the Ruby compatibility fix. Tags and publication remain deferred.
The former package registry could be retained, but it publishes ordinary pushes
and requires authentication; the approved Releases pattern matches scalebar.

Tests exercise real parsing/local files and mock only remote Medusa boundaries
and interactive input. Record product limitations rather than silently fixing
them. Existing GPL license text controls package metadata.

Follow-up scope: user explicitly requested English corrections to every --help
screen. Banner strings and option descriptions may change; parsing and command
operations remain unchanged. No tag creation or publication is authorized.
