# google_places_sdk_plus_http

An HTTP/REST implementation of [`google_places_sdk_plus`](https://pub.dartlang.org/packages/google_places_sdk_plus).

Used by the desktop platform packages (linux, macos, windows) as their underlying implementation.

## Setup

This package uses code generation (`freezed`, `json_serializable`). Generated files (`*.g.dart`, `*.freezed.dart`) are **not** committed to version control.

After cloning or pulling changes, you must generate them before the package will compile:

```bash
cd google_places_sdk_plus_http
fvm dart run build_runner build --delete-conflicting-outputs
```

For continuous development, use watch mode:

```bash
fvm dart run build_runner watch --delete-conflicting-outputs
```

## Running tests

```bash
fvm flutter test
```

## Restrictions

The following methods are not yet implemented:

* `fetchPlace`
* `fetchPlacePhoto`
