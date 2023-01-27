package dependency;

import flash.media.Sound;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

class Paths {
	inline public static var SOUND_EXT = #if web 'mp3' #else 'ogg' #end;

	static var currentLevel:String;

	inline static public function setCurrentLevel(name:String)
		currentLevel = name.toLowerCase();

	static function getPath(file:String, type:AssetType, library:Null<String>) {
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null) {
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, 'shared');
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = 'funkin') {
		return if (library == 'funkin' || library == 'default') getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String) {
		return '$library:assets/funkin/$library/$file';
	}

	static public function exists(path:String):Bool
		{
			var doesIt:Bool = false;
	
			#if FILESYSTEM
			doesIt = FileSystem.exists(Sys.getCwd() + path);
			#else
			doesIt = Assets.exists(path);
			#end
	
			return doesIt;
		}	

	inline static function getPreloadPath(file:String) {
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String) {
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String) {
		return getPath('funkin/data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String) {
		return getPath('funkin/data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String) {
		return getPath('funkin/data/$key.json', TEXT, library);
	}

	inline static public function sound(key:String, ?library:String) {
		return getPath('funkin/sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function formatToSongPath(path:String) {
		return path.toLowerCase().replace(' ', '-');
	}

	inline static public function video(key:String, ?library:String)
		{
			trace('assets/funkin/videos/$key.mp4');
			return getPath('funkin/videos/$key.mp4', BINARY, library);
		}	

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String) {
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function data(key:String, ?library:String)
		{
			return getPath('funkin/data/$key.png', IMAGE, library);
		}	

	inline static public function music(key:String, ?library:String) {
		return getPath('funkin/music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String) {
		return 'songs:assets/funkin/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String) {
		return 'songs:assets/funkin/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String) {
		return getPath('funkin/images/$key.png', IMAGE, library);
	}

	inline static public function cursorImage(key:String, ?library:String) {
		return getPath('$key.png', IMAGE, library);
	}	

	inline static public function font(key:String) {
		return 'assets/core/fonts/$key';
	}

	inline static public function songjson(key:String, isSong=false, ?library:String)
		{
			return getPath('${isSong ? "funkin/songs" : "data"}/$key.json', TEXT, library);
		}

	inline static public function getSparrowAtlas(key:String, ?library:String) {
		return FlxAtlasFrames.fromSparrow(image(key, library), file('funkin/images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String) {
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('funkin/images/$key.txt', library));
	}

	public static function getTextFileArray(path:String, delimeter:String = '\n'):Array<String> {
		var daList:Array<String> = openfl.Assets.getText(path).trim().split(delimeter);

		for (i in 0...daList.length) {
			daList[i] = daList[i].trim();
		}

		return daList;
	}
}
