package funkin.mods;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
#if discord_rpc
import funkin.system.dependency.Discord.DiscordClient
#end
import funkin.menus.MainMenu;
class ModsMenu extends MainMenu // Unfinished mods menu!!!!
{
	// Variables
	var enabledMods:Array<String> = [];
	var modFolders:Array<String> = [];
	var curSelected:Int = 0;

	// Discord RPC
	#if discord_rpc
	DiscordClient.changePresence('Mods Menu', null);
	#end
}