"""
    The 2- and 3-letter ISO 639 language codes.
"""
const IsoLanguageTable =
         "aa" * "aar" * # Afar
         "ab" * "abk" * # Abkhazian
         "ae" * "ave" * # Avestan
         "af" * "afr" * # Afrikaans
         "ak" * "aka" * # Akan
         "am" * "amh" * # Amharic
         "an" * "arg" * # Aragonese
         "ar" * "ara" * # Arabic
         "as" * "asm" * # Assamese
         "av" * "ava" * # Avaric
         "ay" * "aym" * # Aymara
         "az" * "aze" * # Azerbaijani
         "ba" * "bak" * # Bashkir
         "be" * "bel" * # Belarusian
         "bg" * "bul" * # Bulgarian
         "bh" * "bih" * # Bihari
         "bi" * "bis" * # Bislama
         "bm" * "bam" * # Bambara
         "bn" * "ben" * # Bengali
         "bo" * "bod" * # Tibetan
         "br" * "bre" * # Breton
         "bs" * "bos" * # Bosnian
         "ca" * "cat" * # Catalan
         "ce" * "che" * # Chechen
         "ch" * "cha" * # Chamorro
         "co" * "cos" * # Corsican
         "cr" * "cre" * # Cree
         "cs" * "ces" * # Czech
         "cu" * "chu" * # Church Slavic
         "cv" * "chv" * # Chuvash
         "cy" * "cym" * # Welsh
         "da" * "dan" * # Danish
         "de" * "deu" * # German
         "dv" * "div" * # Divehi
         "dz" * "dzo" * # Dzongkha
         "ee" * "ewe" * # Ewe
         "el" * "ell" * # Greek
         "en" * "eng" * # English
         "eo" * "epo" * # Esperanto
         "es" * "spa" * # Spanish
         "et" * "est" * # Estonian
         "eu" * "eus" * # Basque
         "fa" * "fas" * # Persian
         "ff" * "ful" * # Fulah
         "fi" * "fin" * # Finnish
         "fj" * "fij" * # Fijian
         "fo" * "fao" * # Faroese
         "fr" * "fra" * # French
         "fy" * "fry" * # Frisian
         "ga" * "gle" * # Irish
         "gd" * "gla" * # Scottish Gaelic
         "gl" * "glg" * # Gallegan
         "gn" * "grn" * # Guarani
         "gu" * "guj" * # Gujarati
         "gv" * "glv" * # Manx
         "ha" * "hau" * # Hausa
         "he" * "heb" * # Hebrew
         "hi" * "hin" * # Hindi
         "ho" * "hmo" * # Hiri Motu
         "hr" * "hrv" * # Croatian
         "ht" * "hat" * # Haitian
         "hu" * "hun" * # Hungarian
         "hy" * "hye" * # Armenian
         "hz" * "her" * # Herero
         "ia" * "ina" * # Interlingua
         "id" * "ind" * # Indonesian
         "ie" * "ile" * # Interlingue
         "ig" * "ibo" * # Igbo
         "ii" * "iii" * # Sichuan Yi
         "ik" * "ipk" * # Inupiaq
         "id" * "ind" * # Indonesian (new)
         "io" * "ido" * # Ido
         "is" * "isl" * # Icelandic
         "it" * "ita" * # Italian
         "iu" * "iku" * # Inuktitut
         "ne" * "heb" * # Hebrew (new)
         "ja" * "jpn" * # Japanese
         "yi" * "yid" * # Yiddish (new)
         "jv" * "jav" * # Javanese
         "ka" * "kat" * # Georgian
         "kg" * "kon" * # Kongo
         "ki" * "kik" * # Kikuyu
         "kj" * "kua" * # Kwanyama
         "kk" * "kaz" * # Kazakh
         "kl" * "kal" * # Greenlandic
         "km" * "khm" * # Khmer
         "kn" * "kan" * # Kannada
         "ko" * "kor" * # Korean
         "kr" * "kau" * # Kanuri
         "ks" * "kas" * # Kashmiri
         "ku" * "kur" * # Kurdish
         "kv" * "kom" * # Komi
         "kw" * "cor" * # Cornish
         "ky" * "kir" * # Kirghiz
         "la" * "lat" * # Latin
         "lb" * "ltz" * # Luxembourgish
         "lg" * "lug" * # Ganda
         "li" * "lim" * # Limburgish
         "ln" * "lin" * # Lingala
         "lo" * "lao" * # Lao
         "lt" * "lit" * # Lithuanian
         "lu" * "lub" * # Luba-Katanga
         "lv" * "lav" * # Latvian
         "mg" * "mlg" * # Malagasy
         "mh" * "mah" * # Marshallese
         "mi" * "mri" * # Maori
         "mk" * "mkd" * # Macedonian
         "ml" * "mal" * # Malayalam
         "mn" * "mon" * # Mongolian
         "mo" * "mol" * # Moldavian
         "mr" * "mar" * # Marathi
         "ms" * "msa" * # Malay
         "mt" * "mlt" * # Maltese
         "my" * "mya" * # Burmese
         "na" * "nau" * # Nauru
         "nb" * "nob" * # Norwegian Bokmål
         "nd" * "nde" * # North Ndebele
         "ne" * "nep" * # Nepali
         "ng" * "ndo" * # Ndonga
         "nl" * "nld" * # Dutch
         "nn" * "nno" * # Norwegian Nynorsk
         "no" * "nor" * # Norwegian
         "nr" * "nbl" * # South Ndebele
         "nv" * "nav" * # Navajo
         "ny" * "nya" * # Nyanja
         "oc" * "oci" * # Occitan
         "oj" * "oji" * # Ojibwa
         "om" * "orm" * # Oromo
         "or" * "ori" * # Oriya
         "os" * "oss" * # Ossetian
         "pa" * "pan" * # Panjabi
         "pi" * "pli" * # Pali
         "pl" * "pol" * # Polish
         "ps" * "pus" * # Pushto
         "pt" * "por" * # Portuguese
         "qu" * "que" * # Quechua
         "rm" * "roh" * # Raeto-Romance
         "rn" * "run" * # Rundi
         "ro" * "ron" * # Romanian
         "ru" * "rus" * # Russian
         "rw" * "kin" * # Kinyarwanda
         "sa" * "san" * # Sanskrit
         "sc" * "srd" * # Sardinian
         "sd" * "snd" * # Sindhi
         "se" * "sme" * # Northern Sami
         "sg" * "sag" * # Sango
         "si" * "sin" * # Sinhalese
         "sk" * "slk" * # Slovak
         "sl" * "slv" * # Slovenian
         "sm" * "smo" * # Samoan
         "sn" * "sna" * # Shona
         "so" * "som" * # Somali
         "sq" * "sqi" * # Albanian
         "sr" * "srp" * # Serbian
         "ss" * "ssw" * # Swati
         "st" * "sot" * # Southern Sotho
         "su" * "sun" * # Sundanese
         "sv" * "swe" * # Swedish
         "sw" * "swa" * # Swahili
         "ta" * "tam" * # Tamil
         "te" * "tel" * # Telugu
         "tg" * "tgk" * # Tajik
         "th" * "tha" * # Thai
         "ti" * "tir" * # Tigrinya
         "tk" * "tuk" * # Turkmen
         "tl" * "tgl" * # Tagalog
         "tn" * "tsn" * # Tswana
         "to" * "ton" * # Tonga
         "tr" * "tur" * # Turkish
         "ts" * "tso" * # Tsonga
         "tt" * "tat" * # Tatar
         "tw" * "twi" * # Twi
         "ty" * "tah" * # Tahitian
         "ug" * "uig" * # Uighur
         "uk" * "ukr" * # Ukrainian
         "ur" * "urd" * # Urdu
         "uz" * "uzb" * # Uzbek
         "ve" * "ven" * # Venda
         "vi" * "vie" * # Vietnamese
         "vo" * "vol" * # Volapük
         "wa" * "wln" * # Walloon
         "wo" * "wol" * # Wolof
         "xh" * "xho" * # Xhosa
         "yi" * "yid" * # Yiddish
         "yo" * "yor" * # Yoruba
         "za" * "zha" * # Zhuang
         "zh" * "zho" * # Chinese
         "zu" * "zul"   # Zulu

"""
    The 2- and 3-letter ISO 3166 country codes.
"""
const IsoCountryTable =
         "AD" * "AND" * # Andorra, Principality of
         "AE" * "ARE" * # United Arab Emirates
         "AF" * "AFG" * # Afghanistan
         "AG" * "ATG" * # Antigua and Barbuda
         "AI" * "AIA" * # Anguilla
         "AL" * "ALB" * # Albania, People's Socialist Republic of
         "AM" * "ARM" * # Armenia
         "AN" * "ANT" * # Netherlands Antilles
         "AO" * "AGO" * # Angola, Republic of
         "AQ" * "ATA" * # Antarctica (the territory South of 60 deg S)
         "AR" * "ARG" * # Argentina, Argentine Republic
         "AS" * "ASM" * # American Samoa
         "AT" * "AUT" * # Austria, Republic of
         "AU" * "AUS" * # Australia, Commonwealth of
         "AW" * "ABW" * # Aruba
         "AX" * "ALA" * # Åland Islands
         "AZ" * "AZE" * # Azerbaijan, Republic of
         "BA" * "BIH" * # Bosnia and Herzegovina
         "BB" * "BRB" * # Barbados
         "BD" * "BGD" * # Bangladesh, People's Republic of
         "BE" * "BEL" * # Belgium, Kingdom of
         "BF" * "BFA" * # Burkina Faso
         "BG" * "BGR" * # Bulgaria, People's Republic of
         "BH" * "BHR" * # Bahrain, Kingdom of
         "BI" * "BDI" * # Burundi, Republic of
         "BJ" * "BEN" * # Benin, People's Republic of
         "BL" * "BLM" * # Saint Barthélemy
         "BM" * "BMU" * # Bermuda
         "BN" * "BRN" * # Brunei Darussalam
         "BO" * "BOL" * # Bolivia, Republic of
         "BQ" * "BES" * # Bonaire, Sint Eustatius and Saba
         "BR" * "BRA" * # Brazil, Federative Republic of
         "BS" * "BHS" * # Bahamas, Commonwealth of the
         "BT" * "BTN" * # Bhutan, Kingdom of
         "BV" * "BVT" * # Bouvet Island (Bouvetoya)
         "BW" * "BWA" * # Botswana, Republic of
         "BY" * "BLR" * # Belarus
         "BZ" * "BLZ" * # Belize
         "CA" * "CAN" * # Canada
         "CC" * "CCK" * # Cocos (Keeling) Islands
         "CD" * "COD" * # Congo, Democratic Republic of
         "CF" * "CAF" * # Central African Republic
         "CG" * "COG" * # Congo, People's Republic of
         "CH" * "CHE" * # Switzerland, Swiss Confederation
         "CI" * "CIV" * # Cote D'Ivoire, Ivory Coast, Republic of the
         "CK" * "COK" * # Cook Islands
         "CL" * "CHL" * # Chile, Republic of
         "CM" * "CMR" * # Cameroon, United Republic of
         "CN" * "CHN" * # China, People's Republic of
         "CO" * "COL" * # Colombia, Republic of
         "CR" * "CRI" * # Costa Rica, Republic of
         "CS" * "SCG" * # Serbia and Montenegro
         "CU" * "CUB" * # Cuba, Republic of
         "CV" * "CPV" * # Cape Verde, Republic of
         "CW" * "CUW" * # Cura\u00e7ao
         "CX" * "CXR" * # Christmas Island
         "CY" * "CYP" * # Cyprus, Republic of
         "CZ" * "CZE" * # Czech Republic
         "DE" * "DEU" * # Germany
         "DJ" * "DJI" * # Djibouti, Republic of
         "DK" * "DNK" * # Denmark, Kingdom of
         "DM" * "DMA" * # Dominica, Commonwealth of
         "DO" * "DOM" * # Dominican Republic
         "DZ" * "DZA" * # Algeria, People's Democratic Republic of
         "EC" * "ECU" * # Ecuador, Republic of
         "EE" * "EST" * # Estonia
         "EG" * "EGY" * # Egypt, Arab Republic of
         "EH" * "ESH" * # Western Sahara
         "ER" * "ERI" * # Eritrea
         "ES" * "ESP" * # Spain, Spanish State
         "ET" * "ETH" * # Ethiopia
         "FI" * "FIN" * # Finland, Republic of
         "FJ" * "FJI" * # Fiji, Republic of the Fiji Islands
         "FK" * "FLK" * # Falkland Islands (Malvinas)
         "FM" * "FSM" * # Micronesia, Federated States of
         "FO" * "FRO" * # Faeroe Islands
         "FR" * "FRA" * # France, French Republic
         "GA" * "GAB" * # Gabon, Gabonese Republic
         "GB" * "GBR" * # United Kingdom of Great Britain & N. Ireland
         "GD" * "GRD" * # Grenada
         "GE" * "GEO" * # Georgia
         "GF" * "GUF" * # French Guiana
         "GG" * "GGY" * # Guernsey
         "GH" * "GHA" * # Ghana, Republic of
         "GI" * "GIB" * # Gibraltar
         "GL" * "GRL" * # Greenland
         "GM" * "GMB" * # Gambia, Republic of the
         "GN" * "GIN" * # Guinea, Revolutionary People's Rep'c of
         "GP" * "GLP" * # Guadaloupe
         "GQ" * "GNQ" * # Equatorial Guinea, Republic of
         "GR" * "GRC" * # Greece, Hellenic Republic
         "GS" * "SGS" * # South Georgia and the South Sandwich Islands
         "GT" * "GTM" * # Guatemala, Republic of
         "GU" * "GUM" * # Guam
         "GW" * "GNB" * # Guinea-Bissau, Republic of
         "GY" * "GUY" * # Guyana, Republic of
         "HK" * "HKG" * # Hong Kong, Special Administrative Region of China
         "HM" * "HMD" * # Heard and McDonald Islands
         "HN" * "HND" * # Honduras, Republic of
         "HR" * "HRV" * # Hrvatska (Croatia)
         "HT" * "HTI" * # Haiti, Republic of
         "HU" * "HUN" * # Hungary, Hungarian People's Republic
         "ID" * "IDN" * # Indonesia, Republic of
         "IE" * "IRL" * # Ireland
         "IL" * "ISR" * # Israel, State of
         "IM" * "IMN" * # Isle of Man
         "IN" * "IND" * # India, Republic of
         "IO" * "IOT" * # British Indian Ocean Territory (Chagos Archipelago)
         "IQ" * "IRQ" * # Iraq, Republic of
         "IR" * "IRN" * # Iran, Islamic Republic of
         "IS" * "ISL" * # Iceland, Republic of
         "IT" * "ITA" * # Italy, Italian Republic
         "JE" * "JEY" * # Jersey
         "JM" * "JAM" * # Jamaica
         "JO" * "JOR" * # Jordan, Hashemite Kingdom of
         "JP" * "JPN" * # Japan
         "KE" * "KEN" * # Kenya, Republic of
         "KG" * "KGZ" * # Kyrgyz Republic
         "KH" * "KHM" * # Cambodia, Kingdom of
         "KI" * "KIR" * # Kiribati, Republic of
         "KM" * "COM" * # Comoros, Union of the
         "KN" * "KNA" * # St. Kitts and Nevis
         "KP" * "PRK" * # Korea, Democratic People's Republic of
         "KR" * "KOR" * # Korea, Republic of
         "KW" * "KWT" * # Kuwait, State of
         "KY" * "CYM" * # Cayman Islands
         "KZ" * "KAZ" * # Kazakhstan, Republic of
         "LA" * "LAO" * # Lao People's Democratic Republic
         "LB" * "LBN" * # Lebanon, Lebanese Republic
         "LC" * "LCA" * # St. Lucia
         "LI" * "LIE" * # Liechtenstein, Principality of
         "LK" * "LKA" * # Sri Lanka, Democratic Socialist Republic of
         "LR" * "LBR" * # Liberia, Republic of
         "LS" * "LSO" * # Lesotho, Kingdom of
         "LT" * "LTU" * # Lithuania
         "LU" * "LUX" * # Luxembourg, Grand Duchy of
         "LV" * "LVA" * # Latvia
         "LY" * "LBY" * # Libyan Arab Jamahiriya
         "MA" * "MAR" * # Morocco, Kingdom of
         "MC" * "MCO" * # Monaco, Principality of
         "MD" * "MDA" * # Moldova, Republic of
         "ME" * "MNE" * # Montenegro, Republic of
         "MF" * "MAF" * # Saint Martin
         "MG" * "MDG" * # Madagascar, Republic of
         "MH" * "MHL" * # Marshall Islands
         "MK" * "MKD" * # Macedonia, the former Yugoslav Republic of
         "ML" * "MLI" * # Mali, Republic of
         "MM" * "MMR" * # Myanmar
         "MN" * "MNG" * # Mongolia, Mongolian People's Republic
         "MO" * "MAC" * # Macao, Special Administrative Region of China
         "MP" * "MNP" * # Northern Mariana Islands
         "MQ" * "MTQ" * # Martinique
         "MR" * "MRT" * # Mauritania, Islamic Republic of
         "MS" * "MSR" * # Montserrat
         "MT" * "MLT" * # Malta, Republic of
         "MU" * "MUS" * # Mauritius
         "MV" * "MDV" * # Maldives, Republic of
         "MW" * "MWI" * # Malawi, Republic of
         "MX" * "MEX" * # Mexico, United Mexican States
         "MY" * "MYS" * # Malaysia
         "MZ" * "MOZ" * # Mozambique, People's Republic of
         "NA" * "NAM" * # Namibia
         "NC" * "NCL" * # New Caledonia
         "NE" * "NER" * # Niger, Republic of the
         "NF" * "NFK" * # Norfolk Island
         "NG" * "NGA" * # Nigeria, Federal Republic of
         "NI" * "NIC" * # Nicaragua, Republic of
         "NL" * "NLD" * # Netherlands, Kingdom of the
         "NO" * "NOR" * # Norway, Kingdom of
         "NP" * "NPL" * # Nepal, Kingdom of
         "NR" * "NRU" * # Nauru, Republic of
         "NU" * "NIU" * # Niue, Republic of
         "NZ" * "NZL" * # New Zealand
         "OM" * "OMN" * # Oman, Sultanate of
         "PA" * "PAN" * # Panama, Republic of
         "PE" * "PER" * # Peru, Republic of
         "PF" * "PYF" * # French Polynesia
         "PG" * "PNG" * # Papua New Guinea
         "PH" * "PHL" * # Philippines, Republic of the
         "PK" * "PAK" * # Pakistan, Islamic Republic of
         "PL" * "POL" * # Poland, Republic of Poland
         "PM" * "SPM" * # St. Pierre and Miquelon
         "PN" * "PCN" * # Pitcairn Island
         "PR" * "PRI" * # Puerto Rico
         "PS" * "PSE" * # Palestinian Territory, Occupied
         "PT" * "PRT" * # Portugal, Portuguese Republic
         "PW" * "PLW" * # Palau
         "PY" * "PRY" * # Paraguay, Republic of
         "QA" * "QAT" * # Qatar, State of
         "RE" * "REU" * # Reunion
         "RO" * "ROU" * # Romania, Socialist Republic of
         "RS" * "SRB" * # Serbia, Republic of
         "RU" * "RUS" * # Russian Federation
         "RW" * "RWA" * # Rwanda, Rwandese Republic
         "SA" * "SAU" * # Saudi Arabia, Kingdom of
         "SB" * "SLB" * # Solomon Islands
         "SC" * "SYC" * # Seychelles, Republic of
         "SD" * "SDN" * # Sudan, Democratic Republic of the
         "SE" * "SWE" * # Sweden, Kingdom of
         "SG" * "SGP" * # Singapore, Republic of
         "SH" * "SHN" * # St. Helena
         "SI" * "SVN" * # Slovenia
         "SJ" * "SJM" * # Svalbard & Jan Mayen Islands
         "SK" * "SVK" * # Slovakia (Slovak Republic)
         "SL" * "SLE" * # Sierra Leone, Republic of
         "SM" * "SMR" * # San Marino, Republic of
         "SN" * "SEN" * # Senegal, Republic of
         "SO" * "SOM" * # Somalia, Somali Republic
         "SR" * "SUR" * # Suriname, Republic of
         "SS" * "SSD" * # South Sudan
         "ST" * "STP" * # Sao Tome and Principe, Democratic Republic of
         "SV" * "SLV" * # El Salvador, Republic of
         "SX" * "SXM" * # Sint Maarten (Dutch part)
         "SY" * "SYR" * # Syrian Arab Republic
         "SZ" * "SWZ" * # Swaziland, Kingdom of
         "TC" * "TCA" * # Turks and Caicos Islands
         "TD" * "TCD" * # Chad, Republic of
         "TF" * "ATF" * # French Southern Territories
         "TG" * "TGO" * # Togo, Togolese Republic
         "TH" * "THA" * # Thailand, Kingdom of
         "TJ" * "TJK" * # Tajikistan
         "TK" * "TKL" * # Tokelau (Tokelau Islands)
         "TL" * "TLS" * # Timor-Leste, Democratic Republic of
         "TM" * "TKM" * # Turkmenistan
         "TN" * "TUN" * # Tunisia, Republic of
         "TO" * "TON" * # Tonga, Kingdom of
         "TR" * "TUR" * # Turkey, Republic of
         "TT" * "TTO" * # Trinidad and Tobago, Republic of
         "TV" * "TUV" * # Tuvalu
         "TW" * "TWN" * # Taiwan, Province of China
         "TZ" * "TZA" * # Tanzania, United Republic of
         "UA" * "UKR" * # Ukraine
         "UG" * "UGA" * # Uganda, Republic of
         "UM" * "UMI" * # United States Minor Outlying Islands
         "US" * "USA" * # United States of America
         "UY" * "URY" * # Uruguay, Eastern Republic of
         "UZ" * "UZB" * # Uzbekistan
         "VA" * "VAT" * # Holy See (Vatican City State)
         "VC" * "VCT" * # St. Vincent and the Grenadines
         "VE" * "VEN" * # Venezuela, Bolivarian Republic of
         "VG" * "VGB" * # British Virgin Islands
         "VI" * "VIR" * # US Virgin Islands
         "VN" * "VNM" * # Viet Nam, Socialist Republic of
         "VU" * "VUT" * # Vanuatu
         "WF" * "WLF" * # Wallis and Futuna Islands
         "WS" * "WSM" * # Samoa, Independent State of
         "YE" * "YEM" * # Yemen
         "YT" * "MYT" * # Mayotte
         "ZA" * "ZAF" * # South Africa, Republic of
         "ZM" * "ZMB" * # Zambia, Republic of
         "ZW" * "ZWE"   # Zimbabwe

"""
 ISO 15924 - Codes for the representation of names of scripts 
"""
const IsoScriptTable =
	"Adlm" * # Adlam
	"Afak" * # Afaka
	"Aghb" * # Caucasian Albanian
	"Ahom" * # Ahom, Tai Ahom
	"Arab" * # Arabic
	"Aran" * # Arabic (Nastaliq variant)
	"Armi" * # Imperial Aramaic
	"Armn" * # Armenian
	"Avst" * # Avestan
	"Bali" * # Balinese
	"Bamu" * # Bamum
	"Bass" * # Bassa Vah
	"Batk" * # Batak
	"Beng" * # Bengali (Bangla)
	"Bhks" * # Bhaiksuki
	"Blis" * # Blissymbols
	"Bopo" * # Bopomofo
	"Brah" * # Brahmi
	"Brai" * # Braille
	"Bugi" * # Buginese
	"Buhd" * # Buhid
	"Cakm" * # Chakma
	"Cans" * # Unified Canadian Aboriginal Syllabics
	"Cari" * # Carian
	"Cham" * # Cham
	"Cher" * # Cherokee
	"Cirt" * # Cirth
	"Copt" * # Coptic
	"Cpmn" * # Cypro-Minoan
	"Cprt" * # Cypriot syllabary
	"Cyrl" * # Cyrillic
	"Cyrs" * # Cyrillic (Old Church Slavonic variant)
	"Deva" * # Devanagari (Nagari)
	"Dogr" * # Dogra
	"Dsrt" * # Deseret (Mormon)
	"Dupl" * # Duployan shorthand, Duployan stenography
	"Egyd" * # Egyptian demotic
	"Egyh" * # Egyptian hieratic
	"Egyp" * # Egyptian hieroglyphs
	"Elba" * # Elbasan
	"Ethi" * # Ethiopic (Geʻez)
	"Geok" * # Khutsuri (Asomtavruli and Nuskhuri)
	"Geor" * # Georgian (Mkhedruli and Mtavruli)
	"Glag" * # Glagolitic
	"Gong" * # Gunjala Gondi
	"Gonm" * # Masaram Gondi
	"Goth" * # Gothic
	"Gran" * # Grantha
	"Grek" * # Greek
	"Gujr" * # Gujarati
	"Guru" * # Gurmukhi
	"Hanb" * # Han with Bopomofo (alias for Han + Bopomofo)
	"Hang" * # Hangul (Hangŭl, Hangeul)
	"Hani" * # Han (Hanzi, Kanji, Hanja)
	"Hano" * # Hanunoo (Hanunóo)
	"Hans" * # Han (Simplified variant)
	"Hant" * # Han (Traditional variant)
	"Hatr" * # Hatran
	"Hebr" * # Hebrew
	"Hira" * # Hiragana
	"Hluw" * # Anatolian Hieroglyphs (Luwian Hieroglyphs, Hittite Hieroglyphs)
	"Hmng" * # Pahawh Hmong
	"Hmnp" * # Nyiakeng Puachue Hmong
	"Hrkt" * # Japanese syllabaries (alias for Hiragana + Katakana)
	"Hung" * # Old Hungarian (Hungarian Runic)
	"Inds" * # Indus (Harappan)
	"Ital" * # Old Italic (Etruscan, Oscan, etc.)
	"Jamo" * # Jamo (alias for Jamo subset of Hangul)
	"Java" * # Javanese
	"Jpan" * # Japanese (alias for Han + Hiragana + Katakana)
	"Jurc" * # Jurchen
	"Kali" * # Kayah Li
	"Kana" * # Katakana
	"Khar" * # Kharoshthi
	"Khmr" * # Khmer
	"Khoj" * # Khojki
	"Kitl" * # Khitan large script
	"Kits" * # Khitan small script
	"Knda" * # Kannada
	"Kore" * # Korean (alias for Hangul + Han)
	"Kpel" * # Kpelle
	"Kthi" * # Kaithi
	"Lana" * # Tai Tham (Lanna)
	"Laoo" * # Lao
	"Latf" * # Latin (Fraktur variant)
	"Latg" * # Latin (Gaelic variant)
	"Latn" * # Latin
	"Leke" * # Leke
	"Lepc" * # Lepcha (Róng)
	"Limb" * # Limbu
	"Lina" * # Linear A
	"Linb" * # Linear B
	"Lisu" * # Lisu (Fraser)
	"Loma" * # Loma
	"Lyci" * # Lycian
	"Lydi" * # Lydian
	"Mahj" * # Mahajani
	"Maka" * # Makasar
	"Mand" * # Mandaic, Mandaean
	"Mani" * # Manichaean
	"Marc" * # Marchen
	"Maya" * # Mayan hieroglyphs
	"Medf" * # Medefaidrin (Oberi Okaime, Oberi Ɔkaimɛ)
	"Mend" * # Mende Kikakui
	"Merc" * # Meroitic Cursive
	"Mero" * # Meroitic Hieroglyphs
	"Mlym" * # Malayalam
	"Modi" * # Modi, Moḍī
	"Mong" * # Mongolian
	"Moon" * # Moon (Moon code, Moon script, Moon type)
	"Mroo" * # Mro, Mru
	"Mtei" * # Meitei Mayek (Meithei, Meetei)
	"Mult" * # Multani
	"Mymr" * # Myanmar (Burmese)
	"Narb" * # Old North Arabian (Ancient North Arabian)
	"Nbat" * # Nabataean
	"Newa" * # Newa, Newar, Newari, Nepāla lipi
	"Nkdb" * # Naxi Dongba (na²¹ɕi³³ to³³ba²¹, Nakhi Tomba)
	"Nkgb" * # Naxi Geba (na²¹ɕi³³ gʌ²¹ba²¹, 'Na-'Khi ²Ggŏ-¹baw, Nakhi Geba)
	"Nkoo" * # N’Ko
	"Nshu" * # Nüshu
	"Ogam" * # Ogham
	"Olck" * # Ol Chiki (Ol Cemet’, Ol, Santali)
	"Orkh" * # Old Turkic, Orkhon Runic
	"Orya" * # Oriya (Odia)
	"Osge" * # Osage
	"Osma" * # Osmanya
	"Palm" * # Palmyrene
	"Pauc" * # Pau Cin Hau
	"Perm" * # Old Permic
	"Phag" * # Phags-pa
	"Phli" * # Inscriptional Pahlavi
	"Phlp" * # Psalter Pahlavi
	"Phlv" * # Book Pahlavi
	"Phnx" * # Phoenician
	"Plrd" * # Miao (Pollard)
	"Piqd" * # Klingon (KLI pIqaD)
	"Prti" * # Inscriptional Parthian
	"Qaaa" * # Reserved for private use (start)
	"Qabx" * # Reserved for private use (end)
	"Rjng" * # Rejang (Redjang, Kaganga)
	"Roro" * # Rongorongo
	"Runr" * # Runic
	"Samr" * # Samaritan
	"Sara" * # Sarati
	"Sarb" * # Old South Arabian
	"Saur" * # Saurashtra
	"Sgnw" * # SignWriting
	"Shaw" * # Shavian (Shaw)
	"Shrd" * # Sharada, Śāradā
	"Shui" * # Shuishu
	"Sidd" * # Siddham, Siddhaṃ, Siddhamātṛkā
	"Sind" * # Khudawadi, Sindhi
	"Sinh" * # Sinhala
	"Sora" * # Sora Sompeng
	"Soyo" * # Soyombo
	"Sund" * # Sundanese
	"Sylo" * # Syloti Nagri
	"Syrc" * # Syriac
	"Syre" * # Syriac (Estrangelo variant)
	"Syrj" * # Syriac (Western variant)
	"Syrn" * # Syriac (Eastern variant)
	"Tagb" * # Tagbanwa
	"Takr" * # Takri, Ṭākrī, Ṭāṅkrī
	"Tale" * # Tai Le
	"Talu" * # New Tai Lue
	"Taml" * # Tamil
	"Tang" * # Tangut
	"Tavt" * # Tai Viet
	"Telu" * # Telugu
	"Teng" * # Tengwar
	"Tfng" * # Tifinagh (Berber)
	"Tglg" * # Tagalog (Baybayin, Alibata)
	"Thaa" * # Thaana
	"Thai" * # Thai
	"Tibt" * # Tibetan
	"Tirh" * # Tirhuta
	"Ugar" * # Ugaritic
	"Vaii" * # Vai
	"Visp" * # Visible Speech
	"Wara" * # Warang Citi (Varang Kshiti)
	"Wcho" * # Wancho
	"Wole" * # Woleai
	"Xpeo" * # Old Persian
	"Xsux" * # Cuneiform, Sumero-Akkadian
	"Yiii" * # Yi
	"Zanb" * # Zanabazar Square
	"Zinh" * # Code for inherited script
	"Zmth" * # Mathematical notation
	"Zsye" * # Symbols (Emoji variant)
	"Zsym" * # Symbols
	"Zxxx" * # Code for unwritten documents
	"Zyyy" * # Code for undetermined script
	"Zzzz"   # Code for uncoded script

# convert old registered language tags to replacements
GRANDFATHERED = Dict{String,String}(
    # "tag"      => "preferred",
   "art-lojban"  => "jbo",
   "cel-gaulish" => "xtg-x-cel-gaulish",   # fallback
   "en-gb-oed"   => "en-gb-x-oed",         # fallback
   "i-ami"       => "ami",
   "i-bnn"       => "bnn",
   "i-default"   => "en-x-i-default",      # fallback
   "i-enochian"  => "und-x-i-enochian",    # fallback
   "i-hak"       => "hak",
   "i-klingon"   => "tlh",
   "i-lux"       => "lb",
   "i-mingo"     => "see-x-i-mingo",       # fallback
   "i-navajo"    => "nv",
   "i-pwn"       => "pwn",
   "i-tao"       => "tao",
   "i-tay"       => "tay",
   "i-tsu"       => "tsu",
   "no-bok"      => "nb",
   "no-nyn"      => "nn",
   "sgn-be-fr"   => "sfb",
   "sgn-be-nl"   => "vgt",
   "sgn-ch-de"   => "sgg",
   "zh-guoyu"    => "cmn",
   "zh-hakka"    => "hak",
   "zh-min"      => "nan-x-zh-min", # fallback
   "zh-min-nan"  => "nan",
   "zh-xiang"    => "hsn",
  )

# convert old language codes to new codes
OLD_TO_NEW_LANG = Dict{String,String}(
  # "old"=> "new",                          
    "iw" => "he",
    "ji" => "yi",
    "in" => "id")

abstract type StringDict{K,L,M} end

struct StringDict32 <: StringDict{2,3,5}
    data::String
end
struct StringDict50 <: StringDict{0,4,4}
    data::String
end

const LANGUAGE3_DICT = StringDict32(IsoLanguageTable)
const COUNTRY3_DICT = StringDict32(IsoCountryTable)
const SCRIPT_SET = StringDict50(IsoScriptTable)

function Base.getindex(d::StringDict{K,L,M}, x3::Union{T,Symbol}) where {K,L,M,T<:AbstractString}
    x = string(x3)
    length(x) != L && return isa(x3, Symbol) ? x3 : Symbol(x3)
    ix = K
    while ix >= 0 && ix % M != K+1
        ix = first(findnext(x, d.data, ix+1))
        ix = ifelse(ix == 0, -1, ix)
    end
    ix > 0  ? Symbol(d.data[ix-K:ix-1]) : isa(x3, Symbol) ? x3 : Symbol(x)
end

Base.keys(d::StringDict{K,L,M}) where {K,L,M} = StringKeyIterator{K,L,M}(d.data)
struct StringKeyIterator{K,L,M}
    data::String
end
Base.iterate(d::StringDict{K,L,M}) where {K,L,M} = iterate(d, 0)
function Base.iterate(d::StringDict{K,L,M}, s) where {K,L,M}
    s >= length(d.data) && return nothing
    K == 0 ? Symbol(d.data[s+1:s+L]) : Symbol(d.data[s+K+1:s+K+L]) => Symbol(d.data[s+1:s+K]), s + M
end
Base.length(d::StringDict{K,L,M}) where {K,L,M} = length(d.data) ÷ M

Base.iterate(it::StringKeyIterator{K,L,M}) where {K,L,M} = iterate(it, 1 + K)
function Base.iterate(it::StringKeyIterator{K,L,M}, s) where {K,L,M}
    s > length(it.data) && return nothing
    Symbol(it.data[s:s+L-1]), s + M
end
Base.length(it::StringKeyIterator{K,L,M}) where {K,L,M} = length(it.data) ÷ M
Base.in(x, d::StringDict{0,L,M}) where {L,M} = d[x] == Symbol("")

"""
The following translation dictionary was created essentially using the following
code snippet:
``` julia
julia> dict = Dict{String,String}()
Dict{String,String} with 0 entries

julia> function normal(s::AbstractString)
           a = split(s, "@")
           b = split(a[1], ".")
           length(a) <= 1 || a[2] == "euro" ? b[1] : b[1] * "@" * a[2]
       end
normal (generic function with 1 method)

julia> for line in eachline("/usr/share/X11/locale/locale.alias")
           a = split(lowercase(line), r"[[:space]]+", keep=false)
           if length(a) == 2 && !startswith(a[1], "#")
               endswith(a[1], ":") && (a[1] = a[1][1:end-1])
               a1 = normal(a[1])
               a2 = normal(a[2])
               if a1 != a2
                   if !haskey(dict, a1)
                       dict[a1] = a2
                       println('"', a1, '"', " => ", '"', a2, '"', ",")
                   end
               end
           end
       end
```
The codeset specifiers have been removed from the input data.
It is assumed, that the codesset has not been used to encode relevant data.
"""
const POSIX_OLD_TO_NEW = Dict(
    "posix" => "c",
    "posix-utf2" => "c",
    "c_c" => "c",
    "c" => "en_us",
    "cextend" => "en_us",
    "english_united-states" => "c",
    "a3" => "az_az",
    "a3_az" => "az_az",
    "af" => "af_za",
    "am" => "am_et",
    "ar" => "ar_aa",
    "as" => "as_in",
    "az" => "az_az",
    "be" => "be_by",
    "be@latin" => "be_by@latin",
    "bg" => "bg_bg",
    "be_bg" => "bg_bg",
    "br" => "br_fr",
    "bs" => "bs_ba",
    "ca" => "ca_es",
    "cs" => "cs_cz",
    "cs_cs" => "cs_cz",
    "cz" => "cs_cz",
    "cz_cz" => "cs_cz",
    "cy" => "cy_gb",
    "da" => "da_dk",
    "de" => "de_de",
    "ger_de" => "de_de",
    "ee" => "ee_ee",
    "el" => "el_gr",
    "en" => "en_us",
    "en_uk" => "en_gb",
    "eng_gb" => "en_gb",
    "en_zw" => "en_zs",
    "eo" => "eo_xx",
    "es" => "es_es",
    "et" => "et_ee",
    "eu" => "eu_es",
    "fa" => "fa_ir",
    "fi" => "fi_fi",
    "fo" => "fo_fo",
    "fr" => "fr_fr",
    "fre_fr" => "fr_fr",
    "ga" => "ga_ie",
    "gd" => "gd_gb",
    "gl" => "gl_es",
    "gv" => "gv_gb",
    "he" => "he_il",
    "hi" => "hi_in",
    "hne" => "hne_in",
    "hr" => "hr_hr",
    "hu" => "hu_hu",
    "in" => "id_id",
    "in_id" => "id_id",
    "is" => "is_is",
    "it" => "it_it",
    "iu" => "iu_ca",
    "iw" => "he_il",
    "iw_il" => "he_il",
    "ja" => "ja_jp",
    "jp_jp" => "ja_jp",
    "ka" => "ka_ge",
    "kl" => "kl_gl",
    "kn" => "kn_in",
    "ko" => "ko_kr",
    "ks" => "ks_in",
    "kw" => "kw_gb",
    "ky" => "ky_kg",
    "lo" => "lo_la",
    "lt" => "lt_lt",
    "lv" => "lv_lv",
    "mai" => "mai_in",
    "mi" => "mi_nz",
    "mk" => "mk_mk",
    "ml" => "ml_in",
    "mr" => "mr_in",
    "ms" => "ms_my",
    "mt" => "mt_mt",
    "nb" => "nb_no",
    "nl" => "nl_nl",
    "nn" => "nn_no",
    "no" => "no_no",
    "no_no@bokmal" => "no_no",
    "no_no@nynorsk" => "no_no",
    "nr" => "nr_za",
    "nso" => "nso_za",
    "ny" => "ny_no",
    "no@nynorsk" => "ny_no",
    "nynorsk" => "nn_no",
    "oc" => "oc_fr",
    "or" => "or_in",
    "pa" => "pa_in",
    "pd" => "pd_us",
    "ph" => "ph_ph",
    "pl" => "pl_pl",
    "pp" => "pp_an",
    "pt" => "pt_pt",
    "ro" => "ro_ro",
    "ru" => "ru_ru",
    "rw" => "rw_rw",
    "sd" => "sd_in",
    "sd@devanagari" => "sd_in@devanagari",
    "sh" => "sr_rs@latin",
    "sh_ba@bosnia" => "sr_cs",
    "sh_hr" => "hr_hr",
    "sh_yu" => "sr_rs@latin",
    "si" => "si_lk",
    "sk" => "sk_sk",
    "sl" => "sl_si",
    "sq" => "sq_al",
    "sr" => "sr_rs",
    "sr_yu" => "sr_rs@latin",
    "sr@cyrillic" => "sr_rs",
    "sr_yu@cyrillic" => "sr_rs",
    "sr@latn" => "sr_cs@latin",
    "sr_cs@latn" => "sr_cs@latin",
    "sr@latin" => "sr_rs@latin",
    "sr_rs@latn" => "sr_rs@latin",
    "ss" => "ss_za",
    "st" => "st_za",
    "sv" => "sv_se",
    "ta" => "ta_in",
    "te" => "te_in",
    "tg" => "tg_tj",
    "th" => "th_th",
    "tl" => "tl_ph",
    "tn" => "tn_za",
    "tr" => "tr_tr",
    "ts" => "ts_za",
    "tt" => "tt_ru",
    "uk" => "uk_ua",
    "ur" => "ur_in",
    "uz" => "uz_uz",
    "uz_uz@cyrillic" => "uz_uz",
    "ve" => "ve_za",
    "vi" => "vi_vn",
    "wa" => "wa_be",
    "xh" => "xh_za",
    "yi" => "yi_us",
    "zh_cn" => "zh_tw",
    "zu" => "zu_za",
    "english_uk" => "en_gb",
    "english_us" => "en_us",
    "french_france" => "fr_fr",
    "german_germany" => "de_de",
    "portuguese_brazil" => "pt_br",
    "spanish_spain" => "es_es",
    "american" => "en_us",
    "arabic" => "ar_aa",
    "bokmal" => "nb_no",
    "bokmål" => "nb_no",
    "bulgarian" => "bg_bg",
    "c-french" => "fr_ca",
    "catalan" => "ca_es",
    "chinese-s" => "zh_cn",
    "chinese-t" => "zh_tw",
    "croatian" => "hr_hr",
    "czech" => "cs_cz",
    "danish" => "da_dk",
    "dansk" => "da_dk",
    "deutsch" => "de_de",
    "dutch" => "nl_nl",
    "eesti" => "et_ee",
    "english" => "en_en",
    "estonian" => "et_ee",
    "finnish" => "fi_fi",
    "français" => "fr_fr",
    "french" => "fr_fr",
    "galego" => "gl_es",
    "galician" => "gl_es",
    "german" => "de_de",
    "greek" => "el_gr",
    "hebrew" => "he_il",
    "hrvatski" => "hr_hr",
    "hungarian" => "hu_hu",
    "icelandic" => "is_is",
    "italian" => "it_it",
    "japanese" => "ja_jp",
    "korean" => "ko_kr",
    "lithuanian" => "lt_lt",
    "norwegian" => "no_no",
    "polish" => "pl_pl",
    "portuguese" => "pt_pt",
    "romanian" => "ro_ro",
    "rumanian" => "ro_ro",
    "russian" => "ru_ru",
    "serbocroatian" => "sr_rs@latin",
    "sinhala" => "si_lk",
    "slovak" => "sk_sk",
    "slovene" => "sl_si",
    "slovenian" => "sl_si",
    "spanish" => "es_es",
    "swedish" => "sv_se",
    "turkish" => "tr_tr",
    "thai" => "th_th",
    "univ" => "en_us",
    "universal@ucs4" => "en_us",
    "iso_8859_1" => "en_us",
    "iso_8859_15" => "en_us",
    "iso8859-1" => "en_us",
    "iso-8859-1" => "en_us",
    "japan" => "ja_jp",
    "japanese-euc" => "ja_jp",
 )

"""
    Extracted from cldr_32.0.1/tools/java/org/unicode/cldr/util/data/Script_Metadata.csv
"""

const SCRIPT_OLD_NEW = Dict(
    "Common" => "Zyyy",
    "Latin" => "Latn",
    "Han" => "Hani",
    "Cyrillic" => "Cyrl",
    "Hiragana" => "Hira",
    "Katakana" => "Kana",
    "Thai" => "Thai",
    "Arabic" => "Arab",
    "Hangul" => "Hang",
    "Devanagari" => "Deva",
    "Greek" => "Grek",
    "Hebrew" => "Hebr",
    "Tamil" => "Taml",
    "Kannada" => "Knda",
    "Georgian" => "Geor",
    "Malayalam" => "Mlym",
    "Telugu" => "Telu",
    "Armenian" => "Armn",
    "Myanmar" => "Mymr",
    "Gujarati" => "Gujr",
    "Bengali" => "Beng",
    "Gurmukhi" => "Guru",
    "Lao" => "Laoo",
    "Inherited" => "Zinh",
    "Khmer" => "Khmr",
    "Tibetan" => "Tibt",
    "Sinhala" => "Sinh",
    "Ethiopic" => "Ethi",
    "Thaana" => "Thaa",
    "Oriya" => "Orya",
    "Unknown" => "Zzzz",
    "Canadian_Aboriginal" => "Cans",
    "Syriac" => "Syrc",
    "Bopomofo" => "Bopo",
    "Nko" => "Nkoo",
    "Cherokee" => "Cher",
    "Yi" => "Yiii",
    "Samaritan" => "Samr",
    "Coptic" => "Copt",
    "Mongolian" => "Mong",
    "Glagolitic" => "Glag",
    "Vai" => "Vaii",
    "Balinese" => "Bali",
    "Tifinagh" => "Tfng",
    "Bamum" => "Bamu",
    "Batak" => "Batk",
    "Cham" => "Cham",
    "Javanese" => "Java",
    "Kayah_Li" => "Kali",
    "Lepcha" => "Lepc",
    "Limbu" => "Limb",
    "Lisu" => "Lisu",
    "Mandaic" => "Mand",
    "Meetei_Mayek" => "Mtei",
    "New_Tai_Lue" => "Talu",
    "Ol_Chiki" => "Olck",
    "Saurashtra" => "Saur",
    "Sundanese" => "Sund",
    "Syloti_Nagri" => "Sylo",
    "Tai_Le" => "Tale",
    "Tai_Tham" => "Lana",
    "Tai_Viet" => "Tavt",
    "Avestan" => "Avst",
    "Brahmi" => "Brah",
    "Buginese" => "Bugi",
    "Buhid" => "Buhd",
    "Carian" => "Cari",
    "Cuneiform" => "Xsux",
    "Cypriot" => "Cprt",
    "Deseret" => "Dsrt",
    "Egyptian_Hieroglyphs" => "Egyp",
    "Gothic" => "Goth",
    "Hanunoo" => "Hano",
    "Imperial_Aramaic" => "Armi",
    "Inscriptional_Pahlavi" => "Phli",
    "Inscriptional_Parthian" => "Prti",
    "Kaithi" => "Kthi",
    "Kharoshthi" => "Khar",
    "Linear_B" => "Linb",
    "Lycian" => "Lyci",
    "Lydian" => "Lydi",
    "Ogham" => "Ogam",
    "Old_Italic" => "Ital",
    "Old_Persian" => "Xpeo",
    "Old_South_Arabian" => "Sarb",
    "Old_Turkic" => "Orkh",
    "Osmanya" => "Osma",
    "Phags_Pa" => "Phag",
    "Phoenician" => "Phnx",
    "Rejang" => "Rjng",
    "Runic" => "Runr",
    "Shavian" => "Shaw",
    "Tagalog" => "Tglg",
    "Tagbanwa" => "Tagb",
    "Ugaritic" => "Ugar",
    "Chakma" => "Cakm",
    "Meroitic_Cursive" => "Merc",
    "Meroitic_Hieroglyphs" => "Mero",
    "Miao" => "Plrd",
    "Sharada" => "Shrd",
    "Sora_Sompeng" => "Sora",
    "Takri" => "Takr",
    "Braille" => "Brai",
    "Caucasian_Albanian" => "Aghb",
    "Bassa_Vah" => "Bass",
    "Duployan" => "Dupl",
    "Elbasan" => "Elba",
    "Grantha" => "Gran",
    "Pahawh_Hmong" => "Hmng",
    "Khojki" => "Khoj",
    "Linear_A" => "Lina",
    "Mahajani" => "Mahj",
    "Manichaean" => "Mani",
    "Mende_Kikakui" => "Mend",
    "Modi" => "Modi",
    "Mro" => "Mroo",
    "Old_North_Arabian" => "Narb",
    "Nabataean" => "Nbat",
    "Palmyrene" => "Palm",
    "Pau_Cin_Hau" => "Pauc",
    "Old_Permic" => "Perm",
    "Psalter_Pahlavi" => "Phlp",
    "Siddham" => "Sidd",
    "Khudawadi" => "Sind",
    "Tirhuta" => "Tirh",
    "Warang_Citi" => "Wara",
    "Ahom" => "Ahom",
    "Anatolian_Hieroglyphs" => "Hluw",
    "Hatran" => "Hatr",
    "Multani" => "Mult",
    "Old_Hungarian" => "Hung",
    "SignWriting" => "Sgnw",
    "Adlam" => "Adlm",
    "Bhaiksuki" => "Bhks",
    "Marchen" => "Marc",
    "Osage" => "Osge",
    "Tangut" => "Tang",
    "Newa" => "Newa",
    "Masaram Gondi" => "Gonm",
    "Nushu" => "Nshu",
    "Soyombo" => "Soyo",
    "Zanabazar Square" => "Zanb",
)

"""
    Registered variants as found in cldr32.0.1/common/validity/variant.xml 
"""
const VARIANTS = Set([
 "1606nict", "1694acad", "1901", "1959acad", "1994", "1996",
 "abl1943", "akuapem", "alalc97", "aluku", "ao1990", "arevela", "arevmda", "asant",
 "baku1926", "balanka", "barla", "basiceng", "bauddha", "biscayan", "biske", "bohoric", "boont",
 "colb1945", "cornu",
 "dajnko",
 "ekavsk", "emodeng",
 "fonipa", "fonnapa", "fonupa", "fonxsamp",
 "hepburn", "heploc", "hognorsk", "hsistemo",
 "ijekavsk", "itihasa",
 "jauer", "jyutping",
 "kkcor", "kociewie", "kscor",
 "laukika", "lipaw", "luna1918",
 "metelko", "monoton",
 "ndyuka", "nedis", "newfound", "njiva", "nulik",
 "osojs", "oxendict",
 "pahawh2", "pahawh3", "pahawh4", "pamaka", "petr1708", "pinyin", "polyton", "puter",
 "rigik", "rozaj", "rumgr",
 "scotland", "scouse", "simple", "solba", "sotav", "spanglis", "surmiran", "sursilv", "sutsilv",
 "tarask",
 "uccor", "ucrcor", "ulster", "unifon",
 "vaidika", "valencia", "vallader",
 "wadegile",
 "xsistemo",
])

