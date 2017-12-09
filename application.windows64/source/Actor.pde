/**
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * User controlled actor with jump and die animation
 */
public class Actor extends Quad implements KeyboardInteractable {
    
    private PVector _startTranslation;
    private boolean _jumpQued = false;

    private Animation _animJump = new JumpAnimation();
    private Animation _animStart = new StartAnimation();
    private Animation _animDeath = new DeathAnimation();

    public Actor() {     
        super("Actor");   
        keyboardHandler.registerForKeyboardInput(this);      
        setSize(new PVector(20, 30, 30));
    }

    @Override
    public void onComponentBeginOverlap(RenderableObject component, RenderableObject other, String keyword) {
        super.onComponentBeginOverlap(component, other, keyword);
        if (keyword.equals(Collision.COLLISION_OBSTACLE)) {
            endGame();
        } else if (keyword.equals(Collision.COLLISION_TRIGGER)) {
            ui.incrementScore();
            if (!settings.muted) {
                soundScore.rewind();
                soundScore.play();
            }
        }
    }

    @Override
    public void onComponentEndOverlap(RenderableObject component, RenderableObject other, String keyword) {
        super.onComponentEndOverlap(component, other, keyword);
    }

    @Override
    public boolean keyPressed(int keycode, boolean ctrl, boolean alt, boolean shift) {
        if (keycode == settings.keymapJump) {
            if (gameStarted) {
                jump();
                return true;
            } else if (!_animDeath.isRunning()) {
                startNewGame();
                return true;
            }
        }
        return false;
    }

    @Override
    public boolean keyReleased(int keycode, boolean ctrl, boolean alt, boolean shift) {
        return false;
    }

    @Override
    public void setColorInherit(PVector col) {
        super.setColorInherit(new PVector(col.x, col.y, col.z));
    }

    private void startNewGame() {
        if (!_animDeath.isRunning()) {
            gameStarted = true;
            if (_startTranslation == null) {
                _startTranslation = getTranslation();
                ui.showHint("Avoid obstacles, press space to jump!");
            } else {
                _animStart.play(this, 1.5);
                float x = random(5);
                if (x <= 1) {
                    ui.showHint("May the Kloud be with you");
                } else if (x <= 2) {
                    ui.showHint("Go for it, Superbrick");
                } else if (x <= 3) {
                    ui.showHint("A brick does not give up so easily");
                } else if (x <= 4) {
                    ui.showHint("This time you will make it");
                } else {
                    ui.showHint("Don't wish it were easier, wish you were better");
                }
            }
        }
    }

    private void endGame() {
        gameStarted = false;
        _animDeath.play(this, 2);
        ui.hideAll();
        if (!settings.muted) {
            soundDeath.rewind();
            soundDeath.play();
        }
    }

    private void jump() {
        if (!_animStart.isRunning() && !_animDeath.isRunning()) {
            if (_animJump.isRunning()) {
                _jumpQued = true;
            } else {
                _animJump.play(this, 1.025);
            }
        }
    }

    /**
     * Animation to play when jumping. 
     */
    private class JumpAnimation extends Animation {
        @Override
        public PVector animateTranslation(PVector translation, float t) {
            float z = -sq(t*18 - 9) + 81;
            translation.z = z + _startTranslation.z;
            camera.getTarget().setTranslation(new PVector(0, 0, z / 8));            
            return translation;
        }

        @Override
        public PVector animateRotation(PVector rotation, float t) {
            rotation.x = 180 * t;
            return rotation;
        }

        @Override
        public void onAnimationFinished(RenderableObject target) {
            target.setTranslation(_startTranslation.copy());
            target.setRotation(new PVector(0, 0, 0));
            if (_jumpQued) {
                _jumpQued = false;
                restart();
            }
        }
    }

    /**
     * Animation to play when starting a new game after death.
     */
    private class StartAnimation extends Animation {
        private PVector _cameraStartTranslation;

        @Override
        public void onAnimationStarted(RenderableObject target) {
            _cameraStartTranslation = camera.getTarget().getTranslation();
            _animDeath.cancel();
            PVector t = _startTranslation.copy();
            t.y += 300;
            target.setTranslation(t);
            target.setRotation(new PVector(0, 0, 0));
        }
        
        @Override
        public PVector animateTranslation(PVector translation, float t) {
            translation.y = _startTranslation.y + 300 * (1 - t);
            camera.getTarget().setTranslation(new PVector(0, 0, 0).lerp(_cameraStartTranslation, 1 - t));
            return translation;
        }

        @Override
        public void onAnimationFinished(RenderableObject target) {
            target.setTranslation(_startTranslation.copy());
            target.setRotation(new PVector(0, 0, 0));
        }
    }

    /**
     * Animation to play when hitting an object.
     */
    private class DeathAnimation extends Animation {
        
        // z translation when the animation starts
        private float _jumpOffset = 0;
        // translation of the camera target when animation starts
        private PVector _cameraStartTranslation;
        
        @Override
        public void onAnimationStarted(RenderableObject target) {
            _jumpOffset = target.getTranslation().z;
            _cameraStartTranslation = camera.getTarget().getTranslation();
            _jumpQued = false;
            _animJump.cancel();
        }

        @Override
        public PVector animateTranslation(PVector translation, float t) {
            translation.z = -sq(t*40 - 9) + 81 + _jumpOffset;
            translation.x -= 1;
            translation.y += 2;
            camera.getTarget().setTranslation(new PVector(0, 0, 30).lerp(_cameraStartTranslation, 1 - t));           
            return translation;
        }

        @Override
        public PVector animateRotation(PVector rotation, float t) {
            rotation.y = -720 * t;
            rotation.x = -360 * t;
            return rotation;
        }

        @Override
        public void onAnimationFinished(RenderableObject target) {
            ui.showHighScore();
        }
    }
}