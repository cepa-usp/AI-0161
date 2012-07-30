package  BaseAssets.events
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public class BaseEvent extends Event 
	{
		public static const CLOSE_SCREEN:String = "close_screen";
		public static const CANCEL_SCREEN:String = "cancel_screen";
		public static const OK_SCREEN:String = "ok_screen";
		public static const NEXT_BALAO:String = "next_balao";
		public static const CLOSE_BALAO:String = "close_balao";
		
		public function BaseEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			
		}
		
	}

}