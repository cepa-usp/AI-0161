package BaseAssets.interfaces
{
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public interface IDAO 
	{
		function connect():Boolean;
		function setValue(key:String, value:*):void;
		function getValue(key:String):*;
		function disconect():Boolean;
		function getState():String;
	}
	
}