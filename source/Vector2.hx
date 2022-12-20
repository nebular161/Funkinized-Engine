package;

abstract Vector2(Array<Float>) to Array<Float> from Array<Float> {
	public var x(get, set):Float;
	public var y(get, set):Float;

	private function get_x():Float {
		return this[0];
	}

	private function set_x(value:Float):Float {
		return this[0] = value;
	}

	private function get_y():Float {
		return this[1];
	}

	private function set_y(value:Float):Float {
		return this[1] = value;
	}

	public function new(x:Float, y:Float) {
		this = [x, y];
	}
}
