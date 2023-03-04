package funkin.system;

import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import lime.app.Application;
import openfl.text.TextFormat;

class MemoryCounter extends TextField
{
	private var times:Array<Float>;
	private var memPeak:Float = 0;


	public function new(inX:Float = 10.0, inY:Float = 10.0, inCol:Int = 0x000000)
	{
		super();

		x = 60;
		y = inY;
		selectable = false;
		defaultTextFormat = new TextFormat("VCR OSD Mono", 14, inCol);

		addEventListener(Event.ENTER_FRAME, onEnter);
		width = 150;
		height = 70;
	}

	private function onEnter(_)
	{
		var mem:Float = Math.round(System.totalMemory / 1024 / 1024 * 100) / 100;
		if (mem > memPeak)
			memPeak = mem;

		if (visible)
		{
			text = "  / " + mem + " Mem";
		}		
	}
}