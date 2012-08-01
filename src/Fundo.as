package  
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Fundo extends MovieClip
	{
		public var currentPeca:MovieClip;
		public var fundo:Sprite;
		
		public function Fundo() 
		{
			fundo = new Sprite();
			addChild(fundo);
			setChildIndex(fundo, 0);
			fundo.graphics.beginFill(0xFFFF80, 0);
			fundo.graphics.drawRect( -50, -12, 100, 24);
		}
		
		override public function get scaleY():Number 
		{
			return super.scaleY;
		}
		
		override public function set scaleY(value:Number):void 
		{
			fundo.scaleY = 1 / value;
			super.scaleY = value;
		}
		
	}

}