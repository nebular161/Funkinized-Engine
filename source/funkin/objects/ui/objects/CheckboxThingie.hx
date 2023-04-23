package funkin.objects.ui.objects;

import flixel.FlxSprite;
import funkin.backend.system.Paths;

class CheckboxThingie extends FlxSprite {
	public var daValue(default, set):Bool;

	override public function new(x:Float, y:Float, state:Bool = false) {
		super(x, y);

		frames = Paths.getSparrowAtlas('menu objects/options menu/checkboxThingie');
		animation.addByPrefix('static', 'Check Box unselected', 24, false);
		animation.addByPrefix('checked', 'Check Box selecting animation', 24, false);
		
		scale.set(0.7, 0.7);
		updateHitbox();
		daValue = state;
	}

	override function update(elapsed:Float)
		{
			super.update(elapsed);
			switch (animation.curAnim.name)
			{
				case 'checked':
					offset.set(17, 70);
				case 'static':
					offset.set();
			}
		}
	
		function set_daValue(state:Bool)
		{
			if (state)
				animation.play('checked', true);
			else
				animation.play('static');
			return state;
		}
	}
