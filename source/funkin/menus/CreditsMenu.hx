package funkin.menus;

import funkin.system.MusicBeatState;
import funkin.menus.MainMenu;
import flixel.FlxG;
import flixel.text.FlxText;
import openfl.system.System;
#if discord_rpc
import funkin.system.dependency.Discord.DiscordClient;
#end
class CreditsMenu extends MusicBeatState
{
    var selector:FlxText;
}