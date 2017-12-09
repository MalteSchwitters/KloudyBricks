import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.*; 
import java.util.List; 
import java.util.LinkedList; 
import java.awt.event.KeyEvent; 
import java.io.*; 
import java.awt.Color; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class ProcessingLinerunner extends PApplet {

/**
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * Main class
 */








// game objects
public MouseInputHandler mouseHandler = new MouseInputHandler();
public KeyboardInputHandler keyboardHandler = new KeyboardInputHandler();
public Settings settings = new Settings();
public Camera camera = new Camera();
public World world = new World();
public HUD ui = new HUD();

// assets
public PFont font;
public PImage logo;
public AudioPlayer soundDeath;
public AudioPlayer soundScore;
public AudioPlayer music;
public AudioPlayer music2;

// graphics
private PGraphics worldGraphics;
private PGraphics uiGraphics;

// runtime data
public boolean gameStarted = false;
private float fov = PI / 3.0f;
private float ratio;
private float cameraNear;
private float cameraFar;
private int _nextObjectId;

@Override
public void setup() {
    //size(1600, 900, P3D);
    
    
    frameRate(30);
    float cameraZ = (height / 2.0f) / tan(fov / 2.0f);
    ratio = (float) width / (float) height;
    cameraNear = cameraZ / 100.0f;
    cameraFar = cameraZ * 10.0f;

    // create graphics
    worldGraphics = createGraphics(width, height, P3D);
    worldGraphics.colorMode(HSB, 360, 100, 100);
    uiGraphics = createGraphics(width, height, P2D);
    uiGraphics.smooth(8);

    // load assets
    // font = createFont("PressStart2P-Regular.ttf", 32);
    font = createFont("Bangers-Regular.ttf", 32);
    logo = loadImage("Logo.png");

    Minim m = new Minim(this);
    soundDeath = m.loadFile("death.mp3"); // Source: https://opengameart.org/content/red-eclipse-sounds
    soundScore = m.loadFile("score.mp3"); // Source: https://opengameart.org/content/completion-sound
    music2 = m.loadFile("soundtrack.mp3");
    music = m.loadFile("soundtrack1.mp3"); // Source: https://opengameart.org/content/game-game
    music.loop();
    music2.loop();
    music2.mute();
}

@Override
public void draw() {
    long start = System.currentTimeMillis();

    worldGraphics.beginDraw();
    //worldGraphics.perspective(fov, ratio, cameraNear, cameraFar);
    camera.render(worldGraphics);
    world.render(worldGraphics);
    worldGraphics.endDraw();
    image(worldGraphics, 0, 0);

    uiGraphics.beginDraw();   
    ui.render(uiGraphics);
    uiGraphics.endDraw();
    
    image(uiGraphics, 0, 0);

    long duration = System.currentTimeMillis() - start;
    if (duration > 30) {
        println("Warn: Draw took " + duration + " millis");
    }
}

@Override
public void mousePressed() {
    mouseHandler.mousePressed(mouseX, mouseY);
}

@Override
public void mouseReleased() {
    mouseHandler.mouseReleased(mouseX, mouseY);
}

@Override
public void mouseMoved() {
    mouseHandler.mouseMoved(mouseX, mouseY);
}

@Override
public void mouseDragged() {
    mouseHandler.mouseMoved(mouseX, mouseY);
}

@Override
public void mouseWheel(MouseEvent event) {
    mouseHandler.mouseScrolled(event.getCount());
}

@Override
public void keyPressed() {
    keyboardHandler.keyPressed(keyCode);
}

@Override
public void keyReleased() {
    keyboardHandler.keyReleased(keyCode);
}

public int getNextObjectId() {
    return _nextObjectId++;
}
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
                _animStart.play(this, 1.5f);
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
                _animJump.play(this, 1.025f);
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
/**
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * Animated background of the level.
 */
public class Background extends RenderableObject {

    public final PVector houseMinSize = new PVector(50, 50, 400);
    public final PVector houseMaxSize = new PVector(80, 80, 500);
    public final int housesPerLevel = 10;

    private RenderableObject _level1 = new RenderableObject("Background L1");
    private RenderableObject _level2 = new RenderableObject("Background L2");
    private RenderableObject _level3 = new RenderableObject("Background L3");
    
    public Background() {
        super("background");
        setHasCollision(false);
        addChild(generateHouses(_level1, new PVector(-150, 0, -350), 10));
        addChild(generateHouses(_level2, new PVector(-250, 0, -275), 15));
        addChild(generateHouses(_level3, new PVector(-350, 0, -200), 25));
    }

    private RenderableObject generateHouses(RenderableObject level, PVector translation, int houseCount) {
        float animTime = 1.3f * houseCount;
        level.setHasCollision(false);
        level.setTranslation(translation);
        for (int i = 1; i <= houseCount; i++) {
            Quad house = new Quad();
            house.setHasCollision(false);
            house.setSize(houseMinSize.copy().lerp(houseMaxSize, random(1)));
            level.addChild(house);
            
            float bounds = 300 + houseCount * 20;
            Animation animation = new BackgroundAnimation(-bounds, bounds);
            float start = animTime * ((i - 1) / (float) (houseCount)) - animTime / houseCount;
            animation.play(house, animTime, start); 
        }
        return level;
    }

    @Override
    public void render(PGraphics g) {
        g.strokeWeight(1);
        g.stroke(0, 0, 10, 5);
        _level3.render(g);
        _level2.render(g);
        _level1.render(g);
    }

    @Override
    public void setColorInherit(PVector c) {
        // the houses in the back should be brighter
        _level1.setColorInherit(new PVector(c.x, c.y * 0.7f, c.z));
        _level2.setColorInherit(new PVector(c.x, c.y * 0.5f, c.z));
        _level3.setColorInherit(new PVector(c.x, c.y * 0.4f, c.z));
    }

    private class BackgroundAnimation extends Animation {
        
        private float _yMin;
        private float _yMax;
        private float _myOffset;

        public BackgroundAnimation(float min, float max) {
            _yMin = min;
            _yMax = max;
        }

        @Override
        public void onAnimationStarted(RenderableObject target) {
            _myOffset = random(40) - 20;
            target.setTranslation(random(20), _yMin + _myOffset, random(100));
            target.setRotation_deg(0, 0, random(30) - 15);
        }

        @Override
        public PVector animateTranslation(PVector translation, float t) {
            translation.y = _yMin + (_yMax - _yMin) * t + _myOffset;
            return translation;
        }

        @Override
        public void onAnimationFinished(RenderableObject target) {
            restart();
        }
    }
}
/**
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * Camera that can be rotated with mouse (hold mouse button and drag) and zoomed with mouse 
 * scroll. The camera is auto aimed at a target.
 */
public class Camera implements Renderable, MouseInteractable {

    private RenderableObject _target;
    private PVector _up = new PVector(0, 0, -1);
    private float _horizontalRotation = radians(0);
    private float _verticalRotation = radians(0);
    private float _zoom = 250;

    private boolean _mouseDragging = false;
    private float _mouseX = 0;
    private float _mouseY = 0;

    public Camera () {
        mouseHandler.registerForMouseInput(this);
    }

    @Override
    public void render(PGraphics g) {
        g.pushMatrix();
        g.rotateZ(_horizontalRotation);
        g.rotateY(_verticalRotation);
        g.translate(_zoom, 0, 0);
        float x = g.modelX(0, 0, 0);
        float y = g.modelY(0, 0, 0);
        float z = g.modelZ(0, 0, 0);
        g.popMatrix();

        // doing this before popMatrix produces some really strange results
        PVector aim = (_target == null)? new PVector(0, 0, 0) : _target.getWorldTranslation();
        g.camera(x, y, z, aim.x, aim.y, aim.z, _up.x, _up.y, _up.z);

    }

    @Override
    public boolean mousePressed(float x, float y) {
        _mouseDragging = true;
        _mouseX = x;
        _mouseY = y;
        return false;
    }
    
    @Override
    public boolean mouseReleased(float x, float y) {
        _mouseDragging = false;
        _mouseX = 0;
        _mouseY = 0;
        return false;
    }

    @Override
    public boolean mouseMoved(float x, float y) {
        if (_mouseDragging) {
            _horizontalRotation += radians((_mouseX - x) * settings.cameraInputMultX);
            _verticalRotation += radians((_mouseY - y) * settings.cameraInputMultY);
            // Does not work 100%
            _verticalRotation = _verticalRotation % 3.14f;
            if (_verticalRotation <= -1.57f) {
                _up.z = 1;
            } else if (_verticalRotation >= 1.57f) {
                _up.z = 1;
            } else {
                _up.z = -1;
            }
            
            //println("vertical: " + _verticalRotation);
            _mouseX = x;
            _mouseY = y;
        }
        return false;
    }

    @Override
    public boolean mouseScrolled(float direction) {
        if (direction != 0) {
            _zoom += direction * settings.cameraInputMultZoom;
            if (_zoom < 0) {
                _zoom = 0;
            }
        }
        return false;
    }

    public RenderableObject getTarget() {
        return _target;
    }

    public void setTarget(RenderableObject target) {
        _target = target;
    }

    public float getZoom() {
        return _zoom;
    }

    public void setZoom(float zoom) {
        _zoom = zoom;
    }
}
/**
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * Collsion object, that handles bounding box and collision calculations for a RenderableObeject. Only works
 * for polygone objects, as the objects verticies are needed for bounding box calculation!
 */
public class Collision implements Renderable {

    // Collision type, used to check with what kind of object overlapped
    public static final String COLLISION_DEFAULT = "default";
    public static final String COLLISION_FLOOR = "floor";
    public static final String COLLISION_OBSTACLE = "obstacle";
    public static final String COLLISION_ACTOR = "actor";
    public static final String COLLISION_TRIGGER = "trigger";

    // currently detected cullisions, needed for the end overlap event
    private List<RenderableObject> _collidesWith = new ArrayList<RenderableObject>();
    
    // collision properties
    private RenderableObject _collisionFor;
    private PVector _boundingBoxTranslation = new PVector();
    private PVector _boundingBoxSize = new PVector();
    private PVector _extendedBoundingBoxTranslation = new PVector();
    private PVector _extendedBoundingBoxSize = new PVector();
    private String _keyword = COLLISION_DEFAULT;

    public Collision(RenderableObject target) {
        _collisionFor = target;
    }

    @Override
    public void render(PGraphics g) {
        // collision can be rendered for debugging using the specified keys in the settings
        PVector boxTranslation = _extendedBoundingBoxTranslation;// _boundingBoxTranslation;
        PVector boxSize = _extendedBoundingBoxSize;// _boundingBoxSize;

        // if the bounding box has no size, then we don't have a collision to render
        if (boxSize.mag() != 0) {
            g.pushMatrix();
            g.translate(boxTranslation.x, boxTranslation.y, boxTranslation.z);
            // move to the center of the collision, as box is rendered with centered translation
            g.translate(boxSize.x / 2, boxSize.y / 2, boxSize.z / 2);
            g.stroke(150, 0, 0);
            g.fill(150, 0, 0, 5);
            g.box(boxSize.x, boxSize.y, boxSize.z);
            g.popMatrix();
        }

        // render collision of child objects
        for (RenderableObject child : _collisionFor.getChildren()) {
            if (child.hasCollision() && child.isEnabled()) {
                child.getCollision().render(g);
            }
        }
    }

    /**
     * Calculates the bounding box of the collision. 
     */
    public void calculateBoundingBox(List<PVector> vertics) {
        _boundingBoxTranslation = new PVector(0, 0, 0);
        _boundingBoxSize = new PVector(0, 0, 0);
        if (_collisionFor.isEnabled() && vertics != null) {
            PVector boundingBoxMin = new PVector();
            PVector boundingBoxMax = new PVector();

            for (PVector vert : vertics) {
                PVector rotatedVert = unrotateVector(vert, _collisionFor.getWorldRotation());
                boundingBoxMin = minVector(boundingBoxMin, rotatedVert);
                boundingBoxMax = maxVector(boundingBoxMax, rotatedVert);
            }
            _boundingBoxSize = PVector.sub(boundingBoxMax, boundingBoxMin);
            _boundingBoxTranslation = PVector.add(boundingBoxMin, _collisionFor.getWorldTranslation());
            recalculateExtendedBoundingBox();
        }
        checkCurrentCollisions();
    }

    public void checkCurrentCollisions() {
        List<RenderableObject> temp = new ArrayList<RenderableObject>();
        for (RenderableObject obj : _collidesWith) {
            PVector aTranslation = _boundingBoxTranslation;
            PVector aSize = _boundingBoxSize;
            PVector bTranslation = obj.getCollision()._boundingBoxTranslation;
            PVector bSize = obj.getCollision()._boundingBoxSize;
            if (!checkCollision(aTranslation, aSize, bTranslation, bSize)) {
                temp.add(obj);
            }
        }
        _collidesWith.removeAll(temp);
    }

    public void setKeyword(String keyword) {
        _keyword = keyword;
    }

    private void beginOverlap(RenderableObject other) {
        if (!_collidesWith.contains(other)) {
            _collidesWith.add(other);
            other.getCollision()._collidesWith.add(_collisionFor);
            _collisionFor.onBeginOverlap(other, other.getCollision()._keyword);
            other.onBeginOverlap(_collisionFor, _keyword);
        }
    }

    private void endOverlap(RenderableObject other) {
        if (_collidesWith.contains(other)) {
            _collidesWith.remove(other);
            other.getCollision()._collidesWith.remove(_collisionFor);
            _collisionFor.onEndOverlap(other, other.getCollision()._keyword);
            other.onEndOverlap(_collisionFor, _keyword);
        }
    }

    private void extendBoundingBox(RenderableObject object) {        
        if (object == null || object.getCollision()._extendedBoundingBoxSize.mag() == 0) {
            // child has no collision
            return;
        }
        Collision collision = object.getCollision();
        if (_extendedBoundingBoxSize.mag() == 0) {
            _extendedBoundingBoxTranslation = collision._extendedBoundingBoxTranslation.copy();
            _extendedBoundingBoxSize = collision._extendedBoundingBoxSize.copy();
        } else {
            PVector aMin = _extendedBoundingBoxTranslation.copy();
            PVector bMin = collision._extendedBoundingBoxTranslation;
            PVector aMax = PVector.add(aMin, _extendedBoundingBoxSize);
            PVector bMax = PVector.add(bMin, collision._extendedBoundingBoxSize);
            _extendedBoundingBoxTranslation = minVector(aMin, bMin);
            _extendedBoundingBoxSize = maxVector(aMax, bMax).sub(_extendedBoundingBoxTranslation);
        }
    }

    private void recalculateExtendedBoundingBox() {
        _extendedBoundingBoxTranslation = _boundingBoxTranslation;
        _extendedBoundingBoxSize = _boundingBoxSize;
        for (RenderableObject child : _collisionFor.getChildren()) {
            //child.getCollision().recalculateExtendedBoundingBox();
            extendBoundingBox(child);
        }
        if (_collisionFor.getParent() != null) {
            _collisionFor.getParent().getCollision().recalculateExtendedBoundingBox();
        }
    }

    public boolean checkCollision(Collision other) {        
        if (other == this) {
            return false;
        }
        
        // First test extended bounding boxes of both collisions, If these don't overlap
        // then the two boxes are far enough from each other so that children don't overlap
        // as well.
        PVector aTranslation = _extendedBoundingBoxTranslation;
        PVector aSize = _extendedBoundingBoxSize;
        PVector bTranslation = other._extendedBoundingBoxTranslation;
        PVector bSize = other._extendedBoundingBoxSize;
        if (!checkCollision(aTranslation, aSize, bTranslation, bSize)) {
            // TODO children?
            endOverlap(other._collisionFor);
            return false;
        }

        // The extended bounding boxes overlap, we may have a collision. First check own collision
        boolean collides = false;
        aTranslation = _boundingBoxTranslation;
        aSize = _boundingBoxSize;
        bTranslation = other._boundingBoxTranslation;
        bSize = other._boundingBoxSize;
        if (checkCollision(aTranslation, aSize, bTranslation, bSize)) {
            beginOverlap(other._collisionFor);
            collides = true;
        } else {
            endOverlap(other._collisionFor);
        }

        // Check if children of other collide with self 
        for (RenderableObject child : other._collisionFor.getChildren()) {
            if (_collisionFor.checkCollision(child)) {
                collides = true;
            }
        }

        // Check if children collide with other
        for (RenderableObject child : _collisionFor.getChildren()) {
            if (child.checkCollision(other._collisionFor)) {
                collides = true;
            }
        }
        return collides;
    }

    public boolean checkCollision(PVector aTranslation, PVector aSize, PVector bTranslation, PVector bSize) {
        if (aTranslation.x > bTranslation.x + bSize.x) {
            return false;
        }
        if (aTranslation.y > bTranslation.y + bSize.y) {
            return false;
        }
        if (aTranslation.z > bTranslation.z + bSize.z) {
            return false;
        }
        if (bTranslation.x > aTranslation.x + aSize.x) {
            return false;
        }
        if (bTranslation.y > aTranslation.y + aSize.y) {
            return false;
        }
        if (bTranslation.z > aTranslation.z + aSize.z) {
            return false;
        }
        return true;
    }
}
/**
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * User interface, holds all UI components
 */
class HUD implements Renderable {

    private Animation _zoomAnim = new ZoomAnimation();
    private float _textPositionZ = 0;
    
    private boolean _hidden = false;
    private String _hint;
    private int _score = 0;
    private int _lastScore = 0;
    private int _highScore = 0;


    public HUD() {
        _highScore = loadHighScore();
    }

    @Override
    public void render(PGraphics g) {
        _zoomAnim.tick();
        textFont(font);
        textAlign(CENTER, CENTER);

        float centerW = width / 2;
        float centerH = height / 2;
        if (!_hidden) {
            if (gameStarted) {
                textSize(48);
                if (_score > 0) {
                    outlinedText(g, String.valueOf(_score), centerW, 100);
                } else {
                    textSize(32);
                    outlinedText(g, _hint, centerW, 100);
                }
            } else {

                image(logo, centerW - 320, centerH - 150);

                textSize(32);
                outlinedText(g, "Press [space] to start playing!", centerW, height - 200);
                
                if (_lastScore > 0) {
                    textSize(32);
                    outlinedText(g, "SCORE: " + _lastScore + "    HIGH SCORE: " + _highScore, centerW, 150);
                }
            }
        }
        if (settings.drawFps) {
            textAlign(LEFT, CENTER);
            textSize(24);
            outlinedText(g, (int) frameRate + " fps", 10, 32, 0);
        }
    }

    private void outlinedText(PGraphics g, String text, float x, float y, float z) {
        fill(10);
        float thinkness = 2;
        text(text, x - thinkness, y, z);
        text(text, x + thinkness, y, z);
        text(text, x, y - thinkness, z);
        text(text, x, y + thinkness, z);
        text(text, x - thinkness, y - thinkness, z);
        text(text, x + thinkness, y + thinkness, z);
        text(text, x + thinkness, y - thinkness, z);
        text(text, x - thinkness, y + thinkness, z);
        fill(240);
        text(text, x, y, z);
    }

    private void outlinedText(PGraphics g, String text, float x, float y) {
        outlinedText(g, text, x, y, _textPositionZ);
    }

    public void incrementScore() {
        _score++;
        _zoomAnim.play(null, 0.2f);
    }

    public void hideAll() {
        _hidden = true;
    }

    public void showHighScore() {
        _lastScore = _score;
        if (_score > _highScore) {
            _highScore = _score;
            saveHighScore(_highScore);
        }
        _score = 0;
        _hidden = false;
        // logo cannot be "zoomed"
        // _zoomAnim.play(null, 0.2);
    }

    public void showHint(String hint) {
        _hint = hint;
    }

    /**
     * Zooms in the text by animationg th z position
     */
    private class ZoomAnimation extends Animation {
    
        @Override
        public void animate(RenderableObject target, float t) {
            _textPositionZ = 50 * t;
        }
    }
}
/**
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * List of interfaces used in this project. These are all in one file to reduce overall file count.
 */
 
interface Renderable {
    public void render(PGraphics g);
}

interface MouseInteractable {
    public boolean mousePressed(float x, float y);
    public boolean mouseReleased(float x, float y);
    public boolean mouseMoved(float x, float y);
    public boolean mouseScrolled(float direction);
}

interface KeyboardInteractable {
    public boolean keyPressed(int keycode, boolean ctrl, boolean alt, boolean shift);
    public boolean keyReleased(int keycode, boolean ctrl, boolean alt, boolean shift);
}
/**
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * Keyboard input handler to register components for keyboard input. Last added component has highest 
 * prio in input order. If a component consumes the input, components with lower prio will NOT get 
 * input. 
 */
class KeyboardInputHandler {

    // general keyboard input, does not check for keyboard focus on ui components
    private List<KeyboardInteractable> _components = new LinkedList<KeyboardInteractable>();
    
    private boolean _ctrlDown = false;
    private boolean _altDown = false;
    private boolean _shiftDown = false;

    public void registerForKeyboardInput(KeyboardInteractable comp) {
        _components.add(0, comp);
    }

    public void keyPressed(int keycode) {
        // check modifier keys
        if (keycode == KeyEvent.VK_CONTROL) {
            _ctrlDown = true;
        } else if (keycode == KeyEvent.VK_ALT) {
            _altDown = true;
        } else if (keycode == KeyEvent.VK_SHIFT) {
            _shiftDown = true;
        }
        // pass on event
        for (KeyboardInteractable comp : _components) {
            if (comp.keyPressed(keycode, _ctrlDown, _altDown, _shiftDown)) {
                break;
            }
        }
    }

    public void keyReleased(int keycode) {
        // check modifier keys
        if (keycode == KeyEvent.VK_CONTROL) {
            _ctrlDown = false;
        } else if (keycode == KeyEvent.VK_ALT) {
            _altDown = false;
        } else if (keycode == KeyEvent.VK_SHIFT) {
            _shiftDown = false;
        }
        // pass on event
        for (KeyboardInteractable comp : _components) {
            if (comp.keyReleased(keycode, _ctrlDown, _altDown, _shiftDown)) {
                break;
            }
        }
    }
}
/**
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * Mouse input handler to register components for mouse input. Last added component has highest 
 * prio in input order. If a component consumes the input, components with lower prio will NOT get 
 * input.
 */
 public class MouseInputHandler {
    
    private List<MouseInteractable> _components = new LinkedList<MouseInteractable>();

    public void registerForMouseInput(MouseInteractable comp) {
        _components.add(0, comp);
    }

    public void mousePressed(float x, float y) {
        for (MouseInteractable comp : _components) {
            if (comp.mousePressed(x, y)) {
                break;
            }
        }
    }

    public void mouseReleased(float x, float y) {
        for (MouseInteractable comp : _components) {
            if (comp.mouseReleased(x, y)) {
                break;
            }
        }
    }

    public void mouseMoved(float x, float y) {
        for (MouseInteractable comp : _components) {
            if (comp.mouseMoved(x, y)) {
                break;
            }
        }
    }

    public void mouseScrolled(float direction) {
        for (MouseInteractable comp : _components) {
            if (comp.mouseScrolled(direction)) {
                break;
            }
        }
    }
}
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
    private float _slideInAnimTime = 1.5f;

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
            _anim.play(this, _mainAnimTime, _mainAnimTime * _animationStartTime);
        } 

        if (!gameStarted) {
            clearObstacles();
        }
        g.strokeWeight(5);
        g.stroke(getColor().x, getColor().y, getColor().z  * 1.5f);;
        super.render(g);
    }

    public void setColorInherit(PVector c) {
        // the houses in the back should be brighter
        super.setColorInherit(new PVector(c.x, c.y * 1.f, c.z));
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
            _animSlide2.play(_obstacle2, _slideInAnimTime, 0.05f);
            _animSlide3.play(_obstacle3, _slideInAnimTime, 0.1f);
        } else if (type <= 2) {
            // two obstacles on the ground
            _obstacle1.setTranslation(new PVector(0, -15, -90));
            _obstacle2.setTranslation(new PVector(0, 15, -90));
            _animSlide1.play(_obstacle1, _slideInAnimTime);
            _animSlide2.play(_obstacle2, _slideInAnimTime, 0.05f);
        } else if (type <= 2.5f) {
            // one obstacle on the ground
            _obstacle1.setTranslation(new PVector(0, 0, -90));
            _animSlide1.play(_obstacle1, _slideInAnimTime);
        } else if (type <= 3.8f) {
            // one obstacle in the middle
            _obstacle1.setTranslation(new PVector(0, 0, -90));
            _obstacle2.setTranslation(new PVector(0, 0, -60));
            _animSlide1.play(_obstacle1, _slideInAnimTime, 0.05f);
            _animSlide2.play(_obstacle2, _slideInAnimTime);
        } else if (type <= 5) {
            // two obstacles in the middle
            _obstacle1.setTranslation(new PVector(0, -15, -70));
            _obstacle2.setTranslation(new PVector(0, 15, -70));
            _animSlide1.play(_obstacle1, _slideInAnimTime);
            _animSlide2.play(_obstacle2, _slideInAnimTime, 0.05f);
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
            _animSlide2.play(_obstacle2, _slideInAnimTime, 0.05f);
            _animSlide3.play(_obstacle3, _slideInAnimTime, 0.1f);
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

        private float _yMin = -400;
        private float _yMax = 400;

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
/**
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * Simple renderable quad. Does not use Processing box(...) function, but verticies.
 */
public class Quad extends RenderableObject {

    private PVector _size = new PVector(0, 0, 0); 

    public Quad() {
    }

    public Quad(String id) {
        super(id);
    }

    @Override
    public List<PVector> loadGeometry() {
        objectType = QUADS;
        List<PVector> vertics = new ArrayList<PVector>();
        PVector min = PVector.mult(_size, -0.5f);
        PVector max = PVector.mult(_size, 0.5f);

        vertics.add(new PVector(min.x, max.y, max.z));
        vertics.add(new PVector(max.x, max.y, max.z));
        vertics.add(new PVector(max.x, min.y, max.z));
        vertics.add(new PVector(min.x, min.y, max.z));

        vertics.add(new PVector(max.x, max.y, max.z));
        vertics.add(new PVector(max.x, max.y, min.z));
        vertics.add(new PVector(max.x, min.y, min.z));
        vertics.add(new PVector(max.x, min.y, max.z));

        vertics.add(new PVector(max.x, max.y, min.z));
        vertics.add(new PVector(min.x, max.y, min.z));
        vertics.add(new PVector(min.x, min.y, min.z));
        vertics.add(new PVector(max.x, min.y, min.z));

        vertics.add(new PVector(min.x, max.y, min.z));
        vertics.add(new PVector(min.x, max.y, max.z));
        vertics.add(new PVector(min.x, min.y, max.z));
        vertics.add(new PVector(min.x, min.y, min.z));
        
        vertics.add(new PVector(min.x, max.y, min.z));
        vertics.add(new PVector(max.x, max.y, min.z));
        vertics.add(new PVector(max.x, max.y, max.z));
        vertics.add(new PVector(min.x, max.y, max.z));

        vertics.add(new PVector(min.x, min.y, min.z));
        vertics.add(new PVector(max.x, min.y, min.z));
        vertics.add(new PVector(max.x, min.y, max.z));
        vertics.add(new PVector(min.x, min.y, max.z));
        
        return vertics;
    }

    public PVector getSize() {
        return _size;
    }

    public void setSize(PVector size) {
        _size = size;
        clearGeometry();
    }
}
/**
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * Renderable object, that has a hirarchy of children, that inherit its parents transform. Also calculates
 * world rotation and translation and handles auto generated collision. Translation is applied before
 * rotation in z -> y -> x order.
 */
public class RenderableObject implements Renderable {

    // id for this component, used for debugging and equals
    protected String _id = ""; 

    // child/parent hirarchy
    private RenderableObject _parent;
    private List<RenderableObject> _children = new ArrayList<RenderableObject>();
    
    // list of animations for this object
    private List<Animation> _animations = new ArrayList<Animation>();

    // transform
    private PVector _localTranslation = new PVector();
    private PVector _localRotation = new PVector();
    private PVector _worldTranslation = new PVector();
    private boolean _worldTranslationDirty = true;
    private PVector _worldRotation = new PVector();

    // helper variable to recalculate the world transdorm in the render function if needed
    private boolean _worldTransformChanged = false;

    // 3d representation
    protected int objectType = TRIANGLES;
    private List<PVector> _vertics;
    private Collision _collision;
    private PVector _color = new PVector(255, 255, 255);

    // invisible objects still have collision
    private boolean _visible = true;
    // disabled object are invisible and don't have collision, also affects children
    private boolean _enabled = true;
    // objects without collision are still visible, also affects children
    private boolean _hasCollision = true;
    
    public RenderableObject() {
        _id = getClass().getSimpleName() + " " + getNextObjectId();
    }

    public RenderableObject(String id) {
        _id = id + " " + getNextObjectId();
    }

    @Override
    public void render(PGraphics g) {
        long startTime = System.currentTimeMillis();
        if (!_enabled) {
            // nothing to do here
            return;
        }

        // tick animation
        for (Animation anim : _animations) {
            anim.tick();
        }

        // apply transform
        g.pushMatrix();
        g.translate(getTranslation().x, getTranslation().y, getTranslation().z);
        if (getRotation().z != 0) {
            g.rotateZ(getRotation().z);
        }
        if (getRotation().y != 0) {
            g.rotateY(getRotation().y);
        }
        if (getRotation().x != 0) {
            g.rotateX(getRotation().x);
        }

        // only do this calculations, if transform changed flag was set
        if (_worldTransformChanged) {
            _worldTransformChanged = false;
            calculateWorldTransform(g);
        }

        // render own geometry
        if (settings.renderGeometry && _visible) {
            renderGeometry(g);
        }

        long renderTime = System.currentTimeMillis() - startTime;
        if (renderTime > 10) {
            System.currentTimeMillis();
            println("Warn: Rendering " + _id + " took " + renderTime + " millis.");
        }

        // render children
        for (RenderableObject child : getChildren()) {
            child.render(g);
        }

        // undo local transform
        g.popMatrix();
    }

    protected void renderGeometry(PGraphics g) {
        if (getVertics().isEmpty()) {
            return;
        }
        g.fill(_color.x, _color.y, _color.z);
        g.beginShape(objectType);
        for (PVector vert : getVertics()) {
            g.vertex(vert.x, vert.y, vert.z);
        }
        g.endShape();
    }

    private void calculateWorldTransform(PGraphics g) {
        // get the current transformation matrix and undo the camera transform
        // world translation and rotation are relative to camera!
        PMatrix3D m = (PMatrix3D) g.getMatrix().get();
        PMatrix3D cm = world.worldTransformation.get();
        cm.invert();
        m.preApply(cm);

        // Transformation matrix is 4x4 with m03, m13 and m23 beeing the translation
        // in x, y and z, rotation can be calculated using the algorithm for the 
        // rotation order used (in this case y -> x -> z)
        // 
        // see https://www.geometrictools.com/Documentation/EulerAngles.pdf for 
        // rotation algorithms for other orders
        //
        // [m00 m01 m02 m03]
        // [m10 m11 m12 m13]
        // [m20 m21 m22 m23]
        // [m30 m31 m32 m33]

        // get world translatipon from matrix
        _worldTranslation.x = m.m03;
        _worldTranslation.y = m.m13;
        _worldTranslation.z = m.m23;

        // get world rotation from matrix
        _worldRotation.y = asin(-m.m20);
        _worldRotation.z = atan2(m.m10, m.m00);
        _worldRotation.x = atan2(m.m21, m.m22);
        
        // recalculate own bounding box
        getCollision().calculateBoundingBox(getVertics());
        onBoundingBoxChanged();

        // set the world transform changed flag on all children
        for(RenderableObject child : getChildren()) {
            child._worldTransformChanged = true;
        }
    }

    private void onBoundingBoxChanged() {
        if (hasCollision()) {
            getCollision().recalculateExtendedBoundingBox();
            if (getParent() != null) {
                getParent().onBoundingBoxChanged();
            }
        }
    }

    /**
     * Returns the verticies for this object. Calls loadGeometry and updates collision 
     * if vertics is null (lazy init).
     */
    public List<PVector> getVertics() {
        if (_vertics == null) {
            _vertics = loadGeometry();
            getCollision().calculateBoundingBox(_vertics);
        }
        return _vertics;
    }

    /*
     * Override in extending class, to define what should be rendered
     */
    protected List<PVector> loadGeometry() {
        return new ArrayList<PVector>();
    }

    /*
     * Reset the geometry and collision. Use if your object vertics need to be recalculated.
     */
    protected void clearGeometry() {
        _vertics = null;
        getCollision().calculateBoundingBox(null);
    }

    /*
     * Returns the parent of this object, or null if it has no parent.
     */
    public RenderableObject getParent() {
        return _parent;
    }

    /**
     * Adds a child to this object hirarchy.
     */
    public void addChild(RenderableObject child) {
        if (child == this || child == null) {
            return;
        }
        if (child.getParent() != null) {
            child.getParent().removeChild(child);
        }
        child._parent = this;
        child._worldTransformChanged = true;
        getChildren().add(child);
        getCollision().recalculateExtendedBoundingBox();
    }

    /**
     * Removes a child from this objects hirarchy.
     */
    public void removeChild(RenderableObject child) {
        getChildren().remove(child);
        child._parent = null;
        child._worldTransformChanged = true;
    }

    /**
     * Returns current children. Do not add or remove children from this list! Use addChild and 
     * removeChild functions! 
     */
    public List<RenderableObject> getChildren() {
        return _children;
    }

    /**
     * Adds an animation to be ticked in this objects render function.
     */
    public void addAnimation(Animation a) {
        if (!_animations.contains(a)) {
            _animations.add(a);
        }
    }

    public Collision getCollision() {
        if (_collision == null) {
            _collision = new Collision(this);
        }
        return _collision;
    }

    public void setCollision(Collision collision) {
        _collision = collision;
    }

    /**
     * Check if this object collides with the other object.
     */
    public boolean checkCollision(RenderableObject other) {
        if (!isEnabled() || !other.isEnabled() || !hasCollision() || !other.hasCollision()) {
            return false;
        }
        return getCollision().checkCollision(other.getCollision());
    }

    /**
     * Called when this object collides with another object.
     */
    public void onBeginOverlap(RenderableObject other, String keyword) {
        onComponentBeginOverlap(this, other, keyword);
    }

    /**
     * Called when this object stops colliding with another object.
     */
    public void onEndOverlap(RenderableObject other, String keyword) {
        onComponentEndOverlap(this, other, keyword);
    }

    /**
     * Called when this object or one of its children collides with another object.
     */
    public void onComponentBeginOverlap(RenderableObject component, RenderableObject other, String keyword) {
        if (getParent() != null) {
            getParent().onComponentBeginOverlap(component, other, keyword);
        }
    }

    /**
     * Called when this object or one of its children stops colliding with another object.
     */
    public void onComponentEndOverlap(RenderableObject component, RenderableObject other, String keyword) {
        if (getParent() != null) {
            getParent().onComponentEndOverlap(component, other, keyword);
        }
    }

    public PVector getTranslation() {
        return _localTranslation.copy();
    }

    public PVector getWorldTranslation() {
        return _worldTranslation.copy();
    }

    public void setTranslation(float x, float y, float z) {
        setTranslation(new PVector(x, y, z));
    }

    public void setTranslation(PVector translation) {
        _localTranslation = translation;
        _worldTransformChanged = true;
    }

    public PVector getRotation_deg() {
        PVector rotation = new PVector();
        rotation.x = degrees(_localRotation.x);
        rotation.y = degrees(_localRotation.y);
        rotation.z = degrees(_localRotation.z);
        return rotation;
    }

    public PVector getRotation() {
        return _localRotation.copy();
    }

    public void setRotation_deg(float x, float y, float z) {
        setRotation_deg(new PVector(x, y, z));
    }

    public void setRotation_deg(PVector rotation) {
        // first transform to radians
        _localRotation.x = radians(rotation.x);
        _localRotation.y = radians(rotation.y);
        _localRotation.z = radians(rotation.z);
        _worldTransformChanged = true;
    }

    public void setRotation(PVector rotation) {
        _localRotation = rotation;
        _worldTransformChanged = true;
    }

    public PVector getWorldRotation() {
        return _worldRotation.copy();
    }

    public boolean isVisible() {
        return _visible;
    }

    public void setVisible(boolean visible) {
        _visible = visible;
    }

    public boolean isEnabled() {
        return _enabled;
    }

    public void setEnabled(boolean enabled) {
        _enabled = enabled;
        getCollision().calculateBoundingBox(getVertics());
    }

    public boolean hasCollision() {
        return _hasCollision;
    }

    public void setHasCollision(boolean collision) {
        _hasCollision = collision;
    }

    public PVector getColor() {
        return _color;
    }

    public void setColor(PVector col) {
        _color = col;
    }

    /**
     * Sets the color for this object and all its child objects recursively.
     */
    public void setColorInherit(PVector col) {
        _color = col;
        for (RenderableObject child : getChildren()) {
            child.setColorInherit(col);
        }
    }

    @Override
    public boolean equals(Object other) {
        if (other instanceof RenderableObject) {
            RenderableObject otherObj = (RenderableObject) other;
            return _id.equals(otherObj._id);
        }
        return false;
    }
}
/**
 * Malte Schwitters 2017, f\u00fcr das WPM Interaktive 3D-Graphik mit Processing
 * 
 * This class holds some settings for the project. All settings are public and can be accessed 
 * and changed directly. Also has keyboard input to change settings with hotkeys.
 */
class Settings implements KeyboardInteractable {

    // render settings
    public boolean renderCollision = false;
    public boolean renderGeometry = true;
    public boolean drawFps = false;
    public boolean muted = false;

    // input settings
    public float cameraInputMultX = 1;
    public float cameraInputMultY = -1;
    public float cameraInputMultZoom = 5;

    // key mapping
    
    public int keymapJump = KeyEvent.VK_SPACE;
    public int keymapDrawFps = KeyEvent.VK_F;
    public int keymapMute = KeyEvent.VK_M;
    public int keymapGeometryOnly = KeyEvent.VK_1;
    public int keymapCollisionOnly = KeyEvent.VK_2;
    public int keymapGeometryAndCollision = KeyEvent.VK_3;

    public Settings() {
        keyboardHandler.registerForKeyboardInput(this);
    }

    boolean temp;

    @Override
    public boolean keyPressed(int keycode, boolean ctrl, boolean alt, boolean shift) {
        if (keycode == keymapGeometryOnly) {
            renderCollision = false;
            renderGeometry = true;
        } else if (keycode == keymapCollisionOnly) {
            renderCollision = true;
            renderGeometry = false;
        } else if (keycode == keymapGeometryAndCollision) {
            renderCollision = true;
            renderGeometry = true;
        } else if (keycode == keymapDrawFps) {
            drawFps = !drawFps;
        } else if (keycode == keymapMute) {
            temp = !temp;
            if (temp) {
                music.mute();
                music2.unmute();
            } else {
                music.unmute();
                music2.mute();
            }
        }
        return false;
    }

    @Override
    public boolean keyReleased(int keycode, boolean ctrl, boolean alt, boolean shift) {
        return false;
    }
}
/**
 y* Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * Static utility functions for common operations like vector rotation. 
 */
public PVector unrotateVector(PVector translation, PVector rotation) {
    PVector rotatedTranslation = translation;
    rotatedTranslation = rotateVectorX(rotatedTranslation, -rotation.x);
    rotatedTranslation = rotateVectorY(rotatedTranslation, -rotation.y);
    rotatedTranslation = rotateVectorZ(rotatedTranslation, -rotation.z);
    return rotatedTranslation;
}

public PVector rotateVector(PVector translation, PVector rotation) {
    PVector rotatedTranslation = translation;
    rotatedTranslation = rotateVectorZ(rotatedTranslation, rotation.z);
    rotatedTranslation = rotateVectorY(rotatedTranslation, rotation.y);
    rotatedTranslation = rotateVectorX(rotatedTranslation, rotation.x);
    return rotatedTranslation;
}

public PVector rotateVectorX(PVector vec, float angle) {
    PVector rotatedTranslation = new PVector();
    float c = (float) Math.cos(angle);
    float s = (float) Math.sin(angle);
    rotatedTranslation.x = vec.x;
    rotatedTranslation.y = c * vec.y + -s * vec.z;
    rotatedTranslation.z = s * vec.y + c * vec.z;
    return rotatedTranslation;
}

public PVector rotateVectorY(PVector vec, float angle) {
    PVector rotatedTranslation = new PVector();
    float c = (float) Math.cos(angle);
    float s = (float) Math.sin(angle);
    rotatedTranslation.x = c * vec.x + s * vec.z;
    rotatedTranslation.y = vec.y;
    rotatedTranslation.z = -s * vec.x + c * vec.z;
    return rotatedTranslation;
}

public PVector rotateVectorZ(PVector vec, float angle) {
    PVector rotatedTranslation = new PVector();
    float c = (float) Math.cos(angle);
    float s = (float) Math.sin(angle);
    rotatedTranslation.x = c * vec.x + -s * vec.y;
    rotatedTranslation.y = s * vec.x + c * vec.y;
    rotatedTranslation.z = vec.z;
    return rotatedTranslation;
}

public PVector minVector(PVector a, PVector b) {
    PVector result = new PVector();
    result.x = Math.min(a.x, b.x);
    result.y = Math.min(a.y, b.y);
    result.z = Math.min(a.z, b.z);
    return result;
}

public PVector maxVector(PVector a, PVector b) {
    PVector result = new PVector();
    result.x = Math.max(a.x, b.x);
    result.y = Math.max(a.y, b.y);
    result.z = Math.max(a.z, b.z);
    return result;
}

/**
 * Saves the current highscore to highScore.txt. The file only saves the best highscore.
 */
public void saveHighScore(int highscore) {
    try {
        PrintWriter writer = new PrintWriter(new BufferedWriter(new FileWriter("highScore.txt")));
        writer.write(String.valueOf(highscore));
        writer.close();
    } catch (Exception e) {
        println("Cannot write highscore");
    }
}

/**
 * Reads the current highscore from highScore.txt.
 */
public int loadHighScore() {
    try {
        BufferedReader br = new BufferedReader(new FileReader("highScore.txt"));
        String text = br.readLine();
        br.close();
        if (text != null) {
            return Integer.valueOf(text);
        }
    }
    catch (Exception e) {
        println("Cannot read highscore");
    }
    return 0;
}
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
        setHasCollision(false);

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
        _actor.setTranslation(new PVector(0, 100, -85.00f));
        addChild(_actor);

        addChild(_background);

        _animColors.play(this, 10);
    }

    @Override
    public void render(PGraphics g) {
        // save world transformation matrix, used to undo camera transform in world 
        // transform calculation
        worldTransformation = (PMatrix3D) g.getMatrix();

        g.colorMode(HSB, 360, 100, 100);
        // lighting
        g.directionalLight(0, 0, 10, -1, 2, -5);
        g.ambientLight(0, 0, 100);
        g.background(getColor().x, getColor().y * 0.3f, getColor().z);
        
        if (gameStarted) {
            for (RenderableObject child : getChildren()) {
                _actor.checkCollision(child);
                if (settings.renderCollision) {
                    child.getCollision().render(g);
                }
            }
        }

        // poor performance
        // g.hint(ENABLE_DEPTH_SORT);
        super.render(g);
    }

    private class ColorChangeAnimation extends Animation {

        private List<PVector> _colors = new ArrayList<PVector>();
        private int _currentColorIndex = 0;
        
        public ColorChangeAnimation() {
            // init colors
            // rgb
            //_colors.add(new PVector(25, 188, 157)); // tuerkis
            _colors.add(new PVector(231, 126, 34)); // orange
            _colors.add(new PVector(232, 76, 61)); // rot
            _colors.add(new PVector(41, 127, 184)); // blau
            //_colors.add(new PVector(154, 89, 181)); // lila
            //_colors.add(new PVector(241, 197, 14)); // gelb
            _colors.add(new PVector(39, 174, 97)); // gruen
            
            // hsv
            //_colors.add(new PVector(28, 85, 91)); // orange
            //_colors.add(new PVector(5, 74, 91)); // rot
            //_colors.add(new PVector(204, 78, 72)); // blau
            //_colors.add(new PVector(146, 78, 68)); // gruen
        }

        @Override
        public void animate(RenderableObject target, float t) {
            PVector c = _colors.get(_currentColorIndex).copy();
            c.lerp(_colors.get(getNextColor()), t);
            float[] hsb = new float[3];
            hsb = Color.RGBtoHSB((int) c.x, (int) c.y, (int) c.z, hsb);
            target.setColorInherit(new PVector(hsb[0] * 360, hsb[1] * 100, hsb[2] * 100));
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
  public void settings() {  size(1280, 760, P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--hide-stop", "ProcessingLinerunner" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
