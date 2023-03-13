package funkin.system;

import openfl.Lib;
import funkin.system.FpsCounter;
import flixel.FlxG;
import lime.app.Application;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * Version display lmfao
 * @ Mem Usuage Code author Kirill Poletaev
 */
class EngineVer extends TextField
{
	//
	public var infoDisplayed:Array<Bool> = [true, true, true];

	public var memPeak:Float = 0;
	public var currentFPS:Int = 0;

	public static var fpsCounter:FpsCounter;

	public function new(inX:Float = 10.0, inY:Float = 10.0, ?Bold:Bool = true, inCol:Int =0xFFFFFF, ?font:String)
	{
		super();

		x = inX;
		y -= 10;
		selectable = false;
		defaultTextFormat = new TextFormat("VCR OSD Mono", 14, inCol);

		fpsCounter = new FpsCounter(10000, 10000, inCol);
		fpsCounter.visible = false;
		Lib.current.addChild(fpsCounter);

		addEventListener(Event.ENTER_FRAME, onEnter);
		width = FlxG.width;
		height = FlxG.height;
	}

	private function onEnter(event:Event)
	{
		currentFPS = fpsCounter.currentFPS;

		if (visible)
		{
			text = "";

			for (i in 0...infoDisplayed.length)
			{
				if (infoDisplayed[i])
				{
					switch (i)
					{
						case 2:
							version_Function();
					}

					text += "\n";
				}
			}
		}
		else
			text = "";
	}

    function version_Function()
    { 	
				text += "Supernova Engine v" + Application.current.meta.get('version');
    }        
}