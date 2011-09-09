/*
 * Copyright 2006-2009 groe.org.	All rights reserved.
 */
package org.groe.html.components
{
	import flash.display.DisplayObject;
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.core.FlexShape;

import mx.controls.Text;

//For testing
import mx.controls.Alert;


	public class ListItem extends Canvas
	{
		protected var childObject:HtmlLayoutContainer = null;
		protected var bulletComponent:UIComponent;
		protected var type:String;

		
		public var typeDisc:String = "disc";

		public var defaultType:String = typeDisc;
		public var defaultDiscSize:int = 3;
		
		public var bulletSpacerX:int = 0;
		public var childSpacerX:int = 8;


		public function ListItem():void
		{
			super();
			horizontalScrollPolicy = "off";
			verticalScrollPolicy = "off";
			
			bulletComponent = new UIComponent();
			super.addChildAt(bulletComponent, 0);

			childObject = new HtmlLayoutContainer();
			super.addChildAt(childObject, 1);

			try
			{
				setType(defaultType);
			}
			catch (error:Error)
			{
				Alert.show("error=" + error);
			}
		}

		override public function get data():Object
		{
			return childObject.data;
		}
		override public function set data(value:Object):void
		{
			childObject.data = value;
		}

		override public function addChild(child:DisplayObject):DisplayObject
		{
			return childObject.addChild(child);
		}

		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			return childObject.addChildAt(child, index);
		}
		
		override public function contains(child:DisplayObject):Boolean
		{
			return childObject.contains(child);
		}

		override public function getStyle(styleProp:String):*
		{
			if (styleProp == "list-style-type")
				return type;

			return childObject.getStyle(styleProp);
		}

		override public function removeAllChildren():void
		{
			return childObject.removeAllChildren();
		}

		override public function removeChild(child:DisplayObject):DisplayObject
		{
			return childObject.removeChild(child);
		}

		override public function removeChildAt(index:int):DisplayObject
		{
			return childObject.removeChildAt(index);
		}

		override public function setStyle(styleProp:String, newValue:*):void
		{
			if (styleProp == "list-style-type")
			{
				setType(type);
				return;
			}
			
			return childObject.setStyle(styleProp, newValue);
		}

		public function getType():String
		{
			return type;
		}
		
		public function setType(type:String):void
		{
			if (this.type == type)
				return;

			this.type = type;

			while (bulletComponent.numChildren > 0)
				bulletComponent.removeChildAt(0);

			switch (type)
			{
				case typeDisc:
					var disc:FlexShape = new FlexShape();
					disc.graphics.beginFill(0x000000);
					disc.graphics.drawCircle(defaultDiscSize, defaultDiscSize, defaultDiscSize);
					disc.graphics.endFill();
					bulletComponent.addChild(disc);
					bulletComponent.width = disc.width
					bulletComponent.height = disc.height;
					break;
				default:
					bulletComponent.setActualSize(0, 0);
					break;
			}
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		
			if ( isNaN(unscaledWidth) && isNaN(unscaledHeight) )
				return;

			//Force bullet to render to use its dimensions
			bulletComponent.validateDisplayList();

			var deltaX:int = 0;
			if (bulletComponent.width > 0)
				deltaX = bulletSpacerX + bulletComponent.width + childSpacerX;

//Alert.show("bulletComponent.width=" + bulletComponent.width);

			//Determine max width of child container
			var _maxWidth:int = -1;
			if ( !isNaN(explicitWidth) )
				_maxWidth = explicitWidth - deltaX - 20; //20px fudge factor for offset;
			else if ( !isNaN(explicitMaxWidth) )
				_maxWidth = explicitMaxWidth - deltaX - 20; //20px fudge factor for offset;

			//Render child container with proper max width
			childObject.explicitMaxWidth = _maxWidth;
			childObject.invalidateDisplayList();
			childObject.validateDisplayList();

			//Center decorator vertically with first line of container
			var bulletY:int;
			if (childObject.actualFirstLineHeight > 0)
			{
				//Align with baseline of text
				var ascenderHeight:int = childObject.actualFirstLineHeight - childObject.firstLineY;
				bulletY = (ascenderHeight - bulletComponent.height) / 2;
				
				childObject.move(deltaX, -childObject.firstLineY);
			}
			else
				bulletY = 0;

/*
Alert.show("childObject.actualFirstLineHeight=" + childObject.actualFirstLineHeight
	+ ", childObject.actualFirstLineDescenderHeight=" + childObject.actualFirstLineDescenderHeight
	+ ", childObject.firstLineY=" + childObject.firstLineY
	+ ", childObject.y=" + childObject.y
	+ ", childObject.height=" + childObject.height
	+ ", bulletComponent.height=" + bulletComponent.height
	+ ", bulletY=" + bulletY);
*/

			if (bulletComponent.width > 0)
				bulletComponent.move(bulletSpacerX, bulletY);
		}
	}
}
