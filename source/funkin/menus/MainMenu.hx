package funkin.menus;

#if discord_rpc
import dependency.Discord.DiscordClient;
#end
import flixel.util.FlxTimer;
import flixel.FlxState;
import funkin.ui.MenuItem;
import funkin.ui.MenuTypedList;
import funkin.ui.AtlasMenuItem;
import funkin.config.OptionsState;
import funkin.config.Options;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import funkin.system.*;
import funkin.menus.*;
class MainMenu extends MusicBeatState {
	var menuItems:MainMenuList;

	var optionShit:Array<String> = 
	[
		'story mode', 
		'freeplay', 
		'donate', 
		'options'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	override function create() {
		#if discord_rpc
		DiscordClient.changePresence('Main Menu', null);
		#end

		FlxG.mouse.visible = true;

		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(null, null, Paths.image('menuObjects/main_menu/menuBG'));
		bg.scrollFactor.set(0, 0.17);
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(null, null, Paths.image('menuObjects/main_menu/menuDesat'));
		magenta.scrollFactor.set(bg.scrollFactor.x, bg.scrollFactor.y);
		magenta.setGraphicSize(Std.int(bg.width));
		magenta.updateHitbox();
		magenta.setPosition(bg.x, bg.y);
		magenta.visible = false;
		magenta.color = 0xFFFD719B;

		if (Options.getOption('flashing-menu'))
		{	
			add(magenta);
		}
		
		menuItems = new MainMenuList();
		menuItems.enabled = false;
		add(menuItems);
		menuItems.onChange.add(onMenuItemChange);
		menuItems.onAcceptPress.add(function(item:MenuItem) FlxFlicker.flicker(magenta, 1.1, 0.15, false, true));

		menuItems.createItem(null, null, 'story mode', function() startExitState(new StoryMenu()));
		menuItems.createItem(null, null, 'freeplay', function() startExitState(new FreeplayMenu()));

		menuItems.createItem(0, 0, 'options', function() startExitState(new OptionsState()));

		var pos:Float = (FlxG.height - 160 * (menuItems.length - 1)) / 2;
		for (i in 0...menuItems.length) {
			var item:MainMenuItem = menuItems.members[i];
			item.x = FlxG.width / 2;
			item.y = pos + (160 * i);
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "FNF: Everlast Engine | v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat('VCR OSD Mono', 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		super.create();
	}

	override function finishTransIn() {
		super.finishTransIn();
		menuItems.enabled = true;
	}

	function onMenuItemChange(item:MenuItem)
		camFollow.setPosition(item.getGraphicMidpoint().x, item.getGraphicMidpoint().y);

	function selectDonate() {
		#if linux
		Sys.command('/usr/bin/xdg-open', [
			'https://ninja-muffin24.itch.io/funkin',
			'&'
		]);
		#else
		FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
		#end
	}

	function startExitState(nextState:FlxState) {
		menuItems.enabled = false;
		menuItems.forEach(function(item:MainMenuItem) {
			if (menuItems.selectedIndex != item.ID)
				FlxTween.tween(item, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
			else
				item.visible = false;
		});
		new FlxTimer().start(0.4, function(tmr:FlxTimer) FlxG.switchState(nextState));
	}

	override function update(elapsed:Float) {
		FlxG.camera.followLerp = MathFunctions.fixedLerpValue(0.06);

		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		if (_exiting)
			menuItems.enabled = false;
		if (controls.BACK && menuItems.enabled && !menuItems.busy)
			FlxG.switchState(new TitleState());

		super.update(elapsed);
	}
}

class MainMenuItem extends AtlasMenuItem {
	public function new(?x:Float = 0, ?y:Float = 0, name:String, atlas:FlxAtlasFrames, callback:Dynamic) {
		super(x, y, name, atlas, callback);
		this.scrollFactor.set();
	}

	override public function changeAnim(anim:String) {
		super.changeAnim(anim);
		origin.set(frameWidth * 0.5, frameHeight * 0.5);
		offset.copyFrom(origin);
	}
}

class MainMenuList extends MenuTypedList<MainMenuItem> {
	var atlas:FlxAtlasFrames;

	public function new() {
		atlas = Paths.getSparrowAtlas('menuObjects/main_menu/main_menu_assets');
		super(Vertical);
	}

	public function createItem(?x:Float = 0, ?y:Float = 0, name:String, callback:Dynamic = null, fireInstantly:Bool = false) {
		var item:MainMenuItem = new MainMenuItem(x, y, name, atlas, callback);
		item.fireInstantly = fireInstantly;
		item.ID = length;
		return addItem(name, item);
	}
}
