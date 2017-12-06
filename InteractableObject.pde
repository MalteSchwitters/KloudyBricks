/** 
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * RenderableObject that also has mouse and keyboard input registered. Only need to override used functions
 * of MouseInteractable and KeyboardInteractable interfaces.
 */
public class InteractableObject extends RenderableObject implements MouseInteractable, KeyboardInteractable {

    public InteractableObject () {
        this("");
    }

    public InteractableObject (String id) {
        super(id);
        mouseHandler.registerForMouseInput(this);
        keyboardHandler.registerForKeyboardInput(this);
    }

    @Override
    public boolean mousePressed(float x, float y) {
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