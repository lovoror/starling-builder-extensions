package starling.extensions
{
    import flash.display.BitmapData;

    import starling.animation.IAnimatable;
    import starling.display.Quad;
    import starling.textures.Texture;
    import starling.utils.MathUtil;

    /** A quad that efficiently renders a 2D light ray effect on its surface.
     *
     *  <p>This class is useful for adding atmospheric effects, like the typical effects you see
     *  underwater or in a forest. Add it to a juggler or call 'advanceTime' so that the effect
     *  becomes animated.</p>
     *
     *  <p>Play around with the different settings to make it suit the style you want. In addition
     *  to the class-specific properties, you can also assign an overall color or different colors
     *  per vertex.</p>
     */
    public class GodRayPlane extends Quad implements IAnimatable
    {
        private static const TEXTURE_HEIGHT:int = 32;
        private static const TEXTURE_WIDTH:int = 512;

        private var _bitmapData:BitmapData;
        private var _speed:Number;
        private var _size:Number;
        private var _skew:Number;
        private var _fade:Number;

        /** Create a new instance with the given size. Using a "packed" texture format produces
         *  a slightly different effect with visible gradient steps. */
        public function GodRayPlane(width:Number, height:Number, textureFormat:String="bgra")
        {
            super(width, height);

            _speed = 0.1;
            _size = 0.1;
            _skew = 0.0;
            _fade = 1.0;

            _bitmapData = new BitmapData(TEXTURE_WIDTH, TEXTURE_HEIGHT, false);
            texture = Texture.empty(TEXTURE_WIDTH, TEXTURE_HEIGHT, true, false, false,
                    1.0, textureFormat, true);

            updateTexture();
            textureRepeat = true;
            style = new GodRayStyle();
        }

        /** Disposes the internally used texture. */
        override public function dispose():void
        {
            super.dispose();

            _bitmapData.dispose();
            texture.dispose();
        }

        private function updateTexture():void
        {
            _bitmapData.perlinNoise(TEXTURE_WIDTH * _size, TEXTURE_HEIGHT * 0.2,
                    2, 0, true, true, 0, true);
            texture.root.uploadBitmapData(_bitmapData);
        }

        private function updateVertices():void
        {
            vertexData.setPoint(2, "texCoords", -_skew, 1.0);
            vertexData.setPoint(3, "texCoords", -_skew + 1.0, 1.0);

            vertexData.setAlpha(2, "color", 1.0 - _fade);
            vertexData.setAlpha(3, "color", 1.0 - _fade);
        }

        /** @inheritDoc */
        public function advanceTime(time:Number):void
        {
            godRayStyle.offsetY += time * _speed;

            while (godRayStyle.offsetY > 1.0)
                godRayStyle.offsetY -= 1.0;
        }

        private function get godRayStyle():GodRayStyle { return style as GodRayStyle; }

        /** The speed with which the effect is animated. A value of '1.0' causes the pattern
         *  to repeat exactly after one second. Range: 0 - infinite. @default 0.1 */
        public function get speed():Number { return _speed; }
        public function set speed(value:Number):void
        {
            _speed = MathUtil.max(0, value);
        }

        /** Determines up the angle of the light rays.
         *  Range: -5 - 5. @default: 0.0 */
        public function get skew():Number { return _skew; }
        public function set skew(value:Number):void
        {
            _skew = MathUtil.clamp(value, -5, 5);
            updateVertices();
        }

        /** Determines the change in the light ray's angles over the width of the plane.
         *  Range: -1 - 10. @default: 0.0 */
        public function get shear():Number { return godRayStyle.shear; }
        public function set shear(value:Number):void { godRayStyle.shear = value; }

        /** The width of the rays. As a rule of thumb, one divided by this value will yield the
         *  approximate number of rays. Range: 0.0001 - 1. @default: 0.1 */
        public function get size():Number { return _size; }
        public function set size(value:Number):void
        {
            _size = MathUtil.clamp(value, 0.0001, 1);
            updateTexture();
        }

        /** Indicates how the light rays fade out towards the bottom. Zero means no fading,
         *  one means that the rays will become completely invisible at the bottom.
         *  Range: 0 - 1, default: 1 */
        public function get fade():Number { return _fade; }
        public function set fade(value:Number):void
        {
            _fade = MathUtil.clamp(value, 0, 1);
            updateVertices();
        }

        /** The distinctiveness and brightness of the light rays.
         *  Range: 0 - infinite, @default: 1 */
        public function get contrast():Number { return godRayStyle.contrast; }
        public function set contrast(value:Number):void { godRayStyle.contrast = value; }
    }
}

import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;

import starling.display.Mesh;
import starling.rendering.MeshEffect;
import starling.rendering.Program;
import starling.rendering.VertexDataFormat;
import starling.styles.MeshStyle;
import starling.utils.MathUtil;

class GodRayStyle extends MeshStyle
{
    public static const VERTEX_FORMAT:VertexDataFormat =
            MeshStyle.VERTEX_FORMAT.extend("settings:float3");

    private var _offsetY:Number;
    private var _shear:Number;
    private var _contrast:Number;

    public function GodRayStyle()
    {
        _offsetY = 0.0;
        _shear = 0.0;
        _contrast = 1.0;
    }

    override public function copyFrom(meshStyle:MeshStyle):void
    {
        var godRayStyle:GodRayStyle = meshStyle as GodRayStyle;
        if (godRayStyle)
        {
            _offsetY = godRayStyle._offsetY;
            _shear = godRayStyle._shear;
            _contrast = godRayStyle._contrast;
        }

        super.copyFrom(meshStyle);
    }

    override public function createEffect():MeshEffect
    {
        return new GodRayEffect();
    }

    override public function get vertexFormat():VertexDataFormat
    {
        return VERTEX_FORMAT;
    }

    override protected function onTargetAssigned(target:Mesh):void
    {
        updateVertices();
    }

    private function updateVertices():void
    {
        if (target)
        {
            vertexData.setPremultipliedAlpha(false, true);

            var numVertices:int = vertexData.numVertices;
            for (var i:int=0; i<numVertices; ++i)
                vertexData.setPoint3D(i, "settings", _offsetY, _shear, _contrast);

            setRequiresRedraw();
        }
    }

    public function get shear():Number { return _shear; }
    public function set shear(value:Number):void
    {
        _shear = MathUtil.clamp(value, -1, 10);
        updateVertices();
    }

    public function get offsetY():Number { return _offsetY; }
    public function set offsetY(value:Number):void { _offsetY = value; updateVertices(); }

    public function get contrast():Number { return _contrast; }
    public function set contrast(value:Number):void
    {
        _contrast = MathUtil.max(0, value);
        updateVertices();
    }
}

class GodRayEffect extends MeshEffect
{
    private static const sConstants:Vector.<Number> = new <Number>[0, 1, 2, 0.5];

    public function GodRayEffect()
    { }

    override protected function createProgram():Program
    {
        var vertexShader:String = [
            "m44 op, va0, vc0",       // 4x4 matrix transform to output clip-space
            "mov v0, va1     ",       // pass texture coordinates to fragment program
            "mov v1.xyz, va2.xyz",    // copy color to v1.xyz
            "mul v1.w, va2.w, vc4.w", // copy combined alpha to v1.w
            "mov v2, va3     "        // pass settings to fp
        ].join("\n");

        var fragmentShader:String = [
            // offset
            "mov ft0, v0",
            "mov ft0.y, v2.x",  // texture coordinates: v = offset

            // shear
            "mul ft2.x, v0.y, v2.y",    // shear *= v
            "add ft2.x, ft2.x, fc5.y",  // shear = 1 + v * shear
            "div ft0.x, ft0.x, ft2.x",  // texture coordinates: divide 'u' by shear

            // texture lookup
            tex("ft1", "ft0", 0, texture),

            // contrast
            "mul ft1.xyz, ft1.xyz, v2.zzz",  // tex color *= contrast
            "sub ft2.xyz, fc5.yyy, v2.zzz",  // ft2 = 1 - contrast
            "add ft1.xyz, ft1.xyz, ft2.xyz", // tex color += ft2

            // alpha + tinting
            "mul ft1.w, ft1.x, v1.w",        // multiply with vertex alpha
            "mul ft1.xyz, ft1.xxx, v1.xyz",  // tint with vertex color
            "mul ft1.xyz, ft1.xyz, ft1.www", // premultiply alpha

            // copy to output
            "mov oc, ft1"
        ].join("\n");

        return Program.fromSource(vertexShader, fragmentShader);
    }

    override public function get vertexFormat():VertexDataFormat
    {
        return GodRayStyle.VERTEX_FORMAT;
    }

    override protected function beforeDraw(context:Context3D):void
    {
        super.beforeDraw(context);
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, sConstants);
        vertexFormat.setVertexBufferAt(3, vertexBuffer, "settings");
    }

    override protected function afterDraw(context:Context3D):void
    {
        context.setVertexBufferAt(3, null);
        super.afterDraw(context);
    }
}