package funkin.game;

import funkin.game.Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
#if sys
import sys.io.File;
#end
import funkin.system.dependency.Paths;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var player1:String;
	var player2:String;
	var gfVersion:String;
	var noteStyle:String;
	var stage:String;
	var validScore:Bool;
	var ?diff:String;
	var chartVer:String;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var stage:String = '';

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong {
		var rawJson = Assets.getText(Paths.songjson(folder.toLowerCase() + '/charts/' + jsonInput.toLowerCase(), true)).trim();

		while (!rawJson.endsWith('}')) {
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}


		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong 
	{
		return cast Json.parse(rawJson).song;
	}
}