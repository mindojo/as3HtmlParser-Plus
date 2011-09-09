/*
 * Copyright 2006-2009 groe.org.	All rights reserved.
 */
package org.groe.html
{
	import mx.core.UIComponent;


	public class ObjectMapFlashHtmlRenderer extends FlashHtmlRenderer
	{
		protected var m:Object = {};

		public function ObjectMapFlashHtmlRenderer():void
		{
		}

		public static function render(e:Element):UIComponent
		{
			return new ObjectMapFlashHtmlRenderer().renderElement(e);
		}

		public function getBaseObjectForElement(elementType:int):*
		{
			return m[elementType];
		}

		public function setBaseObjectForElement(elementType:int, value:*):void
		{
			m[elementType] = value;
		}

		public function removeBaseObjectForElement(elementType:int):void
		{
			delete m[elementType];
		}

		override public function createBaseObjectForElement(e:Element):UIComponent
		{
			if ( !(e.elementType in m) )
				return super.createBaseObjectForElement(e);
			
			var o:Object, o2:Object, o3:Object;
			
			o = m[e.elementType];
			if (o is Class)
			{
				o2 = new o();
				if (o2 is UIComponent)
					return (o2 as UIComponent);
			}
			else if (o is Function)
			{
				o2 = o();
				if (o2 is UIComponent)
					return (o2 as UIComponent);
				else if (o2 is Class)
				{
					o3 = new o2();
					if (o3 is UIComponent)
						return (o3 as UIComponent);
				}
			}
			else if (o is UIComponent)
				return (o as UIComponent);

			return null;
		}
	}
}
