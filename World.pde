/**
 * Malte Schwitters 2017, für das WPM Interaktive 3D-Graphik mit Processing
 * 
 * Root object of the rendered 3D world. World rotation of all renderable objects is relative to this 
 * object.
 */
public class World extends RenderableObject {

    private List<PVector> _colors = new ArrayList<PVector>();
    private int _currentColorIndex = 0;
    private float _colorChangeAlpha = 0;
    private float _colorChangeRate = 0.005;
    private Actor _actor = new Actor();
    private PMatrix3D worldTransformation; 

    public World () {
        camera.setTarget(this);
        addChild(new LineRunnerChunk(0));
        addChild(new LineRunnerChunk(1));
        addChild(new LineRunnerChunk(2));
        addChild(new LineRunnerChunk(3));
        addChild(_actor);
        _actor.setTranslation(new PVector(0, 75, -90.00));

        _colors.add(new PVector(25, 188, 157)); // tuerkis
        _colors.add(new PVector(39, 174, 97)); // gruen
        _colors.add(new PVector(41, 127, 184)); // blau
        _colors.add(new PVector(154, 89, 181)); // lila
        _colors.add(new PVector(241, 197, 14)); // gelb
        _colors.add(new PVector(231, 126, 34)); // orange
        _colors.add(new PVector(232, 76, 61)); // rot
    }

    @Override
    public void render(PGraphics g) {
        // save world transformation matrix, used to undo camera transform in world 
        // transform calculation
        worldTransformation = (PMatrix3D) g.getMatrix();

        // lighting
        g.noStroke();
        g.lights();
        g.directionalLight(150, 150, 150, -1, -1, -1);

        // Color change over time
        PVector c = _colors.get(_currentColorIndex).copy();
        c.lerp(_colors.get(getNextColor()), _colorChangeAlpha);
        _colorChangeAlpha += _colorChangeRate;
        if (_colorChangeAlpha >= 1) {
            _currentColorIndex = getNextColor();
            _colorChangeAlpha = 0;
        }
        for (RenderableObject child : getChildren()) {
            child.setColorInherit(c);
        }

        // change background over time
        if (settings.renderCollision) {
            // for easier debugging
            g.background(50);
        } else {
            g.background(c.x - 60, c.y - 60, c.z - 60);
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

    private int getNextColor() {
        if (_currentColorIndex + 1 >= _colors.size()) {
            return 0;
        }
        return _currentColorIndex + 1;
    }

}
