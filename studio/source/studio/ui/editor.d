/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.ui.editor;

import etabli;
import studio.ui.propertyeditor;
import studio.ui.tabbar;
import studio.ui.taskbar;
import studio.ui.resourcelist;

final class Editor : UIElement {
    private {
        TaskBar _taskBar;
        TabBar _tabBar;
        //Visualizer _visualizer;
        PropertyEditor _propertyEditor;
        ResourceList _resourceList;
    }

    this() {
        setSize(cast(Vec2f) Etabli.window.size);
        setAlign(UIAlignX.center, UIAlignY.center);

        {
            VBox box = new VBox;
            box.setAlign(UIAlignX.center, UIAlignY.top);
            addUI(box);

            _taskBar = new TaskBar;
            box.addUI(_taskBar);

            _tabBar = new TabBar;
            box.addUI(_tabBar);
        }

        {
            _resourceList = new ResourceList;
            addUI(_resourceList);
        }

        {
            _propertyEditor = new PropertyEditor;
            addUI(_propertyEditor);
        }

        addEventListener("windowSize", { setSize(cast(Vec2f) Etabli.window.size); });
    }
}
