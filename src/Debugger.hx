package ;

import chip8.CPU;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.text.Font;
import flash.display.Sprite;
import flash.ui.Keyboard;
import gui.Button;
import gui.ScrollBar;
import haxe.io.Bytes;

using Std;
using StringTools;


@:font("res/ttf/dina10px.ttf") class DinaFont extends Font {}
@:bitmap("res/img/ui_window_base.png")   class UIWindowBase  extends BitmapData {}

@:bitmap("res/img/ui_button_start.png")  class UIButtonStart extends BitmapData {}
@:bitmap("res/img/ui_button_pause.png")  class UIButtonPause extends BitmapData {}
@:bitmap("res/img/ui_button_stop.png")   class UIButtonStop  extends BitmapData {}
@:bitmap("res/img/ui_button_step.png")   class UIButtonStep  extends BitmapData {}

@:bitmap("res/img/ui_scroll_up.png")     class UIScrollUp    extends BitmapData {}
@:bitmap("res/img/ui_scroll_dn.png")     class UIScrollDn    extends BitmapData {}
@:bitmap("res/img/ui_scroll_md.png")     class UIScrollMd    extends BitmapData {}



@:access(chip8.CPU) 
class Debugger extends Sprite {

    var running:Bool;
    var chip8:CPU;

    
    public inline function reset() chip8.reset();
    public inline function load(rom) {
        chip8.load(rom);
        
        //
        // parse rom
        //
        var pc = 0x0;
        while (pc < rom.length) {
            trace(op_to_string(
                pc, 
                rom.get(pc++), 
                rom.get(pc++)));
        }
    }
    
    public inline function start() running = true;
    public inline function pause() running = false;
    public inline function stop () {
        running = false;
        reset();
    }
    
    
    var wnd_main :Bitmap;
    var btn_start:Button;
    var btn_pause:Button;
    var btn_stop :Button;
    var btn_step :Button;
    var scr_opLst:ScrollBar;
    
    
    public function new(cpu) {
        super();
        
        chip8 = cpu;
        chip8.gpu.view.x = 10;
        chip8.gpu.view.y = 10;
        addChild(chip8.gpu.view);
        
        wnd_main  = new Bitmap(new UIWindowBase(0, 0));
        addChild(wnd_main);


        btn_start = new Button   (this, UIButtonStart, 48, 48, 478, 276, on_start);
        btn_pause = new Button   (this, UIButtonPause, 48, 48, 478, 330, on_pause);
        btn_stop  = new Button   (this, UIButtonStop,  48, 48, 478, 384, on_stop);
        btn_step  = new Button   (this, UIButtonStep,  48, 48, 478, 438, on_step);
        scr_opLst = new ScrollBar(this, UIScrollUp, UIScrollDn, UIScrollMd, 310, 446, 280);

        btn_start.enabled = true;
        btn_pause.enabled = false;
        btn_stop .enabled = false;
        btn_step .enabled = true;
        

        addEventListener(Event.ADDED_TO_STAGE,     added_to_stage,     false, 0, true);
        addEventListener(Event.REMOVED_FROM_STAGE, removed_from_stage, false, 0, true);
    }

    function on_start() {
        start();
        btn_start.enabled = false;
        btn_pause.enabled = true;
        btn_stop .enabled = true;
        btn_step .enabled = false;
    }

    function on_pause() {
        pause();
        btn_start.enabled = true;
        btn_pause.enabled = false;
        btn_stop .enabled = true;
        btn_step .enabled = true;
    }

    function on_stop () {
        stop();
        btn_start.enabled = true;
        btn_pause.enabled = false;
        btn_stop .enabled = false;
        btn_step .enabled = true;
    }

    function on_step () {
        if (running == false)
            chip8.tick();
    }
    
    function added_to_stage(e:Event) {
        stage.addEventListener(Event.ENTER_FRAME,      on_frame, false, 0, true);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, on_key,   false, 0, true);
        stage.addEventListener(KeyboardEvent.KEY_UP,   on_key,   false, 0, true);
    }
    
    function removed_from_stage(e:Event) {
        stage.removeEventListener(Event.ENTER_FRAME,      on_frame, false);
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, on_key,   false);
        stage.removeEventListener(KeyboardEvent.KEY_UP,   on_key,   false);
    }
    
    function on_frame(e:Event) {
        if (running == false) 
            return;
            
        chip8.tick();
    }
    
    function on_key(e:KeyboardEvent) {
        var v = (e.type == KeyboardEvent.KEY_DOWN) ? 1 : 0;
        chip8.key.set(e.keyCode, v);
    }
    
    
    function op_to_string(p, h, l) {
        
        var o = (h & 0xF0) >> 4;
        var x = (h & 0x0F);
        var y = (l & 0xF0) >> 4;
        var b = (l & 0x0F);
        
        var kk  = l;
        var nnn = x << 8 | l;
        
        var str = '|${(0x200 + p).hex(4)}| ${h.hex(2)}:${l.hex(2)} ';
        switch (o) {
            case 0x0:
                switch (nnn) {
                    case 0x0E0: str += 'CLS';
                    case 0x0EE: str += 'RET';
                    default:    str += 'SYS  ${nnn.hex(3)}';
                }
            case 0x1: str += 'JP   ${nnn.hex(3)}';
            case 0x2: str += 'CALL ${nnn.hex(3)}';
            case 0x3: str += 'SE   V${x.hex(1)}, ${kk.hex(2)}';
            case 0x4: str += 'SNE  V${x.hex(1)}, ${kk.hex(2)}';
            case 0x5: str += 'SE   V${x.hex(1)}, V${y.hex(1)}';
            case 0x6: str += 'LD   V${x.hex(1)}, ${kk.hex(2)}';
            case 0x7: str += 'ADD  V${x.hex(1)}, ${kk.hex(2)}';
            case 0x8: 
                switch (b) {
                    case 0x0: str += 'LD   V${x.hex(1)}, V${y.hex(1)}';
                    case 0x1: str += 'OR   V${x.hex(1)}, V${y.hex(1)}';
                    case 0x2: str += 'AND  V${x.hex(1)}, V${y.hex(1)}';
                    case 0x3: str += 'XOR  V${x.hex(1)}, V${y.hex(1)}';
                    case 0x4: str += 'ADD  V${x.hex(1)}, V${y.hex(1)}';
                    case 0x5: str += 'SUB  V${x.hex(1)}, V${y.hex(1)}';
                    case 0x6: str += 'SHR  V${x.hex(1)}, V${y.hex(1)}';
                    case 0x7: str += 'SUBN V${x.hex(1)}, V${y.hex(1)}';
                    case 0xE: str += 'SHL  V${x.hex(1)}, V${y.hex(1)}';
                }
                
            case 0x9: str += 'SNE  V${x.hex(1)}, V${y.hex(1)}';
            case 0xA: str += 'LD    I, ${nnn.hex(3)}';
            case 0xB: str += 'JP   V0, ${nnn.hex(3)}';
            case 0xC: str += 'RND  V${x.hex(1)}, ${kk.hex(2)}';
            case 0xD: str += 'DRW  V${x.hex(1)}, V${y.hex(1)}, ${b.hex(1)}';
            case 0xE: 
                switch (kk) {
                    case 0x9E: str += 'SKP  V${x.hex(1)}';
                    case 0xA1: str += 'SKNP V${x.hex(1)}';
                }
            case 0xF:
                switch (kk) {
                    case 0x07: str += 'LD   V${x.hex(1)}, DT';
                    case 0x0A: str += 'LD   V${x.hex(1)}, KP';
                    case 0x15: str += 'LD   DT, V${x.hex(1)}';
                    case 0x18: str += 'LD   ST, V${x.hex(1)}';
                    case 0x1E: str += 'ADD   I, V${x.hex(1)}';
                    case 0x29: str += 'LD    F, V${x.hex(1)}';
                    case 0x33: str += 'LD    B, V${x.hex(1)}';
                    case 0x55: str += 'LD  [I], V${x.hex(1)}';
                    case 0x65: str += 'LD   V${x.hex(1)}, [I]';
                        
                }
        }
        
        return str;
    }
    
}
