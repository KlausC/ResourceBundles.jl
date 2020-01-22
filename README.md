# ResourceBundles

[![Build Status](https://travis-ci.org/KlausC/ResourceBundles.jl.svg?branch=master)](https://travis-ci.org/KlausC/ResourceBundles.jl)
[![codecov.io](http://codecov.io/github/KlausC/ResourceBundles.jl/coverage.svg?branch=master)](http://codecov.io/github/KlausC/ResourceBundles.jl?branch=master)

## ResourceBundles is a package to support Internationalization (I18n).
Main features:

### Locale
  * create Locale from string formed according to standards Unicode Locale Identifier (BCP47 (tags for Identifying languages), RFC5646, RFC4647)
  * set/get default locale for different purposes
  * startup-locale derived form environment settings (LANG, LC_MESSAGES, ..., LC_ALL)
  * Locale patterns imply a canonical partial ordering by set inclusion

### ResourceBundle
  * Database of objects (e.g. text strings), identified by locale and individual text key
  * select most specific available object according to canonical ordering of locales
  * detect ambiguities for individual keys
  * storage in package module directory
  * database uses files witten in Julia source code
  * database files containing translated texts using gettext-PO format is supported

#### Message text localization (LC_MESSAGES)
  * a string macro providing translation of standard language according to default locale
  * support string interpolation and control ordering of interpolated substrings
  * includes mechanism for multiple plural forms for translations
  * fall back to text provided as key within the source text
  * Define global default Resource bundle for each module
  * Support features of Posix `gettext`

#### NumberFormat and DateTimeFormat (LC_NUMERIC, LC_TIME) (TODO)
  * If an object is formatted in the interpolation context of a translated string, instead of the usual `show` method, a locale sensitive replacement is called.
  * those methods default to the standard methods, if not explicitly defined.
  * For real numbers and date or time objects, methods can be provided as locale dependent resources.

#### String comparison (LC_COLLATE) (TODO)
  * Strings containing natural language texts are sorted locale-sensitive according to
  "Unicode Collation Algorithm". Implementation makes use of `ICU` if possible. In order to treat a string as natural text, it is wrapped by a `NlsString` object.

#### Character Classes (LC_CTYPE) (TODO)
  * Character classification (`isdigit`, `isspace` ...) and character or string transformations
  (`uppercase`, `titlecase`, ...) are performed locale-sensitive for wrapped types.

### Installation

```
# assuming a unix shell
cd ~/.julia/dev
git clone http://github.com/KlausC/ResourceBundles.jl ResourceBundles
]add ResourceBundles

```

### Usage

```
using ResourceBundles

# The following code is to make the test resources of ResourceBundles itself available
# to the Main module. Typically the resources are accessible within their module.
rdir = abspath(pathof(ResourceBundles), "..", "..", "resources")
;ln -s $rdir .

# show current locale (inherited from env LC_ALL, LC_MESSAGES, LANG)
locale()

# change locale for messages programmatically:
set_locale!(LocaleId("de"), LC.MESSAGES)

# use string translation feature
println(tr"original text")
for n = (2,3)
    println(tr"$n dogs have $(4n) legs")
end
for lines in [1,2,3]
    println(tr"$lines lines of code")
end

# access the posix locale definitions
ResourceBundles.CLocales.nl_langinfo(ResourceBundles.CLocales.CURRENCY_SYMBOL)

```
sample configuration files in directory `pathof(MyModule)/../../resources`

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
msgstr "$(2) Beine gehören zu $(1) Hunden"

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

## User Guide

#### Locale Identifiers and Locales

Locale Identifiers are converted from Strings, which are formatted according to Unicode Locale Identifier.
Examples: "en", "en_Latn", "en_US", "en_Latn_GB_london", "en_US_x_private".


Additionally the syntax for Posix environment variables `LANG` and `LC_...` are
supported.
Examples: "C", "en_US", "en_us.utf8", "en_US@posext".
All those formats are converted to a canonical form and stored in objects of type `LocaleID`: `LocaleID("en_US")`.
The `_` may be replaced by `-` in input.

`LocaleId` implements the `equals` and the `issubset` (`⊆`) relations.
Here `LocaleId("en_US") ⊆ LocaleId("en") ⊆ LocaleId("C") == LocaleId("")`.

The `Locale` is a set of locale-properties for several categories. The categories are taken
from the GNU implementation. Each locale-property is identified by a `LocaleId`.

Each category corresponds to one of the `LC_` environment variables and there is a related
constant in module 'LC'. Here is the complete list:

    category          | remark
    -------------------------------
    CTYPE             | character classifications (letter, digit, ...)
    NUMERIC           | number formating (decimal separator, ...)
    TIME              | time and date formats
    COLLATE           | text comparison
    MONETARY          | currency symbol
    MESSAGES          | translation of message texts
    ALL               | not a category - used to override all other settings
    PAPER             | paper formats
    NAME              | person names
    ADDRESS           | address formating
    TELEPHONE         | formating of phone numbers
    MEASUREMENT       | measurement system (1 for metric, 2 for imperial)
    IDENTIFICATION    | name of the locale identifier

For all of those terms there is an environment variable `"LC_category"` and a Julia constant `LC.category`. The categories up to `ALL` are defined in POSIX(), which the others are GNU extensions.
The special variable `"LC_ALL"` overrides all other variables `"LC_category"` if set.
The additional environment variable `"LANG"` is used as a fallback, if neither `"LC_category"` nor `"LC_ALL"` is set.

Each task owns a task specific current locale. It is obtained by `locale()`.
For each category the valid locale identifier is accessed by `locale_id(LC.category)`.
For example the locale `locale_id(LC.MESSAGES)` is used as the default locale for message
text look-up in the current task.
The locale-ids of the current locale may be changed by `set_locale!(localeid, category)`.
For example `set_locale!(LocaleID("de_DE"), LC.MESSAGES)` modifies the current locale to
use German message translations.

All locale categories except for `LC.MESSAGES` are implemented by the GNU installation, which contains the shared library glibc, a set of predefined locale properties, and a tool `locales`, which delivers a list of all locale identifiers installed on the system.
In Julia, the values of all locale dependent variable of those categories may be obtained
like `ResourceBundles.CLocales.nl_langinfo.(ResourceBundles.CLocales.DAY.(1:7))`
or `ResourceBundles.CLocales.nl_langinfo(ResourceBundles.CLocales.IDENTIFICATION_TITLE)`.

These are only available on GNU based systems (including Linux and OSX).

#### Resource Bundles

A resource bundle is an association of string values with arbitrary objects, where the
actual mapping depends on a locale.
Conceptually it behaves like a `Dict{Tuple{String,Locale},Any}`.
Each resource bundle is bound to a package. The corresponding data are stored in the
subdirectory `resources` of the package directory.

`bundle = @resource_bundle("pictures")` creates a resource bundle, which is bound
to the current module. The resource is populated by the content found in the resource files, which are associated with the current module.
The resources are looked for the resources subdirectory of a package module or, if the
base module is `Main`, in the current working directory.

The object stored in reousource bundles are not restricted to strings, but may have any Julia type.
For example, it could make sense to store locale-dependent pictures (containing natural language texts) in resource bundles. Also locale dependent information or algorithms are possible.

The actual data of all resource bundles of a package stored in the package directory in an extra subdirectory named `resources` (`resource-dir>`. An individual resource bundle with name `<name>` consists of a collection of files with path names

`<resource-dir>/<name><intermediate>.[jl|po|mo]`.

 Here `<intermediate>`may be empty or a canonicalized locale tag, whith separator characters replaced by `'_'` or `'/'`. That means, all files have the standard `Julia`extension (and they actually contain `Julia`code) or a `po`
extension indicating message resources in PO format. The files may be spread in a subdirectory hierarchy according to the structure of the languange tags.

Fallback strategy following structure of language tags.


#### String Translations

String translations make use of a current locale `(locale_id(LC.MESSAGES))` and a standard resource bundle `(@__MODULE__).RB_messages`, which is created on demand.

The macro `tr_str` allows the user to write texts in a standard locale and it is translated
at runtime to a corresponding text in the current locale.
It has the following features.

 * translate plain text
 * support string interpolation, allowing re-ordering of variables
 * support multiple plural forms for exactly one interpolation variable
 * support context specifiers

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
Some typical formulas in the PO-file format:

    msgid ""
    msgstr ""
    "Plural-Forms: nplurals=1; plural=0;\n"                 # Chinese
    "Plural-Forms: nplurals=1; plural=n > 1 ? 1 : 0;\n"     # English (default)
    "Plural-Forms: nplurals=1; plural=n == 1 ? 0 : 1;\n"    # French
    "Plural-Forms: nplurals=1; plural=n%10==1&&n%100!=11 ? 0 : n%10>=2&&n%10<=4&&(n%100<10||n%100>=20) ? 1 : 2;\n"
      # Russian

For details see: [PO-Files](https://www.gnu.org/software/gettext/manual/gettext.html#PO-Files).

Message contexts are included in the tr string like `tr"§mood§blue"` or `tr"§color§blue"`. In the PO file it is defined for example like:

    msgctx "mood"
    msgid "blue"
    msgstr "melancholisch"

    msgctx "color"
    msgid "blue"
    msgstr "blau"

The `tr_str` macro includes the functionality of the gnu library calls `gettext`and `ngettext`.
The database supports the file formats and infrastructure defined by [gettext](https://www.gnu.org/software/gettext/manual). Also binary files with extension `.mo` are be processed, which can be compiled from `.po` files by the gettext-utility [`msgfmt`](https://www.gnu.org/software/gettext/manual/gettext.html#msgfmt-Invocation).

#### Limitations

The items labeled with `TODO` are not yet supported.
Windows is only supported for the LC_MESSAGES mechanisms, not the other locale categories.

