/*
 * Copyright 2006-2009 groe.org.	All rights reserved.
 */
package org.groe.html
{
	import flash.xml.*;
	import mx.controls.Image;
	import org.groe.html.util.StringUtil;

//For testing
//import mx.controls.Alert;


	public class HtmlParser
	{
		//Match: < + (word characters) + whitespace + (everything until >) >
		protected static var openTagRE:RegExp = new RegExp(/<(\w*)\s*([^>]*)>/);
		//Match: rgb(XXX, XXX, XXX)
		protected static var colorRGBRE:RegExp = new RegExp(/rgb\s*\((\d*),\s*(\d*),\s*(\d*)\)/i);


		public function HtmlParser():void
		{
		}
		
		public static function parse(htmlString:String):Element
		{
			var a:Array = toElementArray( StringUtil.trim(htmlString) );
			if (a.length == 1)
				return a[0];

			//Encapsulate array in div
			var e:Element = new Element();
			e.tagName = "div";
			e.childElementArray = a;
			return e;
		}
		
		/**
		 * Creates and returns an attribute map for passed html tag string.
		 * Note: assumes comments have been stripped.
		 */
		public static function toElementArray(htmlString:String):Array
		{
			var elementArray:Array = new Array();
			var currentElement:Element = null, e:Element;
			var htmlStringLength:int = htmlString.length;
			var tagName:String;
			var index1:int, index1a:int, index2:int;
			var s:String;

			var currentIndex:int = 0;
			while (true)
			{
				/*
					search for next <
						if the next character is !:
							search for <!--
								then search for -->
							search for <![CDATA[
								then search for ]]>
						if the next character is / close current tag (using closeTagRE)
							serach for >
						if the next character is a nonspace character, open tag
							serach for > then use openTagRE on the contents
				*/

				//Find next "<" (if it doesn't exist, break)
				index1 = htmlString.indexOf("<", currentIndex);
				if (index1 == -1)
					break;

				//If < is last character, break
				if (index1 >= htmlStringLength)
					break;

				//Add text element for currentIndex - index1
				if (index1 > currentIndex)
				{
					s = unescapeHtml( htmlString.substring(currentIndex, index1) );
					if (s.length > 0)
					{
						e = new Element();
						e.tagName = "text";
						e.text = s;
						e.isClosed = true;
						if (currentElement != null)
							currentElement.addChildElement(e);
						else
							elementArray.push(e);
					}
				}

				var c:String = htmlString.charAt(index1 + 1);
				//Comment or cdata
				if (c == "!")
				{
					//Move past whitespace
					index1a = index1 + 2; //Start at character following "<!"
					while (true)
					{
						if (  (currentIndex >= htmlStringLength) || !isSpace( htmlString.charCodeAt(index1a) )  )
							break;
						index1a++
					}
					if (index1a >= htmlStringLength)
						break;

					//"<!--" or "<![CDATA["
					if (htmlString.substr(index1a, 2) == "--")
					{
						//Search for "-->" (not completely to spec but accurate enough)
						index2 = htmlString.indexOf("-->", index1a + 4);
						if (index2 == -1)
							break;
						currentIndex = index2 + 3;
						continue;
					}
					else if (htmlString.substr(index1a, 7) == "[CDATA[")
					{
						//Search for "]]>"
						index2 = htmlString.indexOf("]]>", index1a + 7);
						if (index2 == -1)
							break;

						s = htmlString.substring(index1a + 7, index2);
						if (s.length > 0)
						{
							//Create text element
							e = new Element();
							e.tagName = "text";
							e.text = s;
							e.isClosed = true;
							if (currentElement != null)
								currentElement.addChildElement(e);
							else
								elementArray.push(e);
						}
						
						currentIndex = index2 + 3;
						continue;
					}
					else if (htmlString.charAt(index1a) == ">")
					{
						//Empty comment block <!> from here: http://htmlhelp.com/reference/wilbur/misc/comment.html
						currentIndex = index1 + 3;
						continue;
					}
				}
				//Close tag
				else if (c == "/")
				{
					//Search for ">"
					index2 = htmlString.indexOf(">", index1 + 2);
					if (index2 == -1)
						break;
					currentIndex = index2 + 1;

//Alert.show( "closeTagString=" + htmlString.substring(index1, currentIndex) );

					tagName = StringUtil.trim( htmlString.substring(index1 + 2, index2) ).toLocaleLowerCase();

					//If there is not current element, or tagname doesn't match current element
					if ( (currentElement == null) || (currentElement.tagName != tagName) )
					{
						//Loop until current element shouldn't have its close tag added
						while (true)
						{
							if ( !addMissingCloseTag(currentElement) )
								break;

							currentElement.isClosed = true;
							currentElement = currentElement.parentElement;
//Alert.show("addMissingCloseTag");
						}
					}

					if ( (currentElement == null) || (currentElement.tagName != tagName) )
					{
						//Otherwise add text element
						e = new Element();
						e.tagName = "text";
						e.text = htmlString.substring(index1, index2 + 1);
						e.isClosed = true;
						if (currentElement != null)
							currentElement.addChildElement(e);
						else
							elementArray.push(e);
						continue;
					}

					//Close current element
					currentElement = (currentElement != null) ? currentElement.parentElement : null;
					continue;
				}
				//Open tag
				else if (  !isSpace( c.charCodeAt(0) )  )
				{
					//Search for ">"
					index2 = htmlString.indexOf(">", index1 + 2);
					if (index2 == -1)
						break;
					currentIndex = index2 + 1;

					e = createElementFromOpenTagString( htmlString.substring(index1, currentIndex) );
					if (e == null)
						continue;

					//Eat script blocks
					if (e.tagName.toLocaleLowerCase() == "script")
					{
						if (e.isClosed)
							continue;

						while (true)
						{
							//Search for "</script>", this is the only thing that closes script blocks
							currentIndex = htmlString.indexOf("</", currentIndex);
							
							//If closing tag wasn't found move to end of string and continue
							if (currentIndex == -1)
								break;
							
							//Move past "</"
							currentIndex += 2;

							index1 = htmlString.indexOf(">", currentIndex);
							if (index1 == -1)
								break;

							var name:String = StringUtil.trim( htmlString.substring(currentIndex, index1) ).toLocaleLowerCase();
							if (name == "script")
							{
								currentIndex = index1 + 1; //Include ">"
								break;
							}
						}
						continue;
					}

					//If the current element should close before this element opens
					if ( (currentElement != null) && shouldCloseElement(currentElement, e) )
					{
						currentElement.isClosed = true;
						currentElement = currentElement.parentElement;
					}
					
					if (currentElement != null)
						currentElement.addChildElement(e);
					else
						elementArray.push(e);

					//Change currentElement unless open tag was also close tag
					if (!e.isClosed)
						currentElement = e;
					e = null;
					continue;
				}
			}
			
			//If there are more characters, add text element
			if (currentIndex < htmlStringLength)
			{
				s = unescapeHtml( htmlString.substring(currentIndex) );
				if (s.length > 0)
				{
					e = new Element();
					e.tagName = "text";
					e.text = s;
					e.isClosed = true;
					if (currentElement != null)
						currentElement.addChildElement(e);
					else
						elementArray.push(e);
				}
			}
			
			return elementArray;
		}

		/**
		 * Creates and returns element for passed open tag string.
		 */
		public static function createElementFromOpenTagString(openTagString:String):Element
		{
			var e:Element = new Element();

			//matchArray[0] is the entire matched string
			//matchArray[1] is the tagName
			//matchArray[2] is the attributes string
			var matchArray:Array = openTagString.match(openTagRE);

			//If no match was made, create text element
			if ( (matchArray == null) || (matchArray.length != 3) )
			{
				e.tagName = "text";
				e.text = openTagString;
				e.isClosed = true;
				return e;
			}

			e.tagName = matchArray[1].toLocaleLowerCase();
			
//Alert.show("e.tagName=" + e.tagName);

			var attributesString:String = matchArray[2];

			//The attributesString clause will also match the trailing / of a open and closed tag
			//If string ends with /, mark element closed and chop off trailing /
			if (attributesString.charAt(attributesString.length - 1) == "/")
			{
				e.isClosed = true;
				attributesString = attributesString.substring(0, attributesString.length - 1);
			}

			//Parse attributes
			getAttributeMap(attributesString, e.attributeMap);

			//Parse style attributes
			getStyleAttributeMap(e.attributeMap["style"], e.styleAttributeMap);

			//If a close tag is not allowed for this element type, close element
			if ( !closeTagAllowed(e) )
				e.isClosed = true;
			
			return e;
		}

		/**
		 * Creates and returns an attribute map for passed html tag string.
		 */
		public static function getAttributeMap(attributesString:String, existingAttributeMap:Object):Object
		{
			var m:Object = (existingAttributeMap != null) ? existingAttributeMap : {};
			var name:String;
			var tempS:String;
			var i:int;

			if ( (attributesString == null) || (attributesString.length == 0) )
				return m;

			//The following attribute formats:
			//	name='value'
			//	name="value"
			//	name=value
			//	name
			var s:String = attributesString;
			var currentIndex:int = 0;
			while (true)
			{
				//Find "="
				var index1:int = s.indexOf("=", currentIndex);

				if (index1 != -1)
					name = StringUtil.trim( s.substring(currentIndex, index1) ).toLocaleLowerCase();
				else
					name = StringUtil.trim( s.substring(currentIndex) ).toLocaleLowerCase();

				//If there are spaces name, name contains multiple attributes, split on whitespace
				//and everything but the last is in name-only attribute format
				var a:Array = name.split(/\s+/);
				if (a.length > 1)
				{
					for (i = 0; i < (a.length - 1); i++)
					{
						tempS = StringUtil.trim(a[i]);
						if ( !StringUtil.isEmpty(tempS) )
							m[tempS] = true;
					}
					
					name = StringUtil.trim(a[a.length - 1]).toLocaleLowerCase();
					//If name is empty, parsing will break, this is a hack to prevent additional parsing errors
					//The correct fix is to only add attributes from array while there is still another values
					//past the current
					//Whether this can happen or not is up to the re parsing of as3
					if ( StringUtil.isEmpty(name) )
						name = "name_was_null";
				}

				//If there was no equal sign, and name isn't empty, add name as a name-only attribute and break
				if (index1 == -1)
				{
					if ( !StringUtil.isEmpty(name) )
						m[name] = true;
					break;
				}

				currentIndex = index1 + 1; //One past =

				//Look for  ' " or nonspace
				while (true)
				{
					if (currentIndex >= s.length)
						break;
					if (  !isSpace( s.charCodeAt(currentIndex) )  )
					{
						//If ' or " was found, search for it again
						var c:String = s.charAt(currentIndex);
						if ( (c == "'") || (c == "\"") )
						{
							var index2:int = s.indexOf(c, currentIndex + 1);
							if (index2 == -1)
								index2 = s.length;

							m[name] = unescapeHtml( s.substring(currentIndex + 1, index2) );
							currentIndex = index2 + 1;
						}
						//Otherwise search for space (or end of string)
						else
						{
							index1 = currentIndex;

							while (true)
							{
								if (  (currentIndex >= s.length) || isSpace( s.charCodeAt(currentIndex++) )  )
									break;
							}
							m[name] = unescapeHtml( s.substring(index1, currentIndex - 1) );
						}
						break;
					}
					currentIndex++;
				}
			}

			return m;
		}

		/**
		 * Creates and returns an attribute map for passed style string.
		 */
		public static function getStyleAttributeMap(styleString:String, existingStyleAttributeMap:Object):Object
		{
			var m:Object = (existingStyleAttributeMap != null) ? existingStyleAttributeMap : {};

			if ( (styleString == null) || (styleString.length == 0) )
				return m;

			var a:Array = styleString.split(";")
			for (var i:int = 0; i < a.length; i++)
			{
				var a2:Array = a[i].split(":", 2);
				
				//If style attribute is malformed, continue
				if (a2.length != 2)
					continue;

				var name:String = StringUtil.trim(a2[0]).toLocaleLowerCase();
				//If attribute name is blank, continue
				if (name.length == 0)
					continue;
				
				m[name] = unescapeHtml( StringUtil.trim(a2[1]) );
			}
			
			return m;
		}

		/**
		 * Returns an array of [scalor, unit type] or null, if format is invalid.
		 * Note: throws error on invalid scalor value.
		 */
		public static function parseDimensionString(s:String, allowedUnitTypesMask:int = -1):Array
		{
			if ( (s == null) || (s.length == 0) )
				return null;

			var index:int;
			var unitType:int;

			s = s.toLocaleLowerCase();

			//Search in most commonly used order
			if (   (allowedUnitTypesMask & Constants.unitTypePX) && (  ( index = s.indexOf("px") ) != -1  )   )
				unitType = Constants.unitTypePX;
			else if (   (allowedUnitTypesMask & Constants.unitTypePercent) && (  ( index = s.indexOf("%") ) != -1  )   )
				unitType = Constants.unitTypePercent;
			else if (   (allowedUnitTypesMask & Constants.unitTypePT) && (  ( index = s.indexOf("pt") ) != -1  )   )
				unitType = Constants.unitTypePT;
			else if (   (allowedUnitTypesMask & Constants.unitTypeEM) && (  ( index = s.indexOf("em") ) != -1  )   )
				unitType = Constants.unitTypeEM;
			else if (   (allowedUnitTypesMask & Constants.unitTypeIN) && (  ( index = s.indexOf("in") ) != -1  )   )
				unitType = Constants.unitTypeIN;
			else if (   (allowedUnitTypesMask & Constants.unitTypeMM) && (  ( index = s.indexOf("mm") ) != -1  )   )
				unitType = Constants.unitTypeMM;
			else if (   (allowedUnitTypesMask & Constants.unitTypeCM) && (  ( index = s.indexOf("cm") ) != -1  )   )
				unitType = Constants.unitTypeCM;
			else if (   (allowedUnitTypesMask & Constants.unitTypePC) && (  ( index = s.indexOf("pc") ) != -1  )   )
				unitType = Constants.unitTypePC;
			else if (   (allowedUnitTypesMask & Constants.unitTypeEX) && (  ( index = s.indexOf("ex") ) != -1  )   )
				unitType = Constants.unitTypeEX;
			//Default to unitless pixels
			else
			{
				index = s.length;
				unitType = Constants.unitTypePX;
			}

			var scalor:int;
			try
			{
				scalor = parseInt( s.substring(0, index) );
			}
			catch (e:Error)
			{
				throw new Error("Invalid scalor value:" + s.substring(0, index) + ", error=" + e);
			}

			var a:Array = new Array();
			a.push(scalor);
			a.push(unitType);
			return a;
		}

		/**
		 * Returns an array of [scalor, unit type] or null, if format is invalid.
		 * Note: throws error on invalid scalor value.
		 */
		public static function getWidthArray(e:Element, checkAttributeMap:Boolean = false):Array
		{
			var a:Array = null;

			//First check style attribute map
			a = parseDimensionString(e.styleAttributeMap["width"], 
				Constants.unitTypePX + Constants.unitTypePercent);
			//Next check attribute map
			if ( (a == null) && (checkAttributeMap) )
				a = parseDimensionString(e.attributeMap["width"], 
					Constants.unitTypePX + Constants.unitTypePercent);

			return a;
		}

		/**
		 * Returns an array of [scalor, unit type] or null, if format is invalid.
		 * Note: throws error on invalid scalor value.
		 */
		public static function getHeightArray(e:Element, checkAttributeMap:Boolean = false):Array
		{
			var a:Array = null;

			//First check style attribute map
			a = parseDimensionString(e.styleAttributeMap["height"], 
				Constants.unitTypePX + Constants.unitTypePercent);
			//Next check attribute map
			if ( (a == null) && (checkAttributeMap) )
				a = parseDimensionString(e.attributeMap["height"], 
					Constants.unitTypePX + Constants.unitTypePercent);

			return a;
		}

		/**
		 * Returns an array of size 4, each value being an array of [scalor, unit type] or null, 
		 * if format is invalid.
		 * Note: throws error on invalid scalor value.
		 * This function is designed to parse padding and margin values
		 */
		public static function parse4NumberDimensionString(s:String, allowedUnitTypesMask:int = -1):Array
		{
			var a:Array = s.split(" ", 4);

			if (a.length == 1)
				a.push(s);
			if (a.length == 2)
			{
				a.push( a[0] );
				a.push( a[1] );
			}
			if (a.length == 3)
				a.push( a[1] );

			for (var i:int = 0; i < a.length; i++)
				a[i] = parseDimensionString(a[i], allowedUnitTypesMask);
			
			return a;
		}

		/**
		 * Returns an array of size 3, in the format [border width (array), border style, border color]
		 * or null, if format is invalid.
		 * Note: throws error on invalid scalor value.
		 * This function is designed to parse padding and margin values
		 */
		public static function parseBorderString(s:String, allowedUnitTypesMask:int = -1):Array
		{
			var tempA:Array = s.split(" ", 3);

			if (tempA.length != 3)
				return null;

			var a:Array = new Array();
			a.push( parseDimensionString(tempA[0], allowedUnitTypesMask) );
			a.push( parseColorString(tempA[1]) );
			a.push(tempA[2]);
			return a;
		}

		/**
		 * Returns parsed color string.
		 * Converts RGB values to #XXXXXX format.
		 * Converts some non-standard color names to #XXXXXX values.
		 * Note: throws error on invalid scalor value.
		 */
		public static function parseColorString(s:String):String
		{
			var index:int;

			//Match #XXXXXX			
			index = s.indexOf("#");
			if (index != -1)
				return s;

			//Match rgb(XXX, XXX, XXX)
			var matchArray:Array = s.match(colorRGBRE);
			if ( (matchArray != null) && (matchArray.length == 4) )
			{
				return "#" + parseInt(matchArray[1]).toString(16) 
					+ parseInt(matchArray[2]).toString(16)
					+ parseInt(matchArray[3]).toString(16);
			}
			
			//Handle non-standard colors
			s = s.toLocaleLowerCase();
			if (s in Constants.nonStandardColorNameValueMap)
				return Constants.nonStandardColorNameValueMap[s];

			return s;
		}

		/**
		 * Parses HTML vertical-align style property and returns an array of [scalor, type] or null, if format is invalid.
		 * Note: throws error on invalid scalor value.
		 */
		public static function parseVerticalAlignString(s:String):Array
		{
			if ( (s == null) || (s.length == 0) )
				return null;

			var index:int;
			var scalor:int;

			//If s is a simple vertical align type, return it (set scalor to 0, it won't be used)			
			s = s.toLocaleLowerCase();
			if (s in Constants.verticalAlignStringTypeMap)
				return [ 0, Constants.verticalAlignStringTypeMap[s] ];
			
			//Otherwise check for percentage or length
			index = s.indexOf("%");
			if (index != -1)
			{
				try
				{
					scalor = parseInt( s.substring(0, index) );
					return [scalor, Constants.verticalAlignTypePercentage];
				}
				catch (e:Error)
				{
					throw new Error("Invalid scalor value:" + s.substring(0, index) + ", error=" + e);
				}
			}

			//Otherwise assume value is a length
			try
			{
				scalor = parseInt(s);
				return [scalor, Constants.verticalAlignTypeLength];
			}
			catch (e:Error)
			{
				//Ignore error
			}

			return null;
		}

		/**
		 * Parses HTML line-height style property and returns an array of [scalor, type] or null, if format is invalid.
		 * Note: throws error on invalid scalor value.
		 */
		public static function parseLineHeightString(s:String):Array
		{
			if ( (s == null) || (s.length == 0) )
				return null;

			var index:int;
			var scalor:int;

			//If s is a simple vertical align type, return it (set scalor to 0, it won't be used)			
			s = s.toLocaleLowerCase();
			if (s in Constants.verticalAlignStringTypeMap)
				return [ 0, Constants.verticalAlignStringTypeMap[s] ];
			
			//Otherwise check for percentage or length
			index = s.indexOf("%");
			if (index != -1)
			{
				try
				{
					scalor = parseInt( s.substring(0, index) );
					return [scalor, Constants.verticalAlignTypePercentage];
				}
				catch (e:Error)
				{
					throw new Error("Invalid scalor value:" + s.substring(0, index) + ", error=" + e);
				}
			}

			//Otherwise assume value is a length
			try
			{
				scalor = parseInt(s);
				return [scalor, Constants.verticalAlignTypeLength];
			}
			catch (e:Error)
			{
				//Ignore error
			}

			return null;
		}

		/**
		 * Returns true if element is a block element, false otherwise.
		 * See http://htmlhelp.com/reference/html40/block.html
		 */
		public static function isBlockElement(e:Element, makeRecursiveCall:Boolean = false):Boolean
		{
			if (e == null)
				return false;

			switch (e.elementType)
			{
				case Constants.elementTypeADDRESS:
				case Constants.elementTypeBLOCKQUOTE:
				case Constants.elementTypeCENTER:
				case Constants.elementTypeDIR:
				case Constants.elementTypeDL:
				case Constants.elementTypeFIELDSET:
				case Constants.elementTypeFORM:
				case Constants.elementTypeH1:
				case Constants.elementTypeH2:
				case Constants.elementTypeH3:
				case Constants.elementTypeH4:
				case Constants.elementTypeH5:
				case Constants.elementTypeH6:
				case Constants.elementTypeHR:
				case Constants.elementTypeISINDEX:
				case Constants.elementTypeMENU:
				case Constants.elementTypeNOFRAMES:
				case Constants.elementTypeNOSCRIPT:
				case Constants.elementTypeOL:
				case Constants.elementTypeP:
				case Constants.elementTypePRE:
				case Constants.elementTypeTABLE:
				case Constants.elementTypeUL:
				case Constants.elementTypeDD:
				case Constants.elementTypeDT:
				case Constants.elementTypeFRAMESET:
				case Constants.elementTypeLI:
				case Constants.elementTypeTBODY:
				case Constants.elementTypeTD:
				case Constants.elementTypeTFOOT:
				case Constants.elementTypeTH:
				case Constants.elementTypeTHEAD:
				case Constants.elementTypeTR:
					return true;
				case Constants.elementTypeDIV:
					var value:String = e.styleAttributeMap["display"];
					if ( !StringUtil.isEmpty(value) && (value == "inline") )
						return false;
					return true;
			}
			
			if (makeRecursiveCall)
			{
				if (e.hasChildren)
				{
					for (var i:int = 0; i < e.childElementArray.length; i++)
					{
						if ( isBlockElement(e.childElementArray[i], makeRecursiveCall) )
							return true;
					}
				}
			}
			
			return false;
		}

		/**
		 * Returns true if the passed parent element should be closed, false otherwise.
		 */
		public static function addMissingCloseTag(e:Element):Boolean
		{
			switch (e.elementType)
			{
				case Constants.elementTypeP:
				case Constants.elementTypeB:
				case Constants.elementTypeCENTER:
				case Constants.elementTypeCODE:
				case Constants.elementTypeCOL:
				case Constants.elementTypeDEL:
				case Constants.elementTypeDFN:
				case Constants.elementTypeEM:
				case Constants.elementTypeI:
				case Constants.elementTypeINS:
				case Constants.elementTypeKBD:
				case Constants.elementTypeS:
				case Constants.elementTypeSAMP:
				case Constants.elementTypeSTRIKE:
				case Constants.elementTypeSTRONG:
				case Constants.elementTypeQ:
				case Constants.elementTypeTD:
				case Constants.elementTypeTH:
				case Constants.elementTypeTR:
				case Constants.elementTypeU:
				case Constants.elementTypeVAR:
					return true;
			}
			
			return false;
		}

		/**
		 * Returns true if the passed parent element should be closed, false otherwise.
		 */
		public static function shouldCloseElement(currentElement:Element, nextElement:Element):Boolean
		{
			if ( (currentElement == null) || (nextElement == null) )
				return false;
			
			if (currentElement.elementType == nextElement.elementType)
			{
				switch (currentElement.elementType)
				{
					case Constants.elementTypeA:
					case Constants.elementTypeB:
					case Constants.elementTypeCENTER:
					case Constants.elementTypeCODE:
					case Constants.elementTypeCOL:
					case Constants.elementTypeDEL:
					case Constants.elementTypeDFN:
					case Constants.elementTypeEM:
					case Constants.elementTypeI:
					case Constants.elementTypeINS:
					case Constants.elementTypeKBD:
					case Constants.elementTypeS:
					case Constants.elementTypeSAMP:
					case Constants.elementTypeSTRIKE:
					case Constants.elementTypeSTRONG:
					case Constants.elementTypeQ:
					case Constants.elementTypeTD:
					case Constants.elementTypeTH:
					case Constants.elementTypeTR:
					case Constants.elementTypeU:
					case Constants.elementTypeVAR:
						return true;
				}
			}

			if ( nextElement.isLocalBlock && !currentElement.isLocalBlock && addMissingCloseTag(currentElement) )
				return true;

			//If parent element is a p and this element is a block element, return true
			if ( (currentElement.elementType == Constants.elementTypeP) && nextElement.isLocalBlock )
				return true;

			//If this element is a tr
			if (nextElement.elementType == Constants.elementTypeTR)
			{
				//And the parent element is a td or th
				if ( (currentElement.elementType == Constants.elementTypeTD) ||
					 (currentElement.elementType == Constants.elementTypeTH) )
					return true;
			}

			return false;
		}

		public static function closeTagAllowed(e:Element):Boolean
		{
			switch (e.elementType)
			{
				case Constants.elementTypeAREA:
				case Constants.elementTypeBASE:
				case Constants.elementTypeBR:
				case Constants.elementTypeIMG:
				case Constants.elementTypeINPUT:
				case Constants.elementTypeLINK:
				case Constants.elementTypeMETA:
				case Constants.elementTypeOPTION:
				case Constants.elementTypePARAM:
					return false;
			}
			
			return true;
		}

		public static function escapeHtml(s:String):String
		{
			//Replace & < > " '
			return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/\"/g, "&quot;")
				.replace(/'/g, "&apos;");
		}
		public static function unescapeHtml(s:String):String
		{
			if (s.indexOf("&") != -1)
			{
				//Replace &lt; &gt; &quot; &apos; &amp;
				s = s.replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&quot;/g, "\"")
					.replace(/&apos;/g, "'").replace(/&amp;/g, "&");
			}
			
			return s;
		}

		public static function collapseWhitespace(s:String):String
		{
			return s.split(/\s+/).join(" ");
		}

		public static function toWordArray(s:String):Array
		{
			var tempA:Array = s.split(/\s+/);
			var a:Array = new Array();
			
			for (var i:int = 0; i < tempA.length; i++)
			{
				s = StringUtil.trim(tempA[i]);
				if (s.length == 0)
					continue;
				a.push(s);
			}

			return a;
		}

		public static function unescapeEntities(s:String):String
		{
			if (s.indexOf("&") != -1)
			{
				s = s.split("&nbsp;").join(" ")
				//s = s.replace("&nbsp;", " ");
			}
			
			return s;
		}

		public static function isSpace(c:int):Boolean
		{
			return (c <= 32);
		}
	}
}
