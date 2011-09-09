/*
 * Copyright 2006-2009 groe.org.	All rights reserved.
 */
package org.groe.html
{
	import org.groe.html.util.StringUtil;


	public class Element
	{
		public var _tagName:String = null;
		public var _elementType:int = 0;
		public var attributeMap:Object = {};
		public var styleAttributeMap:Object = {};

		protected var _childElementArray:Array = null;
		protected var _text:String = "";
		protected var _textIsEmpty:Boolean = true;

		public var isClosed:Boolean = false;

		protected var _isBlock:int = -1; //-1 = not set, 0 = false, 1 = true
		protected var _isLocalBlock:int = -1; //-1 = not set, 0 = false, 1 = true

		//Used to determine local value since html inherits and as3 does not
		public var horizontalAlignSetLocally:Boolean = false;
		
		public var parentElement:Element = null;

		
		public function Element():void
		{
		}

		public function get tagName():String
		{
			return _tagName;
		}
		public function set tagName(value:String):void
		{
			_tagName = value;

			if (tagName in Constants.tagNameElementTypeMap)
				_elementType = Constants.tagNameElementTypeMap[tagName];
			else
				_elementType = 0;

			_isBlock = -1;
		}

		public function get elementType():int
		{
			return _elementType;
		}
		
		public function get childElementArray():Array
		{
			return _childElementArray;
		}
		public function set childElementArray(value:Array):void
		{
			_childElementArray = value;
			
			//Set parent element on all children
			if (_childElementArray != null)
			{
				for (var i:int = 0; i < _childElementArray.length; i++)
				{
					var e:Element = _childElementArray[i] as Element;
					if (e != null)
						e.parentElement = this;
				}
			}
			
			//Force isBlock to recalculate
			_isBlock = -1;
		}

		public function get text():String
		{
			return _text;
		}
		public function set text(value:String):void
		{
			_text = value;
			_childElementArray = null;
			
			_textIsEmpty = StringUtil.trim(_text).length == 0;

			_isBlock = -1;
			_isLocalBlock = -1;
		}

		public function get textIsEmpty():Boolean
		{
			return _textIsEmpty;
		}

		public function get isBlock():Boolean
		{
			if (_isBlock == -1)
				_isBlock = ( HtmlParser.isBlockElement(this, true) ) ? 1 : 0;

			return (_isBlock == 1);
		}

		public function get hasChildren():Boolean
		{
			return (_childElementArray != null) && (_childElementArray.length > 0);
		}

		public function get isLocalBlock():Boolean
		{
			if (_isLocalBlock == -1)
				_isLocalBlock = ( HtmlParser.isBlockElement(this, false) ) ? 1 : 0;

			return (_isLocalBlock == 1);
		}
		
		public function toHtmlString():String
		{
			var name:String, value:String;

			//Collapse text elements
			if (elementType == Constants.elementTypeTEXT)
			{
				if ( StringUtil.isEmpty(text) )
					return "";
				return HtmlParser.escapeHtml(text);
			}

			//Use style attribute from styleAttributeMap instead (if it is not empty)
			var styleString:String = "";
			for (name in styleAttributeMap)
			{
				value = styleAttributeMap[name];
				if ( (value == null) || (value.length == 0) )
					continue;

				styleString += name + ":" + HtmlParser.escapeHtml(value) + ";";
			}
			var skipStyle:Boolean = (styleString.length > 0);

			var s:String = "<" + tagName;
			for (name in attributeMap)
			{
				value = attributeMap[name];
				if (value == null)
					value = "";

				if ( skipStyle && (name.toLowerCase() == "style") )
					continue;
				
				s += " " + name + "='" + HtmlParser.escapeHtml(value) + "'";
			}

			if (skipStyle)
				s += " style='" + styleString + "'";

			if ( !HtmlParser.closeTagAllowed(this) )
			{
				s += "/>";
				return s;
			}

			s += ">";
			
			if (_childElementArray != null)
			{
				for (var i:int = 0; i < _childElementArray.length; i++)
				{
					var e:Element = _childElementArray[i] as Element;
					if (e != null)
						s += e.toHtmlString();
				}
			}
			else
			{
				if ( !StringUtil.isEmpty(text) )
					s += HtmlParser.escapeHtml(text);
			}

			s += "</" + tagName + ">";

			return s;
		}

		public function addChildElement(e:Element):void
		{
			//Force isBlock to recalculate
			_isBlock = -1;
			
			if (_childElementArray == null)
				_childElementArray = new Array();
			_childElementArray.push(e);

			e.parentElement = this;
		}
	}
}
