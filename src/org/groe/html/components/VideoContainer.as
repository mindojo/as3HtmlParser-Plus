package org.groe.html.components
{
	import flash.events.Event;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.TextArea;
	import mx.core.Container;
	import mx.core.UIComponent;
	import mx.states.OverrideBase;
	
	import org.groe.html.Element;
	import org.groe.html.HtmlContainer;

	public class VideoContainer extends Canvas
	{

		private var ta:TextArea;
		private var _e2:Element;
		
		private var _width:Number;
		private var _height:Number;
		private var _source:String;
		private var _videoID:String;
		
		
		private var _rootComponent:UIComponent;		
		private var ytp:YTPlayerContainer;
		
		public function VideoContainer()
		{
			super();
			
			buttonMode = false;
			useHandCursor = false;
			
			ytp = new YTPlayerContainer();			
			addElement(ytp);
			
		}
		
		/**
		 * Reference to root component is used to handle resizing.
		 */		
		public function get rootComponent():UIComponent
		{
			return _rootComponent;
		}

		public function set rootComponent(value:UIComponent):void
		{
			if (value)
			{
				_rootComponent = value;
				_rootComponent.addEventListener(Event.RESIZE, rootResizeHandler);
			}
		}		
		
		public function killVideo():void
		{
			if (_rootComponent)
			{
				_rootComponent.removeEventListener(Event.RESIZE, rootResizeHandler);
				_rootComponent = null;				
			}
			
			if (ytp && contains(ytp))
			{
				ytp.kill();
				removeElement(ytp);
				ytp = null;
			}
			width = 0;
			height = 0;
		}
		
						
		private function rootResizeHandler(e:Event):void
		{
			if (!isNaN(rootComponent.width) && !isNaN(rootComponent.height))
			{
				if (rootComponent.width == 0 || rootComponent.width == 0)
				{
					return;
				}
				
				if (rootComponent.width < ytp.playerWidth)
				{
					//trace ("rootComponent", rootComponent.width, rootComponent.height, ytp, ytp.playerWidth, ytp.playerHeight);
					
					var newWidth:Number = rootComponent.width;
					var newHeight:Number = (rootComponent.width / ytp.playerWidth) * ytp.playerHeight;
										
					ytp.setSize(newWidth, newHeight);					
					
					width = newWidth;
					height = newHeight 
				}
				else
				{
					ytp.setSize(ytp.playerWidth,  ytp.playerHeight);
					
					width = ytp.playerWidth;
					height = ytp.playerHeight;
					
				}
			}
						
			
		}
		////////////////////////////////////////////////////////////////////////////////
		
		public function stopVideo():void
		{
			ytp.stopVideo();			
		}
		
		override public function set x(value:Number):void
		{
			super.x = value;
		}
					
		override public function set data(value:Object):void
		{
			_width = value.attributeMap["width"];
			_height = value.attributeMap["height"];
			_source = findSource(value as Element);
			_videoID = matchYTContent(_source);		
			
			//Alert.show("w:\t" + _width + "\nh:\t" + _height + "\ns:\t" + _source + "\nyt:\t" + matchYTContent(_source));
			
			width = _width;
			height = _height;			
			
			super.data = value;
			
			if (ytp)
			{
				ytp.videoID = _videoID;
				ytp.playerWidth = _width;
				ytp.playerHeight = _height;
			}			
		}

		private function findSource(e:Element):String
		{
			for each (var e:Element in e.childElementArray) 
			{
				if (e.tagName == "param")
				{
					if (e.attributeMap["name"] == "movie")
					{
						return e.attributeMap["value"];
					}
				}
			}
			return "";
		}	
		
		private function matchYTContent(value:String):String
		{			
			var ytVideoIdRegExp:RegExp = /(.*?\/)*(.*?)\?(.*)/g;
			var match:Object = ytVideoIdRegExp.exec( value );
			if (match) return match[2];
			return "";
		}

	}
}