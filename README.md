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
  * to be handled in the relevant formatting functions of Base
* DateTimeFormat
  * to be handled in the relevant formatting functions of Base

#### Installation

```
# assuming a unix shell
cd .julia/v0.7
git clone http://github.com/KlausC/ResourceBundles.jl ResourceBundles
[Pkg.add("ResourceBundles")]

```

#### Usage

```
module MyModule
using ResourceBundles

Locales.set_locale!(:MESSAGES, Locale("de"))

println(tr"original text")
println(tr"$n dogs have $(4n) legs")
for lines in [1,2,3]
    println(tr"$errnum lines of code")
end
end module
```
sample configuration files in directory `.julia/v0.7/MyModule/resources`

```
cat messages_de.jl
(
"original text" => "Originaltext",
raw"$(1) dogs have $(2) legs" => raw"$(2) Beine gehören zu $(1) Hunden",
raw"$(1) lines of code" => [raw"$(1) Zeile", raw"""$(2 => "")Zeilenpaar""", raw"$(Any) Zeilen"],) 
```

expected output:
```
Originaltext
12 Beine gehören zu 3 Hunden
0 Zeilen
1 Zeile
ein Zeilenpaar
3 Zeilen
```

#### Implementation

##### Locales

Locales are converted from Strings, which are formatted according to BCP47.
Examples: "en", "en-Latn", "en-us", "en-Latn-GB-london", "en_US-x-private".
Additionally the syntax for Posix environment variables `LANG` and `LC_...` are
supported.
Examples: "C", "en_US", "en_us.utf8", "en_US@posext".
All those formats are converted to a canonical form and stored in objects of type `Locale`.

`Locale` implements the `equals` and the `issubset` (`⊆`) relations. 
Here `Locale("en_US") ⊆ Locale("en") ⊆ Locale("C") === Locale("")`.

There is a set of global variables, which are used as "current locale" for different purposes.
These variables are accessed with get/set methods.
For example the locale `get_locale(:MESSAGES)` is used as the default locale for message
text look-up.

##### Resource Bundles

A resource bundle is an association of string values with arbitrary objects, where the
actual mapping depends on a locale.
Conceptually it behaves like a `Dict{Tuple{String,Locale},Any}`.
Each resource bundle is bound to a package. The corresponding data are stored in the
subdirectory `resources` of the package directory.

`bundle = @resource_bundle("messages")` creates a resource bundle, which is bound
to the current module.
The resources are looked for the resources subdirectory of a package module or, if the
base module is `Main`, in the current working directory.

Naming of locale-specific files. Fallback strategy if requested locale does not exactly match.


##### String Translations

String translations make use of a current locale `(get_locale(:MESSAGES))` and a standard resource bundle `@__MODULE__.RB_messages`.

The macro `tr_str` allows the user to write texts in a standard locale and it is translated
at runtime to a corresponding text in the current locale.
It has the following features.

 * translate plan text
 * support string interpolation, allowing re-ordering of variables
 * support multiple plural forms for exactly one interpolation variable

The database for the translation uses a canonicalized form of the texts used in the source code as keys.

The macro includes the functionality of the gnu library calls `gettext`and `ngettext`.











