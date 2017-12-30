package starlingbuilder.extensions.uicomponents
{
    import starling.display.DisplayObject;
    import starling.extensions.QuadSection;

    public class QuadSectionFactory extends AbstractDisplayObjectFactory
    {
        override public function create():DisplayObject
        {
            var quad:QuadSection = new QuadSection(150, 150);
            return quad;
        }
    }
}

