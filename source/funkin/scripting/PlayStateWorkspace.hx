package funkin.scripting;

import funkin.system.MusicBeatState;
import flixel.FlxG;
import flixel.FlxGame;
import hscript.Interp;
import hscript.Parser;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.ui.FlxBar;
import funkin.game.HealthIcon;
import flixel.FlxCamera;
#if desktop
import Sys;
import sys.FileSystem;
#end
import funkin.game.Character;
import funkin.game.Boyfriend;
import funkin.game.PlayState;
class PlayStateWorkspace extends MusicBeatState
{
    /*To get Boyfriend*/
    public var bf:Boyfriend;

    /* To get Dad*/
    public var dad:Character;

    /* To get Girlfriend*/
    public var gf:Character;

    /* The notes strum lines*/
    public var strumLineNotes:FlxTypedGroup<FlxSprite>;

    /* The player strums (notes)*/
	public var playerStrums:FlxTypedGroup<FlxSprite>;

    /* The health bar background*/
    public var healthBarBG:FlxSprite;

    /* Healthbar*/
	public var healthBar:FlxBar;

    /* Player 1 icon*/
    public var iconP1:HealthIcon;

    /* Player 2 icon*/
	public var iconP2:HealthIcon;

    /* Camera HUD*/
	public var camHUD:FlxCamera;

    /* The games camera*/
	public var camGame:FlxCamera;

}