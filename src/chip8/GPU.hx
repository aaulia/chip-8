package chip8;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;

class GPU {

    inline static var SCREEN_W  = 64;
    inline static var SCREEN_H  = 32;
    inline static var COLOR_ON  = 0xFFFFFF;
    inline static var COLOR_OFF = 0x000000;
           static var TOP_LEFT  = new Point(0, 0);

           
    public  var view (default,    null):Bitmap;
    private var vram (default, default):BitmapData;

    public function new(scale:Float = 1.0) {
        vram = new BitmapData(SCREEN_W, SCREEN_H, false, COLOR_OFF);
        view = new Bitmap(vram.clone());
        
        view.scaleX = scale;
        view.scaleY = scale;
    }

    public inline function cls() {
        vram.fillRect(vram.rect, COLOR_OFF);
    }

    public inline function set(x, y) {
        x  = wrap(x, SCREEN_W);
        y  = wrap(y, SCREEN_H);
        vram.setPixel(x, y, vram.getPixel(x, y) ^ COLOR_ON);
        return vram.getPixel(x, y) == COLOR_OFF;
    }

    public inline function get(x, y) {
        x = wrap(x, SCREEN_W);
        y = wrap(y, SCREEN_H);
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