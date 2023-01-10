package funkin.game;

import funkin.config.PreferencesMenu;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.system.MusicBeatSubstate;
import funkin.system.LoadingState;
import funkin.menus.StoryMenuState;
import funkin.game.Boyfriend;
import funkin.game.PlayState;
import funkin.game.Conductor;
class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	var randomGameover:Int = 1;
	var playingDeathSound:Bool = false;

	public function new(x:Float, y:Float)
	{
		var daStage = PlayState.curStage;
		var daBf:String = '';
		switch (daStage)
		{
			case 'school' | 'schoolEvil':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			default:
				daBf = 'bf-dead';
		}
		if (PlayState.SONG.song.toLowerCase() == 'stress')
		{
			daBf = 'bf-gf-dead';
		}

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		var exclude = [];
		if (PreferencesMenu.getPref('censor-naughty'))
		{
			exclude = [1, 3, 8, 13, 17, 21];
		}
		randomGameover = FlxG.random.int(1, 25, exclude);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (PlayState.storyWeek == 7)
		{
			if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished && !playingDeathSound)
			{
				playingDeathSound = true;
				bf.startedDeath = true;
				coolStartDeath(0.2);
				FlxG.sound.play(Paths.sound('tankZone/jeffGameover/jeffGameover-' + randomGameover), 1, false, null, true, function()
				{
					FlxG.sound.music.fadeIn(4, 0.2, 1);
				});
			}
		}
		else if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			bf.startedDeath = true;
			coolStartDeath();
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	function coolStartDeath(startVol:Float = 1)
	{
		FlxG.sound.playMusic(Paths.music('game-over/gameOver' + stageSuffix), startVol);
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('game-over/gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}