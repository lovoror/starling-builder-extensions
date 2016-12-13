package starling.extensions
{
    import starling.display.Mesh;
    import starling.extensions.Mesh3DStyle;
    import starling.rendering.MeshEffect;
    import starling.styles.MeshStyle;
    import starling.textures.Texture;

    public class Mesh3DStyle extends MeshStyle
    {
        private var _texture:Texture;

        public function Mesh3DStyle()
        {
            super();
            //_type = Object(this).constructor as Class;
        }

        override public function createEffect():MeshEffect
        {
            return new Mesh3DEffect();
        }

        override public function canBatchWith(meshStyle:MeshStyle):Boolean
        {
            return false;
        }

        override protected function onTargetAssigned(target:Mesh):void
        {
            setRequiresRedraw();
        }

        override public function set texture(value:Texture):void
        {
            _texture = value;
            setRequiresRedraw();
        }

        override public function get texture():Texture
        {
            return _texture;
        }
    }
}


