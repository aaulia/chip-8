package gui;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
using Std;

class ScrollBar extends Sprite {

    public var enabled (default, set):Bool;
    function set_enabled(v) {
        
        btn_up.enabled = v;
        btn_dn.enabled = v;
        btn_md.enabled = v;

        mouseEnabled   = v;
        mouseChildren  = v;
        buttonMode     = v;

        return enabled = v;
    }

    public var position (default, set):Int;
    function set_position(v) {
        if (v < 0) v = 0;
        if (v > maximum) v = maximum;
        if (v == position) 
            return v;

        btn_md.y = 22 + ((v / maximum) * area).int();
        return position = v;
    }

    public var maximum (default, set):Int = 100;
    function set_maximum(v) {
        if (v <= 0) throw 'Invalid maximum value: $v';
        if (v == maximum) 
            return v;

        var f = position / maximum;
        
        maximum  = v;
        position = (f * v).int();
        return v;
    }

    public function reset() position = 0;
    

    var btn_up :Button;
    var btn_dn :Button;
    var btn_md :Button;
    var area   :Int;
    var handler:Int->Int->Void;


    public function new(parent, up, dn, md, hg, x, y, max = 100, ?scroll) {
        super();
        parent.addChild(this);

        this.x = x;
        this.y = y;
        this.buttonMode = true;

        btn_up  = new Button(this, up, 22, 22, 0, 0,         on_up);
        btn_dn  = new Button(this, dn, 22, 22, 0, (hg - 22), on_dn);
        btn_md  = new Button(this, md, 22, 22, 0, 22);
        area    = hg - 66;
        maximum = max;
        handler = scroll;
        
        btn_md.addEventListener(MouseEvent.MOUSE_DOWN, on_md_down, false, 0, true);
    }

    function on_up() {
        var prev = position;
        position--;
        if (prev != position && handler != null)
            handler(position, -1);
    }
    
    function on_dn() {
        var prev = position;
        position++;
        if (prev != position && handler != null)
            handler(position, 1);
    }
    
    function on_md_down(e:MouseEvent) {
        stage.addEventListener(MouseEvent.MOUSE_MOVE, on_mouse_mv, false, 0, true);
        stage.addEventListener(MouseEvent.MOUSE_UP,   on_mouse_up, false, 0, true);
    }
    
    function on_mouse_mv(e:MouseEvent) { 
        var py = e.stageY - (y + 22);
        if (py < 0) py = 0;
        if (py > area) py = area;
        
        btn_md.y = 22 + py;
        
        var prev = position;
        position = ((py / area) * maximum).int();
        if (prev != position && handler != null) 
            handler(position, position - prev);
        
    }
    
    function on_mouse_up(e:MouseEvent) { 
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, on_mouse_mv, false);
        stage.removeEventListener(MouseEvent.MOUSE_UP,   on_mouse_up, false);
    }
    
}
