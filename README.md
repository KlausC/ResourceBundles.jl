# ResourceBundles

[![Build Status](https://travis-ci.org/KlausC/ResourceBundles.jl.svg?branch=master)](https://travis-ci.org/KlausC/ResourceBundles.jl)
[![Coverage Status](https://coveralls.io/repos/github/KlausC/ResourceBundles.jl/badge.svg?branch=master)](https://coveralls.io/github/KlausC/ResourceBundles.jl?branch=master)
[![codecov.io](http://codecov.io/github/KlausC/ResourceBundles.jl/coverage.svg?branch=master)](http://codecov.io/github/KlausC/ResourceBundles.jl?branch=master)

### ResourceBundles is a module to support Internationalization (I18n).
Main features:

* Locale
  * create Locale from string formed according to standards (BCP47 (tags for Identifying languages), RFC5646, RFC4647)
  * set/get default locale for different purposes
  * startup-locale derived form environment settings (LANG, LC_MESSAGES, ..., LC_ALL)
  * Locale patterns represent a set of locales by using a kind of pattern matching.
  * Locale patterns imply a canonical partial ordering by set inclusion
* ResourceBundle
  * Database of text strings, identified by locale and individual text key
  * select most specific available text according to canonical ordering of locales
  * detect ambiguities for individual keys
  * storage in package module directory
* Message text localization
  * a string macro providing translation of standard language according to default locale
  * support string interpolation and control ordering of interpolated substrings
  * fall back to text provided as key within the source text
  * Define global default Resource bundle for each module
* NumberFormat
* DateTimeFormat
