package chip8;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;


enum GPUMode {
    CHIP8;
    SCHIP;
}

class GPU {

    inline static var SCHIP_W   = 128;
    inline static var SCHIP_H   = 64;
    inline static var COLOR_ON  = 0xFFFFFF;
    inline static var COLOR_OFF = 0x000000;
           static var TOP_LEFT  = new Point(0, 0);
           static var PIX_BLOCK = new Rectangle(0, 0, 2, 2);
           static var TMP_BLOCK = new Rectangle(0, 0, 1, 1);

           

    private var vram(default, default):BitmapData;
    public  var view(default,    null):Bitmap;
    public  var mode(default, default):GPUMode;


    public  var width (get, never):Int;
    public  var height(get, never):Int;

    inline function get_width () return (mode == GPUMode.CHIP8) ? SCHIP_W >> 1 : SCHIP_W;
    inline function get_height() return (mode == GPUMode.CHIP8) ? SCHIP_H >> 1 : SCHIP_H;


    var scr_w:UInt;
    var scr_h:UInt;

    public function new(w, h) {
        scr_w = w;
        scr_h = h;

        vram = new BitmapData(SCHIP_W, SCHIP_H, false, COLOR_OFF);
        view = new Bitmap(vram.clone());

        view.scaleX = scr_w / vram.width;
        view.scaleY = scr_h / vram.height;

        mode = GPUMode.CHIP8;
    }

    public inline function cls() {
        vram.fillRect(vram.rect, COLOR_OFF);
    }

    public inline function set(x, y) {
        switch (mode) {
            case GPUMode.CHIP8:
                x  = wrap(x, SCHIP_W >> 1) << 1;
                y  = wrap(y, SCHIP_H >> 1) << 1;

                PIX_BLOCK.x = x;
                PIX_BLOCK.y = y;
                vram.fillRect(PIX_BLOCK, vram.getPixel(x, y) ^ COLOR_ON);

            case GPUMode.SCHIP:
                x  = wrap(x, SCHIP_W);
                y  = wrap(y, SCHIP_H);
                vram.setPixel(x, y, vram.getPixel(x, y) ^ COLOR_ON);
        }

        return vram.getPixel(x, y) == COLOR_OFF;
    }

    public inline function get(x, y) {
        switch (mode) {
            case GPUMode.CHIP8:
                x = wrap(x, SCHIP_W >> 1) << 1;
                y = wrap(y, SCHIP_H >> 1) << 1;

            case GPUMode.SCHIP:
                x = wrap(x, SCHIP_W);
                y = wrap(y, SCHIP_H);
        }

        return (vram.getPixel(x, y) == COLOR_ON) ? 1 : 0;
    }

    public inline function scroll_h(n) {
        vram.scroll(0, n);
        
        TMP_BLOCK.x = 0;
        TMP_BLOCK.y = (n < 0) ? vram.height + n : 0;
        TMP_BLOCK.width  = vram.width;
        TMP_BLOCK.height = (n < 0) ? n * -1 : n;

        vram.fillRect(TMP_BLOCK, COLOR_OFF);
    }

    public inline function scroll_v(n) {
        vram.scroll(n, 0);

        TMP_BLOCK.x = (n < 0) ? vram.width + n : 0;
        TMP_BLOCK.y = 0;
        TMP_BLOCK.width  = (n < 0) ? n * -1 : n;
        TMP_BLOCK.height = vram.height;

        vram.fillRect(TMP_BLOCK, COLOR_OFF);
    }

    public inline function flip() {
        view.bitmapData.copyPixels(vram, vram.rect, TOP_LEFT);
    }

    public inline function reset() {
        cls ();
        flip();
        mode = GPUMode.CHIP8;
    }

    inline function wrap(c, s) {
        c %= s;
        return (c < 0) ? (c + s) : c;
    }

}