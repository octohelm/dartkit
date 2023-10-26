# DartKit

Dart & Flutter toolkit

## `@octohelm/dartpkg`

A [Bun](https://bun.sh/) cmd to help do package manager with npm.

### How to use

1. [Create npm monorepo](https://bun.sh/docs/install/workspaces)
2. Add `package.json` into sub dart pkg like

```json5
{
  // only support scoped package
  // /dart- mush prefix pkg name
  "name": "@<scope_name>/dart-<pubspec_name>",
  "type": "module",
  "exports": {
    // for bun module resolver
    "bun": "pubspec.yaml"
  },
  "scripts": {
    "postinstall": "bunx @octohelm/dartpkg postinstall"
  }
}
```

Then after `bun install`:

* `pubspec.yaml` patched
    * `name`
    * `version`
    * `dependencies` and `dev_dependencies` if exists
* `pubspec_overrides.yaml` created.

We could add `scripts` sub in each dart pkg, and do incremental build with [turbo](https://github.com/vercel/turbo)

```json5
{
  "scripts": {
    "gen": "dart run build_runner build --delete-conflicting-outputs",
    "fmt": "dart fix --apply && dart format -o write ./lib",
    "test": "dart test",
    // for flutter pkg
    // "test": "flutter test"
  }
}
```