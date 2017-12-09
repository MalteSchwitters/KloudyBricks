/**
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * Animated background of the level.
 */
public class Background extends RenderableObject {

    public final PVector houseMinSize = new PVector(50, 50, 400);
    public final PVector houseMaxSize = new PVector(80, 80, 500);
    public final int housesPerLevel = 10;

    private RenderableObject _level1 = new RenderableObject("Background L1");
    private RenderableObject _level2 = new RenderableObject("Background L2");
    private RenderableObject _level3 = new RenderableObject("Background L3");
    
    public Background() {
        super("background");
        setHasCollision(false);
        addChild(generateHouses(_level1, new PVector(-150, 0, -350), 10));
        addChild(generateHouses(_level2, new PVector(-250, 0, -275), 15));
        addChild(generateHouses(_level3, new PVector(-350, 0, -200), 25));
    }

    private RenderableObject generateHouses(RenderableObject level, PVector translation, int houseCount) {
        float animTime = 1.3 * houseCount;
        level.setHasCollision(false);
        level.setTranslation(translation);
        for (int i = 1; i <= houseCount; i++) {
            Quad house = new Quad();
            house.setHasCollision(false);
            house.setSize(houseMinSize.copy().lerp(houseMaxSize, random(1)));
            level.addChild(house);
            
            float bounds = 300 + houseCount * 20;
            Animation animation = new BackgroundAnimation(-bounds, bounds);
            float start = animTime * ((i - 1) / (float) (houseCount)) - animTime / houseCount;
            animation.play(house, animTime, start); 
        }
        return level;
    }

    @Override
    public void render(PGraphics g) {
        g.strokeWeight(1);
        g.stroke(0, 0, 10, 5);
        _level3.render(g);
        _level2.render(g);
        _level1.render(g);
    }

    @Override
    public void setColorInherit(PVector c) {
        // the houses in the back should be brighter
        _level1.setColorInherit(new PVector(c.x, c.y * 0.7, c.z));
        _level2.setColorInherit(new PVector(c.x, c.y * 0.5, c.z));
        _level3.setColorInherit(new PVector(c.x, c.y * 0.4, c.z));
    }

    private class BackgroundAnimation extends Animation {
        
        private float _yMin;
        private float _yMax;
        private float _myOffset;

        public BackgroundAnimation(float min, float max) {
            _yMin = min;
            _yMax = max;
        }

        @Override
        public void onAnimationStarted(RenderableObject target) {
            _myOffset = random(40) - 20;
            target.setTranslation(random(20), _yMin + _myOffset, random(100));
            target.setRotation_deg(0, 0, random(30) - 15);
        }

        @Override
        public PVector animateTranslation(PVector translation, float t) {
            translation.y = _yMin + (_yMax - _yMin) * t + _myOffset;
            return translation;
        }

        @Override
        public void onAnimationFinished(RenderableObject target) {
            restart();
        }
    }
}