# MacAdminInspector — agent operating rules

MacAdminInspector is a small macOS 14+ SwiftUI lab application. Preserve its
small scope, local-first behavior, and simple architecture.

## Mandatory tool boundary

Xcode MCP is the sole authority for working with this project.

- Use Xcode MCP to inspect project files, edit Swift and resource files, add or
  remove files, change target settings, manage schemes, build, test, run, and
  debug.
- Do not edit any project-resident file through the shell, a filesystem API, or
  a generic patch/edit tool. This includes `.swift`, `.json`, `.plist`,
  `.entitlements`, `.xcodeproj`, `.xcworkspace`, schemes, and build settings.
- Do not call `xcodebuild`, `swift`, `swiftc`, or other command-line build or
  debug tools for this project.
- Do not modify `project.pbxproj` manually. Let Xcode MCP update project
  membership and build phases.
- If Xcode MCP is unavailable or cannot perform a required operation, stop and
  report the blocker. Do not use a direct-edit or command-line workaround.

## Required workflow

1. Inspect the relevant files and target configuration with Xcode MCP before
   changing anything.
2. Make the smallest change that fulfils the request. Avoid unrelated cleanup
   and avoid changing existing user work outside the request.
3. Build the `MacAdminInspector` scheme with Xcode MCP after every meaningful
   change. Run relevant tests when they exist.
4. Resolve errors and warnings introduced by the change before reporting
   completion.
5. For UI or runtime behavior changes, run/debug the app with Xcode MCP and
   verify the affected path when possible.
6. Report what changed, how it was verified, and any limitation that remains.

## Product constraints

- Keep the minimum deployment target at macOS 14.0. Use SwiftUI/AppKit APIs
  available on that target.
- Device inventory is local and read-only by default. Do not upload inventory,
  change device configuration, request elevated privileges, or run privileged
  commands unless the user explicitly requests and authorizes it.
- Treat externally fetched data as external: name its source in the UI and do
  not represent it as locally verified system state.
- Prefer data that macOS returns explicitly. Do not infer a network type,
  product, ownership, security state, or other classification from names,
  addresses, paths, or heuristics.
- Use a focused Foundation service for each inventory source. Views render
  models and request actions; they contain no filesystem, process, or parsing
  logic.
- Treat the AI-tool catalog as data. Add or adjust catalog entries in
  `Resources/AITools.json`, rather than hard-coding product metadata.

## Change hygiene

- Preserve user-created files and uncommitted changes. Never reset, discard, or
  overwrite unrelated work.
- Do not add dependencies, capabilities, network access, privacy permissions,
  telemetry, or background behavior without explicit user approval.
- Keep strings and data models accurate: show `Unavailable` when the source
  does not return a value rather than substituting a guess.
