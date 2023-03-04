package funkin.system;

import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.graphics.FlxGraphic;
import flixel.FlxSprite;

class FNFSprite extends FlxSprite
{
	public var offsets:Map<String, Array<Float>> = new Map();

	public function new(x:Float = 0, y:Float = 0, graphic:FlxGraphicAsset = null)
	{
		super(x, y, graphic);
		this.antialiasing = true;
	}

	public function setOffset(name:String, x:Float = 0, y:Float = 0)
	{
		offsets.set(name, [x, y]);
	}

	public function playAnim(name:String, force:Bool = false)
	{
		animation.play(name, force);
        updateHitbox();
		if (!offsets.exists(name))
		{
			return;
		}
		offset.set(offsets.get(name)[0], offsets.get(name)[1]);
	}
}