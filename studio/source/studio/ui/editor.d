/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.ui.editor;

import ciel;
import studio.ui.propertyeditor;
import studio.ui.tabbar;
import studio.ui.menubar;
import studio.ui.resourcelist;

final class Editor : UIElement {
    private {
        MenuBar _taskBar;
        TabBar _tabBar;
        //Visualizer _visualizer;
        PropertyEditor _propertyEditor;
        ResourceList _resourceList;
    }

    this() {
        setSize(Ciel.size);
        setAlign(UIAlignX.center, UIAlignY.center);

        _taskBar = new EditorMenu;
        addUI(_taskBar);

        _tabBar = new TabBar;
        _tabBar.setPosition(Vec2f(0f, 50f));
        addUI(_tabBar);

        {
            _resourceList = new ResourceList;
            addUI(_resourceList);
        }

        {
            _propertyEditor = new PropertyEditor;
            addUI(_propertyEditor);
        }

        addEventListener("windowSize", { setSize(Ciel.size); });
    }
}
