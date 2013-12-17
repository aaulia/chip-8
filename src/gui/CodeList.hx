package gui;

import flash.display.Sprite;
import flash.display3D.Context3DStencilAction;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import res.Fonts;

using Std;
using StringTools;

class CodeList extends Sprite{

    var codes:Array<CodeLine>;
    var frame:Rectangle;
    var index:Int;

    
    public var PC (get, set):Int;
    function get_PC() return (index << 1) + 0x200;
    function set_PC(v) {
        var n = (v - 0x200) >> 1;
        if (n < codes.length) {
            
            codes[index].highlight = false;
            index  = n;
            scroll = index;
            codes[index].highlight = true;
            
        }
        
        return v;
    }
    
    public var scroll (default, set):Int;
    function set_scroll(v) {
        if (v < 0) v = 0;
        if (v >= codes.length) v = codes.length - 1;
        
        var mid_h = (frame.height - 26).int() >> 1;
        var max_y = (codes.length * 26) - frame.height;
        
        frame.y = v * 26 - mid_h;
        if (frame.y < 0) frame.y = 0;
        if (frame.y > max_y) 
            frame.y = max_y - (max_y % 26);
            
        scrollRect = frame;
        return scroll = v;
    }
    
    public var length (get, never):Int;
    function get_length() return codes.length;
    
    
    
    public function new(parent, x, y, w, h) {
        super();
        
        parent.addChild(this);
		
        codes = [];
        frame = new Rectangle(0, 0, w, h);
        
        this.x = x;
        this.y = y;
        this.scrollRect = frame;
    }
    
    public function load(rom) {
        codes = [];
        
        var i = 0;
        var p = 0;
        while (p < rom.length) {
            codes[i] = new CodeLine(this, 0, i * 26, frame.width, 26);
            codes[i].text = op_to_string(p, rom.get(p++), rom.get(p++));
            i++;
        }
        
        reset();
    }
    
    public function reset() {
        PC = 0x200;
    }
    
    
    function op_to_string(pc, hi, lo) {
        
        var o = (hi & 0xF0) >> 4;
        var x = (hi & 0x0F);
        var y = (lo & 0xF0) >> 4;
        var b = (lo & 0x0F);
        
        var kk  = lo;
        var nnn = x << 8 | lo;
        
        var str = '${(0x200 + pc).hex(4)}:  ${hi.hex(2)} ${lo.hex(2)} .... ';
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

private class CodeLine extends TextField {
    
    static var BACK_COLORS     = [ 0xFFFFFF, 0xABCDEF ];
    static var TEXT_COLORS     = [ 0x000000, 0x000000 ];
    
    static var STATE_NORMAL    = 0;
    static var STATE_HIGHLITED = 1;
    
    static var DEFAULT_FONT    = new DinaFont();
    static var DEFAULT_FORMAT  = new TextFormat(DEFAULT_FONT.fontName, 24, 0x000000);
    
    
    
    public var highlight (default, set):Bool;
    function set_highlight(v) {
        if (v != highlight) {
            var s = v ? STATE_HIGHLITED : STATE_NORMAL;
            backgroundColor = BACK_COLORS[s];
            textColor       = TEXT_COLORS[s];
        }
        
        return highlight = v;
    }
    
    
    
    public function new(parent, x, y, w, h) {
        super();
        
        parent.addChild(this);
        this.x = x;
        this.y = y;
        width  = w;
        height = h;
        text   = '';
        
        background        = true;
        backgroundColor   = BACK_COLORS[ STATE_NORMAL ];
        textColor         = TEXT_COLORS[ STATE_NORMAL ];
        defaultTextFormat = DEFAULT_FORMAT;
        embedFonts        = true;
        autoSize          = TextFieldAutoSize.NONE;
        selectable        = false;
    }
    
}