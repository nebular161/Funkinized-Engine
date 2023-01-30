package funkin.scripting;

interface IHScriptCustomBehaviour {
    public function hset(name:String, val:Dynamic):Dynamic;
    public function hget(name:String):Dynamic;
}