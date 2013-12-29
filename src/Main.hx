package ;

import chip8.CPU;
import chip8.GPU;
import chip8.KEY;
import flash.Lib;
import haxe.io.Bytes;
import res.Roms;

class Main {
    
    public static function main() {
        var stage = Lib.current.stage;
        var chip8 = new CPU(new GPU(512, 256), new KEY(), cast stage.frameRate);
        var debug = new Debugger(stage, chip8);
    }
    
}
