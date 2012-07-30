package BaseAssets.screens
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class GlassPane extends Sprite
	{
		
		public function GlassPane(w:Number, h:Number) 
		{
			this.graphics.beginFill(0x000000, 0.6);
			this.graphics.drawRect( -w / 2, -h / 2, w, h);
		}
		
	}

}