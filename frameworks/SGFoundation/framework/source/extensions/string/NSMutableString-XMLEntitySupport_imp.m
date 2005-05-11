//: NSMutableString-XMLEntitySupport_imp.m
/**
  * $Id: NSMutableString-XMLEntitySupport_imp.m,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <SGFoundation/NSMutableString-SGExtensions_p.h>
#import <ctype.h>

#define		SGFMS_UC(x)	[NSString stringWithCharacter : (x)]


@implementation NSMutableString(XMLEntitySupport)
+ (NSDictionary *) XHTMLEntityReferenceTable
{
	static NSDictionary *st_entityReferenceTable = nil;
	if(nil == st_entityReferenceTable){
		NSMutableDictionary *tbl_;	//エンティティ解決テーブル
		
		tbl_ = 
			[[NSMutableDictionary alloc] initWithObjectsAndKeys :
			/*************************************************************/
			/***************** XML/標準エンティティ **********************/
			/*************************************************************/
				SGFMS_UC('<'),		@"lt",		
				SGFMS_UC('>'),		@"gt",		
				SGFMS_UC('&'),		@"amp",		
				SGFMS_UC('\''),		@"apos",	
				SGFMS_UC('"'),		@"quot",	
			/*************************************************************/
			/******** ISO Latin-1 のためのキャラクタエンティティ *********/
			/*************************************************************/
				SGFMS_UC(160),		@"nbsp",	// no-break space
				SGFMS_UC(161),		@"iexcl",	// inverted exclamation mark
				SGFMS_UC(162),		@"cent",	// cent sign
				SGFMS_UC(163),		@"pound",	// pound sterling sign
				SGFMS_UC(164),		@"curren",	// general currency sign
				SGFMS_UC(165),		@"yen",		// yen sign
				SGFMS_UC(166),		@"brvbar",	// broken (vertical) bar
				SGFMS_UC(167),		@"sect",	// section sign
				SGFMS_UC(168),		@"uml",		// umlaut (dieresis)
				SGFMS_UC(169),		@"copy",	// copyright sign
				SGFMS_UC(170),		@"ordf",	// ordinal indicator, feminine
				SGFMS_UC(171),		@"laquo",	// angle quotation mark, left
				SGFMS_UC(172),		@"not",		// not sign
				SGFMS_UC(173),		@"shy",		// soft hyphen
				SGFMS_UC(174),		@"reg",		// registered sign
				SGFMS_UC(175),		@"macr",	// macron
				SGFMS_UC(176),		@"deg",		// degree sign
				SGFMS_UC(177),		@"plusmn",	// plus-or-minus sign
				SGFMS_UC(178),		@"sup2",	// superscript two
				SGFMS_UC(179),		@"sup3",	// superscript three
				SGFMS_UC(180),		@"acute",	// acute accent
				SGFMS_UC(181),		@"micro",	// micro sign
				SGFMS_UC(182),		@"para",	// pilcrow (paragraph sign)
				SGFMS_UC(183),		@"middot",	// middle dot
				SGFMS_UC(184),		@"cedil",	// cedilla
				SGFMS_UC(185),		@"sup1",	// superscript one
				SGFMS_UC(186),		@"ordm",	// ordinal indicator, masculine
				SGFMS_UC(187),		@"raquo",	// angle quotation mark, right
				SGFMS_UC(188),		@"frac14",	// fraction one-quarter
				SGFMS_UC(189),		@"frac12",	// fraction one-half
				SGFMS_UC(190),		@"frac34",	// fraction three-quarters
				SGFMS_UC(191),		@"iquest",	// inverted question mark
				SGFMS_UC(192),		@"Agrave",	// capital A, grave accent
				SGFMS_UC(193),		@"Aacute",	// capital A, acute accent
				SGFMS_UC(194),		@"Acirc",	// capital A, circumflex accent
				SGFMS_UC(195),		@"Atilde",	// capital A, tilde
				SGFMS_UC(196),		@"Auml",	// capital A, dieresis or umlaut mark
				SGFMS_UC(197),		@"Aring",	// capital A, ring
				SGFMS_UC(198),		@"AElig",	// capital AE diphthong (ligature)
				SGFMS_UC(199),		@"Ccedil",	// capital C, cedilla
				SGFMS_UC(200),		@"Egrave",	// capital E, grave accent
				SGFMS_UC(201),		@"Eacute",	// capital E, acute accent
				SGFMS_UC(202),		@"Ecirc",	// capital E, circumflex accent
				SGFMS_UC(203),		@"Euml",	// capital E, dieresis or umlaut mark
				SGFMS_UC(204),		@"Igrave",	// capital I, grave accent
				SGFMS_UC(205),		@"Iacute",	// capital I, acute accent
				SGFMS_UC(206),		@"Icirc",	// capital I, circumflex accent
				SGFMS_UC(207),		@"Iuml",	// capital I, dieresis or umlaut mark
				SGFMS_UC(208),		@"ETH",		// capital Eth, Icelandic
				SGFMS_UC(209),		@"Ntilde",	// capital N, tilde
				SGFMS_UC(210),		@"Ograve",	// capital O, grave accent
				SGFMS_UC(211),		@"Oacute",	// capital O, acute accent
				SGFMS_UC(212),		@"Ocirc",	// capital O, circumflex accent
				SGFMS_UC(213),		@"Otilde",	// capital O, tilde
				SGFMS_UC(214),		@"Ouml",	// capital O, dieresis or umlaut mark
				SGFMS_UC(215),		@"times",	// multiply sign
				SGFMS_UC(216),		@"Oslash",	// capital O, slash
				SGFMS_UC(217),		@"Ugrave",	// capital U, grave accent
				SGFMS_UC(218),		@"Uacute",	// capital U, acute accent
				SGFMS_UC(219),		@"Ucirc",	// capital U, circumflex accent
				SGFMS_UC(220),		@"Uuml",	// capital U, dieresis or umlaut mark
				SGFMS_UC(221),		@"Yacute",	// capital Y, acute accent
				SGFMS_UC(222),		@"THORN",	// capital THORN, Icelandic
				SGFMS_UC(223),		@"szlig",	// small sharp s, German (sz ligature)
				SGFMS_UC(224),		@"agrave",	// small a, grave accent
				SGFMS_UC(225),		@"aacute",	// small a, acute accent
				SGFMS_UC(226),		@"acirc",	// small a, circumflex accent
				SGFMS_UC(227),		@"atilde",	// small a, tilde
				SGFMS_UC(228),		@"auml",	// small a, dieresis or umlaut mark
				SGFMS_UC(229),		@"aring",	// small a, ring
				SGFMS_UC(230),		@"aelig",	// small ae diphthong (ligature)
				SGFMS_UC(231),		@"ccedil",	// small c, cedilla
				SGFMS_UC(232),		@"egrave",	// small e, grave accent
				SGFMS_UC(233),		@"eacute",	// small e, acute accent
				SGFMS_UC(234),		@"ecirc",	// small e, circumflex accent
				SGFMS_UC(235),		@"euml",	// small e, dieresis or umlaut mark
				SGFMS_UC(236),		@"igrave",	// small i, grave accent
				SGFMS_UC(237),		@"iacute",	// small i, acute accent
				SGFMS_UC(238),		@"icirc",	// small i, circumflex accent
				SGFMS_UC(239),		@"iuml",	// small i, dieresis or umlaut mark
				SGFMS_UC(240),		@"eth",		// small eth, Icelandic
				SGFMS_UC(241),		@"ntilde",	// small n, tilde
				SGFMS_UC(242),		@"ograve",	// small o, grave accent
				SGFMS_UC(243),		@"oacute",	// small o, acute accent
				SGFMS_UC(244),		@"ocirc",	// small o, circumflex accent
				SGFMS_UC(245),		@"otilde",	// small o, tilde
				SGFMS_UC(246),		@"ouml",	// small o, dieresis or umlaut mark
				SGFMS_UC(247),		@"divide",	// divide sign
				SGFMS_UC(248),		@"oslash",	// small o, slash
				SGFMS_UC(249),		@"ugrave",	// small u, grave accent
				SGFMS_UC(250),		@"uacute",	// small u, acute accent
				SGFMS_UC(251),		@"ucirc",	// small u, circumflex accent
				SGFMS_UC(252),		@"uuml",	// small u, dieresis or umlaut mark
				SGFMS_UC(253),		@"yacute",	// small y, acute accent
				SGFMS_UC(254),		@"thorn",	// small thorn, Icelandic
				SGFMS_UC(255),		@"yuml",	// small y, dieresis or umlaut mark
			/*************************************************************/
			/************************ Special Characters *****************/
			/*************************************************************/
				// Latin Extended-A
				SGFMS_UC(338),		@"OElig",	// latin capital ligature OE, U+0152 ISOlat2 
				SGFMS_UC(339),		@"oelig",	// latin small ligature oe, U+0153 ISOlat2
												// ligature is a misnomer, this is a separate 
												// character in some languages
				SGFMS_UC(352),		@"Scaron",	// latin capital letter S with caron, 
												// U+0160 ISOlat2
				SGFMS_UC(353),		@"scaron",	// latin small letter s with caron, U+0161 
												// ISOlat2
				SGFMS_UC(376),		@"Yuml",	// latin capital letter Y with diaeresis,
												// U+0178 ISOlat2
				// Spacing Modifier Letters
				SGFMS_UC(710),		@"circ",	// modifier letter circumflex accent, 
												// U+02C6 ISOpub 
				SGFMS_UC(732),		@"tilde",	// small tilde, U+02DC ISOdia
				// General Punctuation
				SGFMS_UC(8194),		@"ensp",	// en space, U+2002 ISOpub
				SGFMS_UC(8195),		@"emsp",	// em space, U+2003 ISOpub
				SGFMS_UC(8201),		@"thinsp",	// thin space, U+2009 ISOpub
				SGFMS_UC(8204),		@"zwnj",	// zero width non-joiner, U+200C NEW RFC 2070 
				SGFMS_UC(8205),		@"zwj",		// zero width joiner, U+200D NEW RFC 2070
				SGFMS_UC(8206),		@"lrm",		// left-to-right mark, U+200E NEW RFC 2070
				SGFMS_UC(8207),		@"rlm",		// right-to-left mark, U+200F NEW RFC 2070
				SGFMS_UC(8211),		@"ndash",	// en dash, U+2013 ISOpub
				SGFMS_UC(8212),		@"mdash",	// em dash, U+2014 ISOpub
				SGFMS_UC(8216),		@"lsquo",	// left single quotation mark, U+2018 ISOnum 
				SGFMS_UC(8217),		@"rsquo",	// right single quotation mark, U+2019 ISOnum 
				SGFMS_UC(8218),		@"sbquo",	// single low-9 quotation mark, U+201A NEW
				SGFMS_UC(8220),		@"ldquo",	// left double quotation mark, U+201C ISOnum 
				SGFMS_UC(8221),		@"rdquo",	// right double quotation mark, U+201D ISOnum 
				SGFMS_UC(8222),		@"bdquo",	// double low-9 quotation mark, U+201E NEW
				SGFMS_UC(8224),		@"dagger",	// dagger, U+2020 ISOpub
				SGFMS_UC(8225),		@"Dagger",	// double dagger, U+2021 ISOpub
				SGFMS_UC(8240),		@"permil",	// per mille sign, U+2030 ISOtech
				SGFMS_UC(8249),		@"lsaquo",	// single left-pointing angle quotation mark,
												// U+2039 ISO proposed 
												// lsaquo is proposed but not yet ISO 
												// standardized
				SGFMS_UC(8250),		@"rsaquo",	// single right-pointing angle quotation mark,
												// U+203A ISO proposed 
												// rsaquo is proposed but not yet
												// ISO standardized
				SGFMS_UC(8364),		@"euro",	// euro sign, U+20AC NEW
			/*************************************************************/
			/************************ Symbol Characters ******************/
			/*************************************************************/
				// Latin Extended-B
				SGFMS_UC(402),		@"fnof",	// latin small f with hook = function
												// = florin, U+0192 ISOtech
				// Greek
				SGFMS_UC(913),		@"Alpha",	// greek capital letter alpha, U+0391
				SGFMS_UC(914),		@"Beta",	// greek capital letter beta, U+0392
				SGFMS_UC(915),		@"Gamma",	// greek capital letter gamma, U+0393 ISOgrk3
				SGFMS_UC(916),		@"Delta",	// greek capital letter delta, U+0394 ISOgrk3
				SGFMS_UC(917),		@"Epsilon",	// greek capital letter epsilon, U+0395
				SGFMS_UC(918),		@"Zeta",	// greek capital letter zeta, U+0396
				SGFMS_UC(919),		@"Eta",		// greek capital letter eta, U+0397
				SGFMS_UC(920),		@"Theta",	// greek capital letter theta, U+0398 ISOgrk3
				SGFMS_UC(921),		@"Iota",	// greek capital letter iota, U+0399
				SGFMS_UC(922),		@"Kappa",	// greek capital letter kappa, U+039A
				SGFMS_UC(923),		@"Lambda",	// greek capital letter lambda, U+039B ISOgrk3
				SGFMS_UC(924),		@"Mu",		// greek capital letter mu, U+039C
				SGFMS_UC(925),		@"Nu",		// greek capital letter nu, U+039D
				SGFMS_UC(926),		@"Xi",		// greek capital letter xi, U+039E ISOgrk3
				SGFMS_UC(927),		@"Omicron",	// greek capital letter omicron, U+039F
				SGFMS_UC(928),		@"Pi",		// greek capital letter pi, U+03A0 ISOgrk3
				SGFMS_UC(929),		@"Rho",		// greek capital letter rho, U+03A1
												// there is no Sigmaf, and no U+03A2
												// character either
				SGFMS_UC(931),		@"Sigma",	// greek capital letter sigma, U+03A3 ISOgrk3
				SGFMS_UC(932),		@"Tau",		// greek capital letter tau, U+03A4
				SGFMS_UC(933),		@"Upsilon",	// greek capital letter upsilon, U+03A5 ISOgrk3
				SGFMS_UC(934),		@"Phi",		// greek capital letter phi, U+03A6 ISOgrk3
				SGFMS_UC(935),		@"Chi",		// greek capital letter chi, U+03A7
				SGFMS_UC(936),		@"Psi",		// greek capital letter psi, U+03A8 ISOgrk3
				SGFMS_UC(937),		@"Omega",	// greek capital letter omega, U+03A9 ISOgrk3
				SGFMS_UC(945),		@"alpha",	// greek small letter alpha, U+03B1 ISOgrk3
				SGFMS_UC(946),		@"beta",	// greek small letter beta, U+03B2 ISOgrk3
				SGFMS_UC(947),		@"gamma",	// greek small letter gamma, U+03B3 ISOgrk3
				SGFMS_UC(948),		@"delta",	// greek small letter delta, U+03B4 ISOgrk3
				SGFMS_UC(949),		@"epsilon",	// greek small letter epsilon, U+03B5 ISOgrk3
				SGFMS_UC(950),		@"zeta",	// greek small letter zeta, U+03B6 ISOgrk3
				SGFMS_UC(951),		@"eta",		// greek small letter eta, U+03B7 ISOgrk3
				SGFMS_UC(952),		@"theta",	// greek small letter theta, U+03B8 ISOgrk3
				SGFMS_UC(953),		@"iota",	// greek small letter iota, U+03B9 ISOgrk3
				SGFMS_UC(954),		@"kappa",	// greek small letter kappa, U+03BA ISOgrk3
				SGFMS_UC(955),		@"lambda",	// greek small letter lambda, U+03BB ISOgrk3
				SGFMS_UC(956),		@"mu",		// greek small letter mu, U+03BC ISOgrk3
				SGFMS_UC(957),		@"nu",		// greek small letter nu, U+03BD ISOgrk3
				SGFMS_UC(958),		@"xi",		// greek small letter xi, U+03BE ISOgrk3
				SGFMS_UC(959),		@"omicron",	// greek small letter omicron, U+03BF NEW
				SGFMS_UC(960),		@"pi",		// greek small letter pi, U+03C0 ISOgrk3
				SGFMS_UC(961),		@"rho",		// greek small letter rho, U+03C1 ISOgrk3
				SGFMS_UC(962),		@"sigmaf",	// greek small letter final sigma, U+03C2 ISOgrk3
				SGFMS_UC(963),		@"sigma",	// greek small letter sigma, U+03C3 ISOgrk3
				SGFMS_UC(964),		@"tau",		// greek small letter tau, U+03C4 ISOgrk3
				SGFMS_UC(965),		@"upsilon",	// greek small letter upsilon, U+03C5 ISOgrk3
				SGFMS_UC(966),		@"phi",		// greek small letter phi, U+03C6 ISOgrk3
				SGFMS_UC(967),		@"chi",		// greek small letter chi, U+03C7 ISOgrk3
				SGFMS_UC(968),		@"psi",		// greek small letter psi, U+03C8 ISOgrk3
				SGFMS_UC(969),		@"omega",	// greek small letter omega, U+03C9 ISOgrk3
				SGFMS_UC(977),		@"thetasym",// greek small letter theta symbol, U+03D1 NEW
				SGFMS_UC(978),		@"upsih",	// greek upsilon with hook symbol, U+03D2 NEW
				SGFMS_UC(982),		@"piv",		// greek pi symbol, U+03D6 ISOgrk3
				// General Punctuation
				SGFMS_UC(8226),		@"bull",	// bullet = black small circle, U+2022 ISOpub 
												// bullet is NOT the same as bullet operator, 
												// U+2219
				SGFMS_UC(8230),		@"hellip",	// horizontal ellipsis = three dot leader,
												// U+2026 ISOpub 
				SGFMS_UC(8242),		@"prime",	// prime = minutes = feet, U+2032 ISOtech
				SGFMS_UC(8243),		@"Prime",	// double prime = seconds = inches, 
												// U+2033 ISOtech
				SGFMS_UC(8254),		@"oline",	// overline = spacing overscore, U+203E NEW
				SGFMS_UC(8260),		@"frasl",	// fraction slash, U+2044 NEW
				// Letterlike Symbols
				SGFMS_UC(8472),		@"weierp",	// script capital P = power set
                                    			//  = Weierstrass p, U+2118 ISOamso
				SGFMS_UC(8465),		@"image",	// blackletter capital I = imaginary part, 
												// U+2111 ISOamso
				SGFMS_UC(8476),		@"real",	// blackletter capital R = real part symbol,
												// U+211C ISOamso
				SGFMS_UC(8482),		@"trade",	// trade mark sign, U+2122 ISOnum
				SGFMS_UC(8501),		@"alefsym",	// alef symbol = first transfinite cardinal, 
												// U+2135 NEW
												// alef symbol is NOT the same as hebrew 
												// letter alef, U+05D0 although the same 
												// glyph could be used to depict both 
												// characters
				// Arrows
				SGFMS_UC(8592),		@"larr",	// leftwards arrow, U+2190 ISOnum
				SGFMS_UC(8593),		@"uarr",	// upwards arrow, U+2191 ISOnum
				SGFMS_UC(8594),		@"rarr",	// rightwards arrow, U+2192 ISOnum
				SGFMS_UC(8595),		@"darr",	// downwards arrow, U+2193 ISOnum
				SGFMS_UC(8596),		@"harr",	// left right arrow, U+2194 ISOamsa
				SGFMS_UC(8629),		@"crarr",	// downwards arrow with corner leftwards
                                     			// = carriage return, U+21B5 NEW
				SGFMS_UC(8656),		@"lArr",	// leftwards double arrow, 
												// U+21D0 ISOtech
												// Unicode does not say that lArr is the same 
												//	as the 'is implied by' arrow
												// but also does not have any other character for
												// that function. So ? lArr can be used for
												// 'is implied by' as ISOtech suggests
				SGFMS_UC(8657),		@"uArr",	// upwards double arrow, U+21D1 ISOamsa
				SGFMS_UC(8658),		@"rArr",	// rightwards double arrow,
												// U+21D2 ISOtech
												// Unicode does not say this is the 'implies' 
												// character but does not have another character 
												// with this function so ?
												// rArr can be used for 'implies' as 
												// ISOtech suggests
				SGFMS_UC(8659),		@"dArr",	// downwards double arrow, U+21D3 ISOamsa
				SGFMS_UC(8660),		@"hArr",	// left right double arrow, U+21D4 ISOamsa
				// Mathematical Operators
				SGFMS_UC(8704),		@"forall",	// for all, U+2200 ISOtech
				SGFMS_UC(8706),		@"part",	// partial differential, U+2202 ISOtech 
				SGFMS_UC(8707),		@"exist",	// there exists, U+2203 ISOtech
				SGFMS_UC(8709),		@"empty",	// empty set = null set = diameter,
												// U+2205 ISOamso
				SGFMS_UC(8711),		@"nabla",	// nabla = backward difference, U+2207 ISOtech
				SGFMS_UC(8712),		@"isin",	// element of, U+2208 ISOtech
				SGFMS_UC(8713),		@"notin",	// not an element of, U+2209 ISOtech
				SGFMS_UC(8715),		@"ni",		// contains as member, U+220B ISOtech
												// should there be a more memorable name
												// than 'ni'?
				SGFMS_UC(8719),		@"prod",	// n-ary product = product sign, 
												// U+220F ISOamsb prod is NOT the same character
												// as U+03A0 'greek capital letter pi' though 
												// the same glyph might be used for both
				SGFMS_UC(8721),		@"sum",		// n-ary sumation, U+2211 ISOamsb
												// sum is NOT the same character as U+03A3 
												// 'greek capital letter sigma' though the same 
												// glyph might be used for both
				SGFMS_UC(8722),		@"minus",	// minus sign, U+2212 ISOtech
				SGFMS_UC(8727),		@"lowast",	// asterisk operator, U+2217 ISOtech
				SGFMS_UC(8730),		@"radic",	// square root = radical sign, U+221A ISOtech
				SGFMS_UC(8733),		@"prop",	// proportional to, U+221D ISOtech
				SGFMS_UC(8734),		@"infin",	// infinity, U+221E ISOtech
				SGFMS_UC(8736),		@"ang",		// angle, U+2220 ISOamso
				SGFMS_UC(8743),		@"and",		// logical and = wedge, U+2227 ISOtech
				SGFMS_UC(8744),		@"or",		// logical or = vee, U+2228 ISOtech
				SGFMS_UC(8745),		@"cap",		// intersection = cap, U+2229 ISOtech
				SGFMS_UC(8746),		@"cup",		// union = cup, U+222A ISOtech
				SGFMS_UC(8747),		@"int",		// integral, U+222B ISOtech
				SGFMS_UC(8756),		@"there4",	// therefore, U+2234 ISOtech
				SGFMS_UC(8764),		@"sim",		// tilde operator = varies with = similar to, 
												// U+223C ISOtech
												// tilde operator is NOT the same character 
												// as the tilde, U+007E, although the same glyph 
												// might be used to represent both 
				SGFMS_UC(8773),		@"cong",	// approximately equal to, U+2245 ISOtech
				SGFMS_UC(8776),		@"asymp",	// almost equal to = asymptotic to,
												// U+2248 ISOamsr
				SGFMS_UC(8800),		@"ne",		// not equal to, U+2260 ISOtech
				SGFMS_UC(8801),		@"equiv",	// identical to, U+2261 ISOtech
				SGFMS_UC(8804),		@"le",		// less-than or equal to, U+2264 ISOtech
				SGFMS_UC(8805),		@"ge",		// greater-than or equal to, U+2265 ISOtech
				SGFMS_UC(8834),		@"sub",		// subset of, U+2282 ISOtech
				SGFMS_UC(8835),		@"sup",		// superset of, U+2283 ISOtech
												// note that nsup, 'not a superset of, 
												// U+2283' is not covered by the Symbol 
												// font encoding and is not included. 
												// Should it be, for symmetry?
												// It is in ISOamsn  
				SGFMS_UC(8836),		@"nsub",	// not a subset of, U+2284 ISOamsn
				SGFMS_UC(8838),		@"sube",	// subset of or equal to, U+2286 ISOtech
				SGFMS_UC(8839),		@"supe",	// superset of or equal to, U+2287 ISOtech
				SGFMS_UC(8853),		@"oplus",	// circled plus = direct sum, U+2295 ISOamsb
				SGFMS_UC(8855),		@"otimes",	// circled times = vector product, U+2297 ISOamsb
				SGFMS_UC(8869),		@"perp",	// up tack = orthogonal to = perpendicular, 
												// U+22A5 ISOtech
				SGFMS_UC(8901),		@"sdot",	// dot operator, U+22C5 ISOamsb
												// dot operator is NOT the same character
												// as U+00B7 middle dot
				// Miscellaneous Technical
				SGFMS_UC(8968),		@"lceil",	// left ceiling = apl upstile, U+2308 ISOamsc 
				SGFMS_UC(8969),		@"rceil",	// right ceiling, U+2309 ISOamsc 
				SGFMS_UC(8970),		@"lfloor",	// left floor = apl downstile, U+230A ISOamsc 
				SGFMS_UC(8971),		@"rfloor",	// right floor, U+230B ISOamsc 
				SGFMS_UC(9001),		@"lang",	// left-pointing angle bracket = bra, 
												// U+2329 ISOtech
												// lang is NOT the same character as U+003C 
												// 'less than' or U+2039 'single left-pointing
												// angle quotation mark'
				SGFMS_UC(9002),		@"rang",	// right-pointing angle bracket = ket, 
												// U+232A ISOtech
												// rang is NOT the same character 
												// as U+003E 'greater than' 
												// or U+203A 'single right-pointing 
												// angle quotation mark'
				// Geometric Shapes
				SGFMS_UC(9674),		@"loz",		// lozenge, U+25CA ISOpub
				// Miscellaneous Symbols
				SGFMS_UC(9824),		@"spades",	// black spade suit, U+2660 ISOpub
												// black here seems to mean filled as opposed 
												// to hollow
				SGFMS_UC(9827),		@"clubs",	// black club suit = shamrock, U+2663 ISOpub
				SGFMS_UC(9829),		@"hearts",	// black heart suit = valentine, U+2665 ISOpub
				SGFMS_UC(9830),		@"diams",	// black diamond suit, U+2666 ISOpub
				
				// Not Implemented...
				SGFMS_UC(' '),		@"lre",		
				SGFMS_UC(' '),		@"rle",		
				SGFMS_UC(' '),		@"pdf",		
				SGFMS_UC(' '),		@"lro",		
				SGFMS_UC(' '),		@"rlo",		
				nil];
				
		st_entityReferenceTable = tbl_;
	}
	return st_entityReferenceTable;
}

@end
