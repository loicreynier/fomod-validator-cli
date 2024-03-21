# FOMod Validator CLI

Simple [FOMod] validator CLI app based on [`pyfomod`][pyfomod].

## Usage

```bash
fomod-validator <fomod-root>
```

`<fomod-root>` is the directory containing the `fomod` directory.
In the following example the `<fomod-root>` is the `data` directory:

```text
data
└── fomod
   ├── info.xml
   └── moduleconfig.xml
```

## About

This is a simple CLI wrapper around `pyfomod.parse("...").validate()`
which exits with status 1 if warning are found and print them.
This is intended to be used as pre-commit hook in Git repositories.

In other words,
is a CLI (and simplified) version of [`fomod-validator`][fomod-validator].

[FOMod]: https://fomod-docs.readthedocs.io
[pyfomod]: https://pyfomod.readthedocs.io
[fomod-validator]: https://github.com/GandaG/fomod-validator
