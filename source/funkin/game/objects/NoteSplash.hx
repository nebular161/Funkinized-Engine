package funkin.game.objects;

import flixel.FlxG;
import flixel.FlxSprite;
import funkin.system.Paths;
class NoteSplash extends FlxSprite
{
    public function new(x:Float = 0, y:Float = 0, note:Int = 0)
    {
        super(x, y);

        frames = Paths.getSparrowAtlas('gameObjects/notes/base/noteSplashes');

        animation.addByPrefix("splash-0", "note splash purple", 24, false);
        animation.addByPrefix("splash-1", "note splash blue", 24, false);
        animation.addByPrefix("splash-2", "note splash green", 24, false);
        animation.addByPrefix("splash-3", "note splash red", 24, false);

        setupNoteSplash(x, y, note);
        antialiasing = true;
    }
    public function setupNoteSplash(x:Float, y:Float, note:Int = 0)
    {
        setPosition(x, y);

        alpha = 0.9;
        animation.play('splash-' + note, false);
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