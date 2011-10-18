/*
 * Copyright 2006-2009 groe.org.	All rights reserved.
 */
package org.groe.html.components
{
	import flash.display.DisplayObject;
	import flash.text.TextLineMetrics;
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Text;
	import mx.core.Container;
	import mx.core.UIComponent;
	import org.groe.html.*;
	import org.groe.html.util.StringUtil;


	public class HtmlLayoutContainer extends Canvas
	{
		public var hideWhiteUpdating:Boolean = true;
		public var firstLineOffsetX:int = 0;
		public var parentFirstLineHeight:int = 0;
		public var parentFirstLineDescenderHeight:int = 0;
		public var actualFirstLineWidth:int = 0;
		public var actualFirstLineHeight:int = 0;
		public var actualFirstLineDescenderHeight:int = 0;
		public var firstLineY:int = 0;
		public var parentLastLineWidth:int = -1; //Used for horizontal alignment (only set for not left alignment)
		public var firstLineWidth:int = 0;
		public var lastLineWidth:int = 0;
		public var lastLineHeight:int = 0;
		public var lastLineDescenderHeight:int = 0;
		public var lineCount:int = 1;
		protected var isRecursive:Boolean = false;
		protected var backgroundComponent:UIComponent;
		protected var isUpdating:Boolean = false;

		public var brBeginningOfLinePaddingY:int = 2;
		public var pDefaultPaddingTop:int = 0;//15;
		public var pDefaultPaddingBottom:int = 0;//13;
		public var ulDefaultPaddingTop:int = 15;
		public var ulDefaultPaddingBottom:int = 13;
		public var pThenULPadding:int = 2;
		public var pThenPPadding:int = 10;


		public function HtmlLayoutContainer():void
		{
			super();
			horizontalScrollPolicy = "off";
			verticalScrollPolicy = "off";

			//Hide background on this component and draw using backgroundComponent instead
			setStyle("backgroundAlpha", 0);

			backgroundComponent = new UIComponent();
			addChild(backgroundComponent);
			
			setStyle("borderWidth", 1);
			setStyle("paddingTop", 1);
			setStyle("paddingBottom", 1);
		}

		override protected function measure():void
		{
			//This object cannot be measured directly, updateDisplayList will set measuredWidth and measuredHeight
			validateDisplayList();
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if ( isNaN(unscaledWidth) && isNaN(unscaledHeight) )
				return;

			if (isUpdating)
				return;

			isUpdating = true;

			var _x:int, _y:int;
			var _width:int, _height:int;
			var currentLineHeight:int = parentFirstLineHeight;
			var currentLineDescenderHeight:int = parentFirstLineDescenderHeight;
			var lineEndIndexArray:Array = new Array();
			var lineStartYArray:Array = new Array();
			var lineWidthArray:Array = new Array();
			var lineDescenderHeightArray:Array = new Array();
			var objectIndexlineDescenderHeightMap:Object = {};
			var lineHeightArray:Array = new Array();
			var beginningOfLineX:int = 0;
			var hlc:HtmlLayoutContainer;
			var d:DisplayObject;
			var o:UIComponent;
			var isFirstComponent:Boolean = true;
			var borderWidth:int = 0;
			var offsetY:int;
			var w:int, h:int;
			var i:int, j:int;

//For testing
//setStyle("borderColor", "#000000");
//setStyle("borderStyle", "solid");

			var e:Element = FlashHtmlRenderer.getElementFromComponent(this);
			if (e == null)
			{
				Alert.show("Element must exist");
				isUpdating = false;
				return;
			}

			borderWidth = toNumber( getStyle("borderWidth") );

setStyle("borderThickness", borderWidth);

			//Set border width to 0 if borderCollapse is collapse
			if (FlashHtmlRenderer.getEffectiveBorderCollapse(this) == "collapse")
			{
//				setStyle("borderThickness", 0);
//				borderWidth = 0;
			}
			
			//Hide if visible and hideWhiteUpdating
			var wasHidden:Boolean = false;
			if (visible && hideWhiteUpdating)
			{
				visible = false;
				wasHidden = true;
			}

			firstLineWidth = 0;
			lastLineWidth = 0;
			lastLineHeight = 0;
			lastLineDescenderHeight = 0;
			lineCount = 0;

			var _maxWidth:int = -1;
			if ( !isNaN(explicitWidth) )
				_maxWidth = explicitWidth;
			else if ( !isNaN(explicitMaxWidth) )
				_maxWidth = explicitMaxWidth;
 
 			beginningOfLineX = toNumber( getStyle("paddingLeft") );

			//Set starting _x and _y
			_x = beginningOfLineX + firstLineOffsetX;
			_y = (e.isLocalBlock) ? toNumber( getStyle("paddingTop") ) : 0;
			_height = _y + currentLineHeight;

			//See http://www.alanamos.de/articles/firefox_2+3_offset_attributes.html
			if (!isRecursive)
				_y += borderWidth;

//TO DO: set lineSpacing to line-height - fontSize
var lineSpacing:int = 0;
			var lineHeight:int = getStyle("fontSize");

			var childE:Element = null;
			var previousChildE:Element = null;
			for (i = 0; i < numChildren; i++)
			{
				d = getChildAt(i);
				if (d == backgroundComponent)
					continue;
				if ( !(d is UIComponent) )
					continue;
				o = d as UIComponent;

				previousChildE = childE;
				try { childE = FlashHtmlRenderer.getElementFromComponent(o); }
				catch (error:Error) { }

				if (childE == null)
				{
					Alert.show("Element must exist");
					continue;
				}

				var objectMarginLeft:int = toNumber( o.getStyle("marginLeft") );
				var objectMarginTop:int = (childE.isLocalBlock) ? toNumber( o.getStyle("marginTop") ) : 0;
				var objectMarginRight:int = toNumber( o.getStyle("marginRight") );
				var objectMarginBottom:int = (childE.isLocalBlock) ? toNumber( o.getStyle("marginBottom") ) : 0;

//				var hlcObjectMarginTop:int = objectMarginTop;
				
//				//See http://www.alanamos.de/articles/firefox_2+3_offset_attributes.html
//				objectMarginTop += borderWidth;
//				if (!isRecursive)
//					objectMarginTop += borderWidth;
//				if (!isRecursive)
//					_y += borderWidth;

				//If element is a this is a br, move to next line
				if (childE.elementType == Constants.elementTypeBR)
				{
					//If container is at beginning of line, move down an additional amount
					if (_x == beginningOfLineX)
						_height += lineHeight + brBeginningOfLinePaddingY;
					
					if ( (!isFirstComponent) || isRecursive )
					{
						lineEndIndexArray.push(i - 1);
						lineStartYArray.push(_y);
						lineWidthArray.push(_x);
						lineHeightArray.push(currentLineHeight);
						currentLineHeight = 0;
						lineDescenderHeightArray.push(currentLineDescenderHeight);
						currentLineDescenderHeight = 0;
					}

					_height += lineSpacing;

					_x = beginningOfLineX;
					_y = _height;
				}
				//If this is a block element, place object on new line and move to next line
				else if (childE.isBlock)
				{
/*
Alert.show(this + " block i=" + i + ", html=" + childE.toHtmlString() 
	+ ", _x=" + _x + ", _y=" + _y + ", o.width=" + o.width + ", o.height=" + o.height);
*/

					//Move to new line before placing

					//If this element is a p and previous element isn't a p, move down pDefaultPaddingTop
					if (childE.elementType == Constants.elementTypeP)
					{
						if (previousChildE == null)
							_height += pDefaultPaddingTop;
						else if (previousChildE.elementType == Constants.elementTypeP)
							_height += pThenPPadding;
						else if (previousChildE.elementType != Constants.elementTypeUL)
							_height += pDefaultPaddingTop;
					}

					//If this element is a ul and previous element isn't a p, move down ulDefaultPaddingTop
					if (childE.elementType == Constants.elementTypeUL)
					{
						if (previousChildE == null)
							_height += ulDefaultPaddingTop;
						else if (previousChildE.elementType == Constants.elementTypeP)
							_height += pThenULPadding;
						else if (previousChildE.elementType != Constants.elementTypeUL)
							_height += ulDefaultPaddingTop;
					}

					if (!isFirstComponent)
					{
						lineEndIndexArray.push(i - 1);
						lineStartYArray.push(_y);
						lineWidthArray.push(_x);
						lineHeightArray.push(currentLineHeight);
						currentLineHeight = 0;
						lineDescenderHeightArray.push(currentLineDescenderHeight);
						currentLineDescenderHeight = 0;

						_height += lineSpacing;
					}

					_x = (e.isLocalBlock) ? beginningOfLineX : 0;
					_y = _height;


					//Place component
					if (_maxWidth != -1)
						o.explicitMaxWidth = _maxWidth - objectMarginLeft - objectMarginRight;
					o.move(_x + objectMarginLeft, _y + objectMarginTop);

					w = objectMarginLeft + o.width + objectMarginRight;
					h = objectMarginTop + o.height + objectMarginBottom;

					if (o.includeInLayout)
						_height += h;


					//Move to next line after placing

					//If this element is a p, move down pDefaultPaddingBottom
					if (childE.elementType == Constants.elementTypeP)
						_height += pDefaultPaddingBottom;

					//If this element is a ul, move down ulDefaultPaddingBottom
					if (childE.elementType == Constants.elementTypeUL)
						_height += ulDefaultPaddingBottom;

					_height += lineSpacing;

					_x = (e.isLocalBlock) ? beginningOfLineX : 0;
					_y = _height;

					if ( (o.includeInLayout) && (w > _width) )
						_width = w;
					
					lineEndIndexArray.push(i);
					lineStartYArray.push(_y);
					lineWidthArray.push(_x);
					lineHeightArray.push(currentLineHeight);
					currentLineHeight = 0;
					lineDescenderHeightArray.push(currentLineDescenderHeight);
					currentLineDescenderHeight = 0;
				}
				//If this is an html layout container, place object on same line with offset
				else if (o is HtmlLayoutContainer)
				{
					hlc = o as HtmlLayoutContainer;
					hlc.isRecursive = true;
					hlc.firstLineOffsetX = _x + objectMarginLeft;
					hlc.parentFirstLineHeight = currentLineHeight;
					hlc.parentFirstLineDescenderHeight = currentLineDescenderHeight;
					if (_maxWidth != -1)
						hlc.explicitMaxWidth = _maxWidth;

					o.move(beginningOfLineX, _y);

					hlc.invalidateDisplayList();
					hlc.validateDisplayList();

					//If component flowed over current line
					if (hlc.lineCount > 1)
					{
						lineEndIndexArray.push(i);
						lineStartYArray.push( _y + (hlc.actualFirstLineHeight - currentLineHeight) );
						lineWidthArray.push(hlc.actualFirstLineWidth);
						lineHeightArray.push(hlc.actualFirstLineHeight);
						lineDescenderHeightArray.push(hlc.actualFirstLineDescenderHeight);
					}

					//Update x, y, width and height (if necessary)
					if (o.includeInLayout)
					{
						_x = hlc.lastLineWidth + objectMarginRight;
						_y += objectMarginTop + hlc.height - hlc.lastLineHeight;
						if (hlc.width > _width)
							_width = hlc.width;
						_height += objectMarginTop + (hlc.height - currentLineHeight);
					}

					//Update currentLineHeight and currentLineDescenderHeight
					currentLineHeight = hlc.lastLineHeight;
					currentLineDescenderHeight = hlc.lastLineDescenderHeight;
					
					//Update line count
					lineCount += (hlc.lineCount - 1);
				}
				//Otherwise this is a basic inline component
				else
				{
					w = objectMarginLeft + o.width + objectMarginRight;
					h = o.height;

					//If child component will not fit on current line, move to next line
					if (  (_maxWidth != -1) && ( (_x + w) > _maxWidth )  )
					{
						//Start a new line for all but first component
						if ( (!isFirstComponent) || isRecursive )
						{
							lineEndIndexArray.push(i - 1);
							lineStartYArray.push(_y);
							lineWidthArray.push(_x);
							lineHeightArray.push(currentLineHeight);
							currentLineHeight = 0;
							lineDescenderHeightArray.push(currentLineDescenderHeight);
							currentLineDescenderHeight = 0;
						}

						_height += lineSpacing;

						_x = (e.isLocalBlock) ? beginningOfLineX : 0;
						_y = _height;

						if ( (o.includeInLayout) && (w > _width) )
							_width = w;
					}

					w = objectMarginLeft + o.width + objectMarginRight;
					h = objectMarginTop + o.height + objectMarginBottom;

					//If this is a text component and object is a text object
					if ( (childE.elementType == Constants.elementTypeTEXT) && (o is Text) )
					{
						var text:Text = o as Text;
						var metrics:TextLineMetrics = text.getLineMetrics(0);
						//Use this formula rather than metrics.descent because metrics.height is
						//larger than o.height
						var descenderHeight:int = o.height - metrics.ascent;

						//Store object's descender height in map
						objectIndexlineDescenderHeightMap[i] = descenderHeight;

/*
Alert.show( "ascent=" + text.getLineMetrics(0).	ascent
	+ ", descent=" + text.getLineMetrics(0).descent
	+ ", text height=" + text.getLineMetrics(0).height
	+ ", o.width=" + o.width 
	+ ", o.height=" + o.height 
	+ ", html=" + childE.toHtmlString() );
*/

						//Update currentLineDescenderHeight (and currentLineHeight, height) (if necessary)
						if ( o.includeInLayout && (descenderHeight > currentLineDescenderHeight) )
						{
							offsetY = descenderHeight - currentLineDescenderHeight;
							currentLineDescenderHeight = descenderHeight;
							currentLineHeight += offsetY;
							_height += offsetY;
						}
					}

					o.move(_x + objectMarginLeft, _y + objectMarginTop);

					if (o.includeInLayout)
						_x += w;

					if (_x > _width)
						_width = _x;

					if ( (o.includeInLayout) && (h > currentLineHeight) )
					{
						_height += (h - currentLineHeight);
						currentLineHeight = h;
					}
/*
Alert.show( "o.x=" + o.x+ ", o.y=" + o.y 
	+ ", o.width=" + o.width + ", o.height=" + o.height 
	+ ", html=" + childE.toHtmlString() );
*/
				}
	
				isFirstComponent = false;
			}

			lineEndIndexArray.push(numChildren - 1);
			lineStartYArray.push(_y);
			lineWidthArray.push(_x);
			lineHeightArray.push(currentLineHeight);
			lineDescenderHeightArray.push(currentLineDescenderHeight);

/*
Alert.show( "numChildren=" + numChildren + ", lineWidthArray=" + lineWidthArray 
	+ ", lastLineWidth=" + lastLineWidth + ", _width=" + _width + ", html=" + e.toHtmlString()  );
*/
			firstLineWidth = lineWidthArray[0] - firstLineOffsetX;
			lastLineWidth = lineWidthArray[lineWidthArray.length - 1];
			lineCount += lineEndIndexArray.length;
			lastLineHeight = currentLineHeight;
			lastLineDescenderHeight = currentLineDescenderHeight;
/////////////
//height -= currentLineDescenderHeight;

			actualFirstLineWidth = lineWidthArray[0];
			actualFirstLineHeight = lineHeightArray[0];
			actualFirstLineDescenderHeight = lineDescenderHeightArray[0];
			firstLineY = lineStartYArray[0];
/*
Alert.show( "lineEndIndexArray=" + lineEndIndexArray + ", lineWidthArray=" + lineWidthArray + ", lineCount=" + lineCount 
	+ ", lastLineWidth=" + lastLineWidth + ", lastLineHeight=" + lastLineHeight + ", html=" + e.toHtmlString()  );

*/

			//As long as this isn't a non-block type element holding a block element
			if ( !(e.isBlock && !e.isLocalBlock) )
			{
				//Add paddingRight to _width
				_width += toNumber( getStyle("paddingRight") );

				//Add paddingBottom to _height (if block)
				if (e.isLocalBlock)
					_height += toNumber( getStyle("paddingBottom") );
			}

			//If there is an explicit width, use it as width
			if ( !isNaN(explicitWidth) )
				_width = explicitWidth;
			//If this element is a block element, use max width as width (if it exists)
			else if ( (e.isBlock) && (_maxWidth != -1) )
				_width = _maxWidth;

			//Set height if one exists
			if ( !isNaN(explicitHeight) )
				_height = explicitHeight;

			//Search self and anscestor elements for first set horizontal align value
			var horizontalAlign:String = null;
			o = this;
			while (o != null)
			{
				try { childE = o["data"] as Element; }
				catch (error:Error) { childE = null; }

				if (childE != null)
				{
					if (childE.horizontalAlignSetLocally)
					{
						horizontalAlign = o.getStyle("htmlHorizontalAlign");
						//Ignore left
						if (horizontalAlign == "left")
							horizontalAlign = null;
						break;
					}
				}

				o = o.parent as UIComponent;
			}

			//Handle horizontal and vertical alignment
			for (i = 0; i < lineEndIndexArray.length; i++)
			{
				var lineWidth:int, effectiveWidth:int, offsetX:int;

				var processHorizontalAlign:Boolean;
				if (e.isBlock)
					processHorizontalAlign = true;
				else
				{
					//If this is a recursive call, skip first line this is handled by parent
					processHorizontalAlign = !isRecursive || (i != 0);
				}
				
				//Set horizontal offset for objects in line
				if (!StringUtil.isEmpty(horizontalAlign) && processHorizontalAlign)
				{
					effectiveWidth = (_maxWidth != -1) ? _maxWidth : _width;
					lineWidth = lineWidthArray[i];

					var horizontalAlignType:int = 0;
					if (horizontalAlign == "center")
						horizontalAlignType = 1;
					else if (horizontalAlign == "right")
						horizontalAlignType = 2;

					switch (horizontalAlignType)
					{
						//Centered
						case 1:
							offsetX = (effectiveWidth - lineWidth) / 2;
/*
Alert.show("horizontalAlignType=" + horizontalAlignType
	+ ", html=" + e.toHtmlString()
	+ ", lineWidth=" + lineWidth
	+ ", effectiveWidth=" + effectiveWidth
);
*/
							break;
						//Right
						case 2:
							offsetX = (effectiveWidth - lineWidth);
							break;
						default:
							offsetX = 0;
							break;
					}
				}

				//Loop over elements in row
				var lineStartIndex:int = (i != 0) ? lineEndIndexArray[i - 1] + 1 : 0;
				var lineEndIndex:int = lineEndIndexArray[i];
				for (j = lineStartIndex; j <= lineEndIndex; j++)
				{
					d = getChildAt(j);
					if (d == backgroundComponent)
						continue;
					if ( !(d is UIComponent) )
						continue;
					o = d as UIComponent;

					try { childE = FlashHtmlRenderer.getElementFromComponent(o); }
					catch (error:Error) { childE = null; }
					
					var newX:Number = o.x;
					var newY:Number = o.y;
					var performMove:Boolean = false;
					
					if (processHorizontalAlign)
					{
						if (o is HtmlLayoutContainer)
						{
							hlc = o as HtmlLayoutContainer;
							hlc.firstLineOffsetX = hlc.firstLineOffsetX + offsetX;

							//If this child component is multi-line and this component has another line, 
							//set child's parentLastLineWidth
							if (  (hlc.lineCount > 1) && ( i < (lineWidthArray.length - 1) )  )
								hlc.parentLastLineWidth = lineWidthArray[i + 1];

							//Force redraw
							hlc.invalidateDisplayList();
						}
						else
						{
							newX = o.x + offsetX;
							performMove = true;
						}

						//Update width if necessary
						if ( (o.includeInLayout) && (o.width > _width) )
							_width = o.width;
					}

					//Process vertical alignment
					//Only vertically align inline elements
					if (!childE.isLocalBlock)
					{
						//Only update "first heights" on HtmlLayoutContainers, these objects are
						//responsible for vertically aligning themselves
						if (o is HtmlLayoutContainer)
						{
							hlc = o as HtmlLayoutContainer;

							var redraw:Boolean = false;
							if (hlc.parentFirstLineHeight != lineHeightArray[i])
							{
/*
Alert.show("Redraw: hlc.parentFirstLineHeight=" + hlc.parentFirstLineHeight
	+ ", lineHeightArray[i]=" + lineHeightArray[i]);
*/
								hlc.parentFirstLineHeight = lineHeightArray[i];
								redraw = true;
							}
							if (hlc.parentFirstLineDescenderHeight != lineDescenderHeightArray[i])
							{
/*
Alert.show("Redraw: hlc.parentFirstLineDescenderHeight=" + hlc.parentFirstLineDescenderHeight
	+ ", lineDescenderHeightArray[i]=" + lineDescenderHeightArray[i]);
*/
								hlc.parentFirstLineDescenderHeight = lineDescenderHeightArray[i];
								redraw = true;
							}

							if (redraw)
								hlc.invalidateDisplayList();
						}
						else
						{
							var a:Array = FlashHtmlRenderer.getEffectiveVerticalAlign(o);
							if (a != null)
							{
								switch (a[1])
								{
									case Constants.verticalAlignTypeBaseline:
										//If this is text, align text's baseline with line's baseline
										//(move down all but line's descender minus object's descender)
										if (childE.elementType == Constants.elementTypeTEXT)
										{
											var descenderDelta:int = 
												objectIndexlineDescenderHeightMap[j] - lineDescenderHeightArray[i];

											newY = o.y + lineHeightArray[i] - o.height - descenderDelta;
//newY = o.y + lineHeightArray[i] - o.height - lineDescenderHeightArray[i];

//newY = o.y;

/*
Alert.show("i=" + i
	+ ", o.y=" + o.y
	+ ", lineHeightArray[i]=" + lineHeightArray[i]
	+ ", o.height=" + o.height
	+ ", (newY - oldY)=" + (newY - o.y)
	+ ", lineDescenderHeightArray[i]=" + lineDescenderHeightArray[i]
	+ ", descenderDelta=" + descenderDelta
	+ ", objectIndexlineDescenderHeightMap[j]=" + objectIndexlineDescenderHeightMap[j]
	+ ", html=" + childE.toHtmlString() );
*/
										}
										else
											newY = o.y + lineHeightArray[i] - o.height - lineDescenderHeightArray[i];

/*
Alert.show("lineHeightArray[i]=" + lineHeightArray[i]
	+ ", o.height=" + o.height
	+ ", (newY - oldY)=" + (newY - o.y)
	+ ", lineDescenderHeightArray[i]=" + lineDescenderHeightArray[i]
	+ ", objectIndexlineDescenderHeightMap[j]=" + objectIndexlineDescenderHeightMap[j]
	+ ", html=" + childE.toHtmlString() );
*/

										performMove = true;
										break;
									case Constants.verticalAlignTypeTop:
										//Nothing to do
										break;
									default:
//Alert.show("vertical align other");
										break;
								}
							}
						}
					}
					
					if (performMove)
						o.move(newX, newY);
				}
			}

			if (getStyle("backgroundColor") != undefined)
			{
				backgroundComponent.move(0, 0);
				backgroundComponent.setActualSize(_width, _height);

				backgroundComponent.graphics.clear();

				//Fill entire area for block elements
				if (e.isBlock)
				{
					backgroundComponent.graphics.beginFill( getStyle("backgroundColor") );
					backgroundComponent.graphics.drawRect(0, 0, 
						backgroundComponent.width, backgroundComponent.height);
					backgroundComponent.graphics.endFill();
				}
				//Fill lines for inline elements
				else
				{
					for (i = 0; i < lineWidthArray.length; i++)
					{
						var backgroundX:int = (i == 0) ? firstLineOffsetX : 0;
						backgroundComponent.graphics.beginFill( getStyle("backgroundColor") );
						backgroundComponent.graphics.drawRect(backgroundX, lineStartYArray[i], 
							lineWidthArray[i] - backgroundX, lineHeightArray[i]);
						backgroundComponent.graphics.endFill();
					}
				}
			}

//TO DO: keep last lines of text from getting cut off
//setStyle("paddingBottom", 3);
//setStyle("marginBottom", -3);
//Alert.show( "numChildren=" + numChildren + ", lineWidthArray=" + lineWidthArray 
//	+ ", lastLineWidth=" + lastLineWidth + ", _width=" + _width + ", html=" + e.toHtmlString()  );

//_height += 2;

			setActualSize(_width, _height);
			measuredWidth = _width;
			measuredHeight = _height;

			//Show if was hidden
			if (wasHidden)
				visible = true;

			isUpdating = false;
			
//Alert.show( "inside: width=" + width + ", measuredWidth=" + measuredWidth + ", explicitWidth=" + explicitWidth + ", html=" + e.toHtmlString() );
//Alert.show( "_x=" + _x + ", firstLineOffsetX=" + firstLineOffsetX + ", beginningOfLineX=" + beginningOfLineX + ", html=" + e.toHtmlString() );
		}
		
		protected static function toNumber(o:Object):Number
		{
			if (o != null)
			{
				if (o is Number)
					return (o as Number);
				try { return parseInt( o.toString() ); }
				catch (e:Error) { }
			}
			return 0;
		}
	}
}
