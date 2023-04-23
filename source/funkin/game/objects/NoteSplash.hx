package funkin.game.objects;

import flixel.FlxG;
import flixel.FlxSprite;
import funkin.backend.system.Paths;
class NoteSplash extends FlxSprite
{
    public function new(x:Float = 0, y:Float = 0, noteData:Int = 0)
    {
        super(x, y);

        frames = Paths.getSparrowAtlas('game objects/splashes/base/default_splashes');

		animation.addByPrefix('note1-0', 'splash blue0', 24, false);
		animation.addByPrefix('note2-0', 'splash green0', 24, false);
		animation.addByPrefix('note0-0', 'splash purple0', 24, false);
		animation.addByPrefix('note3-0', 'splash red0', 24, false);
		animation.addByPrefix('note1-1', 'splash blue 2', 24, false);
		animation.addByPrefix('note2-1', 'splash green 2', 24, false);
		animation.addByPrefix('note0-1', 'splash purple 2', 24, false);
		animation.addByPrefix('note3-1', 'splash red 2', 24, false);

        setupNoteSplash(x, y, noteData);
        antialiasing = true;
    }
    public function setupNoteSplash(x:Float, y:Float, noteData:Int = 0)
    {
        setPosition(x, y);

        alpha = 0.9;
        animation.play('note' + noteData + '-' + FlxG.random.int(0, 1), false);
        scale.set(1.05, 1.05);
        updateHitbox();
        offset.set(0.5 * width, 0.5 * height);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        if (animation.curAnim.finished)
            kill();
    }
}