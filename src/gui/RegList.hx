package gui;

import flash.display.Sprite;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import haxe.ds.Vector.Vector;
import res.Fonts;
import res.Fonts.Dina;

using Std;
using StringTools;

class RegList extends Sprite {

    static var PC =  0; static var DT =  1;
    static var  I =  2; static var ST =  3;
    static var V0 =  4; static var V8 =  5;
    static var V1 =  6; static var V9 =  7;
    static var V2 =  8; static var VA =  9;
    static var V3 = 10; static var VB = 11;
    static var V4 = 12; static var VC = 13;
    static var V5 = 14; static var VD = 15;
    static var V6 = 16; static var VE = 17;
    static var V7 = 18; static var VF = 19;

    static var LABELS = 
    [
        "PC: ", "DT: ",
        " I: ", "ST: ",
        "V0: ", "V8: ",
        "V1: ", "V9: ",
        "V2: ", "VA: ",
        "V3: ", "VB: ",
        "V4: ", "VC: ",
        "V5: ", "VD: ",
        "V6: ", "VE: ",
        "V7: ", "VF: ",
    ];

    static var DEFAULT_FORMAT = new TextFormat(
        Dina.fontName, 26, 0x000000, 
        false, false, false, "", "",
        TextFormatAlign.LEFT);

    var texts:Array<TextField>;

    public function new(parent, x, y) {
        super();

        parent.addChild(this);
        this.x = x;
        this.y = y;

        texts = [];
        for (i in 0...20) {
            var t = new TextField();

            t.defaultTextFormat = DEFAULT_FORMAT;
            t.embedFonts        = true;
            t.autoSize          = TextFieldAutoSize.NONE;
            t.selectable        = false;
            t.antiAliasType     = AntiAliasType.ADVANCED;

            t.x      = (i % 2) * 120;
            t.y      = (i / 2).int() * 26 + (i >= 4 ? 10 : 0);
            t.width  = 120;
            t.height = 26;
            t.text   = LABELS[i];

            texts[i] = cast addChild(t);
        }
    }

    public function update(pc:Int, i:Int, dt:Int, st:Int, v:Vector<Int>) {
        texts[PC].text = LABELS[PC] + pc.hex(3);
        texts[ I].text = LABELS[ I] + i .hex(3);
        texts[DT].text = LABELS[DT] + dt.hex(2);
        texts[ST].text = LABELS[ST] + st.hex(2);

        texts[V0].text = LABELS[V0] + v[0x0].hex(2);
        texts[V1].text = LABELS[V1] + v[0x1].hex(2);
        texts[V2].text = LABELS[V2] + v[0x2].hex(2);
        texts[V3].text = LABELS[V3] + v[0x3].hex(2);
        texts[V4].text = LABELS[V4] + v[0x4].hex(2);
        texts[V5].text = LABELS[V5] + v[0x5].hex(2);
        texts[V6].text = LABELS[V6] + v[0x6].hex(2);
        texts[V7].text = LABELS[V7] + v[0x7].hex(2);
        texts[V8].text = LABELS[V8] + v[0x8].hex(2);
        texts[V9].text = LABELS[V9] + v[0x9].hex(2);
        texts[VA].text = LABELS[VA] + v[0xA].hex(2);
        texts[VB].text = LABELS[VB] + v[0xB].hex(2);
        texts[VC].text = LABELS[VC] + v[0xC].hex(2);
        texts[VD].text = LABELS[VD] + v[0xD].hex(2);
        texts[VE].text = LABELS[VE] + v[0xE].hex(2);
        texts[VF].text = LABELS[VF] + v[0xF].hex(2);
    }

}
