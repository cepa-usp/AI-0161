package BaseAssets.components
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public class InfoBar extends Sprite 
	{
		private const BORDER:Number = 10;
		
		private var defaulText:TextFormat = new TextFormat("arial", 15, 0xFFFFFF);
		private var texto:TextField;
		private var background:Sprite;
		private var stageWidth:Number;
		private var wMax:Number;
		
		public function InfoBar(stageWidth:Number, wMax:Number) 
		{
			this.stageWidth = stageWidth;
			this.wMax = wMax;
			
			createTexto();
			createBackground();
			this.visible = false;
		}
		
		private function createTexto():void 
		{
			if (texto != null) {
				removeChild(texto);
			}
			texto = new TextField();
			texto.selectable = false;
			defaulText.align = "justify";
			texto.defaultTextFormat = defaulText;
			texto.width = wMax;
			texto.multiline = true;
			texto.wordWrap = true;
			addChild(texto);
			texto.x = BORDER;
			texto.y = - BORDER - texto.textHeight;
		}
		
		private function createBackground():void 
		{
			if (background == null) {
				background = new Sprite();
				addChild(background);
				setChildIndex(background, 0);
			}
			background.graphics.clear();
			background.graphics.beginFill(0x000000, 0.7);
			background.graphics.drawRect(0, texto.y, stageWidth, Math.abs(texto.y));
		}
		
		public function set info(info:String):void
		{
			texto.text = info;
			texto.y = -BORDER - texto.textHeight;
			createBackground();
			if (info == "") this.visible = false;
			else this.visible = true;
		}
		
		public function set textFormat(tf:TextFormat):void
		{
			texto.defaultTextFormat = tf;
			info = texto.text;
		}
		
	}

}