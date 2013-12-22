package gui;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import res.Fonts.Dina;

using Std;

class Button extends Sprite {

    static var DEFAULT_FORMAT = new TextFormat(
        Dina.fontName, 22, 0x000000, 
        false, false, false, "", "", 
        TextFormatAlign.CENTER);

    inline static var STATE_UP       = 0;
    inline static var STATE_DOWN     = 1;
    inline static var STATE_DISABLED = 2;



    public var enabled (default, set):Bool;
    function set_enabled(v) {
        mouseEnabled      = v;
        mouseChildren     = v;
        buttonMode        = v;
        bitmap.scrollRect = frames[(v == true) ? STATE_UP : STATE_DISABLED];
        label .textColor  = (v == true) ? 0x000000 : 0x666666;

        return enabled = v;
    }



    var label :TextField;
    var bitmap:Bitmap;
    var frames:Array<Rectangle>;


    public function new(parent, image, w, h, x, y, text = "", ?click) {
        super();
        parent.addChild(this);

        var data:BitmapData = Type.createInstance(image, [0, 0]);

        var hc = (data.width  / w).int();
        var vc = (data.height / h).int();

        label  = new TextField();
        bitmap = new Bitmap(data);
        frames = [];

        for (j in 0...vc)
            for (i in 0...hc)
                frames.push(new Rectangle(i * w, j * h, w, h));

        if (frames.length < 3)
            while (frames.length < 3)
                frames.push(frames[0].clone());

        bitmap.scrollRect = frames[STATE_UP];
        addChild(bitmap);

        label.defaultTextFormat = DEFAULT_FORMAT;
        label.selectable = false;
        label.cacheAsBitmap = false;
        label.autoSize = TextFieldAutoSize.NONE;
        label.text = text;
        label.antiAliasType = AntiAliasType.ADVANCED;
        label.width  = w;
        label.height = 32;
        label.embedFonts = true;
        label.x = 0;
        label.y = (h - 22) >> 1;
        addChild(label);

        this.buttonMode = true;
        this.useHandCursor = true;
        this.x = x;
        this.y = y;

        addEventListener(MouseEvent.MOUSE_DOWN, on_mouse_down, false, 0, true);
        if (click != null) 
            addEventListener(MouseEvent.CLICK, function (e) click());

    }

    function on_mouse_down(?e:MouseEvent) {
        bitmap.scrollRect = frames[STATE_DOWN];
        if (stage != null)
            stage.addEventListener(MouseEvent.MOUSE_UP, on_mouse_up, false, 0, true);
    }

    function on_mouse_up(?e:MouseEvent) {
        bitmap.scrollRect = frames[STATE_UP];
        if (stage != null)
            stage.removeEventListener(MouseEvent.MOUSE_UP, on_mouse_up, false);
    }

}