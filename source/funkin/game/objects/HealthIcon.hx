package funkin.game.objects;

import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;
import funkin.system.dependency.Paths;

using StringTools;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;
	private var curicon:String = 'bf';

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		antialiasing = true;
		setIcon(char, isPlayer);
		scrollFactor.set();
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function setIcon(char:String = 'bf', flipX:Bool = false)
	{
		var correctIcon = char; // To make the icons folder less cluttered with the same icon image but on a different file name
		switch (char)
		{
			case 'parents-christmas':
				correctIcon = 'parents-christmas';

			case 'monster-christmas':
				correctIcon = 'monster';

			case 'bf-car' | 'bf-opponent' | 'bf-christmas':
				correctIcon = 'bf';

			case 'bf-pixel-opponent':
				correctIcon = 'bf-pixel';

			case 'mom-car':
				correctIcon = 'mom';

			case 'senpai-angry':
				correctIcon = 'senpai-angry';

			case 'bf-gf':
				correctIcon = 'bf-gf';

			case 'pico-speaker' | 'pico-player':
				correctIcon = 'pico';
		}
		loadGraphic(Paths.data('character-data/icons/' + correctIcon), true, 150, 150);
		
		animation.add(char, [0, 1], 0, false, flipX);
		animation.play(char);
		curicon = char;

		/*iconOffsets[0] = (width - 150) / 2;
		iconOffsets[1] = (width - 150) / 2;
		updateHitbox();*/
	}

	/*override function updateHitbox()
		{
			super.updateHitbox();
			offset.x = iconOffsets[0];
			offset.y = iconOffsets[1];
		}*/

	public function getIcon()
	{
		return curicon;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
