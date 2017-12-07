/**
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * Part of the level
 */
public class Obstacle extends RenderableObject {

    private Animation _anim = new ObstacleAnimation();
    private Quad _pointTrigger = new Quad("trigger");
    private Quad _obstacle1 = new Quad("obstacle");
    private Quad _obstacle2 = new Quad("obstacle");
    private Quad _obstacle3 = new Quad("obstacle");
    private Quad _obstacle4 = new Quad("obstacle");
    private Quad _obstacle5 = new Quad("obstacle");
    private Quad _obstacle6 = new Quad("obstacle");
    private float _animationStartTime;

    public Obstacle(float animationStartTime) {
        _animationStartTime = animationStartTime;

        _pointTrigger.setTranslation(0, 0, -50);
        _pointTrigger.setSize(new PVector(20, 20, 100));
        _pointTrigger.getCollision().setKeyword(Collision.COLLISION_TRIGGER);
        _pointTrigger.setVisible(false);
        addChild(_pointTrigger);

        _obstacle1.setTranslation(new PVector(0, -30, -90));
        _obstacle1.setSize(new PVector(20, 20, 20));
        _obstacle1.getCollision().setKeyword(Collision.COLLISION_OBSTACLE);
        addChild(_obstacle1);

        _obstacle2.setTranslation(new PVector(0, 0, -90));
        _obstacle2.setSize(new PVector(20, 20, 20));
        _obstacle2.getCollision().setKeyword(Collision.COLLISION_OBSTACLE);
        addChild(_obstacle2);

        _obstacle3.setTranslation(new PVector(0, 30, -90));
        _obstacle3.setSize(new PVector(20, 20, 20));
        _obstacle3.getCollision().setKeyword(Collision.COLLISION_OBSTACLE);
        addChild(_obstacle3);

        _obstacle4.setTranslation(new PVector(0, -15, -60));
        _obstacle4.setSize(new PVector(20, 20, 20));
        _obstacle4.getCollision().setKeyword(Collision.COLLISION_OBSTACLE);
        addChild(_obstacle4);
        
        _obstacle5.setTranslation(new PVector(0, 15, -60));
        _obstacle5.setSize(new PVector(20, 20, 20));
        _obstacle5.getCollision().setKeyword(Collision.COLLISION_OBSTACLE);
        addChild(_obstacle5);

        _obstacle6.setTranslation(new PVector(0, 0, -10));
        _obstacle6.setSize(new PVector(20, 20, 20));
        _obstacle6.getCollision().setKeyword(Collision.COLLISION_OBSTACLE);
        addChild(_obstacle6);

        clearObstacles();
    }

    public void render(PGraphics g) {

        // start the animation when game is started, as the initial lag will undo the initial 
        // start time of the animation
        if (gameStarted && !_anim.isRunning()) {
            _anim.play(this, 6, 6 * _animationStartTime);
        } 

        if (!gameStarted) {
            clearObstacles();
        }
        super.render(g);
    }

    public void clearObstacles() {
        _obstacle1.setEnabled(false);
        _obstacle2.setEnabled(false);
        _obstacle3.setEnabled(false);
        _obstacle4.setEnabled(false);
        _obstacle5.setEnabled(false);
        _obstacle6.setEnabled(false);
        _pointTrigger.setEnabled(false);
    } 

    public void randomizeObstacles() {
        clearObstacles();
        _pointTrigger.setEnabled(true);
        float type = random(6);
        if (type <= 1) {
            _obstacle1.setEnabled(true);
            _obstacle2.setEnabled(true);
            _obstacle3.setEnabled(true);
        } else if (type <= 2) {
            _obstacle2.setEnabled(true);
            _obstacle3.setEnabled(true);
        } else if (type <= 3) {
            _obstacle3.setEnabled(true);
        } else if (type <= 4) {
            _obstacle4.setEnabled(true);
        } else if (type <= 5) {
            _obstacle4.setEnabled(true);
            _obstacle5.setEnabled(true);
        } else {
            _obstacle6.setEnabled(true);
        }
    }

    private long getPlayTime() {
        return System.currentTimeMillis() - startTime;
    }

    private class ObstacleAnimation extends Animation {

        private float _yMin = -500;
        private float _yMax = 500;

        @Override
        public PVector animateTranslation(PVector translation, float t) {
            translation.y = _yMin + (_yMax - _yMin) * t;
            return translation;
        }

        @Override
        public void onAnimationFinished(RenderableObject target) {
            if (gameStarted) {
                randomizeObstacles();
            }
            restart();
        }
    }

}
