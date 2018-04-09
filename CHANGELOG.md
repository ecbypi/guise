# Changelog

## [0.7.0] 2018-04-09
### Removed

* Support for ruby < 2.3
* Support for rails < 4.2

## [0.6.1] 2018-04-09
### Fixed

* Fix broken `require` statement
* Correct proxy to `has_guise?` definitions. If `:Labtech` is a defined value,
  correct how the `lab_tech?` predicate calls `has_guise?(:lab_tech)`.
