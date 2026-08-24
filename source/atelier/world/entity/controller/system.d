module atelier.world.entity.controller.system;

mixin template ControllerMixin() {
    import atelier.world.entity.controller.base : EntityController;

    private {
        EntityController _controller;
    }

    EntityController getController() {
        return _controller;
    }

    bool hasController() {
        return _controller !is null;
    }

    void removeController() {
        if (_controller) {
            _controller.unregister();
            _controller = null;
        }
    }

    EntityController setController(string id) {
        if (_controller && _controller.id == id)
            return _controller;

        if (_controller) {
            _controller.unregister();
        }

        _controller = Atelier.world.fetchController!Entity(id);

        if (_controller) {
            _controller.setup(this, id);
            onRegisterController();
            _controller.onStart();
        }

        return _controller;
    }

    void onRegisterController() {
        if (!_controller)
            return;

        Atelier.world.registerController(_controller);
    }

    void sendEvent(string event) {
        if (!_controller)
            return;

        _controller.onEvent(event);
    }

    private void onEnableController() {
        if (!_controller)
            return;

        _controller.onEnable();
    }

    private void onDisableController() {
        if (!_controller)
            return;

        _controller.onDisable();
    }

    private void onCollide(Entity target, Vec3f normal) {
        if (!_controller)
            return;

        _controller.onCollide(target, normal);
    }

    private void onSquish(Vec3f normal) {
        if (!_controller)
            return;

        _controller.onSquish(normal);
    }

    private void onImpact(Entity target, Vec3f normal) {
        if (!_controller)
            return;

        _controller.onImpact(target, normal);
    }
}
