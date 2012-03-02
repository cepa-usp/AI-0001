package 
{
	import cepa.utils.Cronometer;
	import cepa.utils.ToolTip;
	import fl.transitions.easing.Elastic;
	import fl.transitions.easing.None;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
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
		
		private const LEGENDA_BEGIN:String = "Pressione o botão \"iniciar\" para começar um novo arremesso.";
		private const LEGENDA_WAITING_SHOT:String = "Digite as coordenadas polares do alvo e pressione \"atirar\".";
		private const LEGENDA_POS_SHOT:String = "Pressione o botão \"iniciar\" para começar um novo arremesso.";
		private const LEGENDA_END:String = "Exercício finalizado. Clique em \"reiniciar\" para iniciar um novo exercício.";
		
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
		private var score_bird:Number;
		
		//Sons
		private var birdSound:Sound;
		private var dardoSound:Sound;
		private var scoreSound:Sound;
		private var clockSound:Sound;
		
		private var audio:SoundChannel;
		
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
		
		private var regua:RotatingRuler;
		private var transferidor:RotatingTransferidor;
		
		private var passaro:MovieClip;
		private var timerToPassaro:Timer;
		private var tweenPassaro:Tween;
		
		private var shotAnimation:MovieClip;
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			scrollRect = new Rectangle(0, 0, 700, 600);
			
			creditosScreen = new AboutScreen();
			addChild(creditosScreen);
			orientacoesScreen = new InstScreen();
			addChild(orientacoesScreen);
			
			initVariables();
			loadConfig();
			addListeners();
			
			iniciaTutorial();
		}
		
		private function initVariables():void 
		{
			timerToFinish = new Cronometer();
			
			audio = new SoundChannel();
			
			shotAnimation = new MovieClip();
			shotAnimation.gotoAndStop("FINISH");
			shotAnimation.addEventListener(Event.ACTIVATE, shoot);
			
			visualTimer = new VisualTimer();
			visualTimer.x = 0;
			visualTimer.y = -34;
			tempoPonto.addChild(visualTimer);
			
			alvoUser = new AlvoUsuario();
			addChild(alvoUser);
			alvoUser.visible = false;
			
			regua = new RotatingRuler();
			addChild(regua);
			regua.atractors = [posCentral];
			regua.close();
			regua.x = 80;
			regua.y = 250;

			transferidor = new RotatingTransferidor();
			addChild(transferidor);
			transferidor.atractors = [posCentral];
			transferidor.close();
			
			setChildIndex(entrada, numChildren - 1);
			setChildIndex(ferramentas, numChildren - 1);
			setChildIndex(tempoPonto, numChildren - 1);
			setChildIndex(botoes, numChildren - 1);
			setChildIndex(legenda, numChildren - 1);
			
			entrada.raio.restrict = "0123456789.,";
			entrada.angle.restrict = "0123456789.,\\-";
			
			timerToPassaro = new Timer(Math.random() * 60000, 1);
			timerToPassaro.addEventListener(TimerEvent.TIMER_COMPLETE, criaPassaro);
			timerToPassaro.start();
		}
		
		private function criaPassaro(e:TimerEvent):void 
		{
			passaro = new Passaro();
			var finish:Number;
			
			if (Math.random() > 0.5) {
				passaro.x = -100;
				passaro.y = Math.random() * 400 + 50;
				finish = 800;
				
			}else {
				passaro.x = 800;
				passaro.y = Math.random() * 400 + 50;
				finish = -100;
				passaro.scaleX = -1;
			}
			
			addChild(passaro);
			setChildIndex(passaro, Math.round(Math.random() * 5));
			tweenPassaro = new Tween(passaro, "x", None.easeNone, passaro.x, finish, Math.round(Math.random() * 4) + 6, true);
			tweenPassaro.addEventListener(TweenEvent.MOTION_FINISH, createNewPassaro, false, 0, true);
		}
		
		private function createNewPassaro(e:TweenEvent):void 
		{
			if (tweenPassaro != null) {
				if (tweenPassaro.isPlaying) {
					tweenPassaro.stop();
				}
			}
			
			if (tweenAlpha != null) {
				if (tweenAlpha.isPlaying) {
					tweenAlpha.stop();
				}
			}
			
			if (tweenYPassaro != null) {
				if (tweenYPassaro.isPlaying) {
					tweenYPassaro.stop();
				}
			}
			
			removeChild(passaro);
			passaro = null;
			timerToPassaro.delay = Math.random() * 60000;
			timerToPassaro.start();
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
			score_bird = 		Number(xmlConfig.birdScore);
			distance_center = 	Number(xmlConfig.distances.center);
			distance_middle = 	Number(xmlConfig.distances.middle);
			distance_end = 		Number(xmlConfig.distances.end);
			distance_posEnd = 	Number(xmlConfig.distances.posEnd);
			score_center = 		Number(xmlConfig.targetScore.center);
			score_middle = 		Number(xmlConfig.targetScore.middle);
			score_end = 		Number(xmlConfig.targetScore.end);
			score_posEnd = 		Number(xmlConfig.targetScore.posEnd);
			
			birdSound = new Sound(new URLRequest(String(xmlConfig.somPassaro)));
			dardoSound = new Sound(new URLRequest(String(xmlConfig.somDardo)));
			scoreSound = new Sound(new URLRequest(String(xmlConfig.somPonto)));
			clockSound = new Sound(new URLRequest(String(xmlConfig.somRelogio)));
			
			//visualTimer.setTotalTime(totalTime);
			
			reset();
		}
		
		private function addListeners():void 
		{
			botoes.orientacoesBtn.addEventListener(MouseEvent.CLICK, openOrientacoes);
			botoes.resetButton.addEventListener(MouseEvent.CLICK, reset);
			botoes.creditos.addEventListener(MouseEvent.CLICK, openCreditos);
			botoes.tutorialBtn.addEventListener(MouseEvent.CLICK, iniciaTutorial);
			
			ferramentas.openTransfer.addEventListener(MouseEvent.CLICK, openCloseTransfer);
			ferramentas.openRegua.addEventListener(MouseEvent.CLICK, openCloseRuler);
			
			ferramentas.openTransfer.buttonMode = true;
			ferramentas.openRegua.buttonMode = true;
			
			ferramentas.openTransfer.addEventListener(MouseEvent.MOUSE_OVER, overBtn);
			ferramentas.openTransfer.addEventListener(MouseEvent.MOUSE_OUT, outBtn);
			ferramentas.openRegua.addEventListener(MouseEvent.MOUSE_OVER, overBtn);
			ferramentas.openRegua.addEventListener(MouseEvent.MOUSE_OUT, outBtn);
			
			createToolTips();
			
			entrada.okBtn.addEventListener(MouseEvent.CLICK, switchState);
			entrada.okBtn.buttonMode = true;
			
			entrada.raio.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			entrada.angle.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}
		
		private function overBtn(e:MouseEvent):void 
		{
			var btn:MovieClip = MovieClip(e.target);
			btn.scaleX = btn.scaleY = 1.2;
		}
		
		private function outBtn(e:MouseEvent):void 
		{
			var btn:MovieClip = MovieClip(e.target);
			btn.scaleX = btn.scaleY = 1;
		}
		
		private var glow:GlowFilter = new GlowFilter(0xFF0000);
		private function keyUpHandler(e:KeyboardEvent):void 
		{
			if (e.charCode == Keyboard.ENTER) {
				switchState(null);
			}
		}
		
		private function openCloseRuler(e:MouseEvent):void 
		{
			if (regua.visible) {
				regua.close();
				ferramentas.openRegua.gotoAndStop(1);
			}
			else {
				regua.open();
				ferramentas.openRegua.gotoAndStop(2);
			}
		}
		
		private function openCloseTransfer(e:MouseEvent):void 
		{
			if (transferidor.visible) {
				transferidor.close();
				ferramentas.openTransfer.gotoAndStop(1);
			}
			else {
				transferidor.open();
				ferramentas.openTransfer.gotoAndStop(2);
			}
		}
		
		private function switchState(e:MouseEvent):void 
		{
			switch(state) {
				case BEGIN:
					prepareForShot();
					randomizeTargetPosition();
					startTimer();
					state = WAITING_SHOT;
					setLegenda(LEGENDA_WAITING_SHOT);
					entrada.okBtn.gotoAndStop("ATIRAR");
					return;
				case WAITING_SHOT:
					if (fillComplete()) {
						timerFinished();
						//shoot();
						startShotAnimation();
					}else {
						
					}
					return;
				case POS_SHOT:
					prepareForShot();
					randomizeTargetPosition();
					startTimer();
					state = WAITING_SHOT;
					setLegenda(LEGENDA_WAITING_SHOT);
					entrada.okBtn.gotoAndStop("ATIRAR");
					return;
				case END:
					reset();
					return;
			}
		}
		
		private function prepareForShot():void
		{
			alvoUser.visible = false;
			
			entrada.raio.mouseEnabled = true;
			entrada.angle.mouseEnabled = true;
			
			entrada.fundoRaio.filters = [];
			entrada.fundoAngle.filters = [];
			
			entrada.raio.text = "";
			entrada.angle.text = "";
			
			//if (regua.visible) {
				regua.close();
				ferramentas.openRegua.gotoAndStop(1);
				regua.x = 80;
				regua.y = 250;
			//}
			
			//if (transferidor.visible) {
				transferidor.close();
				ferramentas.openTransfer.gotoAndStop(1);
				transferidor.reset();
			//}
			
			visualTimer.reset();
		}
		
		private function startShotAnimation():void 
		{
			shotAnimation.gotoAndPlay("SHOT");
		}
		
		private function shoot(e:Event = null):void 
		{
			entrada.raio.mouseEnabled = false;
			entrada.angle.mouseEnabled = false;
			
			stage.focus = null;
			
			var raioUser:Number = Number(entrada.raio.text.replace(",", ".")) * raioPalco / raioMax;
			var angleUser:Number = - Number(entrada.angle.text.replace(",", ".")) * Math.PI / 180;
			
			alvoUser.x = (raioUser * Math.cos(angleUser)) + posCentral.x;
			alvoUser.y = (raioUser * Math.sin(angleUser)) + posCentral.y;
			alvoUser.visible = true;
			
			audio.stop();
			audio = dardoSound.play();
			
			var marca:Marca = new Marca();
			marca.x = alvoUser.x;
			marca.y = alvoUser.y;
			marcas.push(marca);
			addChild(marca);
			
			evalShot();
		}
		
		private function evalShot():void 
		{
			var distToAlvo:Number = Point.distance(new Point(alvoUser.x, alvoUser.y), new Point(alvo.x, alvo.y));
			var birdShot:Boolean = false;
			
			if(passaro != null)	birdShot = MovieClip(passaro).hitTestPoint(alvoUser.x, alvoUser.y);
			
			if (true) {//Eastern egg!!!
				currentScore += score_bird;
				audio = birdSound.play();
				birdShoted();
				//Caso o pássaro seja atinjido fazer animação dele caindo???
			}
			
			if (distToAlvo <= distance_center) {//Ponuação máxima
				currentScore += score_center;
			}else if (distToAlvo <= distance_middle) {
				currentScore += score_middle;
			}else if (distToAlvo <= distance_end) {
				currentScore += score_end;
			}else if (distToAlvo <= distance_posEnd) {
				currentScore += score_posEnd;
			}
			
			
			setScore(currentScore);
		}
		
		private var tweenYPassaro:Tween;
		private var tweenAlpha:Tween;
		private function birdShoted():void 
		{
			//tweenPassaro.stop();
			tweenAlpha = new Tween(passaro, "alpha", None.easeNone, 1, 0, 1, true);
			tweenAlpha.addEventListener(TweenEvent.MOTION_FINISH, createNewPassaro, false, 0, true);
			tweenYPassaro = new Tween(passaro, "y", None.easeNone, passaro.y, passaro.y + 200, 1, true);
		}
		
		private function setScore(score:Number):void
		{
			var scoreAtual:int = int(tempoPonto.score.text);
			if (score == scoreAtual) return;
			
			var dif:Number = score - scoreAtual;
			setTimeout(somaPonto, 300);
		}
		
		private function somaPonto():void 
		{
			var scoreAtual:int = int(tempoPonto.score.text);
			if(scoreAtual < currentScore){
				scoreAtual++;
				audio = scoreSound.play(0,0,new SoundTransform(0.05));
				tempoPonto.score.text = String(scoreAtual);
				setTimeout(somaPonto, 150);
			}
		}
		
		private function fillComplete():Boolean 
		{
			var retorno:Boolean = true;
			
			if (entrada.raio.text == "") {
				retorno = false;
				entrada.fundoRaio.filters = [glow];
			}else {
				entrada.fundoRaio.filters = [];
			}
			
			if (entrada.angle.text == "") {
				retorno = false;
				entrada.fundoAngle.filters = [glow];
			}else {
				entrada.fundoAngle.filters = [];
			}
			
			return retorno;
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
			var tutoTT:ToolTip = new ToolTip(botoes.tutorialBtn, "Reiniciar tutorial", 12, 0.8, 200, 0.6, 0.1);
			
			var reguaTT:ToolTip = new ToolTip(ferramentas.openRegua, "Exibir/ocultar régua", 12, 0.8, 250, 0.6, 0.1);
			var transferTT:ToolTip = new ToolTip(ferramentas.openTransfer, "Exibir/ocultar transferidor", 12, 0.8, 250, 0.6, 0.1);
			
			var raioTT:ToolTip = new ToolTip(entrada.mc_raio, "Raio", 12, 0.8, 250, 0.6, 0.1);
			var angleTT:ToolTip = new ToolTip(entrada.mc_angle, "Ângulo(em graus)", 12, 0.8, 250, 0.6, 0.1);
			
			addChild(infoTT);
			addChild(instTT);
			addChild(resetTT);
			addChild(tutoTT);
			
			addChild(reguaTT);
			addChild(transferTT);
			
			addChild(raioTT);
			addChild(angleTT);
		}
		
		private function reset(e:MouseEvent = null):void 
		{
			visualTimer.stop();
			
			currentTotalTime = totalTime + timeDecrease;
			currentScore = 0;
			
			state = BEGIN;
			setLegenda(this["LEGENDA_" + state]);
			tempoPonto.score.text = "0";
			
			prepareForShot();
			
			entrada.raio.mouseEnabled = false;
			entrada.angle.mouseEnabled = false;
			
			for (var i:int = 0; i < marcas.length; i++) 
			{
				removeChild(marcas[i]);
			}
			
			marcas.splice(0);
			audio.stop();
			
			entrada.okBtn.gotoAndStop("INICIAR");
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
			soundClockRunning = false;
			currentTotalTime -= timeDecrease;
			timerToFinish.reset();
			timerToFinish.start();
			visualTimer.start(timerToFinish, currentTotalTime);
			addEventListener(Event.ENTER_FRAME, checkCronometer);
		}
		
		private var soundClockRunning:Boolean = false;
		private var timeLeftToPLaySong:Number = 5;
		private function checkCronometer(e:Event):void 
		{
			if (timerToFinish.read()/1000 > currentTotalTime) {
				timerFinished();
				visualTimer.fullTime();
			}
			
			if (currentTotalTime - timerToFinish.read() / 1000 <= timeLeftToPLaySong) {
				if (!soundClockRunning) {
					audio = clockSound.play();
					soundClockRunning = true;
				}
			}
		}
		
		private function timerFinished():void
		{
			removeEventListener(Event.ENTER_FRAME, checkCronometer);
			timerToFinish.pause();
			visualTimer.stop();
			
			entrada.raio.mouseEnabled = false;
			entrada.angle.mouseEnabled = false;
			
			if(currentTotalTime - timeDecrease >= 1){
				state = POS_SHOT;
				setLegenda(LEGENDA_POS_SHOT);
				entrada.okBtn.gotoAndStop("INICIAR");
			}else {
				state = END;
				setLegenda(LEGENDA_END);
				entrada.okBtn.gotoAndStop("REINICIAR");
			}
		}
		
		
		//Tutorial:
		
		private var balao:CaixaTexto;
		private var pointsTuto:Array;
		private var tutoBaloonPos:Array;
		private var tutoPos:int;
		//private var tutoPhaseFinal:Boolean;
		private var tutoSequence:Array = ["Seu objetivo é atingir o alvo.",
										  "Para isso você deve digitar aqui as coordenadas polares dele e clicar em \"Atirar\".",
										  "Você pode utilizar régua e transferidor para medir essas coordenadas, mas...",
										  "... mas o seu tempo é curto e quanto mais rápido você responder o exercício, mais pontos fará.",
										  "Quando em dúvida, leia aqui embaixo qual deve ser o próximo passo."];
										  
		private function iniciaTutorial(e:MouseEvent = null):void 
		{
			tutoPos = 0;
			//tutoPhaseFinal = false;
			if(balao == null){
				balao = new CaixaTexto(true);
				addChild(balao);
				balao.visible = false;
				
				pointsTuto = 	[new Point(alvo.x, alvo.y - (alvoUser.height / 2)),
								new Point(entrada.x + entrada.width, entrada.y + (entrada.height / 2)),
								new Point(ferramentas.x + ferramentas.width, ferramentas.y + (ferramentas.height / 2)),
								new Point(tempoPonto.x - (tempoPonto.width / 2), tempoPonto.y - 30),
								new Point(legenda.x + 50, legenda.y - legenda.height)];
								
				tutoBaloonPos = [[CaixaTexto.BOTTON, CaixaTexto.CENTER],
								[CaixaTexto.LEFT, CaixaTexto.CENTER],
								[CaixaTexto.LEFT, CaixaTexto.FIRST],
								[CaixaTexto.RIGHT, CaixaTexto.FIRST],
								[CaixaTexto.BOTTON, CaixaTexto.FIRST]];
			}
			balao.removeEventListener(Event.CLOSE, closeBalao);
			//feedBackScreen.removeEventListener(Event.CLOSE, iniciaTutorialSegundaFase);
			
			balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
			balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			balao.addEventListener(Event.CLOSE, closeBalao);
			balao.visible = true;
		}
		
		private function closeBalao(e:Event):void 
		{
			/*if (tutoPhaseFinal) {
				balao.removeEventListener(Event.CLOSE, closeBalao);
				balao.visible = false;
				feedBackScreen.removeEventListener(Event.CLOSE, iniciaTutorialSegundaFase);
			}else{*/
				tutoPos++;
				if (tutoPos >= tutoSequence.length) {
					balao.removeEventListener(Event.CLOSE, closeBalao);
					balao.visible = false;
					//feedBackScreen.addEventListener(Event.CLOSE, iniciaTutorialSegundaFase);
					//tutoPhaseFinal = true;
				}else {
					balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
					balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
				}
			//}
		}
		
		/*private function iniciaTutorialSegundaFase(e:Event):void 
		{
			if(tutoPhaseFinal){
				balao.setText("Você pode começar um novo exercício clicando aqui.", tutoBaloonPos[2][0], tutoBaloonPos[2][1]);
				balao.setPosition(160, pointsTuto[2].y);
				tutoPhaseFinal = false;
			}
		}*/
		
		
	}

}