/**
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * Animation class to animate a RenderableObject. This class provides functions to directly change the 
 * local translation and rotation of the target and a generic animate function, that can be overriten 
 * in an extending class. The animation will automatically be ticked in the render function of the 
 * RenderableObject before its transform is applied.
 * 
 * Usage:
 * Animation myAnim = new ImplementedAnimation();
 * myAnim.play(targetReference, 5);
 * 
 */
public class Animation {

    private RenderableObject _target;
    private long _startTimeMillis;
    private float _duration ;
    private boolean _running = false;

    /**
     * Play the animation on the target reference with a given duration. The animation will automatically be 
     * ticked in the render function of the target before transformation is applied. 
     */
    public void play(RenderableObject target, float duration) {
        play(target, duration, 0);
    }

    /**
     * Play the animation on the target reference with a given duration. The animation will automatically be 
     * ticked in the render function of the target before transformation is applied. Starts the animation
     * with an offset. This does not affect the restart function.
     */
    public void play(RenderableObject target, float duration, float start) {
        if (duration <= 0) {
            println("Invalid animation duration. Must be > 0!");
            return;
        }
        if (_running) {
            println("Animation " + getClass().getSimpleName() + " is alread running.");
            return;
        }
        _target = target;
        if (_target != null) {
            _target.addAnimation(this);
        }
        _duration = duration * 1000;
        _startTimeMillis = System.currentTimeMillis() - (long) (start * 1000);
        _running = true;
        onAnimationStarted(_target);
    }

    public void setTime(float time) {
        _startTimeMillis = System.currentTimeMillis() - (long) (time * 1000);
    }

    /**
     * Restarts the animation, if target was already specified once (using the play function). Does
     * nothing otherwise.
     */
    public void restart() {
        if (_duration > 0) {
            _running = true;
            _startTimeMillis = System.currentTimeMillis();
            onAnimationStarted(_target);
        }
    }

    /**
     * Stops the currently running animation and executes the onAnimationFinished() function if it was
     * runnning. Does nothing otherwise.
     */
    public void cancel() {
        if (isRunning()) {
            _running = false;
            onAnimationFinished(_target);
        }
    }

    /**
     * Returns if this animation is currently running.
     */
    public boolean isRunning() {
        return _running;
    }

    /**
     * Triggers update of the animation. animate, animateTranslation and animateRotation will be executed
     * in this function. Does nothing if the animation is not running. This function is intended to be 
     * called by the RenderableObject in the render function. 
     */
    public void tick() {
        if (isRunning()) {
            float t = (System.currentTimeMillis() - _startTimeMillis) / _duration;
            if (t <= 1) {
                animate(_target, t);
                if (_target != null) {
                    _target.setTranslation(animateTranslation(_target.getTranslation(), t));
                    _target.setRotation_deg(animateRotation(_target.getRotation_deg(), t));
                }
            } else {
                animate(_target, 1);
                if (_target != null) {
                    _target.setTranslation(animateTranslation(_target.getTranslation(), 1));
                    _target.setRotation_deg(animateRotation(_target.getRotation_deg(), 1));
                }
                _running = false;
                onAnimationFinished(_target);
            }
        }
    }

    /**
     * Generic animation.
     */
    public void animate(RenderableObject target, float dt) {

    }

    /**
     * Animate the local translation of the target. translation parameter is a copy of the targets
     * current local translation. 
     */
    public PVector animateTranslation(PVector translation, float dt) {
        return translation;
    }

    /**
     * Animate the local rotation of the target. rotation parameter is a copy of the targets
     * current local rotation. 
     */
    public PVector animateRotation(PVector rotation, float dt) {
        return rotation;
    }

    /**
     * Executed once when the animation is started by the play function.
     */
    public void onAnimationStarted(RenderableObject target) {

    }

    /**
     * Executed once when the animation has finished or was canceled.
     */
    public void onAnimationFinished(RenderableObject target) {
        
    }
}