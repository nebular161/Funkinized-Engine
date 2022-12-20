package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;

/**
 * Loosley based on FlxTypeText lolol
 */
class Alphabet extends FlxSpriteGroup {
	public var delay:Float = 0.05;
	public var paused:Bool = false;

	// for menu shit
	public var targetY:Float = 0;
	public var isMenuItem:Bool = false;

	public var text:String = '';

	var _finalText:String = '';
	var _curText:String = '';

	public var widthOfWords:Float = FlxG.width;

	var typedTextRow:Int = 1;

	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:AlphaCharacter;
	var letterXResetted:Bool = false;
	var lastWasSpace:Bool = false;

	var splitWords:Array<String> = [];

	var isBold:Bool = false;

	public function new(?x:Float = 0, ?y:Float = 0, text:String = '', ?bold:Bool = false, typed:Bool = false) {
		super(x, y);

		_finalText = text;
		this.text = text;
		isBold = bold;

		if (text != '') {
			if (typed) {
				startTypedText();
			} else {
				addText();
			}
		}
	}

	public function addText() {
		doSplitWords();

		var nextLetterX:Float = 0;

		for (character in splitWords) {
			if (character == ' ' || character == '-') {
				lastWasSpace = true;
			}

			if (AlphaCharacter.alphabet.indexOf(character.toLowerCase()) != -1) {
				if (lastSprite != null) {
					nextLetterX = lastSprite.x + lastSprite.width;
				}

				if (lastWasSpace) {
					nextLetterX += 40;
					lastWasSpace = false;
				}

				var letter:AlphaCharacter = new AlphaCharacter(nextLetterX, 0);
				add(letter);
				lastSprite = letter;

				if (isBold)
					letter.createBold(character);
				else {
					letter.createLetter(character);
				}
			}
		}
	}

	function doSplitWords():Void {
		splitWords = _finalText.split('');
	}

	public function startTypedText():Void {
		_finalText = text;
		doSplitWords();

		var loopNum:Int = 0;

		var nextLetterX:Float = 0;

		new FlxTimer().start(0.05, function(tmr:FlxTimer) {
			if (_finalText.fastCodeAt(loopNum) == '\n'.code) {
				typedTextRow += 1;
				letterXResetted = true;
				nextLetterX = 0;
			}

			if (splitWords[loopNum] == ' ') {
				lastWasSpace = true;
			}

			loopNum += 1;
			tmr.time = FlxG.random.float(0.04, 0.09);

			var isNumber:Bool = AlphaCharacter.numbers.contains(splitWords[loopNum]);
			var isSymbol:Bool = AlphaCharacter.symbols.contains(splitWords[loopNum]);

			if (AlphaCharacter.alphabet.indexOf(splitWords[loopNum].toLowerCase()) != -1 || isNumber || isSymbol) {
				if (lastSprite != null && !letterXResetted) {
					lastSprite.updateHitbox();
					nextLetterX += lastSprite.width + 3;
				} else {
					letterXResetted = false;
				}

				if (lastWasSpace) {
					nextLetterX += 20;
					lastWasSpace = false;
				}

				var letter:AlphaCharacter = new AlphaCharacter(nextLetterX, 55 * typedTextRow);
				letter.row = typedTextRow;
				add(letter);
				lastSprite = letter;

				if (FlxG.random.bool(40)) {
					var daSound:String = 'GF_';
					FlxG.sound.play(Paths.soundRandom(daSound, 1, 4));
				}

				if (!isBold) {
					if (isNumber) {
						letter.createNumber(splitWords[loopNum]);
					} else if (isSymbol) {
						letter.createSymbol(splitWords[loopNum]);
					} else {
						letter.createLetter(splitWords[loopNum]);
					}

					letter.x += 90;
					return;
				}

				letter.createBold(splitWords[loopNum]);
			}
		}, splitWords.length);
	}

	override function update(elapsed:Float) {
		if (isMenuItem) {
			var remappedY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			y = MathFunctions.fixedLerp(y, (remappedY * 120) + (FlxG.height * 0.48), 0.16);
			x = MathFunctions.fixedLerp(x, (targetY * 20) + 90, 0.16);
		}

		super.update(elapsed);
	}
}

class AlphaCharacter extends FlxSprite {
	public static var alphabet:String = 'abcdefghijklmnopqrstuvwxyz';
	public static var numbers:String = '1234567890';
	public static var symbols:String = '|~#$%()*+-:;<=>@[]^_.,\'!?';

	public var row:Int = 0;

	public function new(x:Float, y:Float) {
		super(x, y);
		frames = Paths.getSparrowAtlas('alphabet');
	}

	public function createBold(letter:String) {
		animation.addByPrefix(letter, letter.toUpperCase() + ' bold', 24);
		animation.play(letter);
		updateHitbox();
	}

	public function createLetter(letter:String):Void {
		var letterCase:String = 'lowercase';
		if (letter.toLowerCase() != letter) {
			letterCase = 'capital';
		}

		animation.addByPrefix(letter, letter + ' ' + letterCase, 24);
		animation.play(letter);
		updateHitbox();

		FlxG.log.add('the row' + row);

		y = (110 - height);
		y += row * 60;
	}

	public function createNumber(letter:String):Void {
		animation.addByPrefix(letter, letter, 24);
		animation.play(letter);

		updateHitbox();
	}

	public function createSymbol(letter:String) {
		switch (letter) {
			case '.':
				animation.addByPrefix(letter, 'period', 24);
				animation.play(letter);
				y += 50;
			case '\'':
				animation.addByPrefix(letter, 'apostraphie', 24);
				animation.play(letter);
				y -= 0;
			case '?':
				animation.addByPrefix(letter, 'question mark', 24);
				animation.play(letter);
			case '!':
				animation.addByPrefix(letter, 'exclamation point', 24);
				animation.play(letter);
		}

		updateHitbox();
	}
}
