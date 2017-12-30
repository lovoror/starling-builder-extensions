/**
 * Created by hyh on 9/29/15.
 */
package
{
    import flash.display.Sprite;

    import starling.extensions.Gauge;
    import starling.extensions.GodRayPlane;
    import starling.extensions.QuadSection;
    import starling.extensions.TextureMaskStyle;
    import starling.extensions.lighting.LightSource;
    import starling.extensions.lighting.LightStyle;

    import starling.extensions.pixelmask.PixelMaskDisplayObject;

    import starlingbuilder.extensions.uicomponents.ContainerButton;
    import starlingbuilder.extensions.uicomponents.GradientQuad;

    public class EmbeddedComponents extends Sprite
    {
        [Embed(source="custom_component_template.json", mimeType="application/octet-stream")]
        public static const custom_component_template:Class;

        public static const linkers:Array = [ContainerButton, GradientQuad, Gauge, TextureMaskStyle, LightSource, LightStyle, PixelMaskDisplayObject, QuadSection, GodRayPlane];
    }
}
