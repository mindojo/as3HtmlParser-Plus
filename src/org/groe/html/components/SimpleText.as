/*
 * Copyright 2006-2009 groe.org.	All rights reserved.
 */
package org.groe.html.components
{
	import mx.controls.Text;
	import org.groe.html.Constants;


	public class SimpleText extends Text
	{
		public function SimpleText():void
		{
			super();
			setStyle("leading", 2);
			setStyle("paddingLeft", -2);
			setStyle("paddingRight", -3);
			setStyle("paddingTop", -3);
			setStyle("paddingBottom", -2);
		}
	}
}