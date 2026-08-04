package hxCompileUMacros;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
#end

class HXCU_MACRO {
    public static function macroInit():Void {
        #if (wiiu || cafe)
        Compiler.define("no-thread");
        #end
    }
}
