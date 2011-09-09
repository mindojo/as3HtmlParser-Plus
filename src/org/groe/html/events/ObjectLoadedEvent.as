/*
 * Copyright 2006-2009 groe.org.  All rights reserved.
 */
package org.groe.html.events
{
	import flash.events.Event;
	import mx.core.UIComponent;


	public class ObjectLoadedEvent extends flash.events.Event
	{
		public static var EVENT_NAME:String = "objectLoaded";
		protected var object:UIComponent;

		public function ObjectLoadedEvent(object:UIComponent)
		{
			super(EVENT_NAME);
			this.object = object;
		}

        override public function clone():Event
        {
			return new ObjectLoadedEvent(object);
        }
        
		public function getObject():UIComponent
		{
			return object;
		}
	}
}
