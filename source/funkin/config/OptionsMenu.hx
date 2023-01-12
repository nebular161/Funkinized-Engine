package funkin.config;

import flixel.FlxG;
import funkin.ui.Page;
import funkin.ui.TextMenuList;
import funkin.config.Options;
import funkin.config.Controls;
import funkin.ui.PageName;
import funkin.ui.TextMenuItem;

class OptionsMenu extends Page {
	var items:TextMenuList;

	override public function new(showDonate:Bool) {
		super();
		add(items = new TextMenuList());
		createItem('preferences', function() {
			onSwitch.dispatch(PageName.Preferences);
		});
		createItem('controls', function() {
			onSwitch.dispatch(PageName.Controls);
		});
		if (showDonate) {
			createItem('donate', selectDonate, true);
		}
		createItem('exit', exit);
	}

	public function createItem(label:String, callback:Dynamic, ?fireInstantly:Bool = false) {
		var item:TextMenuItem = items.createItem(0, 100 + 100 * items.length, label, Bold, callback);
		item.fireInstantly = fireInstantly;
		item.screenCenter(X);
		return item;
	}

	override function set_enabled(state:Bool) {
		items.enabled = state;
		return super.set_enabled(state);
	}

	public function hasMultipleOptions() {
		return items.length > 2;
	}

	function selectDonate() {
		#if linux
		Sys.command('/usr/bin/xdg-open', ['https://ninja-muffin24.itch.io/funkin', '&']);
		#else
		FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
		#end
	}
}
