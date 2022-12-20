package;

class BackgroundGirls extends flixel.FlxSprite {
	public var danceRight:Bool = false;

	public function new(x:Float, y:Float) {
		super(x, y);

		frames = Paths.getSparrowAtlas('weeb/bgFreaks');
		playAnims('girls group');
	}

	public function getScared():Void {
		playAnims('fangirls dissuaded');
	}

	public function playAnims(suffix:String):Void {
		animation.addByIndices('danceLeft', 'BG {suffix}', MathFunctions.numberArray(14), '', 24, false);
		animation.addByIndices('danceRight', 'BG ${suffix}', MathFunctions.numberArray(30, 15), '', 24, false);
		dance();
		animation.finish();
	}

	public function dance():Void {
		animation.play((danceRight = !danceRight) ? 'danceRight' : 'danceLeft', true);
	}
}
