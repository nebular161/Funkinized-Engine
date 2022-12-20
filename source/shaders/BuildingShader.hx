package shaders;

import flixel.graphics.tile.FlxGraphicsShader;

#if USE_SHADERS
class BuildingShader extends FlxGraphicsShader {
	@:glFragmentSource('
        #pragma header

        uniform float alphaShit;

        void main() {
            vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

            if (color.a > 0.0)
                color -= alphaShit;
            
            gl_FragColor = color;
		}
		')
	public function new() {
		super();
	}
}
#end
