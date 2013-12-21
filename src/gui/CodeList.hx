package gui;

import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import res.Fonts;
import res.Images;

using Std;
using StringTools;

class CodeList extends Sprite{

    var scbar:ScrollBar;
    var lists:Sprite;
    var lines:Sprite;
    var codes:Array<CodeBlock>;
    var rows :Array<CodeBlock>;
    var cols :Array<CodeBlock>;
    var frame:Rectangle;


    function highlight(p, v) {
        var h = (frame.width / 36).int() - 1;
        var r = (p / h).int();
        var c = (p % h);

        codes[p].highlight = v;
        rows [r].highlight = v;
        cols [c].highlight = v;
    }

    public var position (default, set):Int;
    function set_position(v) {
        if (codes.length == 0)
            return position = v;

        if (v <  0) v = 0;
        if (v >= codes.length) v = codes.length - 1;

        highlight(position + 0, false);
        highlight(position + 1, false);
        position = v;
        highlight(position + 0, true);
        highlight(position + 1, true);

        var ch = lists.height.int();
        var cy = (codes[position].y - (frame.height - 26) / 2).int();
        
        if (cy > (ch - (frame.height - 26))) cy = ch - (frame.height - 26).int();
        if (cy < 0) cy = 0;

        lists.y = -cy;
        scbar.position = cy;

        return v;
    }

    public var enabled (default, set):Bool;
    function set_enabled(v) {
        var ch = lists.height;
        scbar.enabled = v && (ch > frame.height);
        return v;
    }


    public function new(parent, x, y, w, h) {
        super();
        parent.addChild(this);
		
        lists = new Sprite();
        lines = cast lists.addChild(new Sprite());
        codes = [];
        rows  = [];
        cols  = [];
        frame = new Rectangle(0, 0, w - 22, h - 26);
        scbar = new ScrollBar(this, UIScrollUp, UIScrollDn, UIScrollMd, h.int(), w - 22, 0, 100, on_scroll);
        
        this.x = x;
        this.y = y;

        var area:Sprite = cast addChild(new Sprite());
        area.x = 0;
        area.y = 26;
        area.scrollRect = frame;
        area.addChild(lists);

        var c = (frame.width / 36).int() - 1;
        for (i in 0...c) {
            var m  = new CodeBlock(this, (i + 1) * 36, 0, 36, 26, 0x444444);
            m.text = i.hex(2);
            cols.push(m);
        }
    }
    
    public function load(rom) {
        unload();

        var h = (frame.width / 36).int() - 1;
        var p = 0;
        while (p < rom.length) {
            
            var o:Int = rom.get(p);
            var c = (p % h);
            var r = (p / h).int();

            if (c == 0) {
                var m  = new CodeBlock(lines, 0, r * 26, 36, 26, 0x444444);
                m.text = (r * h).hex(2);
                rows.push(m);
            }

            codes[p] = new CodeBlock(lists, (c + 1) * 36, r * 26, 36, 26);
            codes[p].highlight = false;
            codes[p].text = o.hex(2);
            p++;
        }
     
        reset();
    }

    public function reset() {
        var ch = lists.height;
        if (scbar.enabled = (ch > frame.height))
            scbar.maximum = (ch - frame.height).int();

        position = 0;
    }

    public function unload() {
        codes = [];
        rows  = [];
        reset();
    }


    function on_scroll(pos, delta) lists.y = -pos;

    function op_to_string(pc, hi, lo) {
        
        var o = (hi & 0xF0) >> 4;
        var x = (hi & 0x0F);
        var y = (lo & 0xF0) >> 4;
        var b = (lo & 0x0F);
        
        var kk  = lo;
        var nnn = x << 8 | lo;
        
        var str = '${(0x200 + pc).hex(3)}:  ${hi.hex(2)} ${lo.hex(2)} ..... ';
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

private class CodeBlock extends TextField {
    
    static var DEFAULT_FONT   = new DinaFont();
    static var DEFAULT_FORMAT = new TextFormat(
        DEFAULT_FONT.fontName, 
        26, 0x000000, false, false, false, "", "", 
        TextFormatAlign.CENTER);
    
    
    public var highlight (default, set):Bool;
    function set_highlight(v) {
        return background = highlight = v;
    }
    
    
    public function new(parent, x, y, w, h, hb = 0x89ABCD) {
        super();
        
        parent.addChild(this);
        this.x = x;
        this.y = y;
        width  = w;
        height = h;
        text   = '';
        
        background        = false;
        backgroundColor   = hb;
        defaultTextFormat = DEFAULT_FORMAT;
        embedFonts        = true;
        autoSize          = TextFieldAutoSize.NONE;
        selectable        = false;
        antiAliasType     = AntiAliasType.ADVANCED;
        cacheAsBitmap     = false;
    }
    
}