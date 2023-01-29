package funkin.ui;

import flixel.FlxSprite;
import dependency.Paths;

class CheckboxThingie extends FlxSprite {
	public var daValue(default, set):Bool;

	override public function new(x:Float, y:Float, state:Bool = false) {
		super(x, y);

		frames = Paths.getSparrowAtlas('menuUI/options_menu/checkboxThingie');
		animation.addByPrefix('static', 'Check Box unselected', 24, false);
		animation.addByPrefix('checked', 'Check Box selecting animation', 24, false);
		
		scale.set(0.7, 0.7);
		updateHitbox();
		daValue = state;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		switch (animation.curAnim.name) {
			case 'checked':
				offset.set();
			case 'static':
				offset.set();
		}
	}

	function set_daValue(state:Bool) {
		if (state)
			animation.play('checked', true);
		else
			animation.play('static');
		return state;
	}
}