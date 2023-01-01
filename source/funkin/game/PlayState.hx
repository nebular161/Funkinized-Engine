package funkin.game;

import animate.FlxAnimate;
import animateatlas.AtlasFrameMaker;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import funkin.backgrounds.BGSprite;
import funkin.backgrounds.BackgroundDancer;
import funkin.backgrounds.BackgroundGirls;
import funkin.backgrounds.TankmenBG;
import funkin.config.PreferencesMenu;
import funkin.editors.CharacterEditor;
import funkin.editors.ChartingState;
import funkin.game.Conductor;
import funkin.game.CoolUtil;
import funkin.game.Section.SwagSection;
import funkin.game.Song.SwagSong;
import funkin.menus.StoryMenuState;
import funkin.mp4.FlxVideo;
import funkin.mp4.MP4Handler;
import funkin.mp4.VideoState;
import funkin.shaders.BuildingShaders;
import funkin.shaders.ColorSwap;
import funkin.system.GitarooPause;
import funkin.system.Highscore;
import funkin.system.LoadingState;
import funkin.system.MathFunctions;
import funkin.system.MusicBeatState;
import funkin.ui.DialogueBox;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.Shader;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import openfl.utils.Assets;

using StringTools;
#if desktop
import dependency.Discord.DiscordClient;
#end

class PlayState extends MusicBeatState {
	public static var instance:PlayState = null;
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var deathCounter:Int = 0;
	public static var practiceMode:Bool = false;
	public static var seenCutscene:Bool = false;

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;
	private var vocalsFinished = false;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var songMisses:Int = 0;

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;
	private var camPos:FlxPoint;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;

	public static var dadStrums:FlxTypedGroup<FlxSprite> = null;

	private var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	private var camZooming:Bool = false;
	private var curSong:String = '';

	public var bg:BGSprite;
	public var stageFront:FlxSprite;
	public var stageCurtains:FlxSprite;

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	var dialogue:Array<String> = ['tesy', 'this is also a test'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var foregroundSprites:FlxTypedGroup<BGSprite>;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;
	#if USE_SHADERS
	var lightFadeShader:BuildingShaders;
	#end

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;

	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;

	var gfCutsceneLayer:FlxTypedGroup<FlxAnimate>;
	var bfTankCutsceneLayer:FlxTypedGroup<FlxAnimate>;

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	// Discord RPC variables
	var storyDifficultyText:String = '';
	var iconRPC:String = '';
	var songLength:Float = 0;
	var detailsText:String = '';
	var detailsPausedText:String = '';

	override public function create() {
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.mouse.useSystemCursor = true;

		var instPath = Paths.inst(SONG.song.toLowerCase());
		if (Assets.exists(instPath, SOUND) || Assets.exists(instPath, MUSIC))
			Assets.getSound(instPath, true);
		var vocalsPath = Paths.voices(SONG.song.toLowerCase());
		if (Assets.exists(vocalsPath, SOUND) || Assets.exists(vocalsPath, MUSIC))
			Assets.getSound(vocalsPath, true);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.1;

		persistentUpdate = persistentDraw = true;

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		foregroundSprites = new FlxTypedGroup<BGSprite>();

		switch (SONG.song.toLowerCase()) {
			case 'tutorial':
				dialogue = ['Hey you\'re pretty cute.', 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					'You think you can just sing\nwith my daughter like that?',
					'If you want to date her...',
					'You\'re going to have to go \nthrough ME first!'
				];
			case 'fresh':
				dialogue = ['Not too shabby boy.', ''];
			case 'dadbattle':
				dialogue = [
					'gah you think you\'re hot stuff?',
					'If you can beat me here...',
					'Only then I will even CONSIDER letting you\ndate my daughter!'
				];
			case 'senpai':
				dialogue = Paths.getTextFileArray(Paths.txt('dialouges/senpaiDialogue'));
			case 'roses':
				dialogue = Paths.getTextFileArray(Paths.txt('dialouges/rosesDialogue'));
			case 'thorns':
				dialogue = Paths.getTextFileArray(Paths.txt('dialouges/thornsDialogue'));
		}

		#if discord_rpc
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty) {
			case 0:
				storyDifficultyText = 'Easy';
			case 1:
				storyDifficultyText = 'Normal';
			case 2:
				storyDifficultyText = 'Hard';
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC) {
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode) {
			detailsText = 'Story Mode: Week ' + storyWeek;
		} else {
			detailsText = 'Freeplay';
		}

		// String for when the game is paused
		detailsPausedText = 'Paused - ' + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + ' (' + storyDifficultyText + ')', iconRPC);
		#end

		switch (SONG.stage) {
			case 'spooky':
				{
					curStage = 'spooky';
					halloweenLevel = true;

					var hallowTex = Paths.getSparrowAtlas('stage_assets/week2/halloween_bg', 'shared');

					halloweenBG = new FlxSprite(-200, -100);
					halloweenBG.frames = hallowTex;
					halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
					halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
					halloweenBG.animation.play('idle');
					halloweenBG.antialiasing = true;
					add(halloweenBG);

					isHalloween = true;
				}
			case 'philly':
				{
					curStage = 'philly';

					var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('stage_assets/week3/sky', 'shared'));
					bg.scrollFactor.set(0.1, 0.1);
					add(bg);

					var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('stage_assets/week3/city', 'shared'));
					city.scrollFactor.set(0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					add(city);

					phillyCityLights = new FlxTypedGroup<FlxSprite>();
					add(phillyCityLights);

					for (i in 0...5) {
						var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('stage_assets/week3/win' + i, 'shared'));
						light.scrollFactor.set(0.3, 0.3);
						light.visible = false;
						light.setGraphicSize(Std.int(light.width * 0.85));
						light.updateHitbox();
						light.antialiasing = true;
						phillyCityLights.add(light);
					}

					var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('stage_assets/week3/behindTrain', 'shared'));
					add(streetBehind);

					phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('stage_assets/week3/train', 'shared'));
					add(phillyTrain);

					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
					FlxG.sound.list.add(trainSound);

					// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

					var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('stage_assets/week3/street', 'shared'));
					add(street);
				}
			case 'limo':
				{
					curStage = 'limo';
					defaultCamZoom = 0.90;

					var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('stage_assets/week4/limoSunset', 'shared'));
					skyBG.scrollFactor.set(0.1, 0.1);
					add(skyBG);

					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('stage_assets/week4/bgLimo', 'shared');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					add(bgLimo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5) {
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('stage_assets/week4/limoOverlay', 'shared'));
					overlayShit.alpha = 0.5;

					var limoTex = Paths.getSparrowAtlas('stage_assets/week4/limoDrive', 'shared');

					limo = new FlxSprite(-120, 550);
					limo.frames = limoTex;
					limo.animation.addByPrefix('drive', "Limo stage", 24);
					limo.animation.play('drive');
					limo.antialiasing = true;

					fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('stage_assets/week4/fastCarLol', 'shared'));
					// add(limo);
				}
			case 'mall':
				{
					curStage = 'mall';

					defaultCamZoom = 0.80;

					var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('stage_assets/week5/bgWalls', 'shared'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					upperBoppers = new FlxSprite(-240, -90);
					upperBoppers.frames = Paths.getSparrowAtlas('stage_assets/week5/upperBop', 'shared');
					upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
					upperBoppers.antialiasing = true;
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('stage_assets/week5/bgEscalator', 'shared'));
					bgEscalator.antialiasing = true;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);

					var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('stage_assets/week5/christmasTree', 'shared'));
					tree.antialiasing = true;
					tree.scrollFactor.set(0.40, 0.40);
					add(tree);

					bottomBoppers = new FlxSprite(-300, 140);
					bottomBoppers.frames = Paths.getSparrowAtlas('stage_assets/week5/bottomBop', 'shared');
					bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
					bottomBoppers.antialiasing = true;
					bottomBoppers.scrollFactor.set(0.9, 0.9);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();
					add(bottomBoppers);

					var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('stage_assets/week5/fgSnow', 'shared'));
					fgSnow.active = false;
					fgSnow.antialiasing = true;
					add(fgSnow);

					santa = new FlxSprite(-840, 150);
					santa.frames = Paths.getSparrowAtlas('stage_assets/week5/santa', 'shared');
					santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
					santa.antialiasing = true;
					add(santa);
				}
			case 'mallEvil':
				{
					curStage = 'mallEvil';
					var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('stage_assets/week5/evilBG', 'shared'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('stage_assets/week5/evilTree', 'shared'));
					evilTree.antialiasing = true;
					evilTree.scrollFactor.set(0.2, 0.2);
					add(evilTree);

					var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("stage_assets/week5/evilSnow", 'shared'));
					evilSnow.antialiasing = true;
					add(evilSnow);
				}
			case 'school':
				{
					curStage = 'school';

					// defaultCamZoom = 0.9;

					var bgSky = new FlxSprite().loadGraphic(Paths.image('stage_assets/week6/weebSky', 'shared'));
					bgSky.scrollFactor.set(0.1, 0.1);
					add(bgSky);

					var repositionShit = -200;

					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('stage_assets/week6/weebSchool', 'shared'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					add(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('stage_assets/week6/weebStreet', 'shared'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					add(bgStreet);

					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('stage_assets/week6/weebTreesBack', 'shared'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					add(fgTrees);

					var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
					var treetex = Paths.getPackerAtlas('stage_assets/week6/weebTrees', 'shared');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					add(bgTrees);

					var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
					treeLeaves.frames = Paths.getSparrowAtlas('stage_assets/week6/petals', 'shared');
					treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
					treeLeaves.animation.play('leaves');
					treeLeaves.scrollFactor.set(0.85, 0.85);
					add(treeLeaves);

					var widShit = Std.int(bgSky.width * 6);

					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
					bgTrees.setGraphicSize(Std.int(widShit * 1.4));
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					treeLeaves.setGraphicSize(widShit);

					fgTrees.updateHitbox();
					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();
					bgTrees.updateHitbox();
					treeLeaves.updateHitbox();

					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					if (SONG.song.toLowerCase() == 'roses') {
						bgGirls.getScared();
					}

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
				}
			case 'schoolEvil':
				{
					curStage = 'schoolEvil';

					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

					var posX = 400;
					var posY = 200;

					var bg:FlxSprite = new FlxSprite(posX, posY);
					bg.frames = Paths.getSparrowAtlas('stage_assets/week6/animatedEvilSchool', 'shared');
					bg.animation.addByPrefix('idle', 'background 2', 24);
					bg.animation.play('idle');
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					add(bg);
				}
			case 'tank':
				{
					defaultCamZoom = 0.9;

					curStage = 'tank';

					var sky:BGSprite = new BGSprite('stage_assets/week7/tankSky', -400, -400, 0, 0);
					add(sky);

					var clouds:BGSprite = new BGSprite('stage_assets/week7/tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
					clouds.active = true;
					clouds.velocity.x = FlxG.random.float(5, 15);
					add(clouds);

					var mountains:BGSprite = new BGSprite('stage_assets/week7/tankMountains', -300, -20, 0.2, 0.2);
					mountains.setGraphicSize(Std.int(mountains.width * 1.2));
					mountains.updateHitbox();
					add(mountains);

					var buildings:BGSprite = new BGSprite('stage_assets/week7/tankBuildings', -200, 0, 0.3, 0.3);
					buildings.setGraphicSize(Std.int(buildings.width * 1.1));
					buildings.updateHitbox();
					add(buildings);

					var ruins:BGSprite = new BGSprite('stage_assets/week7/tankRuins', -200, 0, 0.35, 0.35);
					ruins.setGraphicSize(Std.int(ruins.width * 1.1));
					ruins.updateHitbox();
					add(ruins);

					var smokeL:BGSprite = new BGSprite('stage_assets/week7/smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
					add(smokeL);

					var smokeR:BGSprite = new BGSprite('stage_assets/week7/smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
					add(smokeR);

					tankWatchtower = new BGSprite('stage_assets/week7/tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
					add(tankWatchtower);

					tankGround = new BGSprite('stage_assets/week7/tankRolling', 300, 300, 0.5, 0.5, ['BG tank w lighting'], true);
					add(tankGround);

					tankmanRun = new FlxTypedGroup<TankmenBG>();
					add(tankmanRun);

					var ground:BGSprite = new BGSprite('stage_assets/week7/tankGround', -420, -150);
					ground.setGraphicSize(Std.int(ground.width * 1.15));
					ground.updateHitbox();
					add(ground);
					moveTank();

					var tankdude0:BGSprite = new BGSprite('stage_assets/week7/tank0', -500, 650, 1.7, 1.5, ['fg']);
					foregroundSprites.add(tankdude0);

					var tankdude1:BGSprite = new BGSprite('stage_assets/week7/tank1', -300, 750, 2, 0.2, ['fg']);
					foregroundSprites.add(tankdude1);

					var tankdude2:BGSprite = new BGSprite('stage_assets/week7/tank2', 450, 940, 1.5, 1.5, ['foreground']);
					foregroundSprites.add(tankdude2);

					var tankdude4:BGSprite = new BGSprite('stage_assets/week7/tank4', 1300, 900, 1.5, 1.5, ['fg']);
					foregroundSprites.add(tankdude4);

					var tankdude5:BGSprite = new BGSprite('stage_assets/week7/tank5', 1620, 700, 1.5, 1.5, ['fg']);
					foregroundSprites.add(tankdude5);

					var tankdude3:BGSprite = new BGSprite('stage_assets/week7/tank3', 1300, 1200, 3.5, 2.5, ['fg']);
					foregroundSprites.add(tankdude3);
				}
			case 'stage':
				{
					defaultCamZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stage_assets/week1/stageback'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stage_assets/week1/stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = true;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stage_assets/week1/stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = true;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

					add(stageCurtains);
				}
			default:
				{
					defaultCamZoom = 0.9;
					curStage = 'stage';

					bg = new BGSprite('stage_assets/week1/stageback', -600, -200, 0.9, 0.9);
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stage_assets/week1/stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stage_assets/week1/stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

					add(stageCurtains);
				}
		}

		var gfVersion:String = 'gf';

		switch (curStage) {
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
			case 'tank':
				gfVersion = 'gf-tankmen';
		}

		if (SONG.song.toLowerCase() == 'stress')
			gfVersion = 'pico-speaker';

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		if (gfVersion == 'pico-speaker') {
			var tankmen:TankmenBG = new TankmenBG(20, 500, true);
			tankmen.strumTime = 10;
			tankmen.resetShit(20, 600, true);
			tankmanRun.add(tankmen);

			for (i in 0...TankmenBG.animationNotes.length) {
				if (!FlxG.random.bool(16))
					continue;

				var man:TankmenBG = tankmanRun.recycle(TankmenBG);
				man.strumTime = TankmenBG.animationNotes[i][0];
				man.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
				tankmanRun.add(man);
			}
		}

		dad = new Character(100, 100, SONG.player2);
		camPos = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2) {
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode) {
					camPos.x += 600;
					tweenCamIn();
				}
			case 'spooky':
				dad.y += 200;
			case 'monster':
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
			case 'tankman':
				dad.y += 180;
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage) {
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);
			case 'mall':
				boyfriend.x += 200;
			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				add(evilTrail);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'tank':
				gf.y += 10;
				gf.x -= 30;
				boyfriend.x += 40;
				boyfriend.y += 0;
				dad.y += 60;
				dad.x -= 80;

				if (gfVersion != 'pico-speaker') {
					gf.x -= 170;
					gf.y -= 75;
				} else {
					gf.x -= 50;
					gf.y -= 200;
				}
		}

		add(gf);

		gfCutsceneLayer = new FlxTypedGroup<FlxAnimate>();
		add(gfCutsceneLayer);

		bfTankCutsceneLayer = new FlxTypedGroup<FlxAnimate>();
		add(bfTankCutsceneLayer);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);

		add(foregroundSprites);

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, PreferencesMenu.getPref('downscroll') ? FlxG.height - 150 : 50).makeGraphic(FlxG.width, 10);
		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		add(grpNoteSplashes);

		var splashTest:NoteSplash = new NoteSplash(-700, 100, 0);
		grpNoteSplashes.add(splashTest);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		dadStrums = new FlxTypedGroup<FlxSprite>();

		generateSong();

		camFollow = new FlxObject(camPos.x, camPos.y, 1, 1);

		if (prevCamFollow != null) {
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('gameObjects/healthbar/healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);
		if (PreferencesMenu.getPref('downscroll'))
			healthBarBG.y = FlxG.height * 0.1;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 190, healthBarBG.y + 30, 0, '', 20);
		scoreTxt.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		grpNoteSplashes.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode && !seenCutscene) {
			seenCutscene = true;

			var video:MP4Handler = new MP4Handler();

			switch (curSong.toLowerCase()) {
				case 'winter-horrorland':
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer) {
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer) {
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween) {
									startCountdown();
								}
							});
						});
					});
				case 'senpai' | 'roses' | 'thorns':
					if (curSong.toLowerCase() == 'roses')
						FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(newDialogueBox(dialogue, startCountdown, camHUD));
				case 'ugh':
					video.playMP4(Paths.video('ughCutscene'), new PlayState());
				case 'guns':
					video.playMP4(Paths.video('gunsCutscene'), new PlayState());
				case 'stress':
					video.playMP4(Paths.video('stressCutscene'), new PlayState());
				default:
					startCountdown();
			}
		} else {
			switch (curSong.toLowerCase()) {
				default:
					startCountdown();
			}
		}

		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void {
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('characters/senpai/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * daPixelZoom));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += senpaiEvil.width / 5;

		camFollow.setPosition(camPos.x, camPos.y);

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns') {
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns') {
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer) {
			black.alpha -= 0.15;

			if (black.alpha > 0) {
				tmr.reset(0.3);
			} else {
				if (dialogueBox != null) {
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns') {
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer) {
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1) {
								swagTimer.reset();
							} else {
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function() {
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function() {
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer) {
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					} else {
						add(dialogueBox);
					}
				} else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer = new FlxTimer();

	function startCountdown():Void {
		inCutscene = false;

		camHUD.visible = true;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer.start(Conductor.crochet / 1000, function(tmr:FlxTimer) {
			if (swagCounter % gfSpeed == 0) {
				gf.dance();
			}
			if (swagCounter % 2 == 0) {
				if (!boyfriend.animation.curAnim.name.startsWith('sing'))
					boyfriend.playAnim('idle');
				if (!dad.animation.curAnim.name.startsWith('sing'))
					dad.dance();
			} else if (dad.curCharacter == 'spooky' && !dad.animation.curAnim.name.startsWith('sing'))
				dad.dance();

			if (generatedMusic) {
				notes.members.sort(function(Obj1:Note, Obj2:Note) {
					return sortNotes(FlxSort.DESCENDING, Obj1, Obj2);
				});
			}

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['gameObjects/countdowns/base/ready', "gameObjects/countdowns/base/set", "gameObjects/countdowns/base/go"]);
			introAssets.set('school', ['gameObjects/countdowns/pixel/ready-pixel', 'gameObjects/countdowns/pixel/set-pixel', 'gameObjects/countdowns/pixel/date-pixel']);
			introAssets.set('schoolEvil', ['gameObjects/countdowns/pixel/ready-pixel', 'gameObjects/countdowns/pixel/set-pixel', 'gameObjects/countdowns/pixel/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = '';

			for (value in introAssets.keys()) {
				if (value == curStage) {
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter) {
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween) {
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween) {
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween) {
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 4);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void {
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if discord_rpc
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + ' (' + storyDifficultyText + ')', iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong():Void {
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		vocals.onComplete = function() {
			vocalsFinished = true;
		};
		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData) {
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes) {
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3) {
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.altNote = songNotes[3];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength /= Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength)) {
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress) {
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress) {
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int {
		return sortNotes(FlxSort.ASCENDING, Obj1, Obj2);
	}

	function sortNotes(Sort:Int = FlxSort.ASCENDING, Obj1:Note, Obj2:Note):Int {
		return Obj1.strumTime < Obj2.strumTime ? Sort : Obj1.strumTime > Obj2.strumTime ? -Sort : 0;
	}

	private function generateStaticArrows(player:Int):Void {
		for (i in 0...4) {
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			var colorSwap:ColorSwap = new ColorSwap();

			babyArrow.shader = colorSwap.shader;
			colorSwap.update(Note.arrowColors[i]);

			switch (curStage) {
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('gameObjects/notes/pixel/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i)) {
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('gameObjects/notes/base/NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i)) {
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode) {
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			babyArrow.ID = i;

			switch (player) {
				case 0:
					dadStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			dadStrums.forEach(function(spr:FlxSprite) {
				spr.centerOffsets();
			});

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void {
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState) {
		if (paused) {
			if (FlxG.sound.music != null) {
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState() {
		if (paused) {
			if (FlxG.sound.music != null && !startingSong) {
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if discord_rpc
			if (startTimer.finished) {
				DiscordClient.changePresence(detailsText, SONG.song + ' (' + storyDifficultyText + ')', iconRPC, true, songLength - Conductor.songPosition);
			} else {
				DiscordClient.changePresence(detailsText, SONG.song + ' (' + storyDifficultyText + ')', iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	#if discord_rpc
	override public function onFocus():Void {
		if (health > 0 && !paused) {
			if (Conductor.songPosition > 0.0) {
				DiscordClient.changePresence(detailsText, SONG.song + ' (' + storyDifficultyText + ')', iconRPC, true, songLength - Conductor.songPosition);
			} else {
				DiscordClient.changePresence(detailsText, SONG.song + ' (' + storyDifficultyText + ')', iconRPC);
			}
		}

		super.onFocus();
	}

	override public function onFocusLost():Void {
		if (health > 0 && !paused) {
			DiscordClient.changePresence(detailsPausedText, SONG.song + ' (' + storyDifficultyText + ')', iconRPC);
		}

		super.onFocusLost();
	}
	#end

	function resyncVocals():Void {
		if (!_exiting) {
			vocals.pause();

			FlxG.sound.music.play();
			Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;
			if (!vocalsFinished) {
				vocals.time = Conductor.songPosition;
				vocals.play();
			}
		}
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var cameraRightSide:Bool = false;

	public static final iconOffset:Int = 26;

	override public function update(elapsed:Float) {
		if (startingSong) {
			if (startedCountdown) {
				Conductor.songPosition += FlxG.elapsed * 1000.0;
				if (Conductor.songPosition >= 0.0)
					startSong();
			}
		} else {
			#if USE_INST_TIME
			Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;
			#else
			Conductor.songPosition += FlxG.elapsed * 1000.0;
			#end
		}

		switch (curStage) {
			case 'philly':
				if (trainMoving) {
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24) {
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}

			case 'tank':
				moveTank();
		}

		super.update(elapsed);

		scoreTxt.text = 'Score:' + songScore;

		if (controls.PAUSE && startedCountdown && canPause) {
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1)) {
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			} else {
				var screenPos:FlxPoint = boyfriend.getScreenPosition();
				var pauseMenu:PauseSubState = new PauseSubState(screenPos.x, screenPos.y);
				openSubState(pauseMenu);
				pauseMenu.camera = camHUD;
			}

			#if discord_rpc
			DiscordClient.changePresence(detailsPausedText, SONG.song + ' (' + storyDifficultyText + ')', iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN) {
			FlxG.switchState(new ChartingState());

			#if discord_rpc
			DiscordClient.changePresence('Chart Editor', null, null, true);
			#end
		}

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		health = FlxMath.bound(health, 0, 2);

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new CharacterEditor(SONG.player2));

		if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new CharacterEditor(SONG.player1));

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null) {
			cameraRightSide = PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection;
			cameraMovement();
		}

		if (camZooming) {
			FlxG.camera.zoom = MathFunctions.fixedLerp(FlxG.camera.zoom, defaultCamZoom, 0.05);
			camHUD.zoom = MathFunctions.fixedLerp(camHUD.zoom, 1, 0.05);
		}

		FlxG.watch.addQuick('beatShit', curBeat);
		FlxG.watch.addQuick('stepShit', curStep);

		if (curSong.toLowerCase() == 'fresh') {
			switch (curBeat) {
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
			}
		}

		if (curSong.toLowerCase() == 'bopeebo') {
			switch (curBeat) {
				case 128, 129, 130:
					vocals.volume = 0;
			}
		}
		// better streaming of shit

		if (!inCutscene && !_exiting) {
			// RESET = Quick Game Over Screen
			if (controls.RESET) {
				health = 0;
				trace('RESET = True');
			}

			// CHEAT = brandon's a pussy
			// if (controls.CHEAT)
			// {
			// 	health += 1;
			// 	trace('User is cheating!');
			// }

			if (health <= 0 && !practiceMode) {
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				deathCounter += 1;

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if discord_rpc
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence('Game Over - ' + detailsText, SONG.song + ' (' + storyDifficultyText + ')', iconRPC);
				#end
			}
		}

		while (unspawnNotes[0] != null) {
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1800 / SONG.speed) {
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.shift();
			} else {
				break;
			}
		}

		if (generatedMusic) {
			notes.forEachAlive(function(daNote:Note) {
				if (daNote.y > FlxG.height) {
					daNote.active = false;
					daNote.visible = false;
				} else {
					daNote.visible = true;
					daNote.active = true;
				}

				var center = strumLine.y + (Note.swagWidth / 2);

				if (PreferencesMenu.getPref('downscroll')) {
					daNote.y = strumLine.y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);

					if (daNote.isSustainNote) {
						if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
							daNote.y += daNote.prevNote.height;
						else
							daNote.y += daNote.height / 2;

						if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
							&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit)))) {
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
				} else {
					daNote.y = strumLine.y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);

					if (daNote.isSustainNote
						&& daNote.y + daNote.offset.y * daNote.scale.y <= center
						&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit)))) {
						var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
						swagRect.y = (center - daNote.y) / daNote.scale.y;
						swagRect.height -= swagRect.y;

						daNote.clipRect = swagRect;
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit) {
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = '';

					if (SONG.notes[Math.floor(curStep / 16)] != null) {
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}
					if (daNote.altNote)
						altAnim = '-alt';

					if (PreferencesMenu.getPref('glow-strums')) {
						dadStrums.forEach(function(spr:FlxSprite) {
							if (Math.abs(daNote.noteData) == spr.ID) {
								spr.animation.play('confirm', true);
							}
							if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school')) {
								spr.centerOffsets();
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							} else
								spr.centerOffsets();
						});
					}

					switch (Math.abs(daNote.noteData)) {
						case 0:
							dad.playAnim('singLEFT' + altAnim, true);
						case 1:
							dad.playAnim('singDOWN' + altAnim, true);
						case 2:
							dad.playAnim('singUP' + altAnim, true);
						case 3:
							dad.playAnim('singRIGHT' + altAnim, true);
					}

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (PreferencesMenu.getPref('glow-strums')) {
					dadStrums.forEach(function(spr:FlxSprite) {
						if (spr.animation.finished) {
							spr.animation.play('static');
							spr.centerOffsets();
						}
					});
				}

				var doKill = daNote.y < -daNote.height;
				if (PreferencesMenu.getPref('downscroll'))
					doKill = daNote.y > FlxG.height;

				if (doKill) {
					if (daNote.tooLate || !daNote.wasGoodHit) {
						health -= 0.03;
						vocals.volume = 0;
						songMisses;
						noteMiss(daNote.noteData);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void {
		seenCutscene = false;
		deathCounter = 0;
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;

		if (SONG.validScore)
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);

		if (isStoryMode) {
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				if (storyWeek == 7)
					FlxG.switchState(new VideoState());
				else
					FlxG.switchState(new StoryMenuState());

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore) {
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			} else {
				var difficulty:String = '';

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				FlxG.sound.music.stop();
				vocals.stop();

				if (SONG.song.toLowerCase() == 'eggnog') {
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'), 1, false, null, true, function() {
						PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
						LoadingState.loadAndSwitchState(new PlayState());
					});
				} else {
					prevCamFollow = camFollow;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);

					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
		} else {
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float, daNote:Note):Void {
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = 'sick';
		var doSplash:Bool = true;

		if (noteDiff > Conductor.safeZoneOffset * 0.9) {
			daRating = 'shit';
			score = 50;
			doSplash = false;
		} else if (noteDiff > Conductor.safeZoneOffset * 0.75) {
			daRating = 'bad';
			score = 100;
			doSplash = false;
		} else if (noteDiff > Conductor.safeZoneOffset * 0.2) {
			daRating = 'good';
			score = 200;
			doSplash = false;
		}

		if (doSplash) {
			var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			splash.setupNoteSplash(daNote.x + 57, playerStrums.members[daNote.noteData].y + 50, daNote.noteData);
			grpNoteSplashes.add(splash);
		}

		if (!practiceMode)
			songScore += score;

        // alexshadow's been here
        // alexshadow's been here
		// alexshadow's been here

        var thePrefix:String = 'base';
		// var pixelShitPart1:String = '';
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school')) {
			pixelShitPart2 = '-pixel';
            thePrefix = 'pixel';
		}

		rating.loadGraphic(Paths.image('gameObjects/ratings/$thePrefix/' + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameObjects/ratings/$thePrefix/' + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);
		if (combo >= 0)
			add(comboSpr); // adds the combo sprite

		if (!curStage.startsWith('school')) {
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		} else {
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];
		var comboSplit:Array<String> = (combo + "").split('');

		for (i in 0...comboSplit.length) {
			var str:String = comboSplit[i];
			seperatedScore.push(Std.parseInt(str));
		}

		var daLoop:Int = 0;
		for (i in seperatedScore) {
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameObjects/nums/$thePrefix/' + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school')) {
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			} else {
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 0 || combo == 0) // so much win
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween) {
					numScore.kill();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}

		coolText.text = Std.string(seperatedScore);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween) {
				rating.kill();
			},
			startDelay: Conductor.crochet * 0.00125
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.09, {
			onComplete: function(tween:FlxTween) {
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	private function cameraMovement():Void {
		if (camFollow.x != dad.getMidpoint().x + 150 && !cameraRightSide) {
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

			switch (dad.curCharacter) {
				case 'mom':
					camFollow.y = dad.getMidpoint().y;
				case 'senpai' | 'senpai-angry':
					camFollow.y = dad.getMidpoint().y - 430;
					camFollow.x = dad.getMidpoint().x - 100;
			}

			if (dad.curCharacter == 'mom')
				vocals.volume = 1;

			if (SONG.song.toLowerCase() == 'tutorial') {
				tweenCamIn();
			}
		}

		if (cameraRightSide && camFollow.x != boyfriend.getMidpoint().x - 100) {
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

			switch (curStage) {
				case 'limo':
					camFollow.x = boyfriend.getMidpoint().x - 300;
				case 'mall':
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'school':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'schoolEvil':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
			}

			if (SONG.song.toLowerCase() == 'tutorial') {
				FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
			}
		}
	}

	private function keyShit():Void {
		var holdingArray:Array<Bool> = [controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT];
		var controlArray:Array<Bool> = [
			controls.NOTE_LEFT_P,
			controls.NOTE_DOWN_P,
			controls.NOTE_UP_P,
			controls.NOTE_RIGHT_P
		];
		var releaseArray:Array<Bool> = [
			controls.NOTE_LEFT_R,
			controls.NOTE_DOWN_R,
			controls.NOTE_UP_R,
			controls.NOTE_RIGHT_R
		];

		// FlxG.watch.addQuick('asdfa', upP);
		if (holdingArray.contains(true) && generatedMusic) {
			notes.forEachAlive(function(daNote:Note) {
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdingArray[daNote.noteData])
					goodNoteHit(daNote);
			});
		}
		if (controlArray.contains(true) && generatedMusic) {
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			var removeList:Array<Note> = [];

			notes.forEachAlive(function(daNote:Note) {
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					if (ignoreList.contains(daNote.noteData)) {
						for (possibleNote in possibleNotes) {
							if (possibleNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - possibleNote.strumTime) < 10) {
								removeList.push(daNote);
							} else if (possibleNote.noteData == daNote.noteData && daNote.strumTime < possibleNote.strumTime) {
								possibleNotes.remove(possibleNote);
								possibleNotes.push(daNote);
							}
						}
					} else {
						possibleNotes.push(daNote);
						ignoreList.push(daNote.noteData);
					}
				}
			});

			for (badNote in removeList) {
				badNote.kill();
				notes.remove(badNote, true);
				badNote.destroy();
			}

			possibleNotes.sort(function(note1:Note, note2:Note) {
				return Std.int(note1.strumTime - note2.strumTime);
			});

			if (possibleNotes.length > 0) {
				for (i in 0...controlArray.length) {
					if (controlArray[i] && !ignoreList.contains(i)) {
						badNoteHit();
					}
				}
				for (possibleNote in possibleNotes) {
					if (controlArray[possibleNote.noteData]) {
						goodNoteHit(possibleNote);
					}
				}
			} else
				badNoteHit();
		}
		if (boyfriend.holdTimer > 0.007 * Conductor.stepCrochet
			&& !holdingArray.contains(true)
			&& boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.animation.curAnim.name.endsWith('miss')) {
			boyfriend.playAnim('idle');
		}
		playerStrums.forEach(function(spr:FlxSprite) {
			if (controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.animation.play('pressed');
			if (!holdingArray[spr.ID])
				spr.animation.play('static');

			if (spr.animation.curAnim.name != 'confirm' || curStage.startsWith('school'))
				spr.centerOffsets();
			else {
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
		});
	}

	function noteMiss(direction:Int = 1):Void {
		if (!boyfriend.stunned) {
			health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad')) {
				gf.playAnim('sad');
			}
			combo = 0;

			if (!practiceMode)
				songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer) {
				boyfriend.stunned = false;
			});

			switch (direction) {
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
		}
	}

	function badNoteHit() {
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var leftP = controls.NOTE_LEFT_P;
		var downP = controls.NOTE_DOWN_P;
		var upP = controls.NOTE_UP_P;
		var rightP = controls.NOTE_RIGHT_P;

		if (PreferencesMenu.getPref('ghost-tap') == false) {
			if (leftP)
				noteMiss(0);
			if (downP)
				noteMiss(1);
			if (upP)
				noteMiss(2);
			if (rightP)
				noteMiss(3);
		}
	}

	function goodNoteHit(note:Note):Void {
		if (!note.wasGoodHit) {
			if (!note.isSustainNote) {
				popUpScore(note.strumTime, note);
				combo += 1;
			}

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.04;

			switch (note.noteData) {
				case 0:
					boyfriend.playAnim('singLEFT', true);
				case 1:
					boyfriend.playAnim('singDOWN', true);
				case 2:
					boyfriend.playAnim('singUP', true);
				case 3:
					boyfriend.playAnim('singRIGHT', true);
			}

			playerStrums.forEach(function(spr:FlxSprite) {
				if (Math.abs(note.noteData) == spr.ID) {
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void {
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive() {
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer) {
			resetFastCar();
		});
	}

	var tankResetShit:Bool = false;
	var tankMoving:Bool = false;
	var tankAngle:Float = FlxG.random.int(-90, 45);
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankX:Float = 400;

	function moveTank():Void {
		if (!inCutscene) {
			tankAngle += tankSpeed * FlxG.elapsed;
			tankGround.angle = (tankAngle - 90 + 15);
			tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
		}
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void {
		trainMoving = true;
		trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void {
		if (trainSound.time >= 4700) {
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving) {
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing) {
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void {
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void {
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit() {
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20)) {
			resyncVocals();
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2) {
			// dad.dance();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit() {
		super.beatHit();

		if (generatedMusic) {
			notes.members.sort(function(note1:Note, note2:Note) {
				return sortNotes(FlxSort.DESCENDING, note1, note2);
			});
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null) {
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM) {
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			// if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
			// 	dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (PreferencesMenu.getPref('camera-zoom')) {
			// HARDCODING FOR MILF ZOOMS!
			if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35) {
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0) {
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0) {
			gf.dance();
		}

		if (curBeat % 2 == 0) {
			if (!boyfriend.animation.curAnim.name.startsWith('sing')) {
				boyfriend.playAnim('idle');
			}

			if (!dad.animation.curAnim.name.startsWith('sing')) {
				dad.dance();
			}
		} else if (dad.curCharacter == 'spooky') {
			if (!dad.animation.curAnim.name.startsWith('sing')) {
				dad.dance();
			}
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo') {
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48) {
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		foregroundSprites.forEach(function(spr:BGSprite) {
			spr.dance();
		});

		switch (curStage) {
			case 'tank':
				tankWatchtower.dance();
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer) {
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case 'philly':
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0) {
					phillyCityLights.forEach(function(light:FlxSprite) {
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8) {
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset) {
			lightningStrikeShit();
		}
	}

	public function newDialogueBox(dialogue:Array<String>, ?finishFunction:Dynamic, ?camera:flixel.FlxCamera) {
		if (finishFunction == null)
			finishFunction = startCountdown;
		if (camera == null)
			camera = camHUD;

		var box:DialogueBox = new DialogueBox(dialogue);
		box.scrollFactor.set();
		box.finishThing = finishFunction;
		box.cameras = [camera];
		return box;
	}

	var curLight:Int = 0;
}