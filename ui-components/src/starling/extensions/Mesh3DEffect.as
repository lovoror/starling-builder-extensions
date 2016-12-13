package starling.extensions
{
    import flash.display3D.Context3D;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DTriangleFace;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;

    import starling.core.Starling;
    import starling.rendering.IndexData;

    import starling.rendering.MeshEffect;
    import starling.rendering.Program;
    import starling.rendering.VertexData;
    import starling.rendering.VertexDataFormat;

    public class Mesh3DEffect extends MeshEffect
    {
        public static const VERTEX_FORMAT:VertexDataFormat =
                VertexDataFormat.fromString("position:float3,color:float3,texCoord:float2");

        public function Mesh3DEffect()
        {
        }

        override public function get vertexFormat():VertexDataFormat
        {
            return VERTEX_FORMAT;
        }

        override protected function beforeDraw(context:Context3D):void
        {
            context.enableErrorChecking = true;

            context.setCulling(Context3DTriangleFace.BACK);
            context.setDepthTest(true, Context3DCompareMode.LESS_EQUAL);

            context.setProgramConstantsFromMatrix(
                    Context3DProgramType.VERTEX, 0, mvpMatrix3D, true);

            program.activate(context);
            vertexFormat.setVertexBufferAt(0, vertexBuffer, "position");
            vertexFormat.setVertexBufferAt(1, vertexBuffer, "color");

            if (texture)
            {
                vertexFormat.setVertexBufferAt(2, vertexBuffer, "texCoord");
                context.setTextureAt(0, texture.base);
            }

            //super.beforeDraw(context);
        }

        override protected function afterDraw(context:Context3D):void
        {
            context.setVertexBufferAt(0, null);
            context.setVertexBufferAt(1, null);

            if (texture)
            {
                context.setVertexBufferAt(2, null);
                context.setTextureAt(0, null);
            }
        }

        override protected function createProgram():Program
        {
            var vertexShader:String;
            var fragmentShader:String;

            if (texture)
            {
                vertexShader = [
                    "m44 op, va0, vc0",  // multiply vertex by modelViewProjection
                    "mov v0, va1",       // copy the vertex color
                    "mov v1, va2",
                ].join("\n");

                fragmentShader = [
                    tex("ft0", "v1", 0, texture),
                    "mul oc, ft0, v0"
                ].join("\n");
            }
            else
            {
                vertexShader = [
                    "m44 op, va0, vc0",  // multiply vertex by modelViewProjection
                    "mov v0, va1"        // copy the vertex color
                ].join("\n");

                fragmentShader = [
                    "mov oc, v0"  // output the fragment color
                ].join("\n");
            }

            return Program.fromSource(vertexShader, fragmentShader);
        }

        override public function uploadIndexData(indexData:IndexData,
                                        bufferUsage:String="staticDraw"):void
        {
            super.uploadIndexData(indexData, bufferUsage);
        }

        override public function uploadVertexData(vertexData:VertexData,
                                                  bufferUsage:String="staticDraw"):void
        {
            super.uploadVertexData(vertexData, bufferUsage);
        }
    }
}

