public class Animation {

    private RenderableObject _target;
    private long _startTimeMillis;
    private float _duration ;
    private boolean _running = false;

    public void play(RenderableObject target, float duration) {
        if (duration <= 0) {
            println("Invalid animation duration. Must be > 0!");
            return;
        }
        if (_running) {
            println("Animation is alread running.");
            return;
        }
        _target = target;
        _target.addAnimation(this);
        _duration = duration * 1000;
        _startTimeMillis = System.currentTimeMillis();
        _running = true;
        onAnimationStarted(_target);
    }

    public void restart() {
        _running = true;
        _startTimeMillis = System.currentTimeMillis();
    }

    public void cancel() {
        _running = false;
        onAnimationFinished(_target);
    }

    public void tick() {
        if (_running) {
            float t = (System.currentTimeMillis() - _startTimeMillis) / _duration;
            if (t <= 1) {
                animate(_target, t);
                _target.setTranslation(animateTranslation(_target.getTranslation(), t));
                _target.setRotation(animateRotation(_target.getRotation(), t));
            } else {
                _running = false;
                onAnimationFinished(_target);
            }
        }
    }

    public void animate(RenderableObject target, float dt) {

    }

    public PVector animateTranslation(PVector translation, float dt) {
        return translation;
    }

    public PVector animateRotation(PVector rotation, float dt) {
        return rotation;
    }

    public void onAnimationStarted(RenderableObject target) {

    }

    public void onAnimationFinished(RenderableObject target) {
        
    }
}
