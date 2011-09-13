/*
 * Copyright 2006-2009 groe.org.	All rights reserved.
 */
package org.groe.html
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	import mx.containers.Grid;
	import mx.containers.GridItem;
	import mx.containers.GridRow;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.Image;
	import mx.controls.LinkButton;
	import mx.controls.SWFLoader;
	import mx.controls.Text;
	import mx.core.Container;
	import mx.core.UIComponent;
	
	import org.groe.html.components.*;
	import org.groe.html.events.*;
	import org.groe.html.util.StringUtil;

//For testing
//import mx.controls.Alert;


	public class FlashHtmlRenderer
	{
		public static const blockQuoteDefaultPaddingLeft:int = 30;
		public static const blockQuoteDefaultPaddingTop:int = 15;
		public static const blockQuoteDefaultPaddingBottom:int = 15;
		public static const cellspacingDefault:int = 2;
		public static const textSpaceOffsetX:int = -2;
		public static const defaultHorizontalAlign:int = Constants.horizontalAlignTypeLeft;
		public static const defaultVerticalAlign:int = Constants.verticalAlignTypeBaseline;


		public function FlashHtmlRenderer():void
		{
		}

		public static function render(e:Element):UIComponent
		{
			return new FlashHtmlRenderer().renderElement(e);
		}

		public function renderElement(e:Element):UIComponent
		{
			var rootComponent:UIComponent = createRootObject();
			rootComponent.addChild( renderHelper(e, null, rootComponent) );
			return rootComponent;
		}

		public static function renderIntoElement(e:Element, rootComponent:UIComponent):void
		{
			rootComponent.addChild( new FlashHtmlRenderer().renderHelper(e, null, rootComponent) );
		}
		
		public function renderHelper(e:Element, parentComponent:UIComponent, 
			rootComponent:UIComponent):UIComponent
		{
			var childO:UIComponent;
			var childE:Element, parentE:Element;
			var tableE:Element, rowE:Element = null;
			var name:String;
			var value:String, value2:String;
			var intValue:int, intValue2:int;
			var length:int;
			var a:Array;
			var i:int;						

			// If no component exists for this element type, return null
			var o:UIComponent = createBaseObjectForElement(e);
			
			//Alert.show('renderHelper: ' + e._tagName + " " + o);
			
			if (o == null)
				return null;						
			
			// If element cannot be set on this component, return null
			if ( !setElementOnComponent(o, e) )
			{
				return null;
			}

			if (o != null)
				setStandardAttributes(o, e);

			switch (e.elementType)
			{
				case Constants.elementTypeDIV:
				case Constants.elementTypeP:
					setDimensions(o, e);

					//Handle align attribute
					value = e.attributeMap["align"];
					if ( !StringUtil.isEmpty(value) )
					{
						value = value.toLocaleLowerCase();
						if (value == "justify")
							value = "center"

						if (value in Constants.horizontalAlignStringTypeMap)
						{
							o.setStyle("htmlHorizontalAlign", value);
							e.horizontalAlignSetLocally = true;
						}
					}

					break;

				case Constants.elementTypeBLOCKQUOTE:
					//Handle cite attribute
					value = e.attributeMap["cite"];
					if ( !StringUtil.isEmpty(value) )
					{
//TO DO
					}

					o.setStyle("paddingLeft", blockQuoteDefaultPaddingLeft);
					o.setStyle("paddingTop", blockQuoteDefaultPaddingTop);
					o.setStyle("paddingBottom", blockQuoteDefaultPaddingBottom);

					break;

				case Constants.elementTypeBASEFONT:
				case Constants.elementTypeFONT:
					//Handle color attribute
					value = e.attributeMap["color"];
					if ( !StringUtil.isEmpty(value) )
						o.setStyle( "color", HtmlParser.parseColorString(value) );

					//Handle face attribute
					value = e.attributeMap["face"];
					if ( !StringUtil.isEmpty(value) )
					{
						//Setting font family style does not handle multile font values
						a = value.split(",");
						if (a.length > 0)
							o.setStyle( "fontFamily", StringUtil.trim(a[0]) );
					}

					//Handle size attribute
					value = e.attributeMap["size"];
					if ( !StringUtil.isEmpty(value) )
					{
						try { intValue = parseInt(value); }
						catch (e:Error) { intValue = 0; }
						
						if (intValue != 0)
						{
							if (intValue < 0)
								intValue = 1;
							else if (intValue > 7)
								intValue = 7;
								
							switch (intValue)
							{
								case 1:
									intValue = 10;
									break;
								case 2:
									intValue = 12;
									break;
								case 3:
									intValue = 14;
									break;
								case 4:
									intValue = 16;
									break;
								case 5:
									intValue = 24;
									break;
								case 6:
									intValue = 34;
									break;
								case 7:
									intValue = 48;
									break;
							}
							o.setStyle("fontSize", intValue);
						}
					}

					value = e.attributeMap["color"];
					if ( !StringUtil.isEmpty(value) )
						o.setStyle( "color", HtmlParser.parseColorString(value) );

					value = e.attributeMap["class"];
					if ( !StringUtil.isEmpty(value) )
					{
						//Setting font family style does not handle multile font values
						a = value.split(",");
						if (a.length > 0)
							o.styleName = StringUtil.trim(a[0]);
					}

					break;

				case Constants.elementTypeIMG:
					//Resize image after it loads and fire "image loaded" event on root component
					o.addEventListener(Event.COMPLETE, function(event:Event):void
						{
							var component:UIComponent = event.currentTarget as UIComponent;
							var el:Element = getElementFromComponent(component);
							setDimensions(component, el, true);
							rootComponent.dispatchEvent( new ObjectLoadedEvent(component) );
						});

					//Finally set source to start loading
					if (o is Image)
						(o as Image).source = e.attributeMap["src"];

					break;

				case Constants.elementTypeSPAN:
					setDimensions(o, e);
					break;

				case Constants.elementTypeA:
					//Trim href if it exists
					value = e.attributeMap["href"];
					if (value != null)
						value = StringUtil.trim(value);
					e.attributeMap["href"] = value;
					if ( !StringUtil.isEmpty(value) )
					{
						o.setStyle("textDecoration", "underline");
						o.useHandCursor = true;
						o.buttonMode = true;
						o.mouseChildren = false;
					}
					
					//Trim target if it exists
					value = e.attributeMap["target"];
					if (value != null)
						value = StringUtil.trim(value);
					if ( StringUtil.isEmpty(value) )
						value = "_self";
					e.attributeMap["target"] = value;

					o.addEventListener(MouseEvent.CLICK, function(event:Event):void
						{
							var component:UIComponent = event.currentTarget as UIComponent;
							var el:Element = getElementFromComponent(component);
//For testing
//Alert.show("click: event.currentTarget=" + event.currentTarget + ", component=" + component + ", el=" + el);
							var href:String = e.attributeMap["href"];
							if ( !StringUtil.isEmpty(href) )
								flash.net.navigateToURL(new URLRequest(href), e.attributeMap["target"]);
						});
					break;

				case Constants.elementTypeUL:
					//o.setStyle("marginLeft", 20);
					o.setStyle("paddingLeft", 20);
					break;

				case Constants.elementTypeLI:
					break;

				case Constants.elementTypeABBR:
				case Constants.elementTypeACRONYM:
					o.setStyle("textDecoration", "underline");
//TO DO: make underline dotted
					break;
				
				case Constants.elementTypeB:
				case Constants.elementTypeSTRONG:
					o.setStyle("fontWeight", "bold");
					break;

				case Constants.elementTypeBR:
					break;

				case Constants.elementTypeBUTTON:
//TO DO: currently disabled
					value = e.attributeMap["disabled"];
					o.enabled = (value == null);

					break;

/*
				case Constants.elementTypeCAPTION:
//TO DO
					break;
*/

				case Constants.elementTypeCENTER:
					o.setStyle("htmlHorizontalAlign", "center");
					e.horizontalAlignSetLocally = true;
					break;

				case Constants.elementTypeADDRESS:
				case Constants.elementTypeCITE:
				case Constants.elementTypeDFN:
				case Constants.elementTypeEM:
				case Constants.elementTypeI:
				case Constants.elementTypeVAR:
					o.setStyle("fontStyle", "italic");
					break;

				case Constants.elementTypeINS:
				case Constants.elementTypeU:
					o.setStyle("textDecoration", "underline");
					break;

				case Constants.elementTypeDEL:
				case Constants.elementTypeS:
				case Constants.elementTypeSTRIKE:
//TO DO: strike not underline
					o.setStyle("textDecoration", "underline");
					break;

				case Constants.elementTypeCODE:
				case Constants.elementTypeKBD:
				case Constants.elementTypeSAMP:
				case Constants.elementTypeTT:
					o.setStyle("textFamily", "courier");
					break;

				case Constants.elementTypeQ:
					//Add " text to front of child list
					childE = new Element();
					childE.tagName = "text";
					childE.text = "\"";
					renderTextElementSimple(childE, o);
					break;

				case Constants.elementTypeH1:
					o.setStyle("paddingTop", 20);
					o.setStyle("fontSize", 30);
					o.setStyle("fontWeight", "bold");
					o.setStyle("paddingBottom", 20);
					break;
				case Constants.elementTypeH2:
					o.setStyle("paddingTop", 20);
					o.setStyle("fontSize", 22);
					o.setStyle("fontWeight", "bold");
					o.setStyle("paddingBottom", 20);
					break;
				case Constants.elementTypeH3:
					o.setStyle("paddingTop", 20);
					o.setStyle("fontSize", 18);
					o.setStyle("fontWeight", "bold");
					o.setStyle("paddingBottom", 20);
					break;
				case Constants.elementTypeH4:
					o.setStyle("paddingTop", 20);
					o.setStyle("fontSize", 16);
					o.setStyle("fontWeight", "bold");
					o.setStyle("paddingBottom", 20);
					break;
				case Constants.elementTypeH5:
					o.setStyle("paddingTop", 20);
					o.setStyle("fontSize", 14);
					o.setStyle("fontWeight", "bold");
					o.setStyle("paddingBottom", 20);
					break;
				case Constants.elementTypeH6:
					o.setStyle("paddingTop", 20);
					o.setStyle("fontSize", 12);
					o.setStyle("fontWeight", "bold");
					o.setStyle("paddingBottom", 20);
					break;

				case Constants.elementTypeSMALL:
					intValue = o.getStyle("fontSize");
					if ( (intValue == 0) && (parentComponent != null) )
						intValue = parentComponent.getStyle("fontSize");
					if (intValue == 0)
						intValue = 16;

					if (intValue > 3)
						o.setStyle("fontSize", intValue - 3);
					break;

				case Constants.elementTypeBIG:
					intValue = o.getStyle("fontSize");
					if ( (intValue == 0) && (parentComponent != null) )
						intValue = parentComponent.getStyle("fontSize");
					if (intValue == 0)
						intValue = 16;

					o.setStyle("fontSize", intValue + 2);
					break;

				case Constants.elementTypeTABLE:
					setDimensions(o, e, true);

					//Handle align attribute
					value = e.attributeMap["align"];
					if ( !StringUtil.isEmpty(value) )
					{
						value = value.toLocaleLowerCase();
						if (value == "justify")
							value = "center"

						if (value in Constants.horizontalAlignStringTypeMap)
						{
							o.setStyle("horizontalAlign", value);
						}
					}

//TO DO: handle border

					//Handle color attribute
					value = e.attributeMap["bgcolor"];
					if ( !StringUtil.isEmpty(value) )
						o.setStyle( "backgroundColor", HtmlParser.parseColorString(value) );

					//Handle cellspacing attribute
					value = e.attributeMap["cellspacing"];
					if ( !StringUtil.isEmpty(value) )
					{
						try { intValue = parseInt(value); }
						catch (e:Error) { intValue = cellspacingDefault; }
					}
					else
						intValue = cellspacingDefault;
					o.setStyle("horizontalGap", intValue);
					o.setStyle("verticalGap", intValue);

/*
					//Handle cellpadding attribute
					value = e.attributeMap["cellpadding"];
					if ( !StringUtil.isEmpty(value) )
					{
						try { intValue = parseInt(value); }
						catch (e:Error) { intValue = 2; }
					}
					else
						intValue = 2;
*/

					break;

				case Constants.elementTypeTR:
					setDimensions(o, e, true);

					//Handle align attribute
					value = e.attributeMap["align"];
					if ( !StringUtil.isEmpty(value) )
					{
						value = value.toLocaleLowerCase();
						if (value == "justify")
							value = "center"

						if (value in Constants.horizontalAlignStringTypeMap)
						{
							o.setStyle("horizontalAlign", value);
						}
					}

					//Handle valign attribute
					value = e.attributeMap["valign"];
					if ( !StringUtil.isEmpty(value) )
					{
						a = HtmlParser.parseVerticalAlignString(value);
						if (a != null)
						{
							o.setStyle("htmlVerticalAlignScalor", a[0]);
							o.setStyle("htmlVerticalAlignType", a[1]);
						}
					}

					break;

				case Constants.elementTypeTH:
					o.setStyle("fontWeight", "bold");
					o.setStyle("horizontalAlign", "center");
				case Constants.elementTypeTD:
					setDimensions(o, e, true);

					if (o is GridItem)
					{
						var gi:GridItem = o as GridItem;

						//Handle rowspan attribute
						value = e.attributeMap["rowspan"];
						if ( !StringUtil.isEmpty(value) )
						{
							try { intValue = parseInt(value); }
							catch (e:Error) { intValue = 1; }
							if (intValue > 1)
								gi.rowSpan = intValue;
						}

						//Handle colspan attribute
						value = e.attributeMap["colspan"];
						if ( !StringUtil.isEmpty(value) )
						{
							try { intValue = parseInt(value); }
							catch (e:Error) { intValue = 1; }
							if (intValue > 1)
								gi.colSpan = intValue;
						}
					}

					value = e.attributeMap["align"];
					if ( !StringUtil.isEmpty(value) )
					{
						value = value.toLocaleLowerCase();
						if (value == "justify")
							value = "center"

						o.setStyle("horizontalAlign", value);
						break;
					}

					//Handle bgcolor attribute
					value = e.attributeMap["bgcolor"];
					if ( !StringUtil.isEmpty(value) )
						o.setStyle( "backgroundColor", HtmlParser.parseColorString(value) );
					//Handle parent's bgcolor attribute
					else if (e.parentElement != null)
					{
						value = e.parentElement.attributeMap["bgcolor"];
						if ( !StringUtil.isEmpty(value) )
							o.setStyle( "backgroundColor", HtmlParser.parseColorString(value) );
					}

					//Handle valign attribute
					value = e.attributeMap["valign"];
					if ( !StringUtil.isEmpty(value) )
					{
						a = HtmlParser.parseVerticalAlignString(value);
						if (a != null)
						{
							o.setStyle("htmlVerticalAlignScalor", a[0]);
							o.setStyle("htmlVerticalAlignType", a[1]);
						}
					}

					break;
				
				case Constants.elementTypeTBODY:
				case Constants.elementTypeTHEAD:
				case Constants.elementTypeTFOOT:
					if (parentComponent == null)
						return null;

					//Add all children to parentComponent not o and return null
					for (i = 0; i < e.childElementArray.length; i++)
					{
						childO = renderHelper(e.childElementArray[i], parentComponent, rootComponent);
						if (childO != null)
							parentComponent.addChild(childO);
					}
					return null;

				case Constants.elementTypeTEXT:
					//Handle top-level text only
					if (parentComponent != null)
						return null;

					//Wrap in span and make recursive call
					var tempE:Element = new Element();
					tempE.tagName = "span";
					tempE.addChildElement(e);
					return renderHelper(tempE, null, rootComponent);
					
				case Constants.elementTypeSUB:
				case Constants.elementTypeSUP:									
					break;

				default:
					o = null;
			}
			
			if (o != null)
			{
				//Override any default values set above
				setStandardStyleAttributes(o, e);

				//Make recursive call for child elements
				if (e.hasChildren)
				{
					var lastIndex:int = e.childElementArray.length - 1;
					for (i = 0; i < e.childElementArray.length; i++)
					{
						childE = e.childElementArray[i];

						//Handle child text element separately
						if (childE.elementType == Constants.elementTypeTEXT)
						{
							var previousSibling:Element = null;
							if (i > 0)
								previousSibling = e.childElementArray[i - 1];

							var nextSibling:Element = null;
							if (i < lastIndex)
								nextSibling = e.childElementArray[i + 1];

							renderTextElementComplex(childE, o, previousSibling, nextSibling);
						}
						else
						{
							childO = renderHelper(childE, o, rootComponent);
							if (childO != null)
								o.addChild(childO);
						}
					}
				}
				
				if (e.elementType == Constants.elementTypeQ)
				{
					//Add " text to end of child list
					childE = new Element();
					childE.tagName = "text";
					childE.text = "\"";
					renderTextElementSimple(childE, o);
				}
			}
			
			return o;
		}

		public function createRootObject():UIComponent
		{
			return new RootHtmlContainer();
		}

		public function createBaseObjectForElement(e:Element):UIComponent
		{
			
			switch (e.elementType)
			{
				case Constants.elementTypeBR:
					return new Container();
				case Constants.elementTypeBUTTON:
					return new Button();
				case Constants.elementTypeIMG:
					return new Image();
				case Constants.elementTypeLI:
					return new ListItem();
				case Constants.elementTypeTABLE:
					return new Grid();
				case Constants.elementTypeTR:
					return new GridRow();
				case Constants.elementTypeTD:
				case Constants.elementTypeTH:
					return new HtmlLayoutGridItem();
				case Constants.elementTypeTEXT:
					return new SimpleText();
				case Constants.elementTypeTBODY:
				case Constants.elementTypeTHEAD:
				case Constants.elementTypeTFOOT:
					return new Container();
				case Constants.elementTypeSUP:
					var out:UIComponent = new GridItem();
					out.setStyle("paddingTop", supPadding);			
					out.scaleX = out.scaleY = subSupScale;
					return out;
				case Constants.elementTypeSUB:
					var out:UIComponent = new GridItem();
					out.setStyle("paddingBottom", subPadding);			
					out.scaleX = out.scaleY = subSupScale;
					return out;					
			}

			if (e.isBlock)
				return new BlockLayoutContainer();
			else
				return new InlineLayoutContainer();
		}

		public static const subSupScale:Number = 0.7;
		public static const subPadding:Number = -16;
		public static const supPadding:Number = -3;
		
		public function setStandardAttributes(o:UIComponent, e:Element):void
		{
			//Handle: id, class, title
		
			var name:String, value:String;
			var a:Array;

			value = e.attributeMap["id"];
			if ( !StringUtil.isEmpty(value) )
				o.id = e.attributeMap[value];

			value = e.attributeMap["class"];
			if ( !StringUtil.isEmpty(value) )
			{
				//Setting font family style does not handle multile font values
				a = value.split(",");
				if (a.length > 0)
					o.styleName = StringUtil.trim(a[0]);
			}

			value = e.attributeMap["title"];
			if ( !StringUtil.isEmpty(value) )
				o.toolTip = value;

		}

		public function setStandardStyleAttributes(o:UIComponent, e:Element):void
		{
			//Handle: width, height,
			//	margin, margin-bottom, margin-left, margin-right, margin-top,
			//	padding, padding-bottom, padding-left, padding-right, padding-top
			//	background-color, color
			//	font-family, font-size, font-style, font-weight, 
			//	letter-spacing, text-align, text-decoration, text-indent, 
			//	overflow, vertical-align, visibility (none)

			var name:String, value:String;
			var a:Array;

			value = e.styleAttributeMap["margin"];
			if ( !StringUtil.isEmpty(value) )
			{
				a = HtmlParser.parse4NumberDimensionString(value);
				if (a != null)
				{
					o.setStyle( "marginTop", toPixels(a[0]) );
					o.setStyle( "marginRight", toPixels(a[1]) );
					o.setStyle( "marginBottom", toPixels(a[2]) );
					o.setStyle( "marginLeft", toPixels(a[3]) );
				}
			}

			value = e.styleAttributeMap["margin-bottom"];
			if ( !StringUtil.isEmpty(value) )
			{
				a = HtmlParser.parseDimensionString(value);
				if (a != null)
					o.setStyle( "marginBottom", toPixels(a) );
			}
			
			value = e.styleAttributeMap["margin-left"];
			if ( !StringUtil.isEmpty(value) )
			{
				a = HtmlParser.parseDimensionString(value);
				if (a != null)
					o.setStyle( "marginLeft", toPixels(a) );
			}
			
			value = e.styleAttributeMap["margin-right"];
			if ( !StringUtil.isEmpty(value) )
			{
				a = HtmlParser.parseDimensionString(value);
				if (a != null)
					o.setStyle( "marginRight", toPixels(a) );
			}

			value = e.styleAttributeMap["margin-top"];
			if ( !StringUtil.isEmpty(value) )
			{
				a = HtmlParser.parseDimensionString(value);
				if (a != null)
					o.setStyle( "marginTop", toPixels(a) );
			}

			value = e.styleAttributeMap["padding"];
			if ( !StringUtil.isEmpty(value) )
			{
				a = HtmlParser.parse4NumberDimensionString(value);
				if (a != null)
				{
					o.setStyle( "paddingTop", toPixels(a[0]) );
					o.setStyle( "paddingRight", toPixels(a[1]) );
					o.setStyle( "paddingBottom", toPixels(a[2]) );
					o.setStyle( "paddingLeft", toPixels(a[3]) );
				}
			}

			value = e.styleAttributeMap["padding-bottom"];
			if ( !StringUtil.isEmpty(value) )
			{
				a = HtmlParser.parseDimensionString(value);
				if (a != null)
					o.setStyle( "paddingBottom", toPixels(a) );
			}

			value = e.styleAttributeMap["padding-left"];
			if ( !StringUtil.isEmpty(value) )
			{
				a = HtmlParser.parseDimensionString(value);
				if (a != null)
					trace('temporarily removed left-padding style');
//					o.setStyle( "paddingLeft", toPixels(a) );
			}

			value = e.styleAttributeMap["padding-right"];
			if ( !StringUtil.isEmpty(value) )
			{
				a = HtmlParser.parseDimensionString(value);
				if (a != null)
					o.setStyle( "paddingRight", toPixels(a) );
			}

			value = e.styleAttributeMap["padding-top"];
			if ( !StringUtil.isEmpty(value) )
			{
				a = HtmlParser.parseDimensionString(value);
				if (a != null)
					o.setStyle( "paddingTop", toPixels(a) );
			}

			value = e.styleAttributeMap["background-color"];
			if ( !StringUtil.isEmpty(value) )
			{
				o.setStyle( "backgroundColor", HtmlParser.parseColorString(value) );
			}

			value = e.styleAttributeMap["border"];
			if ( !StringUtil.isEmpty(value) )
			{
				a = HtmlParser.parseBorderString(value);
				if (a != null)
				{
					o.setStyle( "borderThickness", toPixels(a[0]) );
					o.setStyle("borderStyle", a[1]);
					o.setStyle("borderColor", a[2]);
				}
			}

			value = e.styleAttributeMap["border-color"];
			if ( !StringUtil.isEmpty(value) )
			{
				o.setStyle( "borderColor", HtmlParser.parseColorString(value) );
			}

			value = e.styleAttributeMap["border-style"];
			if ( !StringUtil.isEmpty(value) )
			{
				o.setStyle("borderStyle", value);
			}

			value = e.styleAttributeMap["border-width"];
			if ( !StringUtil.isEmpty(value) )
			{
				a = HtmlParser.parseDimensionString(value);
				if (a != null)
					o.setStyle( "borderThickness", toPixels(a) );
			}

			value = e.styleAttributeMap["border-collapse"];
			if ( !StringUtil.isEmpty(value) )
			{
				o.setStyle("borderCollapse", value);
			}

			value = e.styleAttributeMap["color"];
			if ( !StringUtil.isEmpty(value) )
			{
				o.setStyle( "color", HtmlParser.parseColorString(value) );
			}

			value = e.styleAttributeMap["font-family"];
			if ( !StringUtil.isEmpty(value) )
			{
				//Setting font family style does not handle multile font values
				a = value.split(",");
				if (a.length > 0)
					o.setStyle( "fontFamily", StringUtil.trim(a[0]) );
			}

			value = e.styleAttributeMap["font-size"];
			if ( !StringUtil.isEmpty(value) )
			{
				value = StringUtil.trim(value).toLocaleLowerCase();
				switch (value)
				{
					case "small":
						value = "12px";
						break;
					case "x-small":
						value = "10px";
						break;
				}

				a = HtmlParser.parseDimensionString(value);
				if (a != null)
					o.setStyle( "fontSize", toPixels(a) );
			}

			value = e.styleAttributeMap["font-style"];
			if ( !StringUtil.isEmpty(value) )
			{
				o.setStyle("fontStyle", value);
			}

			value = e.styleAttributeMap["font-weight"];
			if ( !StringUtil.isEmpty(value) )
			{
				o.setStyle("fontWeight", value);
			}

			value = e.styleAttributeMap["letter-spacing"];
			if ( !StringUtil.isEmpty(value) )
			{
				a = HtmlParser.parseDimensionString(value);
				if (a != null)
					o.setStyle( "letterSpacing", toPixels(a) );
			}

			value = e.styleAttributeMap["text-decoration"];
			if ( !StringUtil.isEmpty(value) )
			{
				o.setStyle("textDecoration", value);
			}

			value = e.styleAttributeMap["text-indent"];
			if ( !StringUtil.isEmpty(value) )
			{
				a = HtmlParser.parseDimensionString(value);
				if (a != null)
					o.setStyle( "marginLeft", toPixels(a) );
			}

			value = e.styleAttributeMap["vertical-align"];
			if ( !StringUtil.isEmpty(value) )
			{
				a = HtmlParser.parseVerticalAlignString(value);
				if (a != null)
				{
					o.setStyle("htmlVerticalAlignScalor", a[0]);
					o.setStyle("htmlVerticalAlignType", a[1]);
				}
			}

			value = e.styleAttributeMap["visibility"];
			if ( !StringUtil.isEmpty(value) )
			{
				value = value.toLocaleLowerCase();
				if ( (value == "hidden") || (value == "collapse") )
					o.visible = false;
			}

			value = e.styleAttributeMap["display"];
			if ( !StringUtil.isEmpty(value) )
			{
				value = value.toLocaleLowerCase();
				if (value == "none")
				{
					
					o.visible = false;
					o.includeInLayout = false;
				}
			}

			value = e.styleAttributeMap["text-align"];
			if ( !StringUtil.isEmpty(value) )
			{
				if (e.isBlock)
				{
					if (value != "left")
					{
						o.setStyle("htmlHorizontalAlign", value);
						
						//If this element doesn't have an explicit size
						if ( !o.getStyle("widthSet") )
						{
							o.percentWidth = 100;
							addPercentWidthListener(o);
						}
					}
				}
			}

			if (o is Container)
			{
				var container:Container = o as Container;

				//Default to no scrollbars
				container.horizontalScrollPolicy = "off";
				container.verticalScrollPolicy = "off";

				//Handle overflow
				value = e.styleAttributeMap["overflow"];
				if ( !StringUtil.isEmpty(value) )
				{
					if (value == "hidden")
					{
						container.horizontalScrollPolicy = "off";
						container.verticalScrollPolicy = "off";
//TO DO: set maxWidth to width and maxHeight to height
					}
					else if (value == "scroll")
					{
						container.horizontalScrollPolicy = "on";
						container.verticalScrollPolicy = "on";
//TO DO: set maxWidth to width and maxHeight to height
					}
					
				}
			}
		}
		
		public function finalizeRender(o:UIComponent, e:Element):void
		{
		}

		public function renderTextElementComplex(e:Element, parentComponent:UIComponent, 
			previousSibling:Element, nextSibling:Element):void
		{
			var o:UIComponent;
			var text:Text;
			var textString:String = e.text;
			var s:String;
			var i:int;

			var effectivePreviousSibling:Element = null;
effectivePreviousSibling = previousSibling;
/*
			if (previousSibling != null)
			{
				effectivePreviousSibling = previousSibling;
				while (true)
				{
					if (!effectivePreviousSibling.hasChildren)
						break;
					if (effectivePreviousSibling.elementType == Constants.elementTypeBR)
						break;

					effectivePreviousSibling = effectivePreviousSibling.childElementArray[0];
				}

				//Ignore previous empty text siblings
				if (effectivePreviousSibling.elementType == Constants.elementTypeTEXT)
				{
					if (effectivePreviousSibling.textIsEmpty)
					{
						//If this was the parent's only child, null out previous sibling
						if (effectivePreviousSibling.parentElement.childElementArray.length == 1)
							effectivePreviousSibling = null;
						else
							effectivePreviousSibling = effectivePreviousSibling.parentElement.childElementArray[1];
					}
				}
			}
*/

			//Ignore first sibling empty text
			if ( (effectivePreviousSibling == null) && e.textIsEmpty )
				return;

			var effectiveNextSibling:Element = null;
effectiveNextSibling = nextSibling;
/*
			if (nextSibling != null)
			{
				effectiveNextSibling = nextSibling;
				while (true)
				{
					if (!effectiveNextSibling.hasChildren)
						break;
					if (effectiveNextSibling.elementType == Constants.elementTypeBR)
						break;

					effectiveNextSibling = effectiveNextSibling.childElementArray[0];
				}
				
				//Ignore next empty text siblings
				if (effectiveNextSibling.elementType == Constants.elementTypeTEXT)
				{
					if (effectiveNextSibling.textIsEmpty)
						effectiveNextSibling = effectiveNextSibling.parentElement;
				}
				
				//Ignore next empty text siblings
				while (true)
				{
					if (effectiveNextSibling.elementType != Constants.elementTypeTEXT)
						break;
					if (StringUtil.trim(effectiveNextSibling.text).length != 0)
						break;
					//If this was the parent's only child, null out next sibling
					if (effectiveNextSibling.parentElement.childElementArray.length == 1)
					{
						effectiveNextSibling = null;
						break;
					}
					
					effectiveNextSibling = effectiveNextSibling.parentElement.childElementArray[1];
				}
			}
*/

			var startsWithWhiteSpace:Boolean = (textString.length > 0)
				&& HtmlParser.isSpace( textString.charCodeAt(0) );

			//If text starts with a space
			//Add a leading space if ...
			var addLeadingSpace:Boolean = false;
			if (startsWithWhiteSpace)
			{
				//Previous element exists
				if (effectivePreviousSibling != null)
				{
//TO DO: Add check for BR
					//If previous sibling is not whitespace only text
					if (effectivePreviousSibling.elementType == Constants.elementTypeTEXT)
					{
						if (StringUtil.trim(effectivePreviousSibling.text).length != 0)
							addLeadingSpace = true;
					}
					//Or if previous sibling is an inline element
					else if (!effectivePreviousSibling.isBlock)
						addLeadingSpace = true;
				}
			}

			//Ignore empty text following BRs
			if ( addLeadingSpace && (effectivePreviousSibling != null) )
			{
				if ( (effectivePreviousSibling.elementType == Constants.elementTypeBR) &&
					 e.textIsEmpty )
					return;
			}

			var endsInWhiteSpace:Boolean = (textString.length > 0)
				&& HtmlParser.isSpace( textString.charCodeAt(textString.length - 1) );

			//If text ends with a space
			//Add a trailing space if ...
			var addTrailingSpace:Boolean = false;
			if (endsInWhiteSpace)
			{
				//Next element exists
				if (effectiveNextSibling != null)
				{
//TO DO: Add check for BR
					//If next sibling is not whitespace only text
					if (effectiveNextSibling.elementType == Constants.elementTypeTEXT)
					{
						if (StringUtil.trim(effectiveNextSibling.text).length != 0)
							addTrailingSpace = true;
					}
					//Or if next sibling is an inline element
					else if (!effectiveNextSibling.isBlock)
						addTrailingSpace = true;
				}
			}

/*
if (addLeadingSpace)
	Alert.show( "addLeadingSpace: e.html=" + e.toHtmlString() );
if (addTrailingSpace)
	Alert.show( "addTrailingSpace: e.html=" + e.toHtmlString() );
*/

			var nowrap:Boolean = false;
			if (!nowrap)
			{
				switch (e.parentElement.elementType)
				{
					case Constants.elementTypeTH:
						nowrap = true;
						break;
				}
			}
			if (!nowrap)
			{
				if (e.parentElement.attributeMap["nowrap"] != null)
					nowrap = true;
			}
			if (nowrap)
			{
				s = HtmlParser.unescapeEntities( StringUtil.trim(textString) );

				if (addLeadingSpace)
					s = " " + s;
				if (addTrailingSpace)
					s += " ";

				if (s.length == 0)
					return;

				o = createBaseObjectForElement(e);
				if ( setElementOnComponent(o, e) )
				{
					if (o is Text)
					{
						text = o as Text;
						text.text = s;
					}
					parentComponent.addChild(o);
				}

				return;
			}
			
			//Otherwise add text component for each word

//Alert.show("textString=" + textString);

			var a:Array = HtmlParser.toWordArray(textString);
			//If a is empty, textString is all whitespace, render single space
			if (a.length == 0)
			{
				if (!addLeadingSpace && !addTrailingSpace)
					return;

				a.push(" ");
				addLeadingSpace = false;
				addTrailingSpace = false;
			}

			var textAdded:Boolean = false;
			var lastIndex:int = a.length - 1;
			for (i = 0; i < a.length; i++)
			{
				s = HtmlParser.unescapeEntities(a[i]);

				if (addLeadingSpace && !textAdded)
					s = " " + s;
				if ( addTrailingSpace || (i != lastIndex) )
					s += " ";
				else if ( addTrailingSpace && (a.length == 1) )
					s += " ";

				o = createBaseObjectForElement(e);
				if ( setElementOnComponent(o, e) )
				{
					if (o is Text)
					{
						text = o as Text;
						text.text = s;
					}
					parentComponent.addChild(o);
				}
				
				textAdded = true;
			}
		}

		public function renderTextElementSimple(e:Element, parentComponent:UIComponent):void
		{
			var text:Text;
			var o:UIComponent;

			o = createBaseObjectForElement(e);
			if ( setElementOnComponent(o, e) )
			{
				if (o is Text)
				{
					text = o as Text;
					text.text = e.text;					
				}
				parentComponent.addChild(o);
			}
		}

		public function setDimensions(o:UIComponent, e:Element, checkAttributeMap:Boolean = false):void
		{
			var widthArray:Array = HtmlParser.getWidthArray(e, checkAttributeMap);
			var heightArray:Array = HtmlParser.getHeightArray(e, checkAttributeMap);
			
			if (widthArray != null)
				o.setStyle("widthSet", true);
			if (heightArray != null)
				o.setStyle("heightSet", true);

			if ( (widthArray != null) && (heightArray != null) && (o is SWFLoader) )
				(o as SWFLoader).maintainAspectRatio = false;

			if (widthArray != null)
			{
				switch (widthArray[1])
				{
					case Constants.unitTypePX:
						o.width = widthArray[0];
//Alert.show("o=" + o + ", o.width=" + o.width);
						break;
					case Constants.unitTypePercent:
						o.percentWidth = widthArray[0];
						addPercentWidthListener(o);
						break;
					default:
						var width:int = toPixels(widthArray)
						o.width = width;
						break;
				}
			}

			if (heightArray != null)
			{
				switch (heightArray[1])
				{
					case Constants.unitTypePX:
						o.height = heightArray[0];
						break;
					case Constants.unitTypePercent:
						o.percentHeight = heightArray[0];
						addPercentHeightListener(o);
						break;
					default:
						var height:int = toPixels(heightArray);
						o.height = height;
						break;
				}
			}

			//If this is an image and either width or height isn't set, set missing dimension
			if (  (o is Image) && ( (widthArray == null) || (heightArray == null) )  )
			{
				var image:Image = o as Image;
				if (heightArray != null)
					image.width = (image.contentHeight > 0) ? image.contentWidth * image.height / image.contentHeight : 0;
				if (widthArray != null)
					image.height = (image.contentWidth > 0) ? image.contentHeight * image.width / image.contentWidth: 0;
			}
		}

		/**
		 * Converts the passed dimension array to pixels
		 * Note: Assumes a point is equal to a pixel
		 */
		public function toPixels(dimensionArray:Array):int
		{
			switch (dimensionArray[1])
			{
				case Constants.unitTypeEM:
					return dimensionArray[0]; //TO DO: multiply by font size
					break;
				case Constants.unitTypeEX:
					return dimensionArray[0]; //TO DO: multiply by font size
					break;
				case Constants.unitTypeIN:
					return dimensionArray[0] * 72;
					break;
				case Constants.unitTypeCM:
					return dimensionArray[0] * 28.3464567;
					break;
				case Constants.unitTypeMM:
					return dimensionArray[0] * 283.464567;
					break;
				case Constants.unitTypePT:
					//return dimensionArray[0] * 12; //TODO: this assume 12pt font
					return dimensionArray[0];
					break;
				case Constants.unitTypePC:
					return dimensionArray[0] / 12;
					break;
				case Constants.unitTypePercent:
					return dimensionArray[0]; //TO DO: bind to parent's width
					break;
				default:
					return dimensionArray[0];
			}
		}

		public static function setElementOnComponent(o:UIComponent, e:Element):Boolean
		{
			if (o == null)
				return false;

			//o must have a data property
			if (o is Container)
				(o as Container).data = e;
			else if (o is Image)
				(o as Image).data = e;
			else if (o is Button)
				(o as Button).data = e;
			else if (o is Text)
				(o as Text).data = e;
			else
				return false;
			
			return true;
		}

		/**
		 * Returns effective vertical alignment scalor and type for UI object.
		 * Note: this will only return null for invalid object and the type will never be inherit.
		 */
		public static function getEffectiveVerticalAlign(passedO:UIComponent):Array
		{
			//Loop until vertical alignment value is found, block element is reached or null is reached
			
			for (var o:UIComponent = passedO; o != null; o = o.parent as UIComponent)
			{
				var e:Element = getElementFromComponent(o);
				
				//If there isn't an element associated with this object, continue
				if (e == null)
					continue;

				//Text elements should always inherit
				if (e.elementType == Constants.elementTypeTEXT)
					continue;
				
				//If vertical alignment is not set, default to default vertical alignment
				if (o.getStyle("htmlVerticalAlignType") == null)
					return [0, defaultVerticalAlign];


				//Otherwise check type

				var type:int = 0;
				try { type = o.getStyle("htmlVerticalAlignType"); }
				catch (e:Error) { }
				
				//If type is inherit, continue to parent
				if (type == Constants.verticalAlignTypeInherit)
					continue;


				//Type is set, return it with scalor

				var scalor:int = 0;
				try { scalor= o.getStyle("htmlVerticalAlignScalor"); }
				catch (e:Error) { }

				return [scalor, type];
			}
			
			//If function gets this far, return null
			return null;
		}

		/**
		 * Returns effective border-collapse type for UI object.
		 * Note: this will only return null for invalid object and the type will never be inherit.
		 */
		public static function getEffectiveBorderCollapse(passedO:UIComponent):String
		{
			for (var o:UIComponent = passedO; o != null; o = o.parent as UIComponent)
			{
				var e:Element = getElementFromComponent(o);
				
				//If there isn't an element associated with this object, continue
				if (e == null)
					continue;

				//Text elements should always inherit
				if (e.elementType == Constants.elementTypeTEXT)
					continue;

				var type:String = "";
				try { type = o.getStyle("borderCollapse"); }
				catch (e:Error) { }

				//If type is unset, continue to parent
				if (type == null)
					continue;

				//If type is inherit, continue to parent
				if (type == "inherit")
					continue;

				return type;
			}

			//If function gets this far, return null
			return null;
		}

		public static function getElementFromComponent(o:UIComponent):Element
		{
			if (o == null)
				return null;

			//o must have a data property
			if (o is Container)
				return (o as Container).data as Element;
			else if (o is Image)
				return (o as Image).data as Element;
			else if (o is Button)
				return (o as Button).data as Element;
			else if (o is Text)
				return (o as Text).data as Element;

			return null;
		}
		
		public function addPercentWidthListener(o:UIComponent):void
		{
			o.addEventListener(Event.ADDED_TO_STAGE, function(event:Event):void
				{
					var self:UIComponent = event.currentTarget as UIComponent;
					
					if (self.parent == null)
						return;
					self.setActualSize(self.parent.width * self.percentWidth / 100, self.height);

/*
var e:Element = getElementFromComponent(self);
Alert.show("self=" + self
	+ ", self.parent=" + self.parent
	+ ", self.parent.width=" + self.parent.width
	+ ", e.html=" + e.toHtmlString()
	+ ", self.width=" + self.width
	+ ", self.height=" + self.height
);
*/

					//Resize on parent resize
					self.parent.addEventListener(Event.RESIZE, function(event:Event):void
						{
							var parent:UIComponent = event.currentTarget as UIComponent;
							
/*
Alert.show("parent=" + parent
	+ ", parent.width=" + parent.width);
*/

/*
//Alert.show("here");
var e:Element = getElementFromComponent(self);
Alert.show("self=" + self
	+ ", self.parent=" + self.parent
	+ ", self.parent.width=" + self.parent.width
	+ ", e.html=" + e.toHtmlString()
	+ ", self.width=" + self.width
	+ ", self.height=" + self.height
);
*/

							self.setActualSize(self.parent.width * self.percentWidth / 100, self.height);
						});
				});
		}
		
		public function addPercentHeightListener(o:UIComponent):void
		{
			o.addEventListener(Event.ADDED_TO_STAGE, function(event:Event):void
				{
					var self:UIComponent = event.currentTarget as UIComponent;
					if (self.parent == null)
						return;
					self.setActualSize(self.width, self.parent.height * self.percentHeight / 100);
				});
		}

		public function isBlockOrBR(e:Element):Boolean
		{
			if (e == null)
				return false;

			return e.isBlock || e.elementType == Constants.elementTypeBR;
		}
	}
}
