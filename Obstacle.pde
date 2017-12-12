/**
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * Part of the level
 */
public class Obstacle extends RenderableObject {

    private Animation _anim = new ObstacleAnimation();
    private Animation _animSlide1 = new ObstacleSlideInAnimation();
    private Animation _animSlide2 = new ObstacleSlideInAnimation();
    private Animation _animSlide3 = new ObstacleSlideInAnimation();

    private Quad _pointTrigger = new Quad("trigger");
    private Quad _obstacle1 = new Quad("obstacle");
    private Quad _obstacle2 = new Quad("obstacle");
    private Quad _obstacle3 = new Quad("obstacle");
    private float _animationStartTime;

    private float _mainAnimTime = 5;
    private float _slideInAnimTime = 1.5;

    public Obstacle(float animationStartTime) {
        _animationStartTime = animationStartTime;

        _pointTrigger.setTranslation(0, 0, -50);
        _pointTrigger.setSize(new PVector(20, 20, 100));
        _pointTrigger.getCollision().setKeyword(Collision.COLLISION_TRIGGER);
        _pointTrigger.setVisible(false);
        addChild(_pointTrigger);

        _obstacle1.setSize(new PVector(20, 20, 20));
        _obstacle1.getCollision().setKeyword(Collision.COLLISION_OBSTACLE);
        addChild(_obstacle1);

        _obstacle2.setSize(new PVector(20, 20, 20));
        _obstacle2.getCollision().setKeyword(Collision.COLLISION_OBSTACLE);
        addChild(_obstacle2);

        _obstacle3.setSize(new PVector(20, 20, 20));
        _obstacle3.getCollision().setKeyword(Collision.COLLISION_OBSTACLE);
        addChild(_obstacle3);

        clearObstacles();
    }

    @Override
    public void render(PGraphics g) {

        // start the animation when game is started, as the initial lag will undo the initial 
        // start time of the animation
        if (gameStarted && !_anim.isRunning()) {
            //_anim.play(this, _mainAnimTime, _mainAnimTime * _animationStartTime);
        } 

        if (!gameStarted) {
            clearObstacles();
        }
        g.strokeWeight(5);
        g.stroke(getColor().x, getColor().y, getColor().z  * 1.5);;
        super.render(g);
    }

    public void setColorInherit(PVector c) {
        // the houses in the back should be brighter
        super.setColorInherit(new PVector(c.x, c.y * 1., c.z));
    }

    public void syncAnimation() {
        _anim.cancel();
        _anim.play(this, _mainAnimTime, _mainAnimTime * _animationStartTime);
    }

    public void clearObstacles() {
        _obstacle1.setEnabled(false);
        _obstacle2.setEnabled(false);
        _obstacle3.setEnabled(false);
        _animSlide1.cancel();
        _animSlide2.cancel();
        _animSlide3.cancel();
        _pointTrigger.setEnabled(false);
    } 

    public void randomizeObstacles() {
        
        clearObstacles();
        _pointTrigger.setEnabled(true);
        float type = random(7);
        if (type <= 1) {
            // 3 obstacles on the ground
            _obstacle1.setTranslation(new PVector(0, -30, -90));
            _obstacle2.setTranslation(new PVector(0, 0, -90));
            _obstacle3.setTranslation(new PVector(0, 30, -90));
            _animSlide1.play(_obstacle1, _slideInAnimTime);
            _animSlide2.play(_obstacle2, _slideInAnimTime, 0.05);
            _animSlide3.play(_obstacle3, _slideInAnimTime, 0.1);
        } else if (type <= 2) {
            // two obstacles on the ground
            _obstacle1.setTranslation(new PVector(0, -15, -90));
            _obstacle2.setTranslation(new PVector(0, 15, -90));
            _animSlide1.play(_obstacle1, _slideInAnimTime);
            _animSlide2.play(_obstacle2, _slideInAnimTime, 0.05);
        } else if (type <= 2.5) {
            // one obstacle on the ground
            _obstacle1.setTranslation(new PVector(0, 0, -90));
            _animSlide1.play(_obstacle1, _slideInAnimTime);
        } else if (type <= 3.8) {
            // one obstacle in the middle
            _obstacle1.setTranslation(new PVector(0, 0, -90));
            _obstacle2.setTranslation(new PVector(0, 0, -60));
            _animSlide1.play(_obstacle1, _slideInAnimTime, 0.05);
            _animSlide2.play(_obstacle2, _slideInAnimTime);
        } else if (type <= 5) {
            // two obstacles in the middle
            _obstacle1.setTranslation(new PVector(0, -15, -70));
            _obstacle2.setTranslation(new PVector(0, 15, -70));
            _animSlide1.play(_obstacle1, _slideInAnimTime);
            _animSlide2.play(_obstacle2, _slideInAnimTime, 0.05);
        } else if (type <= 6) {
            // one obstacle on top
            _obstacle1.setTranslation(new PVector(0, -15, -20));
            _animSlide1.play(_obstacle1, _slideInAnimTime);
        } else {
             // two obstacles on the ground
            _obstacle1.setTranslation(new PVector(0, -15, -90));
            _obstacle2.setTranslation(new PVector(0, 15, -90));
            _obstacle3.setTranslation(new PVector(0, 0, -60));
            _animSlide1.play(_obstacle1, _slideInAnimTime);
            _animSlide2.play(_obstacle2, _slideInAnimTime, 0.05);
            _animSlide3.play(_obstacle3, _slideInAnimTime, 0.1);
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

    private class ObstacleSlideInAnimation extends Animation {
        
        @Override
        public void onAnimationStarted(RenderableObject target) {
            target.setEnabled(true);
            target.setHasCollision(false);
        }

        @Override
        public PVector animateTranslation(PVector translation, float t) {
            //-90 -> -20 -> -90
            translation.x = 500 * (1 - t);
            //translation.z = -95 + 250 * (1 - t);
            return translation;
        }

        @Override
        public void onAnimationFinished(RenderableObject target) {
            target.setHasCollision(true);
        }
    }

    private class ObstacleAnimation extends Animation {

        private float _yMin = -450;
        private float _yMax = 450;

        @Override
        public PVector animateTranslation(PVector translation, float t) {
            translation.y = _yMin + (_yMax - _yMin) * t;
            return translation;
        }

        @Override
        public void onAnimationFinished(RenderableObject target) {
            if (gameStarted) {
                randomizeObstacles();
                restart();
            }
        }
    }

}
