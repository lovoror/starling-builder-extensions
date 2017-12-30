/**
 * Created by hyh on 12/29/17.
 */
package starlingbuilder.extensions.uicomponents
{
    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.extensions.GodRayPlane;

    public class GodRayPlaneFactory extends AbstractDisplayObjectFactory
    {
        override public function create():DisplayObject
        {
            var godRay:GodRayPlane = new GodRayPlane(320, 200);
            Starling.current.juggler.add(godRay);
            return godRay;
        }
    }
}
