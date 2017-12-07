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
    private Quad _obstacle7 = new Quad("obstacle");
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

        _obstacle4.setTranslation(new PVector(0, -15, -70));
        _obstacle4.setSize(new PVector(20, 20, 20));
        _obstacle4.getCollision().setKeyword(Collision.COLLISION_OBSTACLE);
        addChild(_obstacle4);
        
        _obstacle5.setTranslation(new PVector(0, 15, -70));
        _obstacle5.setSize(new PVector(20, 20, 20));
        _obstacle5.getCollision().setKeyword(Collision.COLLISION_OBSTACLE);
        addChild(_obstacle5);

        _obstacle6.setTranslation(new PVector(0, 0, -20));
        _obstacle6.setSize(new PVector(20, 20, 20));
        _obstacle6.getCollision().setKeyword(Collision.COLLISION_OBSTACLE);
        addChild(_obstacle6);

        _obstacle7.setTranslation(new PVector(0, 0, -55));
        _obstacle7.setSize(new PVector(20, 20, 20));
        _obstacle7.getCollision().setKeyword(Collision.COLLISION_OBSTACLE);
        addChild(_obstacle7);

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
        _obstacle7.setEnabled(false);
        _pointTrigger.setEnabled(false);
    } 

    public void randomizeObstacles() {
        clearObstacles();
        _pointTrigger.setEnabled(true);
        float type = random(10);
        if (type <= 1) {
            _obstacle1.setEnabled(true);
            _obstacle2.setEnabled(true);
            _obstacle3.setEnabled(true);
        } else if (type <= 2) {
            _obstacle2.setEnabled(true);
            _obstacle3.setEnabled(true);
        } else if (type <= 2.5) {
            _obstacle3.setEnabled(true);
        } else if (type <= 3.8) {
            _obstacle4.setEnabled(true);
        } else if (type <= 5) {
            _obstacle4.setEnabled(true);
            _obstacle5.setEnabled(true);
        } else if (type <= 6) {
            _obstacle6.setEnabled(true);
            new ObstacleRotationAnimation().play(_obstacle6, 2);
        } else {
            _obstacle7.setEnabled(true);
            new ObstacleUpDownAnimation().play(_obstacle7, 3, random(3));
        }
    }
    
    private class ObstacleRotationAnimation extends Animation {
        @Override
        public PVector animateRotation(PVector rotation, float t) {
            rotation.x = 360 * t;
            return rotation;
        }

        @Override
        public void onAnimationFinished(RenderableObject target) {
            if (target.isEnabled()) {
                restart();
            }
        }
    }

    private class ObstacleUpDownAnimation extends Animation {
        public float _targetTranslation = 0;

        public ObstacleUpDownAnimation() {
            _targetTranslation = (random(2) > 1) ? 50 : 90;
        }

        @Override
        public PVector animateTranslation(PVector translation, float t) {
            //-90 -> -20 -> -90
            translation.z = -90 + 90 * abs(t * 2 - 1);
            //translation.z = -95 + 250 * (1 - t);
            return translation;
        }

        @Override
        public void onAnimationFinished(RenderableObject target) {
            if (target.isEnabled()) {
                restart();
            }
        }
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
