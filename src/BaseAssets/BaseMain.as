package BaseAssets
{
	import BaseAssets.components.InfoBar;
	import BaseAssets.components.MenuBar;
	import BaseAssets.screens.AboutScreen;
	import BaseAssets.screens.FeedBackScreen;
	import BaseAssets.screens.GlassPane;
	import BaseAssets.screens.InstScreen;
	import BaseAssets.screens.StatsScreen;
	import cepa.utils.ToolTip;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class BaseMain extends Sprite
	{
		/**
		 * Borda da atividade.
		 */
		private var bordaAtividade:Borda;
		
		/**
		 * Menu com os botões.
		 */
		protected var botoes:MenuBar;
		
		//Telas da atividade:
		private var creditosScreen:AboutScreen;
		private var orientacoesScreen:InstScreen;
		protected var feedbackScreen:FeedBackScreen;
		protected var statsScreen:StatsScreen;
		
		private var glassPane:GlassPane;
		
		/**
		 * Atividade possui tela de desempenho?
		 */
		private var hasStats:Boolean = false;
		
		private var hasInfoBar:Boolean = true;
		
		protected var infoBar:InfoBar;
		
		private var rect:Rectangle = new Rectangle(0, 0, 700, 600);
		
		/*
		 * Filtro de conversão para tons de cinza.
		 */
		protected const GRAYSCALE_FILTER:ColorMatrixFilter = new ColorMatrixFilter([
			0.2225, 0.7169, 0.0606, 0, 0,
			0.2225, 0.7169, 0.0606, 0, 0,
			0.2225, 0.7169, 0.0606, 0, 0,
			0.0000, 0.0000, 0.0000, 1, 0
		]);
		
		/*
		 * Filtro de conversão para tons de cinza.
		 */
		protected const GRAYSCALE_FILTER_BLOCK:ColorMatrixFilter = new ColorMatrixFilter([
			0.2225, 0.7169, 0.0606, 0, 0,
			0.2225, 0.7169, 0.0606, 0, 0,
			0.2225, 0.7169, 0.0606, 0, 0,
			0.0000, 0.0000, 0.0000, 1, 0
		]);
		
		//Camadas:
		private var layerBorda:Sprite;
		private var layerDebug:Sprite;
		private var layerDialogo:Sprite;
		private var layerGlass:Sprite;
		protected var layerTuto:Sprite;
		private var layerBlock:Sprite;
		private var layerMenu:Sprite;
		protected var layerAtividade:Sprite;
		
		public function BaseMain() 
		{
			if (stage) baseInit();
			else addEventListener(Event.ADDED_TO_STAGE, baseInit);
		}
		
		private function baseInit(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, baseInit);
			
			scrollRect = rect;
			
			criaCamadas();
			criaTelas();
			adicionaBotoes();
			adicionaInfoBar();
			
			init();
		}
		
		protected function init():void {
			
		}
		
		/**
		 * Cria as camadas que serão utilizadas.
		 */
		protected function criaCamadas():void 
		{
			layerBorda = new Sprite();
			layerDebug = new Sprite();
			layerDialogo = new Sprite();
			layerGlass = new Sprite();
			layerTuto = new Sprite();
			layerBlock = new Sprite();
			layerMenu = new Sprite();
			layerAtividade = new Sprite();
			
			layerBlock.name = "block";
			layerBlock.graphics.beginFill(0xFFFFFF, 0);
			layerBlock.graphics.drawRect(0, 0, rect.width, rect.height);
			layerBlock.visible = false;
			
			super.addChild(layerAtividade);
			super.addChild(layerMenu);
			super.addChild(layerBlock);
			super.addChild(layerTuto);
			super.addChild(layerGlass);
			super.addChild(layerDialogo);
			super.addChild(layerDebug);
			super.addChild(layerBorda);
		}
		
		/**
		 * Cria as telas e adiciona no palco.
		 */
		protected function criaTelas():void 
		{
			glassPane = new GlassPane(rect.width, rect.height);
			layerGlass.addChild(glassPane);
			glassPane.visible = false;
			
			creditosScreen = new AboutScreen(glassPane);
			layerDialogo.addChild(creditosScreen);
			orientacoesScreen = new InstScreen(glassPane);
			layerDialogo.addChild(orientacoesScreen);
			feedbackScreen = new FeedBackScreen(glassPane);
			layerDialogo.addChild(feedbackScreen);
			
			if(hasStats){
				statsScreen = new StatsScreen(glassPane);
				layerDialogo.addChild(statsScreen);
			}
			
			botoes = new MenuBar();
			botoes.x = rect.width - botoes.BTN_WIDTH - 12;
			botoes.y = rect.height - 12;
			layerMenu.addChild(botoes);
			
			bordaAtividade = new Borda();
			MovieClip(bordaAtividade).scale9Grid = new Rectangle(20, 20, 610, 460);
			MovieClip(bordaAtividade).scaleX = rect.width / 650;
			MovieClip(bordaAtividade).scaleY = rect.height / 500;
			layerBorda.addChild(bordaAtividade);
		}
		
		private function adicionaBotoes():void 
		{
			botoes.addButton(new CreditBtn(), openCreditos, "Licença e créditos");
			botoes.addButton(new ResetBtn(), reset, "Reiniciar");
			botoes.addButton(new InstructionBtn(), openOrientacoes, "Orientações");
			botoes.addButton(new InfoBtn(), iniciaTutorial, "Reiniciar tutorial");
			if(hasStats) botoes.addButton(new BtStats(), openStats, "Desempenho");
		}
		
		private function adicionaInfoBar():void 
		{
			if (hasInfoBar) {
				infoBar = new InfoBar(rect.width, rect.width - 70);
				infoBar.y = rect.height;
				layerMenu.addChild(infoBar);
				layerMenu.setChildIndex(infoBar, 0);
			}
		}
		
		protected function lock(bt:*):void
		{
			bt.filters = [GRAYSCALE_FILTER];
			bt.alpha = 0.5;
			bt.mouseEnabled = false;
		}
		
		protected function unlock(bt:*):void
		{
			bt.filters = [];
			bt.alpha = 1;
			bt.mouseEnabled = true;
		}
		
		protected function blockAI():void
		{
			layerBlock.visible = true;
			
			//layerMenu.filters = [GRAYSCALE_FILTER_BLOCK];
			//layerAtividade.filters = [GRAYSCALE_FILTER_BLOCK];
			
			layerMenu.alpha = 0.5;
			layerAtividade.alpha = 0.5;
		}
		
		protected function unblockAI():void
		{
			layerBlock.visible = false;
			
			//layerMenu.filters = [];
			//layerAtividade.filters = [];
			
			layerMenu.alpha = 1;
			layerAtividade.alpha = 1;
		}
		
		/**
		 * Abrea a tela de orientações.
		 */
		private function openOrientacoes(e:MouseEvent):void 
		{
			orientacoesScreen.openScreen();
		}
		
		/**
		 * Abre a tela de créditos.
		 */
		private function openCreditos(e:MouseEvent):void 
		{
			creditosScreen.openScreen();
		}
		
		/**
		 * Abre a tela de estatísticas.
		 */
		protected function openStats(e:MouseEvent):void 
		{
			statsScreen.openScreen();
		}
		
		/**
		 * Inicia o tutorial da atividade.
		 */
		public function iniciaTutorial(e:MouseEvent = null):void 
		{
			
		}
		
		/**
		 * Reinicia a atividade, colocando-a no seu estado inicial.
		 */
		public function reset(e:MouseEvent = null):void 
		{
			
		}
		
	}

}