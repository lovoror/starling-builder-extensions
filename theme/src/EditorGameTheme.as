/**
 * Created by hyh on 4/10/17.
 */
package {
    import feathers.themes.*;
    import feathers.core.IFeathersControl;
    import feathers.skins.IStyleProvider;
    import feathers.skins.StyleProviderRegistry;

    import starlingbuilder.editor.themes.ExtendedStyleNameFunctionStyleProvider;

    import starlingbuilder.editor.themes.IUIEditorThemeMediator;

    /**
     * To be able to use your game theme in the editor,
     * extend this class from your game theme and put it to EmbeddedTheme.theme
     */
    public class EditorGameTheme extends TestGameMobileTheme
    {
        private var _themeMediator:IUIEditorThemeMediator

        public function EditorGameTheme(themeMediator:IUIEditorThemeMediator)
        {
            _themeMediator = themeMediator;
            super();
        }

        override protected function starlingConditional(target:IFeathersControl):Boolean
        {
            return _themeMediator.useGameTheme(target);
        }

        override protected function createRegistry():void
        {
            this._registry = new StyleProviderRegistry(false, defaultStyleProviderFactory);
        }

        protected static function defaultStyleProviderFactory():IStyleProvider
        {
            return new ExtendedStyleNameFunctionStyleProvider();
        }
    }
}
