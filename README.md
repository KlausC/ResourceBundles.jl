# ResourceBundles

[![Build Status](https://travis-ci.org/KlausC/ResourceBundles.jl.svg?branch=master)](https://travis-ci.org/KlausC/ResourceBundles.jl)
[![codecov.io](http://codecov.io/github/KlausC/ResourceBundles.jl/coverage.svg?branch=master)](http://codecov.io/github/KlausC/ResourceBundles.jl?branch=master)

### ResourceBundles is a package to support Internationalization (I18n).
Main features:

* Locale
  * create Locale from string formed according to standards (BCP47 (tags for Identifying languages), RFC5646, RFC4647)
  * set/get default locale for different purposes
  * startup-locale derived form environment settings (LANG, LC_MESSAGES, ..., LC_ALL)
  * Locale patterns imply a canonical partial ordering by set inclusion

* ResourceBundle
  * Database of objects (e.g. text strings), identified by locale and individual text key
  * select most specific available object according to canonical ordering of locales
  * detect ambiguities for individual keys
  * storage in package module directory
  * database uses files witten in Julia source code
  * database files containing translated texts using gettext-PO format is supported

* Message text localization (LC_MESSAGES)
  * a string macro providing translation of standard language according to default locale
  * support string interpolation and control ordering of interpolated substrings
  * includes mechanism for multiple plural forms for translations
  * fall back to text provided as key within the source text
  * Define global default Resource bundle for each module

* NumberFormat and DateTimeFormat (LC_NUMERIC, LC_TIME) (TODO)
  * If an object is formatted in the interpolation context of a translated string, instead 
  of the usual `show` method, a locale sensitive replacement is called.
  * those methods default to the standard methods, if not explicitly defined.
  * For real numbers and date or time objects, methods can be provided as locale dependent resources.

* String comparison (LC_COLLATE) (TODO)
  * Strings containing natural language texts are sorted locle-sensitive according to
  "Unicode Collation Algorithm". Implementation makes use of `ICU` if possible. In order to treat a string as natural text, it is wrapped by a `NlsString` object.

* Character Classes (LC_CTYPE) (TODO)
  * Character classification (`isdigit`, `isspace` ...) and character or string transformations
  (`uppercasea`, `titlecase`, ...) are performed locale-sensitive for wrapped types.

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

println(tr"$(context=test)original text")
println(tr"$n dogs have $(4n) legs")
for lines in [1,2,3]
    println(tr"$errnum lines of code")
end
end module
```
sample configuration files in directory `.julia/v0.7/MyModule/resources`

```
cat messages_de.po
#
# Comments
#
# Empty msgid containing options - only Plural-Forms is used
msgid ""
msgstr "other options\n"
       "Plural-Forms: nplurals = 3; plural = n == 1 ? 0 : n == 2 ? 1 : 3\n"
       "other options:  \n"

#: main.jl:6 (used as a comment)
msgid "original text"
msgstr "Originaltext"

#: main.jl:7
msgid "$(1) dogs have $(2) legs"
msgstr $(2) Beine gehören zu $(1) Hunden"

#: main.jl:9
msgid "$(1) lines of code"
msgstr[0] "eine Zeile"
msgstr[1] "Zeilenpaar"
msgstr[2] "$(1) Zeilen" 
```
or alternatively, with same effect
```
cat messages_de.jl
( "" => "Plural-Forms: nplurals = 3; plural = n == 1 ? 0 : n == 2 ? 1 : 3"

"original text" => "Originaltext",
raw"$(1) dogs have $(2) legs" => raw"$(2) Beine gehören zu $(1) Hunden",
raw"$(1) lines of code" => ["eine Zeile", """Zeilenpaar""", raw"$(1) Zeilen"],) 
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

There is a set of task-local variables, which are used as "current locale" for different purposes.
These variables are accessed with get/set methods.
For example the locale `get_locale(:MESSAGES)` is used as the default locale for message
text look-up in the current task.

##### Resource Bundles

A resource bundle is an association of string values with arbitrary objects, where the
actual mapping depends on a locale.
Conceptually it behaves like a `Dict{Tuple{String,Locale},Any}`.
Each resource bundle is bound to a package. The corresponding data are stored in the
subdirectory `resources` of the package directory.

`bundle = @resource_bundle("pictures")` creates a resource bundle, which is bound
to the current module. 
The resources are looked for the resources subdirectory of a package module or, if the
base module is `Main`, in the current working directory.

The object stored in reousource bundles are not restricted to strings, but may have any Julia type.
For example, it could make sense to store locale-dependant pictures (containing natuaral language texts) in resource bundles. Also locale dependant information or algorithms are possible.

The actual data of all resource bundles of a package stored in the package directory in an extra subdirectory named `resources` (`resource-dir>`. An individual resource bundle with name `<name>` consists of a collection of files with path names
`<resource-dir>/<name><intermediate>.jl`. Here `<intermediate>`may be empty or a canonicalized locale tag, whith
separator characters replaced by `'_'` or `'/'`. That means, all files have the standard `Julia`extension (and they 
actually contain `Julia`code). The files may be spread in a subdirectory hierarchy according to the structure of the languange tags. 

Fallback strategy following structure of language tags.


##### String Translations

String translations make use of a current locale `(get_locale(:MESSAGES))` and a standard resource bundle `@__MODULE__.RB_messages`.

The macro `tr_str` allows the user to write texts in a standard locale and it is translated
at runtime to a corresponding text in the current locale.
It has the following features.

 * translate plan text
 * support string interpolation, allowing re-ordering of variables
 * support multiple plural forms for exactly one interpolation variable

The interpolation expressions are embedded in the text of the string-macro `tr` in the usual
form, e.g. `tr" ...  $var ... $(expr) ..."`.
If the programmer wants the text to be translated into one of several grammatical plural forms,
he has to formulate the text in the program in the plural form of the standard language and
embed at least one interpolation expression. One of those expressions has to be flagged by
the unary negation operator ( `tr" ... $(!expr) ... "`). The flagged expression must provide an
integer value. The negation operation is not executed, but indicates to the implementation,
which of several plural options has to be selected.
For this purpose the translation text database defines a "plural-formula", which maps the
integer expression `n` to a zero-based index. This index peeks the proper translation from a
vector of strings.
Some typical formulas:
Chinese: `0`
English: `n > 1 ? 1 : 0`
French:  `n == 1 ? 0 : 1`
Russian: `n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2`

The macro includes the functionality of the gnu library calls `gettext`and `ngettext`.
The database supports the file format, defined by "GNU-gettext".
See (https://www.gnu.org/software/gettext/manual/gettext.html#PO-Files)

