package chip8;

import haxe.ds.IntMap;
import haxe.io.Bytes;
import haxe.ds.Vector;

using Std;
using StringTools;


typedef OpHandler = Int->Int->Int->Int->Int->Void;
class CPU {

    static inline var RAM_SIZE =  4096;
    static inline var PC_START = 0x200;
    static inline var FONT_POS = 0x050;
    static inline var CYC_60HZ = 16.67;

    static inline var A = 0xA;
    static inline var B = 0xB;
    static inline var C = 0xC;
    static inline var D = 0xD;
    static inline var E = 0xE;
    static inline var F = 0xF;

    static var FONT_DATA = 
    [
        0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
        0x20, 0x60, 0x20, 0x20, 0x70, // 1
        0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
        0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
        0x90, 0x90, 0xF0, 0x10, 0x10, // 4
        0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
        0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
        0xF0, 0x10, 0x20, 0x40, 0x40, // 7
        0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
        0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
        0xF0, 0x90, 0xF0, 0x90, 0x90, // A
        0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
        0xF0, 0x80, 0x80, 0x80, 0xF0, // C
        0xE0, 0x90, 0x90, 0x90, 0xE0, // D
        0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
        0xF0, 0x80, 0xF0, 0x80, 0x80, // F
    ];

    

    var RAM  :Bytes;
    var V    :Vector<Int>;
    var STACK:Array<Int>;

    var I  (default, set):Int = 0; 
    var DT (default, set):Int = 0; 
    var ST (default, set):Int = 0; 
    var PC (default, set):Int = PC_START; 

    function set_I (v:Int):Int { return I  = v & 0x0FFF; }
    function set_DT(v:Int):Int { return DT = v & 0x00FF; }
    function set_ST(v:Int):Int { return ST = v & 0x00FF; }
    function set_PC(v:Int):Int { return PC = v & 0xFFFF; }

    
    
    var op_map:Vector<OpHandler>;
    var gpu:GPU;
    var key:KEY;
    var acc:Float;
    var cyc:Float;
    
    

    public function new(video, input, rate) {
        gpu   = video;
        key   = input;
        acc   = 0;
        cyc   = 1000 / rate;
        RAM   = Bytes.alloc(RAM_SIZE);
        STACK = [];
        V     = new Vector<Int>(16);

        for (pos in 0...80) RAM.set(FONT_POS + pos, FONT_DATA[pos]);

        op_map = new Vector<OpHandler>(16);
        op_map[0x0] = op_0x0; op_map[0x1] = op_0x1;
        op_map[0x2] = op_0x2; op_map[0x3] = op_0x3;
        op_map[0x4] = op_0x4; op_map[0x5] = op_0x5;
        op_map[0x6] = op_0x6; op_map[0x7] = op_0x7;
        op_map[0x8] = op_0x8; op_map[0x9] = op_0x9;
        op_map[0xA] = op_0xA; op_map[0xB] = op_0xB;
        op_map[0xC] = op_0xC; op_map[0xD] = op_0xD;
        op_map[0xE] = op_0xE; op_map[0xF] = op_0xF;
    }

    public function reset() {
        for (pos in 0...16) V[pos] = 0;

        STACK = [];
        I     = 0;
        DT    = 0;
        ST    = 0;
        PC    = PC_START;

        gpu.reset();
        key.reset();        
    }

    public function load(rom:Bytes) {
        unload();
        RAM.blit(PC_START, rom, 0, rom.length);
    }

    public function unload() {
        reset();
        for (pos in PC_START...RAM_SIZE) RAM.set(pos, 0);
    }

    public function cycle(s = 1) {
        if (key.wait) return;

        var m = (RAM.get(PC++) << 8) | RAM.get(PC++);
        var o = (m & 0xF000) >> 12;
        var p = (m & 0x0FFF);

        op_map[o](
            (p & 0xF00) >> 8, 
            (p & 0x0F0) >> 4, 
            (p & 0x00F), 
            (p & 0x0FF), 
            p);
        
            
        acc += (cyc / s);
        while (acc > CYC_60HZ) {
            if (DT > 0) DT--;
            if (ST > 0) {
                //
                // TODO: Play sound
                //
                ST--;
            }
            acc -= CYC_60HZ;
        }
    }

    inline function op_0x0(x, y, b, kk, nnn) { 
        switch (nnn) {
            case 0x0E0: gpu.cls();
            case 0x0EE: PC = STACK.pop();
            default: 
                // SYS addr (ignored, only works with Old HW)
        }
    }

    inline function op_0x1(x, y, b, kk, nnn) PC = nnn;
    inline function op_0x2(x, y, b, kk, nnn) { 
        STACK.push(PC);
        PC = nnn;
    }

    inline function op_0x3(x, y, b, kk, nnn) if (V[x] ==   kk) PC += 2;
    inline function op_0x4(x, y, b, kk, nnn) if (V[x] !=   kk) PC += 2;
    inline function op_0x5(x, y, b, kk, nnn) if (V[x] == V[y]) PC += 2;
    inline function op_0x6(x, y, b, kk, nnn) V[x] = kk;

    inline function op_0x7(x, y, b, kk, nnn) { 
        V[x] += kk;
        V[x] &= 0xFF;
    }

    inline function op_0x8(x, y, b, kk, nnn) { 
        switch(b) {
            case 0x0: V[x]  = V[y];
            case 0x1: V[x] |= V[y];
            case 0x2: V[x] &= V[y];
            case 0x3: V[x] ^= V[y];
            case 0x4: 
                V[x] += V[y]; 
                V[F]  = V[x] > 0xFF ? 1 : 0; 
                V[x] &= 0xFF; 

            case 0x5: 
                V[F]  = V[x] > V[y] ? 1 : 0; 
                V[x] -= V[y]; 
                V[x] &= 0xFF;

            case 0x6: 
                /*
                V[F] = V[y] & 0x1; 
                V[x] = V[y] >> 1;
                */
                V[F]   = V[x] & 0x1; 
                V[x] >>= 1;

            case 0x7:
                V[F]  = V[y] > V[x] ? 1 : 0;
                V[x]  = V[y] - V[x];
                V[x] &= 0xFF;

            case 0xE:
                /*
                V[F]  = (V[y] >> 7) & 0x1;
                V[x]  = V[y] << 1;
                V[x] &= 0xFF;
                */
                V[F]   = (V[x] >> 7) & 0x1;
                V[x] <<= 1;
                V[x]  &= 0xFF;

            default:
                throw "Unsupported Operation";
        }
    }

    inline function op_0x9(x, y, b, kk, nnn) if (V[x] != V[y]) PC += 2;
    inline function op_0xA(x, y, b, kk, nnn) I    = nnn;
    inline function op_0xB(x, y, b, kk, nnn) PC   = nnn + V[0];
    inline function op_0xC(x, y, b, kk, nnn) V[x] = (Math.random() * 0xFF).int() & kk;

    inline function op_0xD(x:Int, y:Int, b:Int, kk, nnn) { 
        
        V[F]  = 0;
        var j = V[y];
        for (pos in 0...b) {

            /*
             * HACK: Should this be % and not clipped?
             * PURPOSE: So BLITZ can run correctly.
             */
            if (j < 0 || j >= 32) break;

            var m = RAM.get(I + pos);
            var i = V[x];
            for (bit in 0...8) {

                if ((m & 0x80) == 0x80)
                    if (gpu.set(i, j))
                        V[F] = 1;

                m <<= 1;
                i++;
            }

            j++;
        }
        
        if (V[F] != 0x1) gpu.flip();
    }

    inline function op_0xE(x, y, b, kk, nnn) { 
        switch (kk) {
            case 0x9E: if (key.get(V[x]) == true) PC += 2;
            case 0xA1: if (key.get(V[x]) != true) PC += 2;
        }
    }
    
    inline function op_0xF(x, y, b, kk, nnn) { 
        switch (kk) {
            case 0x07: V[x] = DT;
            case 0x0A: 
                key.ask(
                    function(key) V[x] = key
                );

            case 0x15: DT = V[x];
            case 0x18: ST = V[x];
            case 0x1E: 
                V[F] = (I + V[x] > 0x0FFF) ? 1 : 0;
                I   += V[x];
                
            case 0x29: I  = FONT_POS + (V[x] * 5);
            case 0x33: 
                var v = V[x];
                var s = (v % 10); v = (v / 10).int();
                var p = (v % 10);
                var r = (v / 10).int();

                RAM.set((I + 0), r);
                RAM.set((I + 1), p);
                RAM.set((I + 2), s);

            case 0x55:
                x++;
                for (i in 0...x) RAM.set(I + i, V[i]);
                // I += x;

            case 0x65:
                x++;
                for (i in 0...x) V[i] = RAM.get(I + i);
                // I += x;

            default:
                throw "Unsupported Operation";
        }
    }
}
