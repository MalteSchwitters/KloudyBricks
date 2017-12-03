// Malte Schwitters 2017, für das WPM Interaktive 3D-Graphik mit Processing

public class Actor extends InteractableObject {
    
    private float _jumpOffset = 0;
    private long _jumpStartTime = 0;
    private boolean _jumping = false;
    private boolean _jumpQued = false;

    private Quad _body = new Quad();

    public Actor() {     
        super("Actor");         
        buildGeometry();
    }

    private void buildGeometry() {
        _body.setSize(new PVector(20, 30, 30));
        addChild(_body);
    }

    @Override
    public void render(PGraphics g) {
        if (_jumping) {
            long dt = System.currentTimeMillis() - _jumpStartTime;
            PVector t = getTranslation().copy();
            t.z = calcJumpHeight(dt);
            setTranslation(t);
            setRotation(new PVector((dt/1200.0) * 180, 0, 0));
        } else {
            setRotation(new PVector(0, 0, 0));
        }
        super.render(g);
    }

    private void jump() {
        if (!_jumping) {
            _jumping = true;
            _jumpStartTime = System.currentTimeMillis();
            _jumpQued = false;
            if (_jumpOffset == 0) {
                _jumpOffset = getTranslation().z;
            }
        } else {
            _jumpQued = true;
        }
    }

    @Override
    public void onComponentBeginOverlap(RenderableObject component, RenderableObject other, String keyword) {
        super.onComponentBeginOverlap(component, other, keyword);
        if (keyword.equals(Collision.COLLISION_OBSTACLE)) {
            gameStarted = false;
            ui.onDead();
        }
    }

    @Override
    public void onComponentEndOverlap(RenderableObject component, RenderableObject other, String keyword) {
        super.onComponentEndOverlap(component, other, keyword);
    }

    @Override
    public boolean keyPressed(int keycode, boolean ctrl, boolean alt, boolean shift) {
        if (!gameStarted) {
            gameStarted = true;
            return true;
        }
        if (keycode == settings.keymapJump) {
            jump();
        }
        return false;
    }

    private float calcJumpHeight(long t) {
        float x = t/65.0;
        float result =  -sq(x - 9) + 81 + _jumpOffset;
        if (result > _jumpOffset) {
            return result;
        } 
        if (_jumpQued) {
            _jumpStartTime = System.currentTimeMillis();
            _jumpQued = false;
        } else {
            _jumping = false;
        }
        return _jumpOffset;
    }
}