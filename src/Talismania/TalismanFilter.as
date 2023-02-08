package Talismania 
{
	import com.giab.games.gcfw.entity.TalismanFragment;
	import com.giab.common.utils.PseudoRnd;
	import com.giab.games.gcfw.constants.TalismanPropertyId;
	import com.giab.games.gcfw.constants.TalismanFragmentType;

	/**
	 * ...
	 * @author Skillcheese
	 */
	public class TalismanFilter 
	{
		public static var numTalismans:int = 8999998;
		public static var talismanSeedBase:int = 1000000;
		public static var maxTalismanSeed:int = 1000000 + 8999998;
		public var forceRune:int = -1;
		private var idsInner:Array;
		private var idsCorner:Array;
		private var idsEdge:Array;
		
		public static var worthless:Array = [
		TalismanPropertyId.DAMAGE_TO_FLYING,
		TalismanPropertyId.BEAM_DAMAGE,
		TalismanPropertyId.BOLT_DAMAGE,
		TalismanPropertyId.BARRAGE_DAMAGE,
		TalismanPropertyId.MANA_FOR_EARLY_WAVES,
		TalismanPropertyId.WHITEOUT_POISONBOOST_PCT,
		TalismanPropertyId.DAMAGE_TO_BUILDINGS,
		TalismanPropertyId.HEAVIER_ORBLETS,
		TalismanPropertyId.FASTER_ORBLET_ROLLBACK,
		TalismanPropertyId.MANA_SHARD_HARVESTING_SPEED,
		TalismanPropertyId.FREEZE_ARMOR_PCT,
		TalismanPropertyId.FREEZE_CORPSE_EXPLOSION_HP_PCT,
		TalismanPropertyId.GEM_BOMB_EXTRA_WASP_CHANCE,
		TalismanPropertyId.WASPS_FASTER_ATTACK,
		TalismanPropertyId.ICESHARDS_BLEEDING_PCT,
		TalismanPropertyId.ICESHARDS_SLOWINGDUR_PCT,
		TalismanPropertyId.FREEZE_DURATION,
		TalismanPropertyId.ICESHARDS_EXTRA_HP_TAKEN,
		TalismanPropertyId.ICESHARDS_HPLOSS_PCT,
		TalismanPropertyId.ICESHARDS_ARMORLOSS_PCT
		];
		
		public static var bestFilter:Array = [
		TalismanPropertyId.DAMAGE_TO_SWARMLINGS,
		TalismanPropertyId.DAMAGE_TO_REAVERS,
		TalismanPropertyId.DAMAGE_TO_GIANTS,
		TalismanPropertyId.XP_GAINED,
		TalismanPropertyId.WHITEOUT_XPBOOST_PCT,
		TalismanPropertyId.WHITEOUT_MANALEECHBOOST_PCT,
		TalismanPropertyId.WHITEOUT_DURATION,
		TalismanPropertyId.MAX_WHITEOUT_CHARGE
		];
		
		public static var myFilterCorner:Array = [
		TalismanPropertyId.XP_GAINED,
		TalismanPropertyId.WHITEOUT_XPBOOST_PCT,
		TalismanPropertyId.WHITEOUT_MANALEECHBOOST_PCT,
		TalismanPropertyId.FREEZE_DURATION,
		TalismanPropertyId.ICESHARDS_HPLOSS_PCT
		];
		
		public static var myFilterEdge:Array = [
		TalismanPropertyId.XP_GAINED,
		TalismanPropertyId.DAMAGE_TO_FLYING,
		TalismanPropertyId.WIZLEVEL_TO_XP_AND_MANA,
		TalismanPropertyId.DAMAGE_TO_SWARMLINGS,
		TalismanPropertyId.DAMAGE_TO_REAVERS,
		TalismanPropertyId.DAMAGE_TO_GIANTS
		];
		
		public static var myFilterInner:Array = [
		TalismanPropertyId.XP_GAINED,
		TalismanPropertyId.WIZLEVEL_TO_XP_AND_MANA,
		TalismanPropertyId.WHITEOUT_XPBOOST_PCT,
		TalismanPropertyId.DAMAGE_TO_SWARMLINGS,
		TalismanPropertyId.DAMAGE_TO_REAVERS,
		TalismanPropertyId.DAMAGE_TO_GIANTS
		];
		
		public function TalismanFilter(inner:Array = null, edge:Array = null, corner:Array = null,runeId:int = -1) 
		{
			if (inner == null || edge == null || corner == null)
			{
				idsInner = new Array();
				idsEdge = new Array();
				idsCorner = new Array();
			}
			else
			{
				idsInner = inner;
				idsEdge = edge;
				idsCorner = corner;
			}
			forceRune = runeId;
		}
		
		public function getTalismanMatchingFilter(talismanBase:TalismanFragment): TalismanFragment
		{
			if (talismanBase.rarity.g() < 100)
			{
				return null;
			}
			var start:int = 1000000 + ((talismanBase.seed - 1000000) * 187 + 903953) % 8999998;
			var end:int = maxTalismanSeed;
			var passTest:Boolean = true;
			var ids:Array;
			switch(talismanBase.type)
			{
				case TalismanFragmentType.INNER:
					ids = idsInner;
					break;
				case TalismanFragmentType.EDGE:
					ids = idsEdge;
					break;
				case TalismanFragmentType.CORNER:
					ids = idsCorner;
					break;
			}
			for (var i:int = start; i < end; i++)
			{
				if (forceRune != -1)
				{
					
					var pRand:PseudoRnd = new PseudoRnd();
					pRand.setSeed(i);
					var rune:int = Math.floor(pRand.getRnd() * 9.99);
					if (rune >= 5)
					{
						continue;
					}
				}
				
				var talCurrent:TalismanFragment = getTalisman(talismanBase, i);
				passTest = true;
				
				for each (var id:int in ids)
				{
					if (!doesTalismanContainId(talCurrent, id))
					{
						passTest = false;
						break;
					}
				}
				if (passTest)
				{
					return talCurrent;
				}
			}
			return null;
		}
		
		public function doesTalismanContainId(talisman:TalismanFragment, id:int): Boolean
		{
			return talisman.propertyIds.indexOf(id) != -1;
		}
		
		public function getTalisman(talisman:TalismanFragment, seed:int): TalismanFragment
		{
			talisman.seed = seed;
			talisman.calculateProperties();
			return talisman;
		}
	}

}
