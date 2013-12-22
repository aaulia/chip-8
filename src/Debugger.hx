package ;

import chip8.CPU;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import gui.Button;
import gui.CodeList;
import gui.KeyMap;
import gui.RegList;
import gui.RomSelect;
import gui.ScrollBar;
import haxe.io.Bytes;
import res.Images;

using Std;
using StringTools;


@:access(chip8.CPU) 
class Debugger extends Sprite {

    static inline var SPEED_MULTIPLIER = 40;

    var running :Bool;
    var chip8   :CPU;
    var rom_data:Bytes;

    
    public inline function reset() {
        chip8    .reset();
        lst_codes.reset();
    }
    
    public function load(rom) {
        if (running) 
            stop();
        
        unload();

        if (rom == null)
            return;

        rom_data = Bytes.ofData(Type.createInstance(rom, []));
        chip8    .load(rom_data);
        lst_codes.load(rom_data);

        btn_start.enabled = true;
        btn_pause.enabled = false;
        btn_stop .enabled = false;
        btn_step .enabled = true;
    }

    public function unload() {
        rom_data = null;

        chip8    .unload();
        lst_codes.unload();

        btn_start.enabled = false;
        btn_pause.enabled = false;
        btn_stop .enabled = false;
        btn_step .enabled = false;
    }
    
    public inline function start() running = true;
    public inline function pause() running = false;
    public inline function stop () {
        running = false;
        reset();
    }
    
    
    var bmp_main  :Bitmap;
    var dlg_select:RomSelect;
    
    var btn_start :Button;
    var btn_pause :Button;
    var btn_stop  :Button;
    var btn_step  :Button;
    var btn_load  :Button;

    var lst_codes :CodeList;
    var lst_reg   :RegList;
    var map_keys  :KeyMap;



    inline function add_event(p, e, f) p.addEventListener(e, f, false, 0, true);
    inline function rem_event(p, e, f) p.removeEventListener(e, f, false);

    public function new(parent, cpu) {
        super();

        chip8 = cpu;
        chip8.gpu.view.x = 10;
        chip8.gpu.view.y = 10;
        addChild(chip8.gpu.view);

        
        bmp_main   = cast addChild(new Bitmap(new UIWindowBase(0, 0)));
        btn_start  = new Button   (this, UIButtonStart, 48, 48, 478, 276, on_start);
        btn_pause  = new Button   (this, UIButtonPause, 48, 48, 478, 330, on_pause);
        btn_stop   = new Button   (this, UIButtonStop,  48, 48, 478, 384, on_stop);
        btn_step   = new Button   (this, UIButtonStep,  48, 48, 478, 438, on_step);
        btn_load   = new Button   (this, UIButtonLoad,  48, 48, 478, 492, on_load);
        lst_codes  = new CodeList (this, 10, 280, 458, 310);
        lst_reg    = new RegList  (this, 560, 40);
        map_keys   = new KeyMap   (this, 558, 358);
        dlg_select = new RomSelect(on_rom_select, on_rom_cancel);

        btn_start.enabled = false;
        btn_pause.enabled = false;
        btn_stop .enabled = false;
        btn_step .enabled = false;
        

        add_event(this, Event.ADDED_TO_STAGE, added_to_stage);
        add_event(this, Event.REMOVED_FROM_STAGE, removed_from_stage);

        parent.addChild(this);
    }
    
    function update(c = 1) {
        for (i in 0...c) {
            chip8.cycle(SPEED_MULTIPLIER);
            lst_codes.position = (chip8.PC - 0x200);
        }
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
        lst_reg.update(chip8.PC, chip8.I, chip8.DT, chip8.ST, chip8.V);
        if (running == false) 
            update();
    }

    function on_load() {
        mouseChildren = false;
        if (rom_data != null && running) 
            on_pause(); 

        dlg_select.show(parent);
    }

    function on_rom_select(rom) {
        dlg_select.hide();
        mouseChildren = true;
        load(rom);
    }

    function on_rom_cancel() {
        dlg_select.hide();
        mouseChildren = true;
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
        lst_reg.update(chip8.PC, chip8.I, chip8.DT, chip8.ST, chip8.V);
        if (running == false) 
            return;
            
        update(SPEED_MULTIPLIER);
    }
    
    function on_key(e:KeyboardEvent) {
        var v = (e.type == KeyboardEvent.KEY_DOWN) ? 1 : 0;
        chip8.key.set(e.keyCode, v);

        for (i in 0...16)
            map_keys.set(i, chip8.key.get(i));
    }
    
}
