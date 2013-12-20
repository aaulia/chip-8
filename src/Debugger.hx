package ;

import chip8.CPU;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import gui.Button;
import gui.CodeList;
import gui.RegList;
import gui.ScrollBar;
import res.Images;

using Std;
using StringTools;


@:access(chip8.CPU) 
class Debugger extends Sprite {

    static inline var SPEED_MULTIPLIER = 8;

    var running:Bool;
    var chip8:CPU;

    
    public inline function reset() {
        chip8.reset();
        lst_codes.reset();
        lst_reg.update(
            chip8.PC, 
            chip8.I, 
            chip8.DT, 
            chip8.ST, 
            chip8.V);
    }
    
    public function load(rom) {
        if (running) 
            stop();
        
        chip8.load(rom);
        lst_codes.load(rom);
        lst_reg.update(
            chip8.PC, 
            chip8.I, 
            chip8.DT, 
            chip8.ST, 
            chip8.V);
    }
    
    public inline function start() running = true;
    public inline function pause() running = false;
    public inline function stop () {
        running = false;
        reset();
    }
    
    
    var bmp_main :Bitmap;
    var btn_start:Button;
    var btn_pause:Button;
    var btn_stop :Button;
    var btn_step :Button;
    var lst_codes:CodeList;
    var lst_reg  :RegList;


    inline function add_event(p, e, f) p.addEventListener(e, f, false, 0, true);
    inline function rem_event(p, e, f) p.removeEventListener(e, f, false);

    public function new(cpu) {
        super();
        
        chip8 = cpu;
        chip8.gpu.view.x = 10;
        chip8.gpu.view.y = 10;
        addChild(chip8.gpu.view);

        
        bmp_main  = cast addChild(new Bitmap(new UIWindowBase(0, 0)));
        btn_start = new Button  (this, UIButtonStart, 48, 48, 478, 276, on_start);
        btn_pause = new Button  (this, UIButtonPause, 48, 48, 478, 330, on_pause);
        btn_stop  = new Button  (this, UIButtonStop,  48, 48, 478, 384, on_stop);
        btn_step  = new Button  (this, UIButtonStep,  48, 48, 478, 438, on_step);
        lst_codes = new CodeList(this, 10, 280, 458, 310);
        lst_reg   = new RegList (this, 543, 17);

        btn_start.enabled = true;
        btn_pause.enabled = false;
        btn_stop .enabled = false;
        btn_step .enabled = true;
        

        add_event(this, Event.ADDED_TO_STAGE, added_to_stage);
        add_event(this, Event.REMOVED_FROM_STAGE, removed_from_stage);
    }
    
    function update(s = 1) {
        for (i in 0...s) chip8.cycle(s);
        lst_codes.position = (chip8.PC - 0x200);
        lst_reg.update(
            chip8.PC, 
            chip8.I, 
            chip8.DT, 
            chip8.ST, 
            chip8.V);
    }
    
    function on_start() {
        start();
        btn_start.enabled = false;
        btn_pause.enabled = true;
        btn_stop .enabled = true;
        btn_step .enabled = false;
        lst_codes.enabled = false;
    }

    function on_pause() {
        pause();
        btn_start.enabled = true;
        btn_pause.enabled = false;
        btn_stop .enabled = true;
        btn_step .enabled = true;
        lst_codes.enabled = true;
    }

    function on_stop () {
        stop();
        btn_start.enabled = true;
        btn_pause.enabled = false;
        btn_stop .enabled = false;
        btn_step .enabled = true;
        lst_codes.enabled = true;
    }

    function on_step () {
        if (running == false) 
            update();
    }
    
    function added_to_stage(e:Event) {
        add_event(stage, Event.ENTER_FRAME,      on_frame);
        add_event(stage, KeyboardEvent.KEY_DOWN, on_key);
        add_event(stage, KeyboardEvent.KEY_UP,   on_key);
    }
    
    function removed_from_stage(e:Event) {
        rem_event(stage, Event.ENTER_FRAME,      on_frame);
        rem_event(stage, KeyboardEvent.KEY_DOWN, on_key);
        rem_event(stage, KeyboardEvent.KEY_UP,   on_key);
    }
    
    function on_frame(e:Event) {
        if (running == false) 
            return;
            
        update(SPEED_MULTIPLIER);
    }
    
    function on_key(e:KeyboardEvent) {
        var v = (e.type == KeyboardEvent.KEY_DOWN) ? 1 : 0;
        chip8.key.set(e.keyCode, v);
    }
    
}
