package ;

import chip8.CPU;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import gui.Button;
import gui.CodeList;
import gui.ScrollBar;
import res.Images;

using Std;
using StringTools;


@:access(chip8.CPU) 
class Debugger extends Sprite {

    var running:Bool;
    var chip8:CPU;

    
    public inline function reset() {
        chip8    .reset();
        codeList .reset();
        scrollbar.reset();
    }
    
    public function load(rom) {
        if (running) 
            stop();
        
        chip8   .load(rom);
        codeList.load(rom);
        
        scrollbar.maximum = codeList.length - 1;
        scrollbar.reset();
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
    var scrollbar:ScrollBar;
    var codeList :CodeList;
    
    
    public function new(cpu) {
        super();
        
        chip8 = cpu;
        chip8.gpu.view.x = 10;
        chip8.gpu.view.y = 10;
        addChild(chip8.gpu.view);
        
        bmp_main  = new Bitmap(new UIWindowBase(0, 0));
        addChild(bmp_main);

        
        
        btn_start = new Button   (this, UIButtonStart, 48, 48, 478, 276, on_start);
        btn_pause = new Button   (this, UIButtonPause, 48, 48, 478, 330, on_pause);
        btn_stop  = new Button   (this, UIButtonStop,  48, 48, 478, 384, on_stop);
        btn_step  = new Button   (this, UIButtonStep,  48, 48, 478, 438, on_step);
        scrollbar = new ScrollBar(this, UIScrollUp, UIScrollDn, UIScrollMd, 310, 446, 280, 100, on_scroll);
        codeList  = new CodeList (this, 10, 280, 436, 310);

        btn_start.enabled = true;
        btn_pause.enabled = false;
        btn_stop .enabled = false;
        btn_step .enabled = true;
        
        
        
        addEventListener(Event.ADDED_TO_STAGE,     added_to_stage,     false, 0, true);
        addEventListener(Event.REMOVED_FROM_STAGE, removed_from_stage, false, 0, true);
    }
    
    function update() {
        chip8.tick();
        codeList .PC       = chip8.PC;
        scrollbar.position = (codeList.PC - 0x200) >> 1;
    }
    
    function on_start() {
        start();
        btn_start.enabled = false;
        btn_pause.enabled = true;
        btn_stop .enabled = true;
        btn_step .enabled = false;
        scrollbar.enabled = false;
    }

    function on_pause() {
        pause();
        btn_start.enabled = true;
        btn_pause.enabled = false;
        btn_stop .enabled = true;
        btn_step .enabled = true;
        scrollbar.enabled = true;
    }

    function on_stop () {
        stop();
        btn_start.enabled = true;
        btn_pause.enabled = false;
        btn_stop .enabled = false;
        btn_step .enabled = true;
        scrollbar.enabled = true;
    }

    function on_step () {
        if (running == false) 
            update();
    }
    
    function on_scroll(position, delta) {
        codeList.scroll = position;
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
            
        update();
    }
    
    function on_key(e:KeyboardEvent) {
        var v = (e.type == KeyboardEvent.KEY_DOWN) ? 1 : 0;
        chip8.key.set(e.keyCode, v);
    }
    
}
