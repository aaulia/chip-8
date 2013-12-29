package chip8;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;


enum ScreenMode {
    CHIP8;
    SCHIP;
}

class GPU {

    inline static var CHIP8_W   = 64;
    inline static var CHIP8_H   = 32;
    inline static var COLOR_ON  = 0xFFFFFF;
    inline static var COLOR_OFF = 0x000000;
           static var TOP_LEFT  = new Point(0, 0);

           
    public var mode(default, set):ScreenMode;
    inline function set_mode(v:ScreenMode) {

        if (vram != null) vram.dispose();
        if (view != null && view.bitmapData != null) view.bitmapData.dispose();

        var mul = (v == ScreenMode.CHIP8) ? 1 : 2;
        vram = new BitmapData(CHIP8_W * mul, CHIP8_H * mul, false, COLOR_OFF);
        if (view != null)
            view.bitmapData = vram.clone();
        else 
            view = new Bitmap(vram.clone());

        view.scaleX = scr_w / vram.width;
        view.scaleY = scr_h / vram.height;

        return mode = v;
    }


    public  var view (default,    null):Bitmap;
    private var vram (default, default):BitmapData;

    var scr_w:UInt;
    var scr_h:UInt;

    public function new(w, h) {
        scr_w = w;
        scr_h = h;

        mode = ScreenMode.CHIP8;
    }

    public inline function cls() {
        vram.fillRect(vram.rect, COLOR_OFF);
    }

    public inline function set(x, y) {
        x  = wrap(x, CHIP8_W);
        y  = wrap(y, CHIP8_H);
        vram.setPixel(x, y, vram.getPixel(x, y) ^ COLOR_ON);
        return vram.getPixel(x, y) == COLOR_OFF;
    }

    public inline function get(x, y) {
        x = wrap(x, CHIP8_W);
        y = wrap(y, CHIP8_H);
        return (vram.getPixel(x, y) == COLOR_ON) ? 1 : 0;
    }

    public inline function flip() {
        view.bitmapData.copyPixels(vram, vram.rect, TOP_LEFT);
    }

    public inline function reset() {
        cls ();
        flip();
    }

    inline function wrap(c, s) {
        c %= s;
        return (c < 0) ? (c + s) : c;
    }

}