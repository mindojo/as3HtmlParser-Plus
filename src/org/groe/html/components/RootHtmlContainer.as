/*
 * Copyright 2006-2009 groe.org.	All rights reserved.
 */
package org.groe.html.components
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.containers.Box;
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.core.UIComponent;

	public class RootHtmlContainer extends Box
	{
		public function RootHtmlContainer():void
		{
			super();

//For testing
//setStyle("borderColor", "#000000");
//setStyle("borderStyle", "solid");

			//Default to width of parent
			percentWidth = 100;

			addEventListener(Event.ADDED_TO_STAGE, function(event:Event):void
				{
					var self:UIComponent = event.currentTarget as UIComponent;
					if (self.parent == null)
						return;

					if ( !isNaN(self.percentWidth) )
					{
						self.width = self.parent.width * self.percentWidth / 100;
						for (var i:int = 0; i < numChildren; i++)
						{
							var o:UIComponent = getChildAt(i) as UIComponent;
							if (o == null)
								continue;
							o.maxWidth = self.width;
						}
					}
				});

			/*setStyle("color", "#444444");
			setStyle("fontFamily", "Arial,Verdana,sans-serif");
			setStyle("fontSize", 16);
			setStyle("leading", 0);
			setStyle("paddingTop", 0);
			setStyle("lineHeight", 18);*/
			
			buttonMode = true;
			useHandCursor = true;
			
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if ( isNaN(unscaledWidth) && isNaN(unscaledHeight) )
				return;
			

			if (numChildren > 0)
			{
				var d:DisplayObject = getChildAt(0);
				setActualSize(updateWidth(), d.height);

//				height = d.height;
//Alert.show("d.height=" + d.height);
//Alert.show("d.measuredHeight=" + (d as UIComponent).measuredHeight);
//Alert.show("self.height=" + (d as UIComponent).measuredHeight);
			}

		}
		
		//re-using code above to adjust our wdith and the width of our children dynbamically
		private function updateWidth():Number {
			
			if (this.parent == null) {
				return 0;
			}
			
			//mangling this code but I only need the use case right now to take
			//our parents width ie. percentWidth = 100
			var desiredWidth:Number = parent.width;
			
			for (var i:int = 0; i < numChildren; i++)
			{
				var o:UIComponent = getChildAt(i) as UIComponent;
				if (o == null)
					continue;
				o.maxWidth = desiredWidth;
				o.setActualSize(desiredWidth, o.height);
			}
			
			//trace ("desiredWidth", desiredWidth);
			return desiredWidth;
			
		}
		
		
	}
}
