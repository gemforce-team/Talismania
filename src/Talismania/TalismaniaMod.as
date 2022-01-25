package Talismania
{
    import flash.display.MovieClip;
    import Bezel.BezelMod;
    import Bezel.Bezel;

    /**
     * ...
     * @author Chris
     */
    public class TalismaniaMod extends MovieClip implements BezelMod
    {
        public static const TALISMANIA_VERSION:String = "1.4"
		public function get VERSION():String { return TALISMANIA_VERSION; }
		public function get BEZEL_VERSION():String { return "1.1.0"; }
		public function get MOD_NAME():String { return "Talismania"; }

        private var talismania:GCFWTalismania;

		public function bind(bezel:Bezel, gameObjects:Object):void
		{
            talismania = new GCFWTalismania();
            talismania.bind(bezel, gameObjects);
		}

		public function unload():void
		{
            talismania.unload();
		}
    }
}
