package funkin.utils;

#if cpp
import cpp.NativeGc;
#elseif hl
import hl.Gc;
#elseif java
import java.vm.Gc;
#elseif neko
import neko.vm.Gc;
#end
#if sys
import sys.io.File;
import sys.FileSystem;
#end
#if js
import js.html.Console;
#end
import openfl.utils.Assets;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMath;
import flixel.util.FlxSort;
import flixel.util.FlxSave;
import funkin.game.PlayState;
import funkin.editors.ChartEditor;
import funkin.game.Song;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = 
	[
		'EASY', 
		"NORMAL", 
		"HARD"
	];

	public static var difficultyArrayExport:Array<String> = 
	[
		'-easy', 
		"", 
		"-hard"
    ];

	public static function difficultyString():String
	{
		return difficultyArray[PlayState.storyDifficulty];
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function formatAccuracy(value:Float)
	{
		var conversion:Map<String, String> = [
			'0' => '0.00',
			'0.0' => '0.00',
			'0.00' => '0.00',
			'00' => '00.00',
			'00.0' => '00.00',
			'00.00' => '00.00',
			'000' => '000.00'
		];

		var stringVal:String = Std.string(value);
		var converVal:String = '';
		for (i in 0...stringVal.length)
		{
			if (stringVal.charAt(i) == '.')
				converVal += '.';
			else
				converVal += '0';
		}

		var wantedConversion:String = conversion.get(converVal);
		var convertedValue:String = '';

		for (i in 0...wantedConversion.length)
		{
			if (stringVal.charAt(i) == '')
				convertedValue += wantedConversion.charAt(i);
			else
				convertedValue += stringVal.charAt(i);
		}

		if (convertedValue.length == 0)
			return '$value';

		return convertedValue;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static function formatSong(diff:Int):String
		{
			var coolDiff:String = difficultyArray[diff];
	
			var formatedSong:String = coolDiff;
	
			return formatedSong;
		}	
		
	public static function difficultyExport():String
		{
			return difficultyArrayExport[PlayState.storyDifficulty];
		}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	public static function camLerpShit(ratio:Float, ?offset:Null<Float>)
	{
		if (offset == null)
			offset = FlxG.updateFramerate;
		return FlxG.elapsed / (1 / offset) * ratio;
	}
	public static function coolLerp(a:Float, b:Float, ratio:Float)
	{
		return (1 - Math.max(0, Math.min(1, ratio))) * a + Math.max(0, Math.min(1, ratio)) * b;
	}

	public static function dominantColor(sprite:flixel.FlxSprite):Int
		{
			var countByColor:Map<Int, Int> = [];
	
			for(col in 0...sprite.frameWidth)
			{
				for(row in 0...sprite.frameHeight)
				{
					var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
	
					if(colorOfThisPixel != 0){
						if(countByColor.exists(colorOfThisPixel))
							countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
						else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687))
							countByColor[colorOfThisPixel] = 1;
					}
				}
			}
	
			var maxCount = 0;
			var maxKey:Int = 0;
	
			countByColor[flixel.util.FlxColor.BLACK] = 0;
	
			for(key in countByColor.keys())
			{
				if(countByColor[key] >= maxCount)
				{
					maxCount = countByColor[key];
					maxKey = key;
				}
			}
	
			return maxKey;
		}
	
		public static function openURL(url:String)
		{
			#if linux
			Sys.command('/usr/bin/xdg-open', [url]);
			#else
			FlxG.openURL(url);
			#end
		}	
		inline public static function getSavePath():String
			{
				@:privateAccess
				return #if (flixel < "5.0.0") 'supernova-engine' #else FlxG.stage.application.meta.get('company')
					+ '/'
					+ FlxSave.validate(FlxG.stage.application.meta.get('file')) #end;
			}		
}