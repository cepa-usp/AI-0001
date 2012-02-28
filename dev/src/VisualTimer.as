package 
{
	import cepa.utils.Cronometer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class VisualTimer extends Sprite
	{
		private var background:Sprite;
		private var timerElaspedMask:Sprite;
		private var timerElasped:Sprite;
		
		private var raioTimer:Number = 15;
		
		private var totalTime:Number = 60;
		private var elaspedTime:Number;
		private var secToGrau:Number = 360 / 60;
		
		private var timerToFollow:Cronometer;
		private var timerToDraw:Timer = new Timer(100);
		
		public function VisualTimer() 
		{
			background = new Sprite();
			timerElasped = new Sprite();
			timerElaspedMask = new Sprite();
			
			background.graphics.lineStyle(1, 0x000000);
			background.graphics.beginFill(0xFFFFFF);
			background.graphics.drawCircle(0, 0, raioTimer);
			
			timerElaspedMask.graphics.lineStyle(1, 0x000000);
			timerElaspedMask.graphics.beginFill(0xFFFFFF);
			timerElaspedMask.graphics.drawCircle(0, 0, raioTimer);
			
			addChild(background);
			addChild(timerElaspedMask);
			addChild(timerElasped);
			
			timerElasped.mask = timerElaspedMask;
			
			timerToDraw.addEventListener(TimerEvent.TIMER, updateVisualTimer);
		}
		
		public function setTotalTime(total:Number):void
		{
			totalTime = total;
			secToGrau = 360 / totalTime;
		}
		
		public function start(timer:Cronometer, inicial:Number = 0):void
		{
			elaspedTime = inicial;
			timerToFollow = timer;
			
			timerToDraw.start();
			//addEventListener(Event.ENTER_FRAME, updateVisualTimer);
		}
		
		public function stop():void
		{
			timerToDraw.stop();
			timerToDraw.reset();
			//removeEventListener(Event.ENTER_FRAME, updateVisualTimer);
		}
		
		private function updateVisualTimer(e:TimerEvent):void 
		{
			var timeToShow:Number = elaspedTime + timerToFollow.read() / 1000;
			
			var comp:Number = 2 * raioTimer;
			
			timerElasped.graphics.clear();
			timerElasped.graphics.beginFill(0xFF0000);
			timerElasped.graphics.moveTo(0, 0);
			timerElasped.graphics.lineTo(0, -comp);
			
			for (var i:int = 0; i < int(secToGrau * timeToShow); i++)
			{
				var posX:Number = comp * Math.cos((i - 90) * Math.PI / 180);
				var posY:Number = comp * Math.sin((i - 90) * Math.PI / 180);
				timerElasped.graphics.lineTo(posX, posY);
			}
			
			timerElasped.graphics.lineTo(0, 0);
		}
		
	}

}