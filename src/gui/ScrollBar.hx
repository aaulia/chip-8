package gui;

import flash.display.Sprite;
import flash.events.Event;
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
        position = v;
        dispatchEvent(change);

        return v;
    }

    var maximum (default, set):Int = 100;
    function set_maximum(v) {
        if (v <= 0) throw 'Invalid maximum value: $v';
        if (v == maximum) 
            return v;

        var f = position / maximum;
        
        maximum  = v;
        position = (f * v).int();
        return v;
    }


    var btn_up :Button;
    var btn_dn :Button;
    var btn_md :Button;
    var area   :Int;
    var change :Event;


    public function new(parent, up, dn, md, hg, x, y, max = 100) {
        super();
        parent.addChild(this);

        this.x = x;
        this.y = y;
        this.buttonMode = true;

        btn_up  = new Button(this, up, 22, 22, 0, 0,         on_up);
        btn_dn  = new Button(this, dn, 22, 22, 0, (hg - 22), on_dn);
        btn_md  = new Button(this, md, 22, 22, 0, 22);
        area    = hg - 44;
        maximum = max;
        change  = new Event(Event.CHANGE);
    }

    function on_up() position--;
    function on_dn() position++;

    public function reset() {
        position = 0;
    }

}