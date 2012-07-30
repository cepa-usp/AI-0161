package BaseAssets.tutorial
{
	import BaseAssets.events.BaseEvent;
	import com.eclecticdesignstudio.motion.Actuate;
	import com.eclecticdesignstudio.motion.easing.Elastic;
	import com.eclecticdesignstudio.motion.easing.Linear;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class CaixaTexto extends Sprite
	{
		public static const TOP:String = "top";
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		public static const BOTTON:String = "botton";
		
		public static const FIRST:String = "first";
		public static const CENTER:String = "center";
		public static const LAST:String = "last";
		
		private var texto:TextField;
		private var background:Sprite;
		
		private var marginText:Number = 10;
		private var _roundCorner:Boolean;
		private var widthArrow:Number = 10; //Base da flecha
		private var heightArrow:Number = 15; //comprimento da flecha
		
		private var sideForArrow:String = "left";
		private var alignForArrow:String = "first";
		
		private var distanceToObject:Number = 10;
		private var actualPosition:Point = new Point();
		
		private var hasNext:Boolean = true;
		private var nextButton:TutoNext;
		private var closeButton:TutoClose;
		private var textArray:Array;
		private var currentWidth:Number = 200;
		private var minWidth:Number;
		
		private var normalGlow:GlowFilter = new GlowFilter(0x000000, 0.5, 6, 6, 2, 2);
		private var errorGlow:GlowFilter = new GlowFilter(0xFF0000, 1, 6, 6, 2, 2);
		
		public function CaixaTexto(roundCorner:Boolean = false)
		{
			this.visible = false;
			this.roundCorner = roundCorner;
			background = new Sprite();
			addChild(background);
			background.filters = [normalGlow];
			
			texto = new TextField();
			texto.defaultTextFormat = new TextFormat("arial", 12, 0x000000, null, null, null, null, null, TextFormatAlign.JUSTIFY);
			texto.multiline = true;
			texto.wordWrap = true;
			texto.autoSize = TextFieldAutoSize.LEFT;
			texto.selectable = false;
			texto.x = marginText;
			texto.y = marginText;
			texto.mouseEnabled = false;
			//texto.border = true;
			addChild(texto);
			
			nextButton = new TutoNext();
			closeButton = new TutoClose();
			nextButton.buttonMode = true;
			closeButton.buttonMode = true;
			addChild(nextButton);
			addChild(closeButton);
			if (roundCorner) minWidth = nextButton.width;
			else minWidth = nextButton.width - 2 * marginText + 2;
			
			if (stage) stage.addEventListener(MouseEvent.MOUSE_DOWN, clickHandler);
			else addEventListener(Event.ADDED_TO_STAGE, addListener);
			
			this.filters = [new GlowFilter(0xFF0000, 0, 1, 1)];
		}
		
		private function addListener(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addListener);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, clickHandler);
		}
		
		private function clickHandler(e:MouseEvent):void 
		{
			//trace("clicou em: " + e.target.name);
			if (e.target == nextButton) {
				this.visible = false;
				dispatchEvent(new BaseEvent(BaseEvent.NEXT_BALAO));
			}else if (e.target == closeButton) {
				this.visible = false;
				dispatchEvent(new BaseEvent(BaseEvent.CLOSE_BALAO));
			}else if (e.target.name == "block") {
				Actuate.stop(background);
				background.filters = [errorGlow];
				//Actuate.tween(this, 0.2, { scaleX: 1.2, scaleY:1.2 } ).onComplete(backToNormal).ease(Elastic.easeIn);
				Actuate.effects(background, 0.1).filter(0, { color:0xFFFFFF}).ease(Linear.easeNone).onComplete(backToNormal);
			}
		}
		
		private function backToNormal():void 
		{
			//Actuate.tween(this, 0.2, { scaleX:1, scaleY:1 } ).ease(Elastic.easeOut);
			Actuate.effects(background, 0.1).filter(0, { color:0xFF0000} ).ease(Linear.easeNone).onComplete(backToNormal2);
		}
		
		private function backToNormal2():void 
		{
			//Actuate.tween(this, 0.2, { scaleX:1, scaleY:1 } ).ease(Elastic.easeOut);
			Actuate.effects(background, 0.1).filter(0, { color:0xFFFFFF} ).ease(Linear.easeNone).onComplete(backToNormal3);
		}
		
		private function backToNormal3():void 
		{
			//Actuate.tween(this, 0.2, { scaleX:1, scaleY:1 } ).ease(Elastic.easeOut);
			Actuate.effects(background, 0.1).filter(0, { color:0xFF0000} ).ease(Linear.easeNone).onComplete(back2);
		}
		
		private function back2():void 
		{
			Actuate.stop(background);
			Actuate.timer(0.001).onComplete(back3);
			//background.filters = [normalGlow];
		}
		
		private function back3():void 
		{
			background.filters = [normalGlow];
		}
		
		public function setText(text:String, side:String = null, align:String = null, width:Number = 200):void
		{
			texto.text = "";
			
			if (width >= minWidth) texto.width = width;
			else texto.width = minWidth;
			
			texto.text = text;
			
			currentWidth = width;
			if(side != null) sideForArrow = side;
			if (align != null) alignForArrow = align;
			
			drawBackground(texto.width, texto.textHeight);
			posicionaNextButton();
			setPosition(actualPosition.x, actualPosition.y);
			this.visible = true;
		}
		
		private function posicionaNextButton():void
		{
			if (!hasNext) {
				nextButton.visible = false;
				return;
			}
			nextButton.visible = true;
			var textWidth:Number;
			if (texto.textWidth < minWidth) textWidth = minWidth;
			else textWidth = texto.width;
			
			closeButton.x = marginText + textWidth - nextButton.width / 2 + 4;
			closeButton.y = 2 * marginText + texto.textHeight + nextButton.height / 2;
			
			nextButton.x = closeButton.x - closeButton.width / 2 - nextButton.width / 2 - 5;
			nextButton.y = closeButton.y;
		}
		
		public function setPosition(x:Number, y:Number):void
		{
			actualPosition.x = x;
			actualPosition.y = y;
			
			switch (sideForArrow) {
				case LEFT:
					this.x = x + distanceToObject + heightArrow;
					if (alignForArrow == FIRST) {
						this.y = y - marginText - widthArrow / 2;
					}else if (alignForArrow == CENTER) {
						this.y = y - background.height / 2;
					}else {
						this.y = y - background.height + marginText + widthArrow / 2;
					}
					break;
				case TOP:
					this.y = y + distanceToObject  + heightArrow;
					if (alignForArrow == FIRST) {
						this.x = x - marginText - widthArrow / 2;
					}else if (alignForArrow == CENTER) {
						this.x = x - marginText - texto.textWidth / 2;
					}else {
						this.x = x - marginText - texto.textWidth + widthArrow / 2;
					}
					break;
				case RIGHT:
					this.x = x - distanceToObject - (2 * marginText) - heightArrow - texto.textWidth;
					if (alignForArrow == FIRST) {
						this.y = y - marginText - widthArrow / 2;
					}else if (alignForArrow == CENTER) {
						this.y = y - background.height / 2;
					}else {
						this.y = y - background.height + marginText + widthArrow / 2;
					}
					break;
				case BOTTON:
					this.y = y - background.height - distanceToObject;
					if (alignForArrow == FIRST) {
						this.x = x - marginText - widthArrow / 2;
					}else if (alignForArrow == CENTER) {
						this.x = x - marginText - texto.textWidth / 2;
					}else {
						this.x = x - marginText - texto.textWidth + widthArrow / 2;
					}
					break;
				default:
					this.x = x;
					this.y = y;
			}
		}
		
		private function drawBackground(w:Number, h:Number):void
		{
			background.graphics.clear();
			background.graphics.lineStyle(1, 0xCA9C00);
			background.graphics.beginFill(0xffd647, 1);
			background.graphics.moveTo(marginText, 0);
			
			if (hasNext) {
				h = h + nextButton.height + marginText;
			}
			
			if (w < minWidth) {
				w = minWidth;
				texto.width = minWidth;
			}
			
			if (sideForArrow != TOP) background.graphics.lineTo(marginText + w, 0);
			else {
				switch(alignForArrow) {
					case FIRST:
						background.graphics.lineTo(marginText + widthArrow / 2, -heightArrow);
						background.graphics.lineTo(marginText + widthArrow, 0);
						background.graphics.lineTo(marginText + w, 0);
						break;
					case CENTER:
						background.graphics.lineTo(marginText + (w / 2) - (widthArrow / 2), 0);
						background.graphics.lineTo(marginText + w / 2, -heightArrow);
						background.graphics.lineTo(marginText + (w / 2) + (widthArrow / 2), 0);
						background.graphics.lineTo(marginText + w, 0);
						break;
					case LAST:
						background.graphics.lineTo(marginText + w - widthArrow, 0);
						background.graphics.lineTo(marginText + w - widthArrow / 2, -heightArrow);
						background.graphics.lineTo(marginText + w, 0);
						break;
				}
			}
			
			if (roundCorner) background.graphics.curveTo(2 * marginText + w, 0, 2 * marginText + w, marginText);
			else {
				background.graphics.lineTo(2 * marginText + w, 0);
				background.graphics.lineTo(2 * marginText + w, marginText);
			}
			
			
			if (sideForArrow != RIGHT) background.graphics.lineTo(2 * marginText + w, marginText + h);
			else {
				switch(alignForArrow) {
					case FIRST:
						background.graphics.lineTo(2 * marginText + w + heightArrow, marginText + widthArrow / 2);
						background.graphics.lineTo(2 * marginText + w, marginText + widthArrow);
						background.graphics.lineTo(2 * marginText + w, marginText + h);
						break;
					case CENTER:
						background.graphics.lineTo(2 * marginText + w, marginText + h/2 - widthArrow / 2);
						background.graphics.lineTo(2 * marginText + w + heightArrow, marginText + h/2);
						background.graphics.lineTo(2 * marginText + w, marginText + (h/2) + (widthArrow / 2));
						background.graphics.lineTo(2 * marginText + w, marginText + h);
						break;
					case LAST:
						background.graphics.lineTo(2 * marginText + w, marginText + h - widthArrow);
						background.graphics.lineTo(2 * marginText + w + heightArrow, marginText + h - widthArrow / 2);
						background.graphics.lineTo(2 * marginText + w, marginText + h);
						break;
				}
			}
			
			if (roundCorner) background.graphics.curveTo(2 * marginText + w, 2 * marginText + h, marginText + w, 2 * marginText + h);
			else {
				background.graphics.lineTo(2 * marginText + w, 2 * marginText + h);
				background.graphics.lineTo(marginText + w, 2 * marginText + h);
			}
			
			if (sideForArrow != BOTTON) background.graphics.lineTo(marginText, 2 * marginText + h);
			else {
				switch(alignForArrow) {
					case FIRST:
						background.graphics.lineTo(marginText + widthArrow, 2 * marginText + h);
						background.graphics.lineTo(marginText + widthArrow / 2, 2 * marginText + h + heightArrow);
						background.graphics.lineTo(marginText, 2 * marginText + h);
						break;
					case CENTER:
						background.graphics.lineTo(marginText + w/2 + widthArrow/2, 2 * marginText + h);
						background.graphics.lineTo(marginText + w/2, 2 * marginText + h + heightArrow);
						background.graphics.lineTo(marginText + w / 2 - widthArrow / 2, 2 * marginText + h);
						background.graphics.lineTo(marginText, 2 * marginText + h);
						break;
					case LAST:
						background.graphics.lineTo(marginText + w - widthArrow/2, 2 * marginText + h + heightArrow);
						background.graphics.lineTo(marginText + w - widthArrow, 2 * marginText + h);
						background.graphics.lineTo(marginText, 2 * marginText + h);
						break;
				}
			}
			
			if (roundCorner) background.graphics.curveTo(0, 2 * marginText + h, 0, marginText + h);
			else {
				background.graphics.lineTo(0, 2 * marginText + h);
				background.graphics.lineTo(0, marginText + h);
			}
			
			
			if (sideForArrow != LEFT) background.graphics.lineTo(0, marginText);
			else {
				switch(alignForArrow) {
					case FIRST:
						background.graphics.lineTo(0, marginText + widthArrow);
						background.graphics.lineTo(-heightArrow, marginText + widthArrow / 2);
						background.graphics.lineTo(0, marginText);
						break;
					case CENTER:
						background.graphics.lineTo(0, marginText + h/2 + widthArrow / 2);
						background.graphics.lineTo(-heightArrow, marginText + h/2);
						background.graphics.lineTo(0, marginText + (h/2) - (widthArrow / 2));
						background.graphics.lineTo(0, marginText);
						break;
					case LAST:
						background.graphics.lineTo(- heightArrow, marginText + h - widthArrow / 2);
						background.graphics.lineTo(0, marginText + h - widthArrow);
						background.graphics.lineTo(0, marginText);
						break;
				}
			}
			
			if (roundCorner) background.graphics.curveTo(0, 0, marginText, 0);
			else {
				background.graphics.lineTo(0, 0);
				background.graphics.lineTo(marginText, 0);
			}
			
		}
		
		public function get roundCorner():Boolean 
		{
			return _roundCorner;
		}
		
		public function set roundCorner(value:Boolean):void 
		{
			_roundCorner = value;
		}
		
		public function setSideAlign(side:String, align:String):void
		{
			if (side != TOP || side != LEFT || side != RIGHT || side != BOTTON || align != FIRST || align != CENTER || align != LAST) return;
			
			this.sideForArrow = side;
			this.alignForArrow = align;
			
			//drawBackground(texto.textWidth, texto.textHeight);
		}
		
	}

}