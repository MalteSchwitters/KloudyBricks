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