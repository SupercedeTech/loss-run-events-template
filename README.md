# Loss Run Events

The goal is to implement a page for our _Loss Run Events_ feature.

This repository is a template. You can click _Use this template_ on GitHub to
create your own repository based on this one.

The easiest way to get started working on this project is with Nix. Assuming
Nix is installed, you can just clone your own repository, and then run `nix
develop` from the project root to access a development shell. This shell will
include all the dependencies needed to run the project locally.

Once you're in a development shell, run `ghci`.

With GHCi running, you can run the `:test` command to run the test suite, and
you can run the `:serve` command to serve the project locally. The application
will be served at http://localhost:3000/.

## TODO:

- Add a page for Loss Run Events. Implement the design in Figma as accurately
  as possible. Use idiomatic Hamlet, Cassius, and Julius. Prefer vanilla
  JavaScript over libraries/frameworks.

- Parse the loss run events data from the CSV file and persist the data in the database.

- Add automated tests.

- Document any added top-level functions.

- Feeling ambitious? Move the loss run events page into a subsite.
