/**
 * Malte Schwitters 2017, für das WPM Interaktive 3D-Graphik mit Processing
 * 
 * Camera that can be rotated with mouse (hold mouse button and drag) and zoomed with keyboard 
 * or mouse scroll. The camera is auto aimed at a target. Check settings class for keyboard binding.
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
            _verticalRotation = _verticalRotation % 3.14;
            if (_verticalRotation <= -1.57) {
                _up.z = 1;
            } else if (_verticalRotation >= 1.57) {
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
