/*
 * Copyright 2006-2009 groe.org.	All rights reserved.
 */
package org.groe.html.components
{
	import flash.display.DisplayObject;
	import mx.containers.GridItem;
	import mx.core.UIComponent;
	import org.groe.html.FlashHtmlRenderer;
	import org.groe.html.util.StringUtil;
	import org.groe.html.Constants;
	import org.groe.html.Element;

//For testing
//import mx.controls.Alert;


	public class HtmlLayoutGridItem extends GridItem
	{
		protected var childObject:HtmlLayoutContainer = null;
		protected var backgroundComponent:UIComponent;
		
		public var tdDefaultPaddingRight:Number = -0.5;
		public var tdDefaultPaddingTop:int = 0;
		public var tdDefaultPaddingBottom:int = 1;


		public function HtmlLayoutGridItem():void
		{
			super();

			backgroundComponent = new UIComponent();
			backgroundComponent.includeInLayout = false;
			super.addChildAt(backgroundComponent, 0);

			childObject = new HtmlLayoutContainer();
			super.addChildAt(childObject, 1);

			childObject.setStyle("paddingRight", tdDefaultPaddingRight);
			childObject.setStyle("paddingTop", tdDefaultPaddingTop);
			childObject.setStyle("paddingBottom", tdDefaultPaddingBottom);

			//Hide background on this component and draw using backgroundComponent instead
			super.setStyle("backgroundAlpha", 0);
			super.setStyle("borderThickness", 0);
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
			if (styleProp == "backgroundColor")
				return super.getStyle(styleProp);
			else if (styleProp == "horizontalAlign")
				return super.getStyle(styleProp);
			else if (styleProp.substr(0, 6) == "border")
				return super.getStyle(styleProp);

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
			if (styleProp == "backgroundColor")
			{
				super.setStyle("backgroundAlpha", 1);
				super.setStyle(styleProp, newValue);
				return;
			}
			else if (styleProp == "horizontalAlign")
			{
				super.setStyle(styleProp, newValue);
				return;
			}
			else if (styleProp.substr(0, 6) == "border")
			{
				super.setStyle(styleProp, newValue);
				return;
			}

			return childObject.setStyle(styleProp, newValue);
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			//Set border width to 0 if borderCollapse is collapse
//			if (FlashHtmlRenderer.getEffectiveBorderCollapse(this) == "collapse")
//				setStyle("borderThickness", 0)

			var childE:Element;
			var value:String;
			var o:UIComponent;

			//Get align from self, tr or table
			o = this;
			while (o != null)
			{
				try { childE = o["data"] as Element; }
				catch (error:Error) { childE = null; }
				if (childE != null)
				{
					if ( (childE.elementType == Constants.elementTypeTD) ||
						 (childE.elementType == Constants.elementTypeTR) ||
						 (childE.elementType == Constants.elementTypeTABLE) )
					{
						value = childE.attributeMap["align"];
						if ( !StringUtil.isEmpty(value) )
						{
							value = value.toLocaleLowerCase();
							if (value == "justify")
								value = "center"

							setStyle("horizontalAlign", value);
							break;
						}
					}
				}
				
				o = o.parent as UIComponent;
			}

setStyle( "borderThickness", getStyle("borderWidth") );

/*
			//Determine if this component should draw its border (get border-collapse from self, tr or table)
			o = this;
			while (o != null)
			{
				try { childE = o["data"] as Element; }
				catch (error:Error) { childE = null; }
				if (childE != null)
				{
					if ( (childE.elementType == Constants.elementTypeTD) ||
						 (childE.elementType == Constants.elementTypeTR) ||
						 (childE.elementType == Constants.elementTypeTABLE) )
					{
//Alert.show( "html=" + childE.toHtmlString() );

						value = childE.styleAttributeMap["border-collapse"];
						if ( !StringUtil.isEmpty(value) )
						{
//Alert.show("value=" + value);
							value = value.toLocaleLowerCase();
							if (value == "collapse")
							{
//Alert.show( "html=" + childE.toHtmlString() );
								//childObject.setStyle("borderWidth", 0);
								setStyle("borderThickness", 0);
							}
							break;
						}
					}
				}
				
				o = o.parent as UIComponent;
			}
*/

/*
			//If this object doesn't have an explicit horizontalAlign
			if (  !StringUtil.isEmpty( super.getStyle("horizontalAlign") )  )
			{
				//If childObject contains a single child element, and it is block,
				//use its horizontalAlign
				try { childE = childObject["data"] as Element; }
				catch (error:Error) { childE = null; }
				if (childE != null)
				{
					if ( (childE.childElementArray != null) && (childE.childElementArray.length > 0) )
					{
						childE = childE.childElementArray[0];
						if (childE.isBlock)
						{
							value = childE.styleAttributeMap["horizontalAlign"];
							if ( !StringUtil.isEmpty(value) )
							{
								super.setStyle("horizontalAlign", value)
							}
						}
					}
				}
			}
*/

			super.updateDisplayList(unscaledWidth, unscaledHeight);

			if ( isNaN(unscaledWidth) && isNaN(unscaledHeight) )
				return;

			if (getStyle("backgroundColor") != undefined)
			{
				backgroundComponent.move(0, 0);
				backgroundComponent.setActualSize(width, height);

				backgroundComponent.graphics.clear();
				backgroundComponent.graphics.beginFill( getStyle("backgroundColor") );
				backgroundComponent.graphics.drawRect(0, 0, 
					backgroundComponent.width, backgroundComponent.height);
				backgroundComponent.graphics.endFill();
			}
		}
	}
}
