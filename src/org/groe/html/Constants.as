/*
 * Copyright 2006-2009 groe.org.	All rights reserved.
 */
package org.groe.html
{
	public class Constants
	{
		//Unit types from http://htmlhelp.com/reference/css/units.html
		public static const unitTypeEM:int = 1;
		public static const unitTypeEX:int = 2;
		public static const unitTypePX:int = 4;
		public static const unitTypeIN:int = 8;
		public static const unitTypeCM:int = 16;
		public static const unitTypeMM:int = 32;
		public static const unitTypePT:int = 64;
		public static const unitTypePC:int = 128;
		public static const unitTypePercent:int = 256;

		//Element types from http://www.w3schools.com/tags/tag_noscript.asp
		public static const elementTypeA:int = 1;
		public static const elementTypeABBR:int = 2;
		public static const elementTypeACRONYM:int = 3;
		public static const elementTypeADDRESS:int = 4;
		public static const elementTypeAPPLET:int = 5;
		public static const elementTypeAREA:int = 6;
		public static const elementTypeB:int = 7;
		public static const elementTypeBASE:int = 8;
		public static const elementTypeBASEFONT:int = 9;
		public static const elementTypeBDO:int = 10;
		public static const elementTypeBIG:int = 11;
		public static const elementTypeBLOCKQUOTE:int = 12;
		public static const elementTypeBODY:int = 13;
		public static const elementTypeBR:int = 14;
		public static const elementTypeBUTTON:int = 15;
		public static const elementTypeCAPTION:int = 16;
		public static const elementTypeCENTER:int = 17;
		public static const elementTypeCITE:int = 18;
		public static const elementTypeCODE:int = 19;
		public static const elementTypeCOL:int = 20;
		public static const elementTypeCOLGROUP:int = 21;
		public static const elementTypeDD:int = 22;
		public static const elementTypeDEL:int = 23;
		public static const elementTypeDFN:int = 24;
		public static const elementTypeDIR:int = 25;
		public static const elementTypeDIV:int = 26;
		public static const elementTypeDL:int = 27;
		public static const elementTypeDT:int = 28;
		public static const elementTypeEM:int = 29;
		public static const elementTypeFIELDSET:int = 30;
		public static const elementTypeFONT:int = 31;
		public static const elementTypeFORM:int = 32;
		public static const elementTypeFRAME:int = 33;
		public static const elementTypeFRAMESET:int = 34;
		public static const elementTypeHEAD:int = 35;
		public static const elementTypeH1:int = 36;
		public static const elementTypeH2:int = 37;
		public static const elementTypeH3:int = 38;
		public static const elementTypeH4:int = 39;
		public static const elementTypeH5:int = 40;
		public static const elementTypeH6:int = 41;
		public static const elementTypeHR:int = 42;
		public static const elementTypeHTML:int = 43;
		public static const elementTypeI:int = 44;
		public static const elementTypeIFRAME:int = 45;
		public static const elementTypeIMG:int = 46;
		public static const elementTypeINPUT:int = 47;
		public static const elementTypeINS:int = 48;
		public static const elementTypeKBD:int = 49;
		public static const elementTypeLABEL:int = 50;
		public static const elementTypeLEGEND:int = 51;
		public static const elementTypeLI:int = 52;
		public static const elementTypeLINK:int = 53;
		public static const elementTypeMAP:int = 54;
		public static const elementTypeMENU:int = 55;
		public static const elementTypeMETA:int = 56;
		public static const elementTypeNOFRAMES:int = 57;
		public static const elementTypeNOSCRIPT:int = 58;
		public static const elementTypeOBJECT:int = 59;
		public static const elementTypeOL:int = 60;
		public static const elementTypeOPTGROUP:int = 61;
		public static const elementTypeOPTION:int = 62;
		public static const elementTypeP:int = 63;
		public static const elementTypePARAM:int = 64;
		public static const elementTypePRE:int = 65;
		public static const elementTypeQ:int = 66;
		public static const elementTypeS:int = 67;
		public static const elementTypeSAMP:int = 68;
		public static const elementTypeSCRIPT:int = 69;
		public static const elementTypeSELECT:int = 70;
		public static const elementTypeSMALL:int = 71;
		public static const elementTypeSPAN:int = 72;
		public static const elementTypeSTRIKE:int = 73;
		public static const elementTypeSTRONG:int = 74;
		public static const elementTypeSTYLE:int = 75;
		public static const elementTypeSUB:int = 76;
		public static const elementTypeSUP:int = 77;
		public static const elementTypeTABLE:int = 78;
		public static const elementTypeTBODY:int = 79;
		public static const elementTypeTD:int = 80;
		public static const elementTypeTEXTAREA:int = 81;
		public static const elementTypeTFOOT:int = 82;
		public static const elementTypeTH:int = 83;
		public static const elementTypeTHEAD:int = 84;
		public static const elementTypeTITLE:int = 85;
		public static const elementTypeTR:int = 86;
		public static const elementTypeTT:int = 87;
		public static const elementTypeU:int = 88;
		public static const elementTypeUL:int = 89;
		public static const elementTypeVAR:int = 90;
		public static const elementTypeISINDEX:int = 91;
		
		//Add custom text element
		public static const elementTypeTEXT:int = 100;
		

		public static var tagNameElementTypeMap:Object = 
			{
				"a" : elementTypeA,
				"abbr" : elementTypeABBR,
				"acronym" : elementTypeACRONYM,
				"address" : elementTypeADDRESS,
				"applet" : elementTypeAPPLET,
				"area" : elementTypeAREA,
				"b" : elementTypeB,
				"base" : elementTypeBASE,
				"basefont" : elementTypeBASEFONT,
				"bdo" : elementTypeBDO,
				"big" : elementTypeBIG,
				"blockquote" : elementTypeBLOCKQUOTE,
				"body" : elementTypeBODY,
				"br" : elementTypeBR,
				"button" : elementTypeBUTTON,
				"caption" : elementTypeCAPTION,
				"center" : elementTypeCENTER,
				"cite" : elementTypeCITE,
				"code" : elementTypeCODE,
				"col" : elementTypeCOL,
				"colgroup" : elementTypeCOLGROUP,
				"dd" : elementTypeDD,
				"del" : elementTypeDEL,
				"dfn" : elementTypeDFN,
				"dir" : elementTypeDIR,
				"div" : elementTypeDIV,
				"dl" : elementTypeDL,
				"dt" : elementTypeDT,
				"em" : elementTypeEM,
				"fieldset" : elementTypeFIELDSET,
				"font" : elementTypeFONT,
				"form" : elementTypeFORM,
				"frame" : elementTypeFRAME,
				"frameset" : elementTypeFRAMESET,
				"head" : elementTypeHEAD,
				"h1" : elementTypeH1,
				"h2" : elementTypeH2,
				"h3" : elementTypeH3,
				"h4" : elementTypeH4,
				"h5" : elementTypeH5,
				"h6" : elementTypeH6,
				"hr" : elementTypeHR,
				"html" : elementTypeHTML,
				"i" : elementTypeI,
				"iframe" : elementTypeIFRAME,
				"img" : elementTypeIMG,
				"input" : elementTypeINPUT,
				"ins" : elementTypeINS,
				"kbd" : elementTypeKBD,
				"label" : elementTypeLABEL,
				"legend" : elementTypeLEGEND,
				"li" : elementTypeLI,
				"link" : elementTypeLINK,
				"map" : elementTypeMAP,
				"menu" : elementTypeMENU,
				"meta" : elementTypeMETA,
				"noframes" : elementTypeNOFRAMES,
				"noscript" : elementTypeNOSCRIPT,
				"object" : elementTypeOBJECT,
				"ol" : elementTypeOL,
				"optgroup" : elementTypeOPTGROUP,
				"option" : elementTypeOPTION,
				"p" : elementTypeP,
				"param" : elementTypePARAM,
				"pre" : elementTypePRE,
				"q" : elementTypeQ,
				"s" : elementTypeS,
				"samp" : elementTypeSAMP,
				"script" : elementTypeSCRIPT,
				"select" : elementTypeSELECT,
				"small" : elementTypeSMALL,
				"span" : elementTypeSPAN,
				"strike" : elementTypeSTRIKE,
				"strong" : elementTypeSTRONG,
				"style" : elementTypeSTYLE,
				"sub" : elementTypeSUB,
				"sup" : elementTypeSUP,
				"table" : elementTypeTABLE,
				"tbody" : elementTypeTBODY,
				"td" : elementTypeTD,
				"textarea" : elementTypeTEXTAREA,
				"tfoot" : elementTypeTFOOT,
				"th" : elementTypeTH,
				"thead" : elementTypeTHEAD,
				"title" : elementTypeTITLE,
				"tr" : elementTypeTR,
				"tt" : elementTypeTT,
				"u" : elementTypeU,
				"ul" : elementTypeUL,
				"var" : elementTypeVAR,
				"text" : elementTypeTEXT
			};

		public static const horizontalAlignTypeLeft:int = 1;
		public static const horizontalAlignTypeCenter:int = 2;
		public static const horizontalAlignTypeRight:int = 4;
		public static const horizontalAlignTypeJustify:int = 8;
		public static const horizontalAlignTypeInherit:int = 16;

		public static var horizontalAlignStringTypeMap:Object = 
			{
				"left" : horizontalAlignTypeLeft,
				"center" : horizontalAlignTypeCenter,
				"right" : horizontalAlignTypeRight,
				"justify" : horizontalAlignTypeJustify,
				"inherit" : horizontalAlignTypeInherit
			};

		//Vertical align types from http://webdesign.about.com/od/styleproperties/p/blspverticalali.htm
		public static const verticalAlignTypeBaseline:int = 1;
		public static const verticalAlignTypeSub:int = 2;
		public static const verticalAlignTypeSuper:int = 4;
		public static const verticalAlignTypeTop:int = 8;
		public static const verticalAlignTypeTextTop:int = 16;
		public static const verticalAlignTypeMiddle:int = 32;
		public static const verticalAlignTypeBottom:int = 64;
		public static const verticalAlignTypeTextBottom:int = 128;
		public static const verticalAlignTypeInherit:int = 256;
		public static const verticalAlignTypePercentage:int = 512;
		public static const verticalAlignTypeLength:int = 1024;

		public static var verticalAlignStringTypeMap:Object = 
			{
				"baseline" : verticalAlignTypeBaseline,
				"sub" : verticalAlignTypeSub,
				"super" : verticalAlignTypeSuper,
				"top" : verticalAlignTypeTop,
				"text-top" : verticalAlignTypeTextTop,
				"middle" : verticalAlignTypeMiddle,
				"bottom" : verticalAlignTypeBottom,
				"text-bottom" : verticalAlignTypeTextBottom,
				"inherit" : verticalAlignTypeInherit
			};

		public static var nonStandardColorNameValueMap:Object = 
			{
				"orange" : "#FFA500"
			};
	}
}
