package;

class BGSprite extends flixel.FlxSprite {
	public var idleAnim:String = null;

	override public function new(image:String, x:Float = 0, y:Float = 0, ?scrollFactor:Vector2, animations:Array<String> = null, loopAnims:Bool = false,
			?scale:Vector2, antialiasing:Bool = true) {
		super(x, y);

		if (animations != null) {
			frames = Paths.getSparrowAtlas(image);

			for (anim in animations) {
				animation.addByPrefix(anim, anim, 24, loopAnims);
				animation.play(anim);
				if (idleAnim == null)
					idleAnim = anim;
			}
		} else
			loadGraphic(Paths.image(image));

		if (scrollFactor != null)
			this.scrollFactor.set(scrollFactor.x, scrollFactor.y);
		if (scale != null)
			this.scale.set(scale.x, scale.y);
		this.antialiasing = antialiasing;
	}

	public function dance() {
		if (idleAnim != null)
			animation.play(idleAnim);
	}
}
