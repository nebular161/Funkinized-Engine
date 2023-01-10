package funkin.hscript;
#if FEATURE_HSCRIPT

import flixel.FlxBasic;
import funkin.hscript.Interp;
import openfl.Lib;

/**
 * For Hscript support.
 * Credit: Yoshicrafter & lunarcleint.
 */
class Script extends FlxBasic
{
	public var _interp:Interp;

	public override function new()
	{
		super();
		_interp = new Interp();
	}

	public function runScript(script:String)
	{
		var parser = new hscript.Parser();

		try
		{
			var ast = parser.parseString(script);

			_interp.execute(ast);
		}
		catch (e)
		{
			Lib.application.window.alert(e.message, "HSCRIPT ERROR!1111");
		}
	}

	public function setVariable(name:String, val:Dynamic)
	{
		_interp.variables.set(name, val);
	}

	public inline function getVariable(name:String):Dynamic
	{
		return _interp.variables.get(name);
	}

	public function executeFunc(funcName:String, ?args:Array<Any>):Dynamic
	{
		if (_interp == null)
			return null;

		if (_interp.variables.exists(funcName))
		{
			var func = _interp.variables.get(funcName);
			if (args == null)
			{
				var result = null;
				try
				{
					result = func();
				}
				catch (e)
				{
					trace('$e');
				}
				return result;
			}
			else
			{
				var result = null;
				try
				{
					result = Reflect.callMethod(null, func, args);
				}
				catch (e)
				{
					trace('$e');
				}
				return result;
			}
		}
		return null;
	}

	public override function destroy()
	{
		super.destroy();
		_interp = null;
	}
}
#end