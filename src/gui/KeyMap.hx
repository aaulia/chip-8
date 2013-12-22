package gui;

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import flash.text.AntiAliasType;
import flash.text.TextFormatAlign;
import res.Fonts;
import res.Fonts.Dina;

using Lambda;

class KeyMap extends Sprite {

    static inline var NORMAL  = 0x000000;
    static inline var PRESSED = 0xFFFF00;

    static var KEYS = 
    [
        [ '1', '2', '3', 'C' ],
        [ '4', '5', '6', 'D' ],
        [ '7', '8', '9', 'E' ],
        [ 'A', '0', 'B', 'F' ]
    ];

    static var MAPS = 
    [
        0xD, 0x0, 0x1, 0x2,
        0x4, 0x5, 0x6, 0x8,
        0x9, 0xA, 0xC, 0xE,
        0x3, 0x7, 0xB, 0xF
    ];

    static var FORMAT  = new TextFormat(
        Dina.fontName,
        32, NORMAL, false, false, false, "", "",
        TextFormatAlign.CENTER);

    
    var keys:Array<TextField>;

    public function new(parent, x, y) {
        super();

        parent.addChild(this);

        this.x = x;
        this.y = y;
        this.mouseEnabled  = false;
        this.mouseChildren = false;

        keys = [];
        for (j in 0...4) {
            for (i in 0...4) {
                var tf = new TextField();

                tf.defaultTextFormat = FORMAT;
                tf.embedFonts        = true;
                tf.selectable        = false;
                tf.antiAliasType     = AntiAliasType.ADVANCED;
                tf.cacheAsBitmap     = false;
                tf.autoSize          = TextFieldAutoSize.NONE;

                tf.x      = i * (48 + 6);
                tf.y      = j * (48 + 6) + 6;
                tf.width  = 48;
                tf.height = 36;
                tf.text   = KEYS[j][i];

                keys.push(cast addChild(tf));
            }
        }
    }

    public inline function set(key, v = true) {
        trace(key, MAPS[key], v);
        keys[MAPS[key]].textColor = (v == true) ? PRESSED : NORMAL;
    }

    public inline function reset()
        for (i in 0...16)
            keys[MAPS[i]].textColor = NORMAL;

}