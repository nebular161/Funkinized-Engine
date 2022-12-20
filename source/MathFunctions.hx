package;

class MathFunctions {
	public static function numberArray(max:Int, ?min = 0):Array<Int> {
		var dumbArray:Array<Int> = [];
		for (i in min...max)
			dumbArray.push(i);
		return dumbArray;
	}

	public static function fixedLerpValue(ratio:Float):Float {
		return flixel.FlxG.elapsed / (1.0 / 60.0) * ratio;
	}

	inline public static function fixedLerp(a:Float, b:Float, ratio:Float):Float {
		return flixel.math.FlxMath.lerp(a, b, fixedLerpValue(ratio));
	}
}
