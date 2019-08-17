# Changelog

## Unreleased

## [0.8.0]
## Added
* Rails 6 support
* Testing on ruby 2.6

### Fixed
* Fix how `:validate` option to `guise_for` was being handled. Passing
  `validate: false` would still define validations.

## [0.7.0] 2018-04-09
### Removed

* Support for ruby < 2.3
* Support for rails < 4.2

## [0.6.1] 2018-04-09
### Fixed

* Fix broken `require` statement
* Correct proxy to `has_guise?` definitions. If `:Labtech` is a defined value,
  correct how the `lab_tech?` predicate calls `has_guise?(:lab_tech)`.
