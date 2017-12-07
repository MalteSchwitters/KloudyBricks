/**
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * Main class
 */

import ddf.minim.*;
import java.util.List;
import java.util.LinkedList;
import java.awt.event.KeyEvent;
import java.io.*;
import java.awt.Color;

public MouseInputHandler mouseHandler = new MouseInputHandler();
public KeyboardInputHandler keyboardHandler = new KeyboardInputHandler();
public Settings settings = new Settings();
public Camera camera = new Camera();
public World world = new World();
public HUD ui = new HUD();

private AudioPlayer deathSound;
private AudioPlayer _soundtrack;

public boolean gameStarted = false;

private PGraphics worldGraphics;
private PGraphics uiGraphics;

private float fov = PI / 3.0;
private float ratio;
private float cameraNear;
private float cameraFar;
private int _nextObjectId;

@Override
public void setup() {
    size(1280, 768, P3D);
    frameRate(30);
    float cameraZ = (height / 2.0) / tan(fov / 2.0);
    ratio = (float) width / (float) height;
    cameraNear = cameraZ / 100.0;
    cameraFar = cameraZ * 10.0;

    worldGraphics = createGraphics(width, height, P3D);
    worldGraphics.colorMode(HSB, 360, 100, 100);
    uiGraphics = createGraphics(width, height, P2D);
    uiGraphics.smooth(8);

    // Source: https://opengameart.org/content/red-eclipse-sounds
    deathSound = new Minim(this).loadFile("death.mp3");
    // Source: https://opengameart.org/content/game-game
    _soundtrack = new Minim(this).loadFile("soundtrack.mp3");
    _soundtrack.play();
}

@Override
public void draw() {
    // loop soundtrack
    if (!_soundtrack.isPlaying()) {
        _soundtrack.rewind();
        _soundtrack.play();
    }

    worldGraphics.beginDraw();
    worldGraphics.perspective(fov, ratio, cameraNear, cameraFar);
    camera.render(worldGraphics);
    world.render(worldGraphics);
    worldGraphics.endDraw();
    image(worldGraphics, 0, 0);

    uiGraphics.beginDraw();   
    uiGraphics.background(0, 0, 0, 0);
    ui.render(uiGraphics);
    uiGraphics.endDraw();
    image(uiGraphics, 0, 0);
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