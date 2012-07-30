package BaseAssets.components
{
	import cepa.utils.ToolTip;
	import com.eclecticdesignstudio.motion.Actuate;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class MenuBar extends Sprite
	{
		public const BTN_WIDTH:Number = 44;
		private const BTN_TWEEN_TIME:Number = 0.2;
		private const HEIGHT_BORDER:Number = 3;
		private const ROUND_RECT_ELIPSE:Number = 10;
		
		private var totalHeight:Number = 0;
		private var overAnimated:Boolean = true;
		private var doublInicialFinalBorder:Boolean = true;
		
		private var buttons:Vector.<Sprite> = new Vector.<Sprite>();
		private var background:Sprite;
		
		public function MenuBar() 
		{
			if (doublInicialFinalBorder) totalHeight = HEIGHT_BORDER;
		}
		
		public function addButton(spr:Sprite, func:Function, descricao:String = null):void
		{
			spr.x = BTN_WIDTH / 2;
			spr.y = -totalHeight - HEIGHT_BORDER - spr.height / 2;
			totalHeight += spr.height + 2 * HEIGHT_BORDER;
			
			buttons.push(spr);
			makeButton(spr, func);
			if (descricao != null) createToolTip(spr, descricao);
			
			drawBackground();
			
			addChild(spr);
		}
		
		private function createToolTip(spr:Sprite, descricao:String):void 
		{
			var btnTT:ToolTip = new ToolTip(spr, descricao, 12, 0.8, 150, 0.6, 0.1);
			stage.addChild(btnTT);
		}
		
		private function makeButton(spr:Sprite, func:Function):void 
		{
			spr.buttonMode = true;
			spr.addEventListener(MouseEvent.MOUSE_OVER, overBtn);
			spr.addEventListener(MouseEvent.MOUSE_OUT, outBtn);
			spr.addEventListener(MouseEvent.CLICK, func);
		}
		
		private function overBtn(e:MouseEvent):void 
		{
			var btn:Sprite = Sprite(e.target);
			if (overAnimated) Actuate.tween(btn, BTN_TWEEN_TIME, { scaleX:1.2, scaleY:1.2 } );
			else btn.scaleX = btn.scaleY = 1.2;
		}
		
		private function outBtn(e:MouseEvent):void 
		{
			var btn:Sprite = Sprite(e.target);
			if (overAnimated) Actuate.tween(btn, BTN_TWEEN_TIME, { scaleX:1, scaleY:1 } );
			else btn.scaleX = btn.scaleY = 1;
		}
		
		private function drawBackground():void 
		{
			if (background == null) {
				background = new Sprite();
				background.filters = [new DropShadowFilter(3, 45, 0x000000, 1, 5, 5)];
				addChild(background);
				setChildIndex(background, 0);
			}
			
			background.graphics.clear();
			background.graphics.beginFill(0xDBDBDB, 1);
			background.graphics.drawRoundRect(0, (doublInicialFinalBorder ? -totalHeight - HEIGHT_BORDER : -totalHeight), BTN_WIDTH, (doublInicialFinalBorder ? totalHeight + HEIGHT_BORDER : totalHeight), ROUND_RECT_ELIPSE, ROUND_RECT_ELIPSE);
		}
		
	}

}