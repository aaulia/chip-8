package gui;

import flash.display.Bitmap;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.utils.ByteArray;
import res.Images;
import res.Fonts.Dina;
import res.Roms;

using Lambda;

class RomSelect extends Sprite {

    static var ROM_NAMES = 
    [
        "PUZZLE15", "BLINKY",  "BLITZ",  "BRIX",   "CONNECT4", "GUESS",  "HIDDEN", "INVADERS", "KALEID", "MAZE", "MERLIN", "MISSILE", 
        "PONG",     "PONG2",   "PUZZLE", "SYZYGY", "TANK",     "TETRIS", "TICTAC", "UFO",      "VBRIX",  "VERS", "WIPEOFF"
    ];

    static var ROM_CLASS:Array<Class<ByteArray>> =
    [
        PUZZLE15, BLINKY, BLITZ,  BRIX,   CONNECT4, GUESS,  HIDDEN, INVADERS, KALEID, MAZE, MERLIN, MISSILE,
        PONG,     PONG2,  PUZZLE, SYZYGY, TANK,     TETRIS, TICTAC, UFO,      VBRIX,  VERS, WIPEOFF 
    ];

    static var DEFAULT_FORMAT = new TextFormat(
        Dina.fontName, 22, 0x000000, 
        false, false, false, "", "", 
        TextFormatAlign.LEFT);


    var bmp_window:Bitmap;
    var btn_select:Button;
    var btn_cancel:Button;
    var scr_bar   :ScrollBar;

    var frame     :Rectangle;
    var lists     :Sprite;
    var names     :Array<TextField>;
    var selected  :Class<ByteArray>;

    var fun_select:Class<ByteArray>->Void;
    var fun_cancel:Void->Void;

    public function new(select, cancel) {
        super();

        fun_select = select;
        fun_cancel = cancel;

        bmp_window = cast addChild(new Bitmap(new UIWindowSelect(0, 0)));
        btn_select = new Button   (this, UIButtonText, 80, 38, 230, 10, "Ok", on_select);
        btn_cancel = new Button   (this, UIButtonText, 80, 38, 230, 54, "Close", on_cancel);
        scr_bar    = new ScrollBar(this, UIScrollUp, UIScrollDn, UIScrollMd, 294, 199, 13, 100, on_scroll);

        frame = new Rectangle(0, 0, 186, 294);
        lists = cast addChild(new Sprite());
        names = [];

        lists.x = 13;
        lists.y = 13;
        lists.scrollRect = frame;

        var index = 0;
        for (name in ROM_NAMES) {
            names.push(cast lists.addChild(create_text(name, 0, index * 22, 186, 22)));
            ++index;
        }

        scr_bar.maximum = cast (lists.height - frame.height);

        selected = ROM_CLASS[0];
        names[0].backgroundColor = 0x345678;
        names[0].textColor = 0xFFFFFF;
    }

    function create_text(name, x, y, w, h) {
        var tf = new TextField();

        tf.defaultTextFormat = DEFAULT_FORMAT;
        tf.selectable        = false;
        tf.background        = true;
        tf.backgroundColor   = 0x7f7f7f;
        tf.width             = w;
        tf.height            = h;
        tf.autoSize          = TextFieldAutoSize.NONE;
        tf.embedFonts        = true;
        tf.text              = name;
        tf.x                 = x;
        tf.y                 = y;

        tf.addEventListener(MouseEvent.CLICK, on_clicked, false, 0, true);

        return tf;
    }

    function on_clicked(e:MouseEvent) {
        var tf = e.target;
        for (name in names) {
            name.backgroundColor = (name == tf) ? 0x345678 : 0x7f7f7f;
            name.textColor       = (name == tf) ? 0xFFFFFF : 0x000000;
        }

        selected = ROM_CLASS[names.indexOf(tf)];
    }

    public function show(parent:DisplayObjectContainer) {
        parent.addChild(this);

        x = cast (parent.width  - bmp_window.width)  >> 1;
        y = cast (parent.height - bmp_window.height) >> 1;
    }

    public function hide() {
        if (parent != null)
            parent.removeChild(this);
    }

    function on_select() {
        if (fun_select != null) 
            fun_select(selected);
    }

    function on_cancel() {
        if (fun_cancel != null) 
            fun_cancel();
    }

    function on_scroll(position, delta) {
        frame.y = position;
        lists.scrollRect = frame;
    }

}