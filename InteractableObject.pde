/** 
 * Malte Schwitters 2017, für das WPM Interaktive 3D-Graphik mit Processing
 * 
 * RenderableObject that also has mouse and keyboard input registered. Only needs to override needed functions
 * of MouseInteractable and KeyboardInteractable interfaces.
 */
public class InteractableObject extends RenderableObject implements MouseInteractable, KeyboardInteractable {

    private color cSelected = color(255, 0, 0);
    private color cDefault = color(255, 255, 255);
    private boolean _selected = false;

    public InteractableObject () {
        this("");
    }

    public InteractableObject (String id) {
        super(id);
        mouseHandler.registerForMouseInput(this);
        keyboardHandler.registerForKeyboardInput(this);
    }

    @Override
    public void render(PGraphics g) {
        if (_selected) {
            g.fill(cSelected);
            super.render(g);
            g.fill(cDefault);
        } else {
            super.render(g);
        }
    }

    @Override
    public boolean mousePressed(float x, float y) {
       // _selected = !_selected;
       return false;
    }

    @Override
    public boolean mouseReleased(float x, float y) {
        return false;
    }

    @Override
    public boolean mouseMoved(float x, float y) {
        return false;
    }

    @Override
    public boolean mouseScrolled(float direction) {
        return false;
    }

    @Override
    public boolean keyPressed(int keycode, boolean ctrl, boolean alt, boolean shift) {
        return false;
    }
    
    @Override
    public boolean keyReleased(int keycode, boolean ctrl, boolean alt, boolean shift) {
        return false;
    }
}