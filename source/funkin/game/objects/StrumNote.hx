package funkin.game.objects;

import funkin.settings.Options;
import funkin.game.shaders.ColorSwap;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import funkin.game.PlayState;
import funkin.backend.system.Paths;

using StringTools;

class StrumNote extends FlxSprite {
	public var strumTime:Float = 0;
	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var willMiss:Bool = false;
	public var altNote:Bool = false;
	public var prevNote:StrumNote;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public static var swagWidth:Float = 160 * 0.7;
	public static var arrowColors = [1, 1, 1, 1];
	public static var PURPLE_RECEPTOR:Int = 0;
	public static var GREEN_RECEPTOR:Int = 2;
	public static var BLUE_RECEPTOR:Int = 1;
	public static var RED_RECEPTOR:Int = 3;

	var colorSwap:ColorSwap;

	public function new(strumTime:Float, noteData:Int, ?prevNote:StrumNote, ?sustainNote:Bool = false) {
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		this.strumTime = strumTime;
		this.noteData = noteData;

		/* Note Positions */
		x += 50;
		y -= 2000;

		switch (PlayState.curStage) {
			case 'school' | 'schoolEvil':
				var imgPath = Paths.image('gameObjects/notes/pixel/pixel-arrows');
				loadGraphic(imgPath, true, 17, 17);
				animation.add('greenScroll', [6]);
				animation.add('redScroll', [7]);
				animation.add('blueScroll', [5]);
				animation.add('purpleScroll', [4]);



				if (isSustainNote) {
					var endingPath = Paths.image('gameObjects/notes/pixel/arrowEnds');
					loadGraphic(endingPath, true, 7, 6);
					animation.add('purplehold', [0]);
					animation.add('greenhold', [2]);
					animation.add('redhold', [3]);
					animation.add('bluehold', [1]);

					animation.add('purpleholdend', [4]);
					animation.add('greenholdend', [6]);
					animation.add('redholdend', [7]);
					animation.add('blueholdend', [5]);
				}

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;
			default:
				frames = Paths.getSparrowAtlas('gameObjects/notes/base/default');

				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');

				animation.addByPrefix('purplehold', 'purple hold piece');
				animation.addByPrefix('greenhold', 'green hold piece');
				animation.addByPrefix('redhold', 'red hold piece');
				animation.addByPrefix('bluehold', 'blue hold piece');

				animation.addByPrefix('purpleholdend', 'pruple end hold');
				animation.addByPrefix('greenholdend', 'green hold end');
				animation.addByPrefix('redholdend', 'red hold end');
				animation.addByPrefix('blueholdend', 'blue hold end');

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
		}
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		updateColors();

		if (this.strumTime < 0 )
			this.strumTime = 0;

		switch (noteData) {
			case 0:
				x += swagWidth * 0;
				animation.play('purpleScroll');
			case 1:
				x += swagWidth * 1;
				animation.play('blueScroll');
			case 2:
				x += swagWidth * 2;
				animation.play('greenScroll');
			case 3:
				x += swagWidth * 3;
				animation.play('redScroll');
		}

		if (isSustainNote && prevNote != null) {
			alpha = 0.6;

			if (Options.getOption('downscroll')) 
			{
				flipY = true;
			}

			x += width / 2;

			switch (noteData) {
				case 0:
					animation.play('purpleholdend');
				case 1:
					animation.play('blueholdend');
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (PlayState.curStage.startsWith('school'))
			{	
				x += 30;
			}	

			if (prevNote.isSustainNote) {
				switch (prevNote.noteData) {
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
			}
		}
	}

	function updateColors() {
		colorSwap.update(arrowColors[noteData]);
	}

	override function update(elapsed:Float)
		{
			super.update(elapsed);
			if (mustPress)
			{
				if (isSustainNote)
				{
					if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
						&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
						canBeHit = true;
					else
						canBeHit = false;
				}
				else
				{
					if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
						&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
						canBeHit = true;
					else
						canBeHit = false;
				}
	
				if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit) tooLate = true;
			}
			else
			{
				canBeHit = false;
	
				if (strumTime <= Conductor.songPosition)
					wasGoodHit = true;
			}
	
			if (tooLate)
			{
				if (alpha > 0.3)
					alpha = 0.3;
			}
		}
}