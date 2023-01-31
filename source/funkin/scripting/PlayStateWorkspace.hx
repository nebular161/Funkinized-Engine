package funkin.scripting;

interface PlayStateWorkspace 
{
    public function create():Void;
    
    public function update(elapsed:Float):Void;

    public function beatHit(curBeat:Int):Void;

    public function stepHit(curBeat:Int):Void;
}