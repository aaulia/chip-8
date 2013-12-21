package chip8;

import flash.ui.Keyboard;
import haxe.ds.Vector;

using Lambda;
using StringTools;

class KEY {

    static var DEFAULT_KEYMAP = 
    [
        Keyboard.X,
        Keyboard.NUMBER_1,
        Keyboard.NUMBER_2,
        Keyboard.NUMBER_3,
        Keyboard.Q,
        Keyboard.W,
        Keyboard.E,
        Keyboard.A,
        Keyboard.S,
        Keyboard.D,
        Keyboard.Z,
        Keyboard.C,
        Keyboard.NUMBER_4,
        Keyboard.R,
        Keyboard.F,
        Keyboard.V,
    ];

    public var wait (default, null):Bool;
    var keys:Array<UInt>;
    var kmap:Array<UInt>;
    var retf:Int->Void;

    public function new() {
        kmap = DEFAULT_KEYMAP.copy();
        reset();
    }

    public inline function map(key, code) {
        kmap[key] = code;
    }

    public inline function set(code, v = 1) {
        var i = kmap.indexOf(code);
        if (i >= 0 && i <= 0xF) {
            keys[i] = v;
            if (v == 1) {
                if (wait && retf != null) {
                    retf(i);
                    wait = false;
                    retf = null;
                }
            }
        }
    }

    public inline function get(key) {
        return keys[key] == 1;
    }

    public inline function ask(f:Int->Void) {
        wait = true;
        retf = f;
    }

    public inline function reset() {
        wait = false;
        keys = [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ];
        retf = null;
    }

}