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