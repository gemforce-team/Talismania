package Talismania
{
	/**
	 * ...
	 * @author Skillcheese
	 */
	
	import Talismania.TalismanFilter;
	import Bezel.Bezel;
	import Bezel.Logger;
	import com.giab.games.gcfw.GV;
	import com.giab.games.gcfw.entity.TalismanFragment;
	import com.giab.games.gcfw.entity.Gem;
	import flash.utils.Timer;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.KeyboardEvent;
	import flash.utils.getTimer;
	import Bezel.Utils.Keybind;
	import com.giab.games.gcfw.constants.TalismanPropertyId;

	// We extend MovieClip so that flash.display.Loader accepts our class
	// The loader also requires a parameterless constructor (AFAIK), so we also have a .Bind method to bind our class to the game
	public class GCFWTalismania
	{
		
		public const GAME_VERSION:String = "1.2.1a";
		
		// Mod loader object
		internal static var bezel:Bezel;
		
		internal static var logger:Logger;
		
		private var checkedTalismans:Array = new Array();
		private const filterCost:int = 50000;
		private const randomCost:int = 1000;
		
		// Parameterless constructor for flash.display.Loader
		public function GCFWTalismania()
		{
			super();
		}
		
		// This method binds the class to the game's objects
		public function bind(modLoader:Bezel, gameObjects:Object) : void
		{
			bezel = modLoader;
			logger = bezel.getLogger("Talismania");
			
			addEventListeners();
			
			logger.log("Talismania", "Talismania initialized!");
			checkTalismanDrops();

			bezel.keybindManager.registerHotkey("Talismania: Reroll For Best Fragment", new Keybind("alt+k"), "Costs 50k shadow cores");
			bezel.keybindManager.registerHotkey("Talismania: Reroll For +1 To All Skills", new Keybind("k"), "Costs 1k shadow cores");
		}

		public function showMessage(message:String) :void
		{
			GV.vfxEngine.createFloatingText4(GV.main.mouseX, GV.main.mouseY < 60?Number(GV.main.mouseY + 30):Number(GV.main.mouseY - 20), message, 16768392, 12, "center", Math.random() * 3 - 1.5, -4 - Math.random() * 3, 0, 0.55, 12, 0, 1000);
		}
		
		public function checkTalismanDrops(): void
		{
			for (var i:int = 0; i < GV.ingameCore.ocLootTalFrags.length; i++)
			{
				var item:TalismanFragment = GV.ingameCore.ocLootTalFrags[i];
				if (checkedTalismans.indexOf(item) == -1)
				{
					logger.log("", "" + item.seed);
					var enrageGem:Gem = GV.ingameCore.gemInEnragingSlot;
					var rarity:Number = item.rarity.g();
					if (enrageGem != null)
					{
						rarity += enrageGem.grade.g() * 1.5;
					}
					if (rarity > 100)
					{
						rarity = 100;
					}
					item.rarity.s(rarity);
					item.calculateProperties();
					checkedTalismans.push(item);
				}
			}
			var timer:Timer = new Timer(100, 1);
			var func:Function = function(e:Event): void {checkTalismanDrops(); };
			timer.addEventListener(TimerEvent.TIMER, func);
			timer.start();
		}
		
		public function prettyVersion(): String
		{
			return 'v' + TalismaniaMod.TALISMANIA_VERSION + ' for ' + GAME_VERSION;
		}
		
		private function ehKeyboardInStageMenu(pE:KeyboardEvent): void
		{
			if (GV.selectorCore.screenStatus == 205 || GV.selectorCore.screenStatus == 206) // if we're in the talisman menu
			{
				var filter:TalismanFilter;
				if (bezel.keybindManager.getHotkeyValue("Talismania: Reroll For Best Fragment").matches(pE))
				{
					filter = new TalismanFilter(TalismanFilter.myFilterInner, TalismanFilter.myFilterEdge, TalismanFilter.myFilterCorner, 3);
					filterTalisman(filter);
				}
				else if (bezel.keybindManager.getHotkeyValue("Talismania: Reroll For +1 To All Skills").matches(pE))
				{
					filter = new TalismanFilter([TalismanPropertyId.SKILLS_ALL], [TalismanPropertyId.SKILLS_ALL], [TalismanPropertyId.SKILLS_ALL]);
					filterTalisman(filter, true);
				}
			}
		}
		
		public function filterTalisman(filter:TalismanFilter, costOverride:Boolean = false): void
		{
			var cost:int = costOverride ? randomCost : filterCost;
			if (GV.selectorCore.screenStatus != 205 && GV.selectorCore.screenStatus != 206) // if we're in the talisman menu
			{
				return;
			}
			var talFrag:TalismanFragment = getMouseTalisman();
			if (talFrag == null) //if we are over a talisman
			{
				return;
			}
			if (talFrag.rarity.g() < 100)
			{
				showMessage("Fragment must be rarity 100!");
				return;
			}
			if (GV.ppd.shadowCoreAmount.g() < cost)
			{
				var costBeginning:int = Math.round(cost / 1000);
				showMessage("Not enough shadow cores, requires " + costBeginning + ",000!");
				return;
			}
			var time:int = getTimer();
			var frag:TalismanFragment = filter.getTalismanMatchingFilter(talFrag.clone());
			if (frag != null)
			{
				var elapsedTime:Number = (getTimer() - time + 1) / 1000;
				logger.log("", "Elapsed Time: " + elapsedTime);
				talFrag.seed = frag.seed;
				talFrag.calculateProperties();
				talFrag.hasChangedShape = true;
				GV.selectorCore.pnlTalisman.dirtyFlag = true;
				GV.talFragBitmapCreator.giveTalFragBitmaps(talFrag);
				
				GV.ppd.shadowCoreAmount.s(GV.ppd.shadowCoreAmount.g() - cost);
				GV.selectorCore.renderer.updateShadowCoreCounter(GV.ppd.shadowCoreAmount.g());
				
				showMessage("Talismania Completed Successfully!");
			}
			else
			{
				showMessage("Fragment search failed!");
			}
		}
		
		private function getMouseTalisman(): TalismanFragment
		{
			var vMx:Number = GV.selectorCore.pnlTalisman.mc.root.mouseX;//find talisman or null
			var vMy:Number = GV.selectorCore.pnlTalisman.mc.root.mouseY;
			var pSlotNum:int = -1;
			var location:int = -1;
			if(vMx > 1180 && vMx < 1180 + 6 * 106 && vMy > 170 && vMy < 170 + 6 * 106)
			{
				pSlotNum = 6 * Math.floor((vMy - 170) / 106) + Math.floor((vMx - 1180) / 106); // inventory
				location = 1;
			}
			else if(vMx > 106 && vMx < 106 + 5 * 183 && vMy > 98 && vMy < 98 + 5 * 160) // talisman slots
			{
				pSlotNum = 5 * Math.floor((vMy - 98) / 160) + Math.floor((vMx - 106) / 183);
				location = 2;
			}
			var talFrag:TalismanFragment = null;
			switch(location)
			{
				case -1:
					break;
				case 1:
					talFrag = GV.ppd.talismanInventory[pSlotNum];
					break;
				case 2:
					talFrag = null;
					showMessage("You cannot edit fragments in the talisman");
					break;
			}
			return talFrag;
		}
		
		public function unload(): void
		{
			removeEventListeners();
			bezel = null;
			logger = null;
		}
		
		private function addEventListeners(): void
		{
			GV.main.stage.addEventListener(KeyboardEvent.KEY_DOWN, ehKeyboardInStageMenu);
		}
		
		private function removeEventListeners(): void
		{
			GV.main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, ehKeyboardInStageMenu);
		}
		
	}
}
