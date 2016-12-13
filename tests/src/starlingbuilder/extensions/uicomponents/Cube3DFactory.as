package starlingbuilder.extensions.uicomponents
{
    import starling.display.DisplayObject;
    import starling.extensions.Mesh3D;
    import starling.extensions.Mesh3DEffect;
    import starling.rendering.IndexData;
    import starling.rendering.VertexData;

    public class Cube3DFactory extends AbstractDisplayObjectFactory
    {
        public function Cube3DFactory()
        {
            super();
        }

        override public function create():DisplayObject
        {
            return createCube();
        }

        public function createCube():Mesh3D
        {
            // Vertexes for the cube. Format is (x, y, z, r, g, b), counter-clockwise
            // winding, with normal OpenGL axes (-x/+x = left/right, -y/+y = bottom/top,
            // -z/+z = far/near). This is also a bit overkill on vertexes, but the
            // extras are needed to make each side a solid color.
            var _cubeVertexes:Vector.<Number> = Vector.<Number>([
                // near face
                -1.0, -1.0,  1.0, 1.0, 0.0, 0.0, 0, 0,
                -1.0,  1.0,  1.0, 1.0, 0.0, 0.0, 0, 1,
                1.0,  1.0,  1.0, 1.0, 0.0, 0.0, 1, 1,
                1.0, -1.0,  1.0, 1.0, 0.0, 0.0, 1, 0,

                // left face
                -1.0, -1.0, -1.0, 0.0, 1.0, 0.0, 0, 0,
                -1.0,  1.0, -1.0, 0.0, 1.0, 0.0, 0, 1,
                -1.0,  1.0,  1.0, 0.0, 1.0, 0.0, 1, 1,
                -1.0, -1.0,  1.0, 0.0, 1.0, 0.0, 1, 0,

                // far face
                1.0, -1.0, -1.0, 0.0, 0.0, 1.0, 0, 0,
                1.0,  1.0, -1.0, 0.0, 0.0, 1.0, 0, 1,
                -1.0,  1.0, -1.0, 0.0, 0.0, 1.0, 1, 1,
                -1.0, -1.0, -1.0, 0.0, 0.0, 1.0, 1, 0,

                // right face
                1.0, -1.0,  1.0, 1.0, 1.0, 0.0, 0, 0,
                1.0,  1.0,  1.0, 1.0, 1.0, 0.0, 0, 1,
                1.0,  1.0, -1.0, 1.0, 1.0, 0.0, 1, 1,
                1.0, -1.0, -1.0, 1.0, 1.0, 0.0, 1, 0,

                // top face
                -1.0,  1.0,  1.0, 1.0, 0.0, 1.0, 0, 0,
                -1.0,  1.0, -1.0, 1.0, 0.0, 1.0, 0, 1,
                1.0,  1.0, -1.0, 1.0, 0.0, 1.0, 1, 1,
                1.0,  1.0,  1.0, 1.0, 0.0, 1.0, 1, 0,

                // bottom face
                -1.0, -1.0, -1.0, 0.0, 1.0, 1.0, 0, 0,
                -1.0, -1.0,  1.0, 0.0, 1.0, 1.0, 0, 1,
                1.0, -1.0,  1.0, 0.0, 1.0, 1.0, 1, 1,
                1.0, -1.0, -1.0, 0.0, 1.0, 1.0, 1, 0,
            ]);

            // Indexes into the vertex buffer above for each of the cube's triangles.
            var _cubeIndexes:Vector.<uint> = Vector.<uint>([
                0, 1, 2,
                0, 2, 3,
                4, 5, 6,
                4, 6, 7,
                8, 9, 10,
                8, 10, 11,
                12, 13, 14,
                12, 14, 15,
                16, 17, 18,
                16, 18, 19,
                20, 21, 22,
                20, 22, 23
            ]);

            var vertex:VertexData = new VertexData(Mesh3DEffect.VERTEX_FORMAT);
            var index:IndexData = new IndexData(_cubeIndexes.length);
            index.useQuadLayout = false;

            var s:Number = 1;

            for (var i:int = 0; i < _cubeVertexes.length; i += 8)
            {
                vertex.setPoint3D(i / 8, "position", _cubeVertexes[i] * s, _cubeVertexes[i + 1] * s, _cubeVertexes[i + 2] * s);
                vertex.setPoint3D(i / 8, "color", _cubeVertexes[i + 3], _cubeVertexes[i + 4], _cubeVertexes[i + 5]);
                vertex.setPoint(i / 8, "texCoord", _cubeVertexes[i + 6], _cubeVertexes[i + 7]);
            }

            for (var j:int = 0; j < _cubeIndexes.length; ++j)
                index.setIndex(j, _cubeIndexes[j]);

            var cube:Mesh3D = new Mesh3D(vertex, index);

            cube.x = -1;
            cube.y = 0.7
            cube.z = -6;
            return cube;

        }
    }
}
