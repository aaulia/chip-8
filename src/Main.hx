package ;

import chip8.CPU;
import chip8.GPU;
import chip8.KEY;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.utils.ByteArray;
import flash.Lib;
import haxe.io.Bytes;


@:file("res/rom/15PUZZLE") class PUZZLE15 extends ByteArray {}
@:file("res/rom/BLINKY")   class BLINKY   extends ByteArray {}
@:file("res/rom/BLITZ")    class BLITZ    extends ByteArray {}
@:file("res/rom/BRIX")     class BRIX     extends ByteArray {}
@:file("res/rom/CONNECT4") class CONNECT4 extends ByteArray {}
@:file("res/rom/GUESS")    class GUESS    extends ByteArray {}
@:file("res/rom/HIDDEN")   class HIDDEN   extends ByteArray {}
@:file("res/rom/INVADERS") class INVADERS extends ByteArray {}
@:file("res/rom/KALEID")   class KALEID   extends ByteArray {}
@:file("res/rom/MAZE")     class MAZE     extends ByteArray {}
@:file("res/rom/MERLIN")   class MERLIN   extends ByteArray {}
@:file("res/rom/MISSILE")  class MISSILE  extends ByteArray {}
@:file("res/rom/PONG")     class PONG     extends ByteArray {}
@:file("res/rom/PONG2")    class PONG2    extends ByteArray {}
@:file("res/rom/PUZZLE")   class PUZZLE   extends ByteArray {}
@:file("res/rom/SYZYGY")   class SYZYGY   extends ByteArray {}
@:file("res/rom/TANK")     class TANK     extends ByteArray {}
@:file("res/rom/TETRIS")   class TETRIS   extends ByteArray {}
@:file("res/rom/TICTAC")   class TICTAC   extends ByteArray {}
@:file("res/rom/UFO")      class UFO      extends ByteArray {}
@:file("res/rom/VBRIX")    class VBRIX    extends ByteArray {}
@:file("res/rom/VERS")     class VERS     extends ByteArray {}
@:file("res/rom/WIPEOFF")  class WIPEOFF  extends ByteArray {}


class Main {

    static var cpu = new CPU(new GPU(8), new KEY());
    static var dbg = new Debugger(cpu);

    public static function main() {
        var stage = Lib.current.stage;
        stage.addChild(dbg);
        
        dbg.reset();
        dbg.load(Bytes.ofData(new BRIX()));
    }
}
