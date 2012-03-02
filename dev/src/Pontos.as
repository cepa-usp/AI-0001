package 
{
	import flash.display.MovieClip;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Pontos extends MovieClip
	{
		
		public function Pontos() 
		{
			this.scaleX = this.scaleY = 1.6;
		}
		
		public function setPontuacao(pts:Number):void
		{
			gotoAndPlay(1);
			this.pt.pontos.text = String(pts);
		}
		
	}

}