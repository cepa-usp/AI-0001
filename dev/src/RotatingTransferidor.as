package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.geom.*;
	
	public class RotatingTransferidor extends MovieClip {
		
		private var ruler:Transferidor = new Transferidor();
		private var startAngle:Number;
		private var startOrientation:Number;
		private var rotating:Boolean;
		private var MiliToPix = 1.8;
		private var arrayAtractors:Array = new Array();
		private var clickOfSet:Point = new Point();
		private var i:Number;
		private var visivel:Boolean = false;
		private var radius:Number;
		var matrixCorrente:Matrix;
		var matrix2:Matrix;
		
		public function RotatingTransferidor () {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
			
		private function init (event:Event = null) {
			rotating = false;
			addChild(ruler);
			buttonMode = true;
			ruler.transferidorC.addEventListener(MouseEvent.MOUSE_DOWN, scaleRuler);
			ruler.transferidorB.addEventListener(MouseEvent.MOUSE_DOWN, rotateRuler);
			ruler.transferidorA.addEventListener(MouseEvent.MOUSE_DOWN, moveRuler);
		}
		
		private function scaleRuler(e:MouseEvent):void
		{
			radius = Math.sqrt((this.x - stage.mouseX)*(this.x- stage.mouseX) + (this.y - stage.mouseY)*(this.y - stage.mouseY));
			stage.addEventListener(MouseEvent.MOUSE_MOVE, scalingRuler);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopScale);
			matrixCorrente = this.transform.matrix.clone();
		}
		
		private function scalingRuler(e:MouseEvent):void
		{
			var newRadius:Number = Math.sqrt((this.x - stage.mouseX)*(this.x - stage.mouseX) + (this.y - stage.mouseY)*(this.y - stage.mouseY));
			var matrix:Matrix = new Matrix();
			matrix.scale(1 + ((newRadius - radius) / radius), 1 + ((newRadius - radius) / radius));
			
			var undoMatrix:Matrix = this.transform.matrix.clone();
			
			matrix2 = matrixCorrente.clone();
			var xx:Number = matrix2.tx;
			var yy:Number = matrix2.ty;
			matrix2.tx = 0;
			matrix2.ty = 0;
			matrix2.concat(matrix);
			matrix2.tx = xx;
			matrix2.ty = yy;
			this.transform.matrix = matrix2;
			
			if (this.width < 300) this.transform.matrix = undoMatrix;
			
			//if(1+ (newRadius - radius)/radius > 0.5)
				//this.scaleX = this.scaleY = 1 + ((newRadius - radius)/radius);
		}
		
		private function stopScale(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, scalingRuler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopScale);
		}
		
		private function moveRuler(e:MouseEvent):void
		{
			//startDrag();
			stage.addEventListener(MouseEvent.MOUSE_MOVE, movingRuler);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopMove);
			clickOfSet.x = stage.mouseX - x;
			clickOfSet.y = stage.mouseY - y;
		}
		
		private function movingRuler(e:MouseEvent):void
		{
			if (arrayAtractors.length > 0)
			{
				for (i = 0; i < arrayAtractors.length; i++)
				{
					if ((stage.mouseX-clickOfSet.x > arrayAtractors[i].x - 10 && stage.mouseX-clickOfSet.x < arrayAtractors[i].x + 10) &&
					   (stage.mouseY-clickOfSet.y > arrayAtractors[i].y - 10 && stage.mouseY-clickOfSet.y < arrayAtractors[i].y + 10))
					{
						x = arrayAtractors[i].x;
						y = arrayAtractors[i].y;
						break;
					}
					else
					{
						x = stage.mouseX - clickOfSet.x;
						y = stage.mouseY - clickOfSet.y;
					}
				}
			}
			else
			{
				x = stage.mouseX - clickOfSet.x;
				y = stage.mouseY - clickOfSet.y;
			}
		}
		
		private function stopMove(e:MouseEvent):void
		{
			//stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, movingRuler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopMove);
		}
		
		public function rotateRuler(event:MouseEvent) : void {
			rotating = true;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveEvent);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpEvent);
			startAngle = (Math.atan2(stage.mouseY - y, stage.mouseX - x)) * 180 / Math.PI;
			startOrientation = rotation;
		}
		
		private function onMouseMoveEvent(event:MouseEvent) : void {
			if (rotating) {
				rotation = Math.round((Math.atan2(stage.mouseY - y, stage.mouseX - x)) * 180 / Math.PI - startAngle + startOrientation);
				if (Math.abs(rotation - 0) <= 2) rotation = 0;
				else if (Math.abs(rotation - 90) <= 2) rotation = 90;
				else if (Math.abs(rotation + 90) <= 2) rotation = -90;
				else if (Math.abs(rotation - 180) <= 2) rotation = -180;
				else if (Math.abs(rotation + 180) <= 2) rotation = -180;
			}
		}
		
		private function onMouseUpEvent(event:MouseEvent) : void {
			rotating = false;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveEvent);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpEvent);
		}
		
		public function get angulo() : Number {
			return rotation;
		}
		
		public function set angulo (rotation:Number) : void {
			this.rotation = rotation;
		}
		
		public function set atractors(listaAtractor:Array):void
		{
			arrayAtractors = listaAtractor;
		}
		
		public function open():void
		{
			this.visible = true;
			visivel = true;
		}
		
		public function close():void
		{
			this.visible = false;
			visivel = false;
		}
		
		public function rulerVisible():void
		{
			if (this.visible)
			{
				this.visible = false;
				visivel = false;
			}
			else
			{
				this.visible = true;
				visivel = true;
			}
		}
		
		public function retornaVisibilidade():Boolean
		{
			return visivel;
		}
	}
}