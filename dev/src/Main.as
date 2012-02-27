package 
{
	import cepa.utils.Cronometer;
	import cepa.utils.ToolTip;
	import fl.transitions.easing.None;
	import fl.transitions.Tween;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends Sprite
	{
		//Constantes:
		private const BEGIN:String = "BEGIN";
		private const WAITING_SHOT:String = "WAITING_SHOT";
		private const POS_SHOT:String = "POS_SHOT";
		private const END:String = "END";
		
		private const LEGENDA_BEGIN:String = "Clique em OK para iniciar.Atenção ao tempo.";
		private const LEGENDA_WAITING_SHOT:String = "Preencha as coordenadas e clique em OK.";
		private const LEGENDA_POS_SHOT:String = "Clique em OK para uma nova posição do alvo.";
		private const LEGENDA_END:String = "Exercício finalizado. Clique em \"Reset\" para iniciar um novo exercício.";
		
		private var state:String;
		
		//Configurações lidas externamente:
		private var totalTime:Number;
		private var timeDecrease:Number;
		private var raioMax:Number;
		private var maxTimePoints:Number;
		private var distance_center:Number;
		private var distance_middle:Number;
		private var distance_end:Number;
		private var distance_posEnd:Number;
		private var score_center:Number;
		private var score_middle:Number;
		private var score_end:Number;
		private var score_posEnd:Number;
		
		//Telas de orientações e créditos
		private var orientacoesScreen:InstScreen;
		private var creditosScreen:AboutScreen;
		
		/**
		 * Arquivo de configurações externo
		 */
		private var xmlConfig:XML;
		
		private var currentTotalTime:Number;
		private var currentScore:Number;
		
		private var tweenX:Tween;
		private var tweenY:Tween;
		
		private var timerToFinish:Cronometer;
		private var visualTimer:VisualTimer;
		
		private var alvoUser:AlvoUsuario;
		private var marcas:Array = [];
		
		private var posCentral:Point = new Point(339.3, 248.55);
		private var raioPalco:Number = 388.3 / 2;
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			creditosScreen = new AboutScreen();
			addChild(creditosScreen);
			orientacoesScreen = new InstScreen();
			addChild(orientacoesScreen);
			
			initVariables();
			loadConfig();
			addListeners();
			
		}
		
		private function initVariables():void 
		{
			timerToFinish = new Cronometer();
			
			visualTimer = new VisualTimer();
			visualTimer.x = 666;
			visualTimer.y = 32;
			addChild(visualTimer);
			
			alvoUser = new AlvoUsuario();
			addChild(alvoUser);
			alvoUser.visible = false;
		}
		
		private function loadConfig():void 
		{
			var urlReq:URLRequest = new URLRequest("config.xml");
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.load(urlReq);
			urlLoader.addEventListener(Event.COMPLETE, readXML);
		}
		
		private function readXML(e:Event):void 
		{
			xmlConfig = new XML(e.target.data);
			
			totalTime = 		Number(xmlConfig.time);
			timeDecrease = 		Number(xmlConfig.timeDecrease);
			raioMax = 			Number(xmlConfig.raio);
			maxTimePoints = 	Number(xmlConfig.maxTimePoints);
			distance_center = 	Number(xmlConfig.distances.center);
			distance_middle = 	Number(xmlConfig.distances.middle);
			distance_end = 		Number(xmlConfig.distances.end);
			distance_posEnd = 	Number(xmlConfig.distances.posEnd);
			score_center = 		Number(xmlConfig.targetScore.center);
			score_middle = 		Number(xmlConfig.targetScore.middle);
			score_end = 		Number(xmlConfig.targetScore.end);
			score_posEnd = 		Number(xmlConfig.targetScore.posEnd);
			
			reset();
		}
		
		private function addListeners():void 
		{
			botoes.orientacoesBtn.addEventListener(MouseEvent.CLICK, openOrientacoes);
			botoes.resetButton.addEventListener(MouseEvent.CLICK, reset);
			botoes.creditos.addEventListener(MouseEvent.CLICK, openCreditos);
			
			createToolTips();
			
			okBtn.addEventListener(MouseEvent.CLICK, switchState);
		}
		
		private function switchState(e:MouseEvent):void 
		{
			switch(state) {
				case BEGIN:
					randomizeTargetPosition();
					startTimer();
					state = WAITING_SHOT;
					setLegenda(LEGENDA_WAITING_SHOT);
					return;
				case WAITING_SHOT:
					if (fillComplete()) {
						timerFinished();
						shoot();
						state = POS_SHOT;
						setLegenda(LEGENDA_POS_SHOT);
					}else {
						
					}
					return;
				case POS_SHOT:
					randomizeTargetPosition();
					startTimer();
					state = WAITING_SHOT;
					alvoUser.visible = false;
					setLegenda(LEGENDA_WAITING_SHOT);
					return;
				case END:
					
					return;
			}
		}
		
		private function shoot():void 
		{
			var raioUser:Number = Number(entrada.raio.text.replace(",", ".")) * raioPalco / raioMax;
			var angleUser:Number = - Number(entrada.angle.text.replace(",", ".")) * Math.PI / 180;
			
			alvoUser.x = (raioUser * Math.cos(angleUser)) + posCentral.x;
			alvoUser.y = (raioUser * Math.sin(angleUser)) + posCentral.y;
			alvoUser.visible = true;
			
			var marca:Marca = new Marca();
			marca.x = alvoUser.x;
			marca.y = alvoUser.y;
			marcas.push(marca);
			addChild(marca);
		}
		
		private function fillComplete():Boolean 
		{
			if (entrada.raio.text == "") return false;
			if (entrada.angle.text == "") return false;
			
			return true;
		}
		
		private function openCreditos(e:MouseEvent):void 
		{
			creditosScreen.openScreen();
			setChildIndex(creditosScreen, numChildren - 1);
			setChildIndex(borda, numChildren - 1);
		}
		
		private function openOrientacoes(e:MouseEvent):void 
		{
			orientacoesScreen.openScreen();
			setChildIndex(orientacoesScreen, numChildren - 1);
			setChildIndex(borda, numChildren - 1);
		}
		
		private function createToolTips():void 
		{
			var infoTT:ToolTip = new ToolTip(botoes.creditos, "Créditos", 12, 0.8, 100, 0.6, 0.1);
			var instTT:ToolTip = new ToolTip(botoes.orientacoesBtn, "Orientações", 12, 0.8, 100, 0.6, 0.1);
			var resetTT:ToolTip = new ToolTip(botoes.resetButton, "Reiniciar", 12, 0.8, 100, 0.6, 0.1);
			
			addChild(infoTT);
			addChild(instTT);
			addChild(resetTT);
		}
		
		private function reset(e:MouseEvent = null):void 
		{
			currentTotalTime = totalTime + timeDecrease;
			currentScore = 0;
			
			state = BEGIN;
			setLegenda(this["LEGENDA_" + state]);
		}
		
		/**
		 * Atualiza a legenda da atividade de acordo com o texto passado.
		 * @param	txt Texto para atualizar a legenda.
		 */
		private function setLegenda(txt:String):void
		{
			legenda.texto.text = txt;
		}
		
		private function randomizeTargetPosition():void
		{
			var raioRand:Number = Math.random() * raioPalco;
			var angleRand:Number = (Math.random() * 365) * Math.PI / 180;
			
			tweenX = new Tween(alvo, "x", None.easeNone, alvo.x, raioRand * Math.cos(angleRand) + posCentral.x, 0.5, true);
			tweenY = new Tween(alvo, "y", None.easeNone, alvo.y, raioRand * Math.sin(angleRand) + posCentral.y, 0.5, true);
		}
		
		private function startTimer():void
		{
			currentTotalTime -= timeDecrease;
			timerToFinish.reset();
			timerToFinish.start();
			visualTimer.start(timerToFinish, totalTime - currentTotalTime);
			addEventListener(Event.ENTER_FRAME, checkCronometer);
		}
		
		private function checkCronometer(e:Event):void 
		{
			if (timerToFinish.read()/1000 >= totalTime) {
				timerFinished();
			}
		}
		
		private function timerFinished():void
		{
			trace("fim");
			removeEventListener(Event.ENTER_FRAME, checkCronometer);
			timerToFinish.pause();
			visualTimer.stop();
		}
		
		
		//Programação do jogo:
		
		
	}

}