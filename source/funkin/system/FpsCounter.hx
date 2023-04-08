package funkin.system;

import flixel.FlxG;
import flixel.util.FlxStringUtil;
import haxe.Timer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.ui.Keyboard;

class FpsCounter extends Sprite {
	public var bg:Sprite;
	public var fps:FPSField;

	#if cpp
	public var mem:MemoryField;
	#if debug public var deb:DebugField; #end
	#end
	var childrenFields:Array<TextField> = [];

	public function new():Void {
		super();

		bg = new Sprite();
		bg.graphics.beginFill(0);
		bg.graphics.drawRect(0, 0, 1, 50);
		bg.graphics.endFill();
		bg.alpha = 0.5;
		addChild(bg);

		fps = new FPSField();
		addField(fps);

		#if cpp
		mem = new MemoryField();
		addField(mem);

		#if debug
		deb = new DebugField();
		addField(deb);
		#end
		#end

		addEventListener(Event.ENTER_FRAME, function(_:Event):Void {
			var lastField:TextField = childrenFields[childrenFields.length - 1];
			bg.scaleX = lastField.x + lastField.width + 15;
			bg.scaleY = Math.floor(lastField.text.length / lastField.textHeight) + #if debug 0.5 #else 0 #end;
		});

		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent):Void {
			switch (e.keyCode) {
				case Keyboard.F3:
					visible = !visible;
			}
		});
	}

	public function addField(field:TextField):Void {
		var lastField:TextField = childrenFields[childrenFields.length - 1];
		var yAdd:Float = 10;
		if (lastField == fps)
			yAdd = 15;

		field.x = 5;
		field.autoSize = LEFT;
		field.selectable = false;
		field.defaultTextFormat = new TextFormat("VCR OSD Mono", field == fps ? 20 : 16, -1);

		if (lastField != null)
			field.y = lastField.y + lastField.height + yAdd;

		childrenFields.push(field);
		addChild(field);
	}
}

class FPSField extends TextField {
	public var times:Array<Float> = [];
	public var curFPS:Float = 0;

	public function new():Void {
		super();
		addEventListener(Event.ENTER_FRAME, update);
	}

	public function update(_:Event):Void {
		var now:Float = Timer.stamp();
		times.push(now);
		while (times[0] < now - 1)
			times.shift();

		curFPS = times.length;
		if (curFPS > FlxG.updateFramerate)
			curFPS = FlxG.updateFramerate;

		if (visible)
			text = '${curFPS} FPS';
	}
}

class MemoryField extends TextField {
	public var curMEM:Float = 0;
	public var peakMEM:Float = 0;

	public function new():Void {
		super();
		addEventListener(Event.ENTER_FRAME, function(_:Event):Void {
			curMEM = System.totalMemory;
			if (curMEM > peakMEM)
				peakMEM = curMEM;

			if (visible)
				text = '${FlxStringUtil.formatBytes(curMEM)} / ${FlxStringUtil.formatBytes(peakMEM)}';
		});
	}
}

class DebugField extends TextField 
{
	public function new():Void 
	{
		super();
		addEventListener(Event.ENTER_FRAME, function(_:Event):Void 
		{
			if (visible) {
				text = '${Type.getClassName(Type.getClass(FlxG.state))}';
				appendText('\nOBJS: ${FlxG.state.countLiving()} - DEAD: ${FlxG.state.countDead()}');
			}
		});
	}
}