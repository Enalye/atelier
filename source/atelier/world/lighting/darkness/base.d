module atelier.world.lighting.darkness.base;

interface Darkness {
    @property {
        float brightness() const;
        bool isAlive() const;
    }

    void update();
}
