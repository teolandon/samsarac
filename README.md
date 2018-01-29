# samsara
A Samsara compiler in OCaml. Also an assignment repo for CSC-312
Language Implementation with Peter Michael Osera. By Theo Kalfas.

# simplecli
A simple exercise in CLI construction in OCaml.

simplecli takes an amount of arguments and prints them out in order, one in
each line. It also supports two command flags:

* **-length** -- prints out the lengths of the arguments instead of the arguments
    themselves.
* **-help**  -- prints out a usage message for simplecli.

## Dependencies
simplecli is written in OCaml, and uses the core library exclusively. Follow
the official instructions from the [OCaml website](https://ocaml.org/docs/install.html)
to install the latest OCaml tools.

The `ocamlopt` compiler is used to build the project.
A number of common GNU tools are also required for tests and simple builds.
These tools are as follows:

* bash, located in `/bin/bash`
* `make`
* `diff`
* `rm`
* `cd`
* `echo`
* `pwd`

These, or equivalent versions are available with almost all Linux and MacOS
installations, and are mostly available in Windows using the [Windows Subsystem
for Linux](https://docs.microsoft.com/en-us/windows/wsl/about).

## Build
To compile simplecli, run `make` in the root directory.
To remove all compiled and intermediary files, run `make clean`.

## Testing
Tests can be ran using `make test`. They produce a diff of the expected outputs
of the arguments in `test/args.in` and the actual results when ran. An easy way
of checking if the test was successful in a script is to check the result of the
variable `$?`, which reports the exit code of the last command that ran. If it's
`0`, then the results are identical, else the test has failed.

## Execution
Run simplecli in the terminal, using `./simplecli [flag] arg1 arg2 arg3`,
where `arg1` `arg2` `arg3`, etc are the arguments that are to be echoed back
into the terminal line by line, and `[flag]` an optional flag, as seen above in
the **simplecli** section.

Note about flags: The `-help` flag overrides any other execution. If it's
present, then the usage message will be displayed and no arguments will be
echoed. Invalid flags also interrupt the program and print the usage statement.

## Hooks
It's highly recommended that git hooks are installed for this repo to automate
testing and keep commits clean and correct. Refer to the HOOKS.md file in the
**hooks/** directory.

# Changelog

## Assignment 01 - 2018-01-30

### Added
* simplecli source code
* Tests for simplecli in `test/`
* Makefile with targets for `make`, `clean` and `test`

### Changed
* None

### Known bugs
* None
