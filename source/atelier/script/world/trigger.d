module atelier.script.world.trigger;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world;
import atelier.script.util;

package void loadLibWorld_trigger(GrModule mod) {
    mod.setModule("world.trigger");
    mod.setModuleInfo(GrLocale.fr_FR, "Définit un déclencheur");

    GrType triggerType = mod.addNative("Trigger", [], "Entity");

    //mod.setDescription(GrLocale.fr_FR, "Crée un déclencheur dans la scène");
    //mod.setParameters(["rid"]);
    //mod.addConstructor(&_ctor, triggerType, [grString]);
    
    mod.addProperty(&_isActive!"get", &_isActive!"set", "isActive", triggerType, grBool);
    mod.addProperty(&_isActiveOnce!"get", &_isActiveOnce!"set", "isActiveOnce", triggerType, grBool);
}

private void _isActive(string op)(GrCall call) {
    Trigger trigger = call.getNative!Trigger(0);
    
    static if (op == "set") {
        trigger.isActive = call.getBool(1);
    }

    call.setBool(trigger.isActive);
}

private void _isActiveOnce(string op)(GrCall call) {
    Trigger trigger = call.getNative!Trigger(0);
    
    static if (op == "set") {
        trigger.isActiveOnce = call.getBool(1);
    }

    call.setBool(trigger.isActiveOnce);
}


