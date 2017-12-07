/**
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * Root object of the rendered 3D world. World rotation of all renderable objects is relative to this 
 * object.
 */
public class World extends RenderableObject {

    private PMatrix3D worldTransformation; 

    private Animation _animColors = new ColorChangeAnimation();

    private Actor _actor = new Actor();
    private Quad _ground = new Quad();
    private Background _background = new Background();
    private RenderableObject _cameraTarget = new RenderableObject();

    public World () {
        addChild(_cameraTarget);
        camera.setTarget(_cameraTarget);
        
        // create obstacles
        for (int i = 0; i < 4; i++) {
            addChild(new Obstacle(1 - i / 4f));
        }

        // init ground
        _ground.setSize(new PVector(20, 1000, 100));
        _ground.setTranslation(new PVector(0, 0, -150));
        _ground.getCollision().setKeyword(Collision.COLLISION_FLOOR);
        addChild(_ground);
        
        // init actor
        _actor.setTranslation(new PVector(0, 100, -85.00));
        addChild(_actor);

        addChild(_background);

        _animColors.play(this, 10);
    }

    @Override
    public void render(PGraphics g) {
        // save world transformation matrix, used to undo camera transform in world 
        // transform calculation
        worldTransformation = (PMatrix3D) g.getMatrix();

        // lighting
        g.noStroke();
        g.lights();
        g.directionalLight(150, 150, 150, 1, 1, -1);

        // change background over time
        if (settings.renderCollision) {
            // for easier debugging
            g.background(50);
        } else {
            g.background(getColor().x + 80, getColor().y + 80, getColor().z + 80);
        }

        // poor performance
        // g.hint(ENABLE_DEPTH_SORT);
        super.render(g);

        // check collisions
        for (RenderableObject child : getChildren()) {
            _actor.checkCollision(child);
            if (settings.renderCollision) {
                child.getCollision().render(g);
            }
        }
    }

    private class ColorChangeAnimation extends Animation {

        private List<PVector> _colors = new ArrayList<PVector>();
        private int _currentColorIndex = 0;
        
        public ColorChangeAnimation() {
            // init colors
            //_colors.add(new PVector(25, 188, 157)); // tuerkis
            _colors.add(new PVector(231, 126, 34)); // orange
            _colors.add(new PVector(232, 76, 61)); // rot
            _colors.add(new PVector(41, 127, 184)); // blau
            //_colors.add(new PVector(154, 89, 181)); // lila
            //_colors.add(new PVector(241, 197, 14)); // gelb
            _colors.add(new PVector(39, 174, 97)); // gruen
        }

        @Override
        public void animate(RenderableObject target, float t) {
            PVector c = _colors.get(_currentColorIndex).copy();
            c.lerp(_colors.get(getNextColor()), t);
            target.setColorInherit(c);
        }

        @Override
        public void onAnimationFinished(RenderableObject target) {
            _currentColorIndex = getNextColor();
            restart();
        }

        private int getNextColor() {
            if (_currentColorIndex + 1 >= _colors.size()) {
                return 0;
            }
            return _currentColorIndex + 1;
        }
    }
}
