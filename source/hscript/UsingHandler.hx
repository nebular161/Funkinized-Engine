package hscript;

import Type.ValueType;
import haxe.macro.ComplexTypeTools;
#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Printer;
import haxe.macro.Compiler;

using StringTools;

class UsingHandler {
    public var usedClass:Class<Dynamic>;
    public var className:String;

    public function new(className:String, usedClass:Class<Dynamic>) {
        this.className = className;
        this.usedClass = usedClass;
    }

    public static function init() {
        Compiler.addGlobalMetadata('flixel', '@:build(hscript.UsingHandler.build())');
        Compiler.addGlobalMetadata('openfl.display.BlendMode', '@:build(hscript.UsingHandler.build())');
    }

    public static function build():Array<Field> {
        var fields = Context.getBuildFields();
        var clRef = Context.getLocalClass();
        if (clRef == null) return fields;
        var cl = clRef.get();

        if (/* cl.name.startsWith("Flx") && */ cl.name.endsWith("_Impl_") && cl.params.length <= 0 && !cl.meta.has(":multiType")) {
            var metas = cl.meta.get();

            var shadowClass = macro class {
                
            };
            shadowClass.params = switch(cl.params.length) {
                case 0:
                    null;
                case 1:
                    [
                        {
                            name: "T",
                        }
                    ];
                default:
                    [for(k=>e in cl.params) {
                        name: "T" + Std.int(k+1)
                    }];
            };
            shadowClass.name = '${cl.name.substr(0, cl.name.length - 6)}_HSC';

            for(f in fields)
                switch(f.kind) {
                    case FFun(fun):
                        if (f.access.contains(AStatic)) {
                            if (fun.expr != null)
                                shadowClass.fields.push(f);
                        }
                    case FProp(get, set, t, e):
                        if (get == "default" && (set == "never" || set == "null"))
                            shadowClass.fields.push(f);
                    case FVar(t, e):
                        if (f.access.contains(AStatic) || cl.meta.has(":enum") || f.name.toUpperCase() == f.name) {
                            var name:String = f.name;
                            var enumType:String = cl.name;
                            var pack = cl.module.split(".");
                            pack.pop();
                            var complexType:ComplexType = t != null ? t : (name.contains("REGEX") ? TPath({
                                name: "EReg",
                                pack: []
                            }) : TPath({
                                name: cl.name.substr(0, cl.name.length - 6),
                                pack: pack}));
                            var field:Field = {
                                pos: f.pos,
                                name: f.name,
                                meta: f.meta,
                                kind: FVar(complexType, {
                                    pos: Context.currentPos(),
                                    expr: ECast(e, complexType)
                                }),
                                doc: f.doc,
                                access: [APublic, AStatic]
                            }
                            
                            shadowClass.fields.push(field);
                        }
                    default:
                }

            Context.defineModule(cl.module, [shadowClass], Context.getLocalImports());
        }

        return fields;
    }
}
#else
class UsingHandler {
    public var usedClass:Class<Dynamic>;
    public var className:String;
}
#end