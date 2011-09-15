package org.groe.html.components
{
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.TextArea;
	import mx.core.Container;
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
		
		private var ytp:YTPlayerContainer;
		
		public function VideoContainer()
		{
			super();
			
			buttonMode = false;
			useHandCursor = false;
			
			ytp = new YTPlayerContainer();
			addElement(ytp);

		}
		
		public function kill():void
		{
			ytp.stopVideo();			
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
			
			ytp.videoID = _videoID;
			ytp.playerWidth = _width;
			ytp.playerHeight = _height;				
			
			super.data = value;
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