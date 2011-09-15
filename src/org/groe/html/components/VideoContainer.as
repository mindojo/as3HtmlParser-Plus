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

	public class VideoContainer extends HtmlLayoutContainer
	{

		private var ta:TextArea;
		private var _e2:Element;
		
		private var _width:Number;
		private var _height:Number;
		private var _source:String;
		
		public function VideoContainer()
		{
			super();
			
			buttonMode = false;
			useHandCursor = false;
			
			setStyle("borderColor", "#FF0000");
			setStyle("borderStyle", "solid");	

		}
		
		
		
		override public function set data(value:Object):void
		{
			_width = value.attributeMap["width"];
			_height = value.attributeMap["height"];
			_source = findSource(value as Element);
			
			Alert.show("w:\t" + _width + "\nh:\t" + _height + "\ns:\t" + _source);
			
			width = _width;
			height = _height;
			
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

	}
}