package funkin.objects.ui;

import funkin.objects.ui.MenuTypedItem;

class TextTypedMenuItem extends MenuTypedItem {
	override public function setItem(text:String, ?callback:Dynamic) {
		if (label != null) {
			label.text = text;
			label.alpha = alpha;
			width = label.width;
			height = label.height;
		}
		super.setItem(text, callback);
	}

	override function set_label(atlasText:AtlasText) {
		super.set_label(atlasText);
		setItem(name, callback);
		return atlasText;
	}
}
