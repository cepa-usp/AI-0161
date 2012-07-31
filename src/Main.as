package 
{
	import BaseAssets.BaseMain;
	import BaseAssets.tutorial.CaixaTexto;
	import com.adobe.serialization.json.JSON;
	import cepa.utils.ToolTip;
	import com.eclecticdesignstudio.motion.Actuate;
	import fl.transitions.easing.None;
	import fl.transitions.Tween;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import pipwerks.SCORM;
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends BaseMain
	{
		//private var tweenX:Tween;
		//private var tweenY:Tween;
		//
		//private var tweenX2:Tween;
		//private var tweenY2:Tween;
		
		private var tweenTime:Number = 0.2;
		
		private var fundoLayer:Sprite;
		private var pecasLayer:Sprite;
		
		override protected function init():void 
		{
			fundoLayer = new Sprite();
			addChild(fundoLayer);
			pecasLayer = new Sprite();
			addChild(pecasLayer);
			
			//organizeLayers();
			addListeners();
			createAnswer();
			
			if (ExternalInterface.available) {
				initLMSConnection();
				if (mementoSerialized != null) {
					if(mementoSerialized != "" && mementoSerialized != "null") recoverStatus(mementoSerialized);
				}
			}
			verificaFinaliza();
			
			
			if (completed) {
				travaPecas();
			}else iniciaTutorial();
			
			//if(!completed) iniciaTutorial();
		}
		
		private function organizeLayers():void 
		{
			for (var i:int = 0; i < numChildren; i++) 
			{
				var child:DisplayObject = getChildAt(i);
				if (child is Peca) {
					addChild(child)
				}else if (child is Fundo) {
					addChild(child);
				}
			}
		}
		
		private function addListeners():void 
		{
			finaliza.addEventListener(MouseEvent.CLICK, finalizaExec);
			finaliza.buttonMode = true;
		}
		
		private function finalizaExec(e:MouseEvent):void 
		{
			var nCertas:int = 0;
			var nPecas:int = 0;
			
			for (var i:int = 0; i < numChildren; i++) 
			{
				var child:DisplayObject = getChildAt(i);
				if (child is Peca) {
					nPecas++;
					if(Peca(child).fundo.indexOf(Peca(child).currentFundo) != -1){
						nCertas++;
						trace(Peca(child).nome);
					}
				}
			}
			
			var currentScore:Number = int((nCertas / nPecas) * 100);
			
			if (currentScore < 100) {
				feedbackScreen.setText("Ops!... \nReveja sua resposta.\nInicie uma nova tentativa para refazer o exercício.");
			}
			else {
				feedbackScreen.setText("Parabéns!\nSua resposta está correta!");
			}
			
			if (!completed) {
				completed = true;
				score = currentScore;
				saveStatus();
				commit();
				
				travaPecas();
			}
			
			//setChildIndex(feedbackScreen, numChildren - 1);
			//setChildIndex(bordaAtividade, numChildren - 1);
		}
		
		private function travaPecas():void 
		{
			for (var i:int = 0; i < numChildren; i++) 
			{
				var child:DisplayObject = getChildAt(i);
				if (child is Peca) {
					Peca(child).mouseEnabled = false;
				}
			}
			
			//finaliza.mouseEnabled = false;
			//finaliza.alpha = 0.5;
			
			//botoes.resetButton.mouseEnabled = false;
			//botoes.resetButton.alpha = 0.5;
		}
		
		private function verificaFinaliza():void 
		{
			for (var i:int = 0; i < numChildren; i++) 
			{
				var child:DisplayObject = getChildAt(i);
				if (child is Peca) {
					if(Peca(child).currentFundo == null){
						finaliza.mouseEnabled = false;
						finaliza.alpha = 0.5;
						return;
					}
				}
			}
			
			finaliza.mouseEnabled = true;
			finaliza.alpha = 1;
		}
		
		private function checkForFinish():Boolean
		{
			for (var i:int = 0; i < numChildren; i++) 
			{
				var child:DisplayObject = getChildAt(i);
				
				if (child is Peca) {
					if (Peca(child).currentFundo == null) return false;
				}
			}
			
			return true;
		}
		
		private function createAnswer():void 
		{
			for (var i:int = 0; i < numChildren; i++) 
			{
				var child:DisplayObject = getChildAt(i);
				if (child is Peca) {
					setAnswerForPeca(Peca(child));
					var objClass:Class = Class(getDefinitionByName(getQualifiedClassName(child)));
					var ghostObj:* = new objClass();
					MovieClip(ghostObj).gotoAndStop(1);
					Peca(child).ghost = ghostObj;
					Peca(child).addListeners();
					Peca(child).inicialPosition = new Point(child.x, child.y);
					child.addEventListener("paraArraste", verifyPosition);
					child.addEventListener("iniciaArraste", verifyForFilter);
					Peca(child).buttonMode = true;
					Peca(child).gotoAndStop(1);
				}
			}
		}
		
		private function saveStatusForRecovery(e:MouseEvent = null):void
		{
			var status:Object = new Object();
			
			status.pecas = new Object();
			
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:DisplayObject = getChildAt(i);
				if (child is Peca) {
					if (Peca(child).currentFundo != null) status.pecas[child.name] = Peca(child).currentFundo.name;
					else status.pecas[child.name] = "null";
				}
			}
			
			mementoSerialized = JSON.encode(status);
		}
		
		private function recoverStatus(memento:String):void
		{
			var status:Object = JSON.decode(memento);
			
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:DisplayObject = getChildAt(i);
				if (child is Peca) {
					if (status.pecas[child.name] != "null") {
						Peca(child).currentFundo = getFundoByName(status.pecas[child.name]);
						Fundo(Peca(child).currentFundo).currentPeca = Peca(child);
						Peca(child).x = Peca(child).currentFundo.x;
						Peca(child).y = Peca(child).currentFundo.y + 10;
						Peca(child).gotoAndStop(2);
					}
				}
			}
			
		}
		
		private var pecaDragging:Peca;
		//private var fundoFilter:GlowFilter = new GlowFilter(0xFF0000, 1, 20, 20, 1, 2, true, true);
		private var fundoFilter:GlowFilter = new GlowFilter(0x800000);
		private var fundoWGlow:MovieClip;
		private function verifyForFilter(e:Event):void 
		{
			pecaDragging = Peca(e.target);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, verifying);
		}
		
		private function verifying(e:MouseEvent):void 
		{
			var fundoUnder:Fundo = getFundo(new Point(pecaDragging.ghost.x, pecaDragging.ghost.y));
			
			if (fundoUnder != null) {
				/*if (fundoUnder.currentPeca != null) {
					if (fundoWGlow == null) {
						fundoWGlow = fundoUnder.currentPeca;
						fundoWGlow.gotoAndStop(2);
					}else {
						if (fundoWGlow is Fundo) {
							fundoWGlow.borda.filters = [];
						}else {
							fundoWGlow.gotoAndStop(1);
						}
						fundoWGlow = fundoUnder.currentPeca;
						fundoWGlow.gotoAndStop(2);
					}
				}else{*/
					if (fundoWGlow == null) {
						fundoWGlow = fundoUnder;
						fundoWGlow.borda.filters = [fundoFilter];
					}else {
						if (fundoWGlow is Fundo) {
							fundoWGlow.borda.filters = [];
						}else {
							fundoWGlow.gotoAndStop(1);
						}
						fundoWGlow = fundoUnder;
						fundoWGlow.borda.filters = [fundoFilter];
					}
				//}
			}else {
				if (fundoWGlow != null) {
					if(fundoWGlow is Fundo){
						Fundo(fundoWGlow).borda.filters = [];
					}else {
						fundoWGlow.gotoAndStop(1);
					}
					fundoWGlow = null;
				}
			}
		}
		
		private function verifyPosition(e:Event):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, verifying);
			pecaDragging = null;
			if (fundoWGlow != null) {
				if (fundoWGlow is Fundo) fundoWGlow.borda.filters = [];
				else fundoWGlow.gotoAndStop(1);
				fundoWGlow = null;
			}
			
			var peca:Peca = e.target as Peca;
			var fundoDrop:Fundo = getFundo(peca.position);
			
			if (fundoDrop != null) {
				if (fundoDrop.currentPeca == null) {
					if (peca.currentFundo != null) {
						Fundo(peca.currentFundo).currentPeca = null;
					}
					fundoDrop.currentPeca = peca;
					peca.currentFundo = fundoDrop;
					//tweenX = new Tween(peca, "x", None.easeNone, peca.x, fundoDrop.x, 0.5, true);
					//tweenY = new Tween(peca, "y", None.easeNone, peca.y, fundoDrop.y, 0.5, true);
					peca.x = fundoDrop.x;
					peca.y = fundoDrop.y + 10;
					peca.gotoAndStop(2);
				}else {
					if(peca.currentFundo != null){
						var pecaFundo:Peca = Peca(fundoDrop.currentPeca);
						var fundoPeca:Fundo = Fundo(peca.currentFundo);
						
						Actuate.tween(peca, tweenTime, { x:fundoDrop.x, y:fundoDrop.y + 10 } );
						//tweenX = new Tween(peca, "x", None.easeNone, peca.x, fundoDrop.x, tweenTime, true);
						//tweenY = new Tween(peca, "y", None.easeNone, peca.y, fundoDrop.y + 20, tweenTime, true);
						
						Actuate.tween(pecaFundo, tweenTime, { x:fundoPeca.x, y:fundoPeca.y + 10} );
						//tweenX2 = new Tween(pecaFundo, "x", None.easeNone, pecaFundo.x, fundoPeca.x, tweenTime, true);
						//tweenY2 = new Tween(pecaFundo, "y", None.easeNone, pecaFundo.y, fundoPeca.y + 20, tweenTime, true);
						
						peca.currentFundo = fundoDrop;
						fundoDrop.currentPeca = peca;
						
						pecaFundo.currentFundo = fundoPeca;
						fundoPeca.currentPeca = pecaFundo;
					}else {
						pecaFundo = Peca(fundoDrop.currentPeca);
						
						//tweenX = new Tween(peca, "x", None.easeNone, peca.position.x, fundoDrop.x, tweenTime, true);
						//tweenY = new Tween(peca, "y", None.easeNone, peca.position.y, fundoDrop.y, tweenTime, true);
						peca.x = fundoDrop.x;
						peca.y = fundoDrop.y + 10;
						peca.gotoAndStop(2);
						
						Actuate.tween(pecaFundo, tweenTime, { x:pecaFundo.inicialPosition.x, y:pecaFundo.inicialPosition.y + 10} );
						//tweenX2 = new Tween(pecaFundo, "x", None.easeNone, pecaFundo.x, pecaFundo.inicialPosition.x, tweenTime, true);
						//tweenY2 = new Tween(pecaFundo, "y", None.easeNone, pecaFundo.y, pecaFundo.inicialPosition.y, tweenTime, true);
						
						peca.currentFundo = fundoDrop;
						fundoDrop.currentPeca = peca;
						
						pecaFundo.currentFundo = null;
						pecaFundo.gotoAndStop(1);
					}
				}
			}else {
				if (peca.currentFundo != null) {
					Fundo(peca.currentFundo).currentPeca = null;
					peca.currentFundo = null;
				}
				
				Actuate.tween(peca, tweenTime, { x:peca.inicialPosition.x, y:peca.inicialPosition.y} );
				//tweenX = new Tween(peca, "x", None.easeNone, peca.x, peca.inicialPosition.x, tweenTime, true);
				//tweenY = new Tween(peca, "y", None.easeNone, peca.y, peca.inicialPosition.y, tweenTime, true);
				peca.gotoAndStop(1);
			}
			
			verificaFinaliza();
			
			//setTimeout(saveStatus, (tweenTime + 0.1) * 1000);
			Actuate.timer(tweenTime + 0.1).onComplete(saveStatus);
		}
		
		private function getFundo(position:Point):Fundo 
		{
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:DisplayObject = getChildAt(i);
				if (child is Fundo) {
					if (child.hitTestPoint(position.x, position.y)) return Fundo(child);
				}
			}
			return null;
		}
		
		private function getFundoByName(name:String):Fundo 
		{
			if (name == "") return null;
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:DisplayObject = getChildAt(i);
				if (child is Fundo) {
					if (child.name == name) return Fundo(child);
				}
			}
			return null;
		}
		
		private function setAnswerForPeca(child:Peca):void 
		{
			if (child is Peca1) {
				child.fundo = [fundo1];
				child.nome = "peca1";
			}else if (child is Peca2) {
				child.fundo = [fundo2];
				child.nome = "peca2";
			}else if (child is Peca3) {
				child.fundo = [fundo3];
				child.nome = "peca3";
			}else if (child is Peca4) {
				child.fundo = [fundo4];
				child.nome = "peca4";
			}else if (child is Peca5) {
				child.fundo = [fundo5];
				child.nome = "peca5";
				makeOverOut(child);
			}else if (child is Peca6) {
				child.fundo = [fundo6];
				child.nome = "peca6";
				makeOverOut(child);
			}else if (child is Peca7) {
				child.fundo = [fundo7];
				child.nome = "peca7";
				makeOverOut(child);
			}else if (child is Peca8) {
				child.fundo = [fundo8];
				child.nome = "peca8";
				makeOverOut(child);
			}else if (child is Peca9) {
				child.fundo = [fundo9, fundo10];
				child.nome = "peca9";
			}else if (child is Peca10) {
				child.fundo = [fundo10, fundo9];
				child.nome = "peca10";
			}else if (child is Peca11) {
				child.fundo = [fundo11];
				child.nome = "peca11";
				makeOverOut(child);
			}else if (child is Peca12) {
				child.fundo = [fundo12];
				child.nome = "peca12";
			}else if (child is Peca13) {
				child.fundo = [fundo13];
				child.nome = "peca13";
			}else if (child is Peca14) {
				child.fundo = [fundo14];
				child.nome = "peca14";
				makeOverOut(child);
			}
			
			//pecasLayer.addChild(child);
		}
		
		private function makeOverOut(peca:MovieClip):void
		{
			peca.addEventListener(MouseEvent.MOUSE_OVER, overChid);
			peca.addEventListener(MouseEvent.MOUSE_OUT, outChid);
		}
		
		private var alturaPecaOver:Number;
		private function overChid(e:MouseEvent):void
		{
			var peca:Peca = Peca(e.target);
			
			if (peca.currentFundo != null) {
				peca.gotoAndStop(4);
				alturaPecaOver = peca.currentFundo.height;
				peca.currentFundo.height = peca.height;
			}else {
				peca.gotoAndStop(3);
			}
		}
		
		private function outChid(e:MouseEvent):void
		{
			var peca:Peca = Peca(e.target);
			
			if (peca.currentFundo != null) {
				peca.gotoAndStop(2);
				peca.currentFundo.height = alturaPecaOver;
			}else {
				peca.gotoAndStop(1);
			}
		}
		
		override public function reset(e:MouseEvent = null):void
		{
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:DisplayObject = getChildAt(i);
				if (child is Peca) {
					child.x = Peca(child).inicialPosition.x;
					child.y = Peca(child).inicialPosition.y;
					Peca(child).currentFundo = null;
					Peca(child).gotoAndStop(1);
				}
				if (child is Fundo) {
					Fundo(child).currentPeca = null;
				}
			}
			
			verificaFinaliza();
			saveStatus();
		}
		
		
		//---------------- Tutorial -----------------------
		
		private var balao:CaixaTexto;
		private var pointsTuto:Array;
		private var tutoBaloonPos:Array;
		private var tutoPos:int;
		private var tutoSequence:Array = ["Arraste os conceitos...", 
										  "... para as caixas corretas...",
										  "... conforme descrito nas orientações.",
										  "Quando você tiver concluído, pressione \"terminei\"."];
		
		override public function iniciaTutorial(e:MouseEvent = null):void  
		{
			tutoPos = 0;
			if(balao == null){
				balao = new CaixaTexto(true);
				addChild(balao);
				balao.visible = false;
				
				pointsTuto = 	[new Point(405, 460),
								new Point(348 , 180),
								new Point(650 , 543),
								new Point(finaliza.x, finaliza.y + finaliza.height / 2)];
								
				tutoBaloonPos = [[CaixaTexto.BOTTON, CaixaTexto.CENTER],
								[CaixaTexto.TOP, CaixaTexto.CENTER],
								[CaixaTexto.RIGHT, CaixaTexto.FIRST],
								[CaixaTexto.TOP, CaixaTexto.FIRST]];
			}
			balao.removeEventListener(Event.CLOSE, closeBalao);
			
			balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
			balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			balao.addEventListener(Event.CLOSE, closeBalao);
			balao.visible = true;
		}
		
		private function closeBalao(e:Event):void 
		{
			tutoPos++;
			if (tutoPos >= tutoSequence.length) {
				balao.removeEventListener(Event.CLOSE, closeBalao);
				balao.visible = false;
			}else {
				balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
				balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			}
		}
		
		
		/*------------------------------------------------------------------------------------------------*/
		//SCORM:
		
		private const PING_INTERVAL:Number = 5 * 60 * 1000; // 5 minutos
		private var completed:Boolean;
		private var scorm:SCORM;
		private var scormExercise:int;
		private var connected:Boolean;
		private var score:int = 0;
		private var pingTimer:Timer;
		private var mementoSerialized:String = "";
		
		/**
		 * @private
		 * Inicia a conexão com o LMS.
		 */
		private function initLMSConnection () : void
		{
			completed = false;
			connected = false;
			scorm = new SCORM();
			
			pingTimer = new Timer(PING_INTERVAL);
			pingTimer.addEventListener(TimerEvent.TIMER, pingLMS);
			
			connected = scorm.connect();
			
			if (connected) {
				
				if (scorm.get("cmi.mode" != "normal")) return;
				
				scorm.set("cmi.exit", "suspend");
				// Verifica se a AI já foi concluída.
				var status:String = scorm.get("cmi.completion_status");	
				mementoSerialized = scorm.get("cmi.suspend_data");
				var stringScore:String = scorm.get("cmi.score.raw");
				
				switch(status)
				{
					// Primeiro acesso à AI
					case "not attempted":
					case "unknown":
					default:
						completed = false;
						break;
					
					// Continuando a AI...
					case "incomplete":
						completed = false;
						break;
					
					// A AI já foi completada.
					case "completed":
						completed = true;
						//setMessage("ATENÇÃO: esta Atividade Interativa já foi completada. Você pode refazê-la quantas vezes quiser, mas não valerá nota.");
						break;
				}
				
				//unmarshalObjects(mementoSerialized);
				scormExercise = 1;
				score = Number(stringScore.replace(",", "."));
				
				var success:Boolean = scorm.set("cmi.score.min", "0");
				if (success) success = scorm.set("cmi.score.max", "100");
				
				if (success)
				{
					scorm.save();
					pingTimer.start();
				}
				else
				{
					//trace("Falha ao enviar dados para o LMS.");
					connected = false;
				}
			}
			else
			{
				trace("Esta Atividade Interativa não está conectada a um LMS: seu aproveitamento nela NÃO será salvo.");
				mementoSerialized = ExternalInterface.call("getLocalStorageString");
			}
			
			//reset();
		}
		
		/**
		 * @private
		 * Salva cmi.score.raw, cmi.location e cmi.completion_status no LMS
		 */ 
		private function commit()
		{
			if (connected)
			{
				if (scorm.get("cmi.mode" != "normal")) return;
				
				// Salva no LMS a nota do aluno.
				var success:Boolean = scorm.set("cmi.score.raw", score.toString());

				// Notifica o LMS que esta atividade foi concluída.
				success = scorm.set("cmi.completion_status", (completed ? "completed" : "incomplete"));

				// Salva no LMS o exercício que deve ser exibido quando a AI for acessada novamente.
				success = scorm.set("cmi.location", scormExercise.toString());
				
				// Salva no LMS a string que representa a situação atual da AI para ser recuperada posteriormente.
				//mementoSerialized = marshalObjects();
				success = scorm.set("cmi.suspend_data", mementoSerialized.toString());

				if (success)
				{
					scorm.save();
				}
				else
				{
					pingTimer.stop();
					//setMessage("Falha na conexão com o LMS.");
					connected = false;
				}
			}else { //LocalStorage
				ExternalInterface.call("save2LS", mementoSerialized);
			}
		}
		
		/**
		 * @private
		 * Mantém a conexão com LMS ativa, atualizando a variável cmi.session_time
		 */
		private function pingLMS (event:TimerEvent)
		{
			//scorm.get("cmi.completion_status");
			commit();
		}
		
		private function saveStatus(e:Event = null):void
		{
			if (ExternalInterface.available) {
				if (connected) {
					
					if (scorm.get("cmi.mode" != "normal")) return;
					
					saveStatusForRecovery();
					scorm.set("cmi.suspend_data", mementoSerialized);
					commit();
				}else {//LocalStorage
					saveStatusForRecovery();
					ExternalInterface.call("save2LS", mementoSerialized);
				}
			}
		}
		
	}

}