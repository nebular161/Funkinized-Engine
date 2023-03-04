package funkin;

import funkin.system.MemoryCounter;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.util.FlxColor;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flixel.system.ui.FlxSoundTray;
import haxe.Exception;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Application;
import openfl.display.BlendMode;
import funkin.system.Fps;
import funkin.system.EngineVer;
import openfl.display.Sprite;
import openfl.display.StageScaleMode;
import openfl.events.Event;
import openfl.text.TextFormat;
import funkin.config.Options;
import funkin.utils.*;
import funkin.menus.TitleState;
class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 144; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var instance:Main;
	public static var watermarks = true;
	public static var fpsVar:Fps;
	public static var fpsCounter:Fps;
	static public var buildNumber:Int;

	public static function main():Void
		{
			Lib.current.addChild(instance = new Main());
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
	
			FlxG.save.bind('everlast-engine', CoolUtil.getSavePath());
	
			#if (flixel < "5.0.0")
			var stageWidth:Int = Lib.current.stage.stageWidth;
			var stageHeight:Int = Lib.current.stage.stageHeight;
			var zoom:Float = Math.min(stageWidth / gameWidth, stageHeight / gameHeight);
			#end
			addChild(new FlxGame(#if (flixel < "5.0.0") Math.ceil(stageWidth / zoom) #else gameWidth #end,
				#if (flixel < "5.0.0") Math.ceil(stageHeight / zoom) #else gameHeight #end, initialState, #if (flixel < "5.0.0") zoom, #end framerate, framerate,
				skipSplash, startFullscreen));

			FlxG.mouse.load('assets/core/cursors/default.png');				
	
			fpsVar = new Fps(10, 3, 0xFFFFFF);
			addChild(fpsVar);
			
			memoryCounter = new MemoryCounter(10, 3, 0xffffff);
			addChild(memoryCounter);
				   
			engineVersion = new EngineVer(10, 3, 0xFFFFFF);
			addChild(engineVersion);
	
			#if !mobile
			Lib.current.stage.align = "tl";
			Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
			#end
		}

	var game:FlxGame;

	public static var memoryCounter:MemoryCounter;
	public static var engineVersion:EngineVer;

	public static function toggleMem(memEnabled:Bool):Void
	{
		memoryCounter.visible = memEnabled;
	}
	public function toggleVers(enabled:Bool):Void
		{
			engineVersion.infoDisplayed[2] = enabled;
		}		
	public function getFPS():Float
		{
			return fpsCounter.currentFPS;
		}		
}	