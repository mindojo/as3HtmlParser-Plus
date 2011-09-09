/*
 * Copyright 2006-2008 socialDragon, Inc.  All rights reserved.
 */
package org.groe.html.util
{
	public class StringUtil
	{
		public static function trim(s:String):String
		{
			return ltrim( rtrim(s) );
		}
		
		public static function ltrim(s:String):String
		{
			if (s == null)
				return "";

			var size:int = s.length;
			for (var i:int = 0; i < size; i++)
			{
				if (s.charCodeAt(i) > 32)
					return s.substring(i);
			}
			return "";
		}

		public static function rtrim(s:String):String
		{
			if (s == null)
				return "";

			var size:int = s.length;
			for (var i:int = size; i > 0; i--)
			{
				if (s.charCodeAt(i - 1) > 32)
					return s.substring(0, i);
			}
			return "";
		}

		public static function isEmpty(s:String):Boolean
		{
			return (s == null) || (s.length == 0);
		}

		public static function isSpace(c:int):Boolean
		{
			return (c <= 32);
		}

		//From buRRRn.eden.GenericParser.as
		//(http://code.google.com/p/edenrr/source/browse/trunk/as3/src/buRRRn/eden/GenericParser.as)
		public static function isAlpha(c:String):Boolean
		{
			return ( ("A" <= c) && (c <= "Z") ) || ( ("a" <= c) && (c <= "z") );
		}
		public static function isDigit(c:String):Boolean
		{
			return ("0" <= c) && (c <= "9");
		}
		public static function isHexDigit( c:String ):Boolean
		{
			return isDigit(c) || ( ("A" <= c) && (c <= "F") ) || ( ("a" <= c) && (c <= "f") );
		}

		/**
		 * Returns true if character is allowed at the beginning of an identifier.
		 */
		public static function isValidIdentifierStartChar(c:String):Boolean
		{
			return (c == "_") || isAlpha(c);
		}

		/**
		 * Returns true if character is allowed in an identifier.
		 */
		public static function isIdentifierChar(c:String):Boolean
		{
			return (c == "_") || isAlpha(c) || isDigit(c);
		}
	}
}
