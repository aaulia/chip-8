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
        var chip8 = new CPU(new GPU(8), new KEY(), cast stage.frameRate);
        var debug = new Debugger(chip8);
        
        stage.addChild(debug);
        debug.load(MAZE);
    }
    
}
