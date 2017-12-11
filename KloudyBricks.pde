/**
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * Main class
 */
import ddf.minim.*;
import java.awt.Color;
import java.awt.event.KeyEvent;
import java.util.List;
import java.util.LinkedList;
import java.io.*;

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

// graphics
private PGraphics worldGraphics;
private PGraphics uiGraphics;

// runtime data
public boolean gameStarted = false;
private int _nextObjectId;

@Override
public void setup() {
    //size(1600, 900, P3D);
    size(1280, 760, P3D);
    
    frameRate(30);

    // create graphics
    worldGraphics = createGraphics(width, height, P3D);
    worldGraphics.colorMode(HSB, 360, 100, 100);
    uiGraphics = createGraphics(width, height, P2D);
    uiGraphics.smooth(8);

    // load assets
    font = createFont("Bangers-Regular.ttf", 32);
    logo = loadImage("Logo.png");

    Minim m = new Minim(this);
    soundDeath = m.loadFile("death.mp3"); // Credits: https://opengameart.org/content/red-eclipse-sounds
    soundScore = m.loadFile("score.mp3"); // Credits: https://opengameart.org/content/completion-sound
    music = m.loadFile("soundtrack.mp3"); // Credits: Moritz Bergan
    music.loop();
}

@Override
public void draw() {
    long start = System.currentTimeMillis();

    worldGraphics.beginDraw();
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