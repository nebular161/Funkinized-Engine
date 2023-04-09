package funkin.config;

import openfl.Lib;
import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import haxe.ds.StringMap;
import funkin.ui.Page;
import funkin.ui.objects.CheckboxThingie;
import funkin.ui.TextMenuList;
import funkin.ui.TextMenuItem;
import funkin.utils.*;
import funkin.menus.MainItem;
import funkin.Main;
class Options extends Page
{
	public static var preferences:StringMap<Dynamic> = new StringMap<Dynamic>();

	var checkboxes:Array<CheckboxThingie> = [];
	var menuCamera:FlxCamera;
	var items:TextMenuList;
	var camFollow:FlxObject;

	override public function new()
	{
		super();
		menuCamera = new FlxCamera();
		FlxG.cameras.add(menuCamera, false);
		menuCamera.bgColor = FlxColor.TRANSPARENT;
		camera = menuCamera;
		add(items = new TextMenuList());

	/*----------------------------------------------------------------*/
						/* Options List*/
		createPrefItem('Censor Naughtyness', 'censor-naughty', false);
		createPrefItem('Downscroll', 'downscroll', false);
		createPrefItem('Flashing Lights', 'flashing-lights', true);
		createPrefItem('Note Splashes', 'notesplash', true);
		createPrefItem('Show Accuracy', 'accuracy', true);
		createPrefItem('Ghost Tapping', 'ghost-tap', true);
		createPrefItem('Low End Mode', 'low-end', false);
		createPrefItem('Game Statistics', 'statistics', false);
		createPrefItem('Auto Pause', 'auto-pause', false);
		createPrefItem('Glow Opponent Strums', 'glow-strums', true);
		createPrefItem('Info Display', 'display', true);
	/*---------------------------------------------------------------*/
		camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
		if (items != null)
		{
			camFollow.y = items.members[items.selectedIndex].y;
		}
		menuCamera.follow(camFollow, null, 0.06);
		menuCamera.deadzone.set(0, 160, menuCamera.width, 40);
		menuCamera.minScrollY = 0;
		items.onChange.add(function(item:TextMenuItem)
		{
			camFollow.y = item.y;
		});
	}

	public static function getOption(pref:String)
	{
		return preferences.get(pref);
	}

	public static function initPrefs()
	{
		if(FlxG.save.data.censorNaughty != null)
		{
			preferenceCheck('censor-naughty', FlxG.save.data.censorNaughty);
		}
		else
		{
			preferenceCheck('censor-naughty', false);
		}

		if(FlxG.save.data.downscroll != null)
		{
			preferenceCheck('downscroll', FlxG.save.data.downscroll);
		}
		else
		{
			preferenceCheck('downscroll', false);
		}

		if(FlxG.save.data.notesplash != null)
		{
			preferenceCheck('notesplash', FlxG.save.data.notesplash);
		}
		else
		{
			preferenceCheck('notesplash', true);
		}
	
		if(FlxG.save.data.accuracy != null)
		{
			preferenceCheck('accuracy', FlxG.save.data.accuracy);
		}
		else
		{
			preferenceCheck('accuracy', true);
		}		

		if(FlxG.save.data.flashingLights != null)
		{
			preferenceCheck('flashing-lights', FlxG.save.data.flashingLights);
		}
		else
		{
			preferenceCheck('flashing-lights', true);
		}

		if(FlxG.save.data.lowEnd != null)
		{
			preferenceCheck('low-end', FlxG.save.data.lowEnd);
		}
		else
		{
			preferenceCheck('low-end', false);
		}

		if(FlxG.save.data.autoPause != null)
		{
			preferenceCheck('auto-pause', FlxG.save.data.autoPause);
		}
		else
		{
			preferenceCheck('auto-pause', false);
		}	

		if(FlxG.save.data.glowStrums != null)
		{
			preferenceCheck('glow-strums', FlxG.save.data.glowStrums);
		}
		else
		{
			preferenceCheck('glow-strums', true);
		}
			
		if(FlxG.save.data.ghostTap != null)
		{
			preferenceCheck('ghost-tap', FlxG.save.data.ghostTap);
		}
		else
		{
			preferenceCheck('ghost-tap', true);
		}	
		
		if(FlxG.save.data.statistics != null)
		{
			preferenceCheck('statistics', FlxG.save.data.statistics);
		}
		else
		{
			preferenceCheck('statistics', false);
		}

		if(FlxG.save.data.infoDisplay != null)
		{	
			preferenceCheck('display', FlxG.save.data.infoDisplay);
		}	
		else
		{	
			preferenceCheck('display', false);
		}

		FlxG.autoPause = getOption('auto-pause');
	}

	public static function preferenceCheck(identifier:String, defaultValue:Dynamic)
	{
		if (preferences.get(identifier) == null)
		{
			preferences.set(identifier, defaultValue);
			trace('set preference!');
		}
		else
		{
			trace('found preference: ' + Std.string(preferences.get(identifier)));
		}
	}

	public function createPrefItem(label:String, identifier:String, value:Dynamic)
	{
		items.createItem(120, 120 * items.length + 30, label, Bold, function()
		{
			preferenceCheck(identifier, value);
			if (Type.typeof(value) == TBool)
			{
				prefToggle(identifier);
			}
			else
			{
				trace('swag');
			}
		});
		if (Type.typeof(value) == TBool)
		{
			createCheckbox(identifier);
		}
		else
		{
			trace('swag');
		}
	}

	public function createCheckbox(identifier:String)
	{
		var box:CheckboxThingie = new CheckboxThingie(0, 120 * (items.length - 1), preferences.get(identifier));
		checkboxes.push(box);
		add(box);
	}

	public function prefToggle(identifier:String)
	{
		var value:Bool = preferences.get(identifier);
		value = !value;
		preferences.set(identifier, value);
		checkboxes[items.selectedIndex].daValue = value;
		
	/*----------------------------------------------------------------*/		
		/* Having FlxG save your choice after selecting the option*/
		FlxG.save.data.censorNaughty = getOption('censor-naughty');
		FlxG.save.data.downscroll = getOption('downscroll');
		FlxG.save.data.flashingLights = getOption('flashing-lights');
		FlxG.save.data.glowStrums = getOption('glow-strums');
		FlxG.save.data.notesplash = getOption('notesplash');
		FlxG.save.data.accuracy = getOption('accuracy');
		FlxG.save.data.glowTap = getOption('ghost-tap');
		FlxG.save.data.lowEnd = getOption('low-end');
		FlxG.save.data.autoPause = getOption('auto-pause');
		FlxG.save.data.statistics = getOption('statistics');
		FlxG.save.data.infoDisplay = getOption('display');
	/*----------------------------------------------------------------*/
		FlxG.save.flush();

		trace('toggled? ' + Std.string(preferences.get(identifier)));
		switch (identifier)
		{
			case 'auto-pause':
				FlxG.autoPause = getOption('auto-pause');
			case 'display':
				if (getOption('display'))
					Lib.current.stage.addChild(Main.fpsCounter);
				else
					Lib.current.stage.removeChild(Main.fpsCounter);	
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		menuCamera.followLerp = CoolUtil.camLerpShit(0.02);
		items.forEach(function(item:MainItem)
		{
			if (item == items.members[items.selectedIndex])
				item.x = 150;
			else
				item.x = 120;
		});
	}
}