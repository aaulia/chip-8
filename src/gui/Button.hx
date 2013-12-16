package gui;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

using Std;

class Button extends Sprite {

    static inline var STATE_UP       = 0;
    static inline var STATE_DOWN     = 1;
    static inline var STATE_DISABLED = 2;

    public var enabled (default, set):Bool;

    inline function set_enabled(v) {
        mouseEnabled      = v;
        mouseChildren     = v;
        buttonMode        = v;
        bitmap.scrollRect = frames[(v == true) ? STATE_UP : STATE_DISABLED];

        return enabled = v;
    }

    var bitmap:Bitmap;
    var frames:Array<Rectangle>;

    public function new(parent, image, w, h, x, y, ?click) {
        super();
        parent.addChild(this);

        var data:BitmapData = Type.createInstance(image, [0, 0]);

        var hc = (data.width  / w).int();
        var vc = (data.height / h).int();

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

        this.buttonMode = true;
        this.useHandCursor = true;
        this.x = x;
        this.y = y;

        addEventListener(MouseEvent.MOUSE_DOWN, on_mouse_down, false, 0, true);
        if (click != null) 
            addEventListener(MouseEvent.CLICK, function (e) click(), false, 0, true);

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