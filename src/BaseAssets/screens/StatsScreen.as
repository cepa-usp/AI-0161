package BaseAssets.screens
{
	import BaseAssets.events.BaseEvent;
	import com.eclecticdesignstudio.motion.Actuate;
	import com.eclecticdesignstudio.motion.easing.Elastic;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class StatsScreen extends MovieClip
	{
		private var glassPane:GlassPane;
		private var stats:Object = new Object();
		
		public function StatsScreen(glass:GlassPane) 
		{
			glassPane = glass;
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.x = stage.stageWidth / 2;
			this.y = stage.stageHeight / 2;
			
			//this.closeButton.addEventListener(MouseEvent.CLICK, closeScreen);
			stage.addEventListener(KeyboardEvent.KEY_UP, escCloseScreen);
			addEventListener(KeyboardEvent.KEY_UP, escCloseScreen);
			closeButton.addEventListener(MouseEvent.CLICK, closeScreen);

			this.scaleX = this.scaleY = 0;
			this.visible = false;
			
			stats.nTotal = 0;
			stats.nValendo = 0;
			stats.nNaoValendo = 0;
			stats.scoreMin = 0;
			stats.scoreTotal = 0;
			stats.scoreValendo = 0;
			stats.valendo = false;
		}
		
		private function escCloseScreen(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.ESCAPE) {
				if (this.visible) closeScreen(null);
			}
		}
		
		private function closeScreen(e:MouseEvent):void 
		{
			Actuate.tween(glassPane, 0.4, { scaleX:0, scaleY:0 } );
			Actuate.tween(this, 0.4, { scaleX:0, scaleY:0 } ).onComplete(turnInvisible);
		}
		
		private function turnInvisible():void 
		{
			this.visible = false;
			glassPane.visible = false;
			dispatchEvent(new BaseEvent(BaseEvent.CLOSE_SCREEN, true));
		}
		
		public function openScreen():void
		{
			updateStatics();
			
			glassPane.x = this.x;
			glassPane.y = this.y;
			glassPane.scaleX = glassPane.scaleY = 0;
			this.visible = true;
			glassPane.visible = true;
			Actuate.tween(glassPane, 0.4, { scaleX:1, scaleY:1 } );
			Actuate.tween(this, 0.6, { scaleX:1, scaleY:1 } ).ease(Elastic.easeOut);
		}
		
		public function updateStatics(stats:Object = null):void
		{
			if(stats != null){
				this.stats.nTotal = stats.nTotal;
				this.stats.nValendo = stats.nValendo;
				this.stats.nNaoValendo = stats.nNaoValendo;
				this.stats.scoreMin = stats.scoreMin;
				this.stats.scoreTotal = stats.scoreTotal;
				this.stats.scoreValendo = stats.scoreValendo;
				this.stats.valendo = stats.valendo;
			}
			
			nTotal.text = this.stats.nTotal;
			nValendo.text = this.stats.nValendo;
			nNaoValendo.text = this.stats.nNaoValendo;
			scoreMin.text = String(this.stats.scoreMin).replace(".", "");
			scoreTotal.text = String(this.stats.scoreTotal).replace(".", "");
			scoreValendo.text = String(this.stats.scoreValendo).replace(".", "");
			
			if (this.stats.valendo) {
				valendoMC.gotoAndStop("VALENDO");
			}
			else {
				valendoMC.gotoAndStop("NAO_VALENDO");
			}
		}
		
	}

}