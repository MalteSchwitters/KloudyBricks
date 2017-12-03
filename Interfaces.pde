/**
 * Malte Schwitters 2017, für das WPM Interaktive 3D-Graphik mit Processing
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