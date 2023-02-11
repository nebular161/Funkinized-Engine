package funkin.menus;

#if discord_rpc
import dependency.Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import funkin.menus.*;
import funkin.system.*;
import funkin.game.*;

using StringTools;

class FreeplayMenu extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;
	var curDifficultyArray:Array<String> = ["Easy", "Normal", "Hard"];

	var bg:FlxSprite;
	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Float = 0;
	var intendedScore:Int = 0;

	public var grpSongs:FlxTypedGroup<Alphabet>;
	public var coolColors = [
		0xFF691818, // Tutorial
		0xFF9271FD, // Week 1
		0xFFFF9900, // Week 2
		0xFF15B400, // Week 3
		0xFF96005F, // Week 4
		0xFF593074, // Week 5
		0xFFFFB96A, // Week 6
		0xFF5E5E5E, // Week 7
		0xFF00DDFF]; // Test

	public var curPlaying:Bool = false;

	public var iconArray:Array<HealthIcon> = [];

	override function create()
	{
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('meta/freeplaySonglist'));

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('menus/freakyMenu'));
		}
// This is god awful, idk how to make this shit easier, I'm shit at coding
		songs.push(new SongMetadata("Tutorial", 0, 'gf'));

		songs.push(new SongMetadata("Bopeebo", 1, 'dad'));

		songs.push(new SongMetadata("Fresh", 1, 'dad'));

		songs.push(new SongMetadata("Dadbattle", 1, 'dad'));

		songs.push(new SongMetadata("Spookeez", 2, 'spooky'));

		songs.push(new SongMetadata("South", 2, 'spooky'));

		songs.push(new SongMetadata("Monster", 2, 'monster'));

		songs.push(new SongMetadata("Pico", 3, 'pico'));

		songs.push(new SongMetadata("Philly", 3, 'pico'));

		songs.push(new SongMetadata("Blammed", 3, 'pico'));

		songs.push(new SongMetadata("Satin-Panties", 4, 'mom'));

		songs.push(new SongMetadata("High", 4, 'mom'));

		songs.push(new SongMetadata("Milf", 4, 'mom'));

		songs.push(new SongMetadata("Cocoa", 5, 'parents-christmas'));

		songs.push(new SongMetadata("Eggnog", 5, 'parents-christmas'));

		songs.push(new SongMetadata("Winter-Horrorland", 5, 'monster-christmas'));

		songs.push(new SongMetadata("Senpai", 6, 'senpai'));

		songs.push(new SongMetadata("Roses", 6, 'senpai-angry'));

		songs.push(new SongMetadata("Thorns", 6, 'spirit'));

		songs.push(new SongMetadata("Ugh", 7, 'tankman'));

		songs.push(new SongMetadata( "Guns", 7, 'tankman'));

		songs.push(new SongMetadata("Stress", 7, 'tankman'));
		
		songs.push(new SongMetadata("Test", 8, 'bf-pixel'));

		bg = new FlxSprite().loadGraphic(Paths.image('menuObjects/main_menu/menuDesat'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			iconArray.push(icon);
			add(icon);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.antialiasing = false;
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = CoolUtil.coolLerp(lerpScore, intendedScore, 0.4);
		bg.color = FlxColor.interpolate(bg.color, coolColors[songs[curSelected].week % coolColors.length], CoolUtil.camLerpShit(0.045));

		scoreText.text = "YOUR SCORE:" + Math.round(lerpScore);
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}
		if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeSelection(-FlxG.mouse.wheel);
				changeDiff();
			}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		if (controls.UI_RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound("cancelMenu"));
			FlxG.switchState(new MainMenu());
		}

		if (accepted)
		{
			PlayState.SONG = Song.loadFromJson(curDifficultyArray[curDifficulty], songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty2 = curDifficultyArray[curDifficulty].toLowerCase();
			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< ' + CoolUtil.difficultyString() + ' >';
		positionHighscore();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}

	function positionHighscore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - scoreBG.scale.x / 2;
		diffText.x = scoreBG.x + scoreBG.width / 2;
		diffText.x -= diffText.width / 2;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}