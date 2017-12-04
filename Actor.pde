// Malte Schwitters 2017, für das WPM Interaktive 3D-Graphik mit Processing

public class Actor extends InteractableObject {
    
    private float _jumpOffset = 0;
    private long _jumpStartTime = 0;
    private boolean _jumping = false;
    private boolean _jumpQued = false;

    private PVector _startTranslation;
    private boolean _dead = false;
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
        if (_startTranslation != null && getTranslation().y != _startTranslation.y) {
            addTranslationY(-2);
        } else if (_dead) {
            animateDeath();
        } else if (_jumping) {
            animateJump();
        } else {
            setRotation(new PVector(0, 0, 0));
        }
        super.render(g);
    }

    private void jump() {
        if (getTranslation().y == _startTranslation.y) {
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
    }

    @Override
    public void onComponentBeginOverlap(RenderableObject component, RenderableObject other, String keyword) {
        super.onComponentBeginOverlap(component, other, keyword);
        if (keyword.equals(Collision.COLLISION_OBSTACLE)) {
            endGame();
        }
    }

    @Override
    public void onComponentEndOverlap(RenderableObject component, RenderableObject other, String keyword) {
        super.onComponentEndOverlap(component, other, keyword);
    }

    @Override
    public boolean keyPressed(int keycode, boolean ctrl, boolean alt, boolean shift) {
        if (!gameStarted) {
            startNewGame();
            return true;
        }
        if (keycode == settings.keymapJump) {
            jump();
        }
        return false;
    }

    private void startNewGame() {
        _dead = false;
        gameStarted = true;
        if (_startTranslation == null) {
            _startTranslation = getTranslation().copy();
        } else {
            PVector t = _startTranslation.copy();
            t.y += 300;
            setTranslation(t);
            setRotation(new PVector(0, 0, 0));
        }
    }

    private void endGame() {
        gameStarted = false;
        _dead = true;   
        _jumpStartTime = System.currentTimeMillis();
        _jumpOffset = getTranslation().z;
        ui.onDead();
    }

    private void animateJump() {
        float dt = (System.currentTimeMillis() - _jumpStartTime);
        PVector t = getTranslation().copy();
        t.z = Math.max(-sq(dt/64 - 9) + 81 + _startTranslation.z, _startTranslation.z);
        setTranslation(t);
        if (t.z == _startTranslation.z) {
            if (_jumpQued) {
                _jumpStartTime = System.currentTimeMillis();
                _jumpQued = false;
                setTranslation(_startTranslation.copy());
            } else {
                _jumping = false;
                setTranslation(_startTranslation.copy());
            }
        }
        setRotation(new PVector((dt/1200.0) * 180, 0, 0));
    }

    private void animateDeath() {
        long dt = (System.currentTimeMillis() - _jumpStartTime);
        PVector t = getTranslation().copy();
        t.z = -sq(dt/64 - 9) + 81 + _jumpOffset;
        t.x -= 1;
        setTranslation(t);
        addRotationY(-1);
    }
}