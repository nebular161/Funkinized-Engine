package;

#if discord_rpc
import Discord.DiscordClient;
#end

#if USE_SHADERS
import shaders.ColorSwap;
#end

#if html5
import openfl.display.Sprite;
import openfl.net.NetStream;
import openfl.media.Video;
import openfl.Lib;
#end

import ui.PreferencesMenu;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

class TitleState extends MusicBeatState {
	public static var initialized:Bool = false;

	var credGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var titleText:FlxSprite;
	var logoBl:FlxSprite;

	var gfDance:FlxSprite;
	var danceLeft:Bool = false;

	var curWacky:Array<String> = [];
	var lastBeat:Int = 0;
	var skippedIntro:Bool = false;
	var transitioning:Bool = false;

	var swagShader:ColorSwap;

	#if web
	var video:Video;
	var netStream:NetStream;
	var overlay:Sprite;
	#end

	override public function create():Void {
		#if polymod
		polymod.Polymod.init({modRoot: 'mods', dirs: ['introMod'], framework: OPENFL});
		#end

		#if USE_SHADERS
		swagShader = new ColorSwap();
		#end

		curWacky = FlxG.random.getObject(getIntroTextShit());
		FlxG.sound.muteKeys = [ZERO];

		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');

		PreferencesMenu.initPrefs();
		PlayerSettings.init();
		Highscore.load();

		if (FlxG.save.data.weekUnlocked != null) { // QUICK PATCH OOPS!
			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		if (FlxG.save.data.seenVideo != null)
			VideoState.seenVideo = FlxG.save.data.seenVideo;

		new FlxTimer().start(1, function(tmr:FlxTimer) startIntro());

		#if discord_rpc
		DiscordClient.initialize();
		Application.current.onExit.add(function(exitCode) DiscordClient.shutdown());
		#end
	}

	#if web
	function client_onMetaData(e) {
		video.attachNetStream(netStream);
		video.width = video.videoWidth;
		video.height = video.videoHeight;
	}

	function netStream_onAsyncError(e)
		trace('Error loading video');

	function netConnection_onNetStatus(e) {
		if (e.info.code == 'NetStream.Play.Complete')
			startIntro();
		trace(e.toString());
	}

	function overlay_onMouseDown(e) {
		netStream.soundTransform.volume = 0.2;
		netStream.soundTransform.pan = -1;
		Lib.current.stage.removeChild(overlay);
	}
	#end

	function startIntro() {
		if (!initialized) {
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;

			FlxTransitionableState.defaultTransIn = transIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = transOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
			Conductor.changeBPM(102);
		}

		persistentUpdate = true;
		add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		#if USE_SHADERS
		logoBl.shader = swagShader.shader;
		#end
		add(logoBl);

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], '', 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '', 24, false);
		#if USE_SHADERS
		gfDance.shader = swagShader.shader;
		#end
		add(gfDance);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', 'Press Enter to Begin', 24);
		titleText.animation.addByPrefix('press', 'ENTER PRESSED', 24);
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		credGroup = new FlxGroup();
		credGroup.add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));
		add(credGroup);

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		add(ngSpr);

		FlxG.mouse.visible = false;

		if (initialized) skipIntro();
		else initialized = true;

		if (FlxG.sound.music != null)
			FlxG.sound.music.onComplete = function() FlxG.switchState(new VideoState());
	}

	function getIntroTextShit():Array<Array<String>> {
		var firstArray:Array<String> = Paths.getTextFileArray(Paths.txt('introText'));
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
			swagGoodArray.push(i.split('--'));
		return swagGoodArray;
	}

	override function update(elapsed:Float) {
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		if (FlxG.keys.justPressed.FIVE || FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new CutsceneAnimTestState());

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		var pressedEnter:Bool = gamepad != null ? FlxG.keys.justPressed.ENTER || gamepad.justPressed.START : FlxG.keys.justPressed.ENTER;

		if (pressedEnter && !transitioning && skippedIntro) {
			if (FlxG.sound.music != null)
				FlxG.sound.music.onComplete = null;

			titleText.animation.play('press');
			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
			transitioning = true;
			FlxG.switchState(new MainMenuState());
		}

		if (pressedEnter && !skippedIntro && initialized)
			skipIntro();
		#if USE_SHADERS
		if (controls.UI_LEFT || controls.UI_RIGHT) swagShader.update(elapsed * (controls.UI_LEFT ? 0.1 : -0.1));
		#end

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>) {
		for (i in 0...textArray.length) {
			var text:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			text.screenCenter(X);
			text.y += (i * 60) + 200;
			credGroup.add(text);
		}
	}

	function addMoreText(_text:String) {
		var text:Alphabet = new Alphabet(0, 0, _text, true, false);
		text.screenCenter(X);
		text.y += ((credGroup.length - 1) * 60) + 200;
		credGroup.add(text);
	}

	function deleteCoolText() {
		while (credGroup.members.length > 1)
			credGroup.remove(credGroup.members[1], true);
	}

	override function beatHit() {
		super.beatHit();

		if (logoBl != null && gfDance != null) {
			logoBl.animation.play('bump');
			danceLeft = !danceLeft;
			gfDance.animation.play(danceLeft ? 'danceRight' : 'danceLeft');
		}

		if (curBeat > lastBeat && credGroup != null) {
			for (i in lastBeat...curBeat) {
				switch (i + 1) {
					case 1:
						createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
					case 3:
						addMoreText('present');
					case 4:
						deleteCoolText();
					case 5:
						createCoolText(['In association', 'with']);
					case 7:
						addMoreText('newgrounds');
						ngSpr.visible = true;
					case 8:
						deleteCoolText();
						ngSpr.visible = false;
					case 9:
						createCoolText([curWacky[0]]);
					case 11:
						addMoreText(curWacky[1]);
					case 12:
						deleteCoolText();
					case 13:
						addMoreText('Friday');
					case 14:
						addMoreText('Night');
					case 15:
						addMoreText('Funkin');
					case 16:
						skipIntro();
				}
			}
		}

		lastBeat = curBeat;
	}

	function skipIntro():Void {
		if (!skippedIntro) {
			FlxG.camera.flash(FlxColor.WHITE, 4);
			skippedIntro = true;
			remove(ngSpr, true);
			remove(credGroup, true);
		}
	}
}
