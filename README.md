# ResourceBundles

[![Build Status](https://travis-ci.org/KlausC/ResourceBundles.jl.svg?branch=master)](https://travis-ci.org/KlausC/ResourceBundles.jl)
[![Coverage Status](https://coveralls.io/repos/KlausC/ResourceBundles.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/KlausC/ResourceBundles.jl?branch=master)
[![codecov.io](http://codecov.io/github/KlausC/ResourceBundles.jl/coverage.svg?branch=master)](http://codecov.io/github/KlausC/ResourceBundles.jl?branch=master)

ResourceBundles is a module to support Internationalization (I18n).
Main features:
* Locale
  * create Locale from string formed according to standards (BCP47 (tags for Identifying languages), RFC5646, RFC4647)   
  * set/get default locale for different purposes 
  * startup-locale derived form environment settings (LANG, LC_MESSAGES, ..., LC_ALL)
* ResourceBundle
  * Database of text strings, identified by locale and individual text key
  * select most specific available text according to ordering of locales
* Message text localization
  * a string macro providing translation of standard language according to default locale
  * support string interpolation and control ordering of interpolated substrings
* NumberFormat
* DateTimeFormat
