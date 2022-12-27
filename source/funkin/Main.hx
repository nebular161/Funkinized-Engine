package funkin;

import funkin.openfl.display.Mem;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.util.FlxColor;
import sys.io.Process;
import sys.io.File;
import flixel.system.ui.FlxSoundTray;
import sys.FileSystem;
import haxe.Exception;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Application;
import openfl.display.BlendMode;
import funkin.openfl.display.FPS;
import funkin.openfl.display.SimpleInfoDisplay;
import openfl.display.Sprite;
import openfl.display.StageScaleMode;
import openfl.events.Event;
import openfl.text.TextFormat;
import funkin.config.PreferencesMenu;
import funkin.game.CoolUtil;
import funkin.menus.TitleState;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var watermarks = true;
	public static var fpsVar:FPS;
	public static var fpsCounter:FPS;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		// quick checks
		try {
			Lib.current.addChild(new Main());
		}
		catch (e:Exception)
		{
			var fileStr:String = "";

			fileStr += "CRASH REASON:" + e.message + "\n\n";

			fileStr += e.stack.toString();

			File.saveContent("crash-dialog/crash-logs/CRASHDUMP.txt", fileStr);
			#if windows
			var process = new Process('start .\\crash-dialog\\Everlast-Engine-Crash.exe ".\\CRASHDUMP.txt"');
			#else
			Application.current.window.alert("FNF Crashed!\nCRASH REASON:" + e.message + "\nMORE INFO IN CRASHDUMP.TXT!", "FNF Crashed!");
			#end
			Sys.exit(1);
		}
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
		{
			if (hasEventListener(Event.ADDED_TO_STAGE))
				removeEventListener(Event.ADDED_TO_STAGE, init);
	
			FlxG.save.bind('fizzy-engine', CoolUtil.getSavePath());
	
			#if (flixel < "5.0.0")
			var stageWidth:Int = Lib.current.stage.stageWidth;
			var stageHeight:Int = Lib.current.stage.stageHeight;
			var zoom:Float = Math.min(stageWidth / gameWidth, stageHeight / gameHeight);
			#end
			addChild(new FlxGame(#if (flixel < "5.0.0") Math.ceil(stageWidth / zoom) #else gameWidth #end,
				#if (flixel < "5.0.0") Math.ceil(stageHeight / zoom) #else gameHeight #end, initialState, #if (flixel < "5.0.0") zoom, #end framerate, framerate,
				skipSplash, startFullscreen));
	
			FlxG.mouse.useSystemCursor = true;
	
			fpsVar = new FPS(10, 3, 0xFFFFFF);
			addChild(fpsVar);
			
			memoryCounter = new Mem(10, 3, 0xffffff);
			addChild(memoryCounter);
				   
			display = new SimpleInfoDisplay(10, 3, 0xFFFFFF);
			addChild(display);
	
			#if !mobile
			Lib.current.stage.align = "tl";
			Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
			#end
	
			#if CRASH_HANDLER
			Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
			#end
		}

	var game:FlxGame;

	public static var memoryCounter:Mem;
	public static var display:SimpleInfoDisplay;

	public static function toggleMem(memEnabled:Bool):Void
	{
		memoryCounter.visible = memEnabled;
	}
	public function toggleVers(enabled:Bool):Void
		{
			display.infoDisplayed[2] = enabled;
		}		
	public function getFPS():Float
		{
			return fpsCounter.currentFPS;
		}		
}	