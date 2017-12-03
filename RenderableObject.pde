/**
 * Malte Schwitters 2017, für das WPM Interaktive 3D-Graphik mit Processing
 * 
 * Renderable object, that has a hirarchy of children, that inherit its parents transform. Also calculates
 * world rotation and translation and handles auto generated collision. Translation is applied before
 * rotation in y -> x -> z order (hpb).
 */
public class RenderableObject implements Renderable {

    // name for this component, used for debugging
    protected String _id = ""; 
    private RenderableObject _parent;
    private List<RenderableObject> _children = new ArrayList<RenderableObject>();
    
    private PVector _localTranslation = new PVector();
    private PVector _localRotation = new PVector();
    private PVector _worldTranslation = new PVector();
    private boolean _worldTranslationDirty = true;
    private PVector _worldRotation = new PVector();
    // set this variable to true to recalculate the world transdorm in the render function
    private boolean _worldTransformChanged = false;

    protected int objectType = TRIANGLES;
    private List<PVector> _vertics;
    private Collision _collision;

    // invisible objects still have collision
    private boolean _visible = true;
    // disabled object are invisible and don't have collision
    private boolean _enabled = true;
    private PVector _color = new PVector(255, 255, 255);
    

    public RenderableObject() {
        _id = getClass().getSimpleName() + " " + getNextObjectId();
    }

    public RenderableObject(String id) {
        _id = id;
    }

    @Override
    public void render(PGraphics g) {
        if (!_enabled) {
            return;
        }

        g.pushMatrix();
        // local translation needs to be rotated first, because the local rotation is applied after 
        // the local translation in the render function
        g.translate(getTranslation().x, getTranslation().y, getTranslation().z);
        g.rotateZ(getRotation().z);
        g.rotateY(getRotation().y);
        g.rotateX(getRotation().x);
        
        // only do this calculations, if transform changed flag is set
        if (_worldTransformChanged) {
            _worldTransformChanged = false;
            calculateWorldTransform(g);
        }

        if (settings.renderGeometry && _visible) {
            renderGeometry(g);
        }

        for (RenderableObject child : getChildren()) {
            child.render(g);
        }
        g.popMatrix();
    }

    private void renderGeometry(PGraphics g) {
        if (getVertics().isEmpty()) {
            return;
        }
        g.fill(_color.x, _color.y, _color.z);
        g.beginShape(objectType);
        for (PVector vert : getVertics()) {
            g.vertex(vert.x, vert.y, vert.z);
        }
        g.fill(255);
        g.endShape();
    }

    protected void calculateWorldTransform(PGraphics g) {
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
        getCollision().recalculateExtendedBoundingBox();
        if (getParent() != null) {
            getParent().onBoundingBoxChanged();
        }
    }

    public List<PVector> getVertics() {
        if (_vertics == null) {
            _vertics = loadGeometry();
            getCollision().calculateBoundingBox(_vertics);
        }
        return _vertics;
    }

    // override in extending class, to define what should be rendered
    protected List<PVector> loadGeometry() {
        return new ArrayList<PVector>();
    }

    protected void clearGeometry() {
        _vertics = null;
        getCollision().clearCollision();
    }

    // may be null
    public RenderableObject getParent() {
        return _parent;
    }

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

    public void removeChild(RenderableObject child) {
        getChildren().remove(child);
        child._parent = null;
        child._worldTransformChanged = true;
    }

    public List<RenderableObject> getChildren() {
        return _children;
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

    public boolean checkCollision(RenderableObject other) {
        if (!isEnabled() || !other.isEnabled()) {
            return false;
        }
        return getCollision().checkCollision(other.getCollision());
    }

    public void onBeginOverlap(RenderableObject other, String keyword) {
        onComponentBeginOverlap(this, other, keyword);
    }

    public void onEndOverlap(RenderableObject other, String keyword) {
        onComponentEndOverlap(this, other, keyword);
    }

    public void onComponentBeginOverlap(RenderableObject component, RenderableObject other, String keyword) {
        if (getParent() != null) {
            getParent().onComponentBeginOverlap(component, other, keyword);
        }
    }

    public void onComponentEndOverlap(RenderableObject component, RenderableObject other, String keyword) {
        if (getParent() != null) {
            getParent().onComponentEndOverlap(component, other, keyword);
        }
    }

    // get local translation
    public PVector getTranslation() {
        return _localTranslation;
    }

    // set local translation
    public void setTranslation(PVector translation) {
        _localTranslation = translation;
        _worldTransformChanged = true;
    }

    public PVector getWorldTranslation() {
        return _worldTranslation;
    }

    public void addTranslationX(float delta) {
        _localTranslation.x += delta;
        _worldTransformChanged = true;
    }

    public void addTranslationY(float delta) {
        _localTranslation.y += delta;
        _worldTransformChanged = true;
    }

    public void addTranslationZ(float delta) {
        _localTranslation.z += delta;
        _worldTransformChanged = true;
    }

    public PVector getRotation() {
        return _localRotation;
    }

    // set rotation in degrees
    public void setRotation(PVector rotation) {
        // transform to radians
        _localRotation.x = radians(rotation.x);
        _localRotation.y = radians(rotation.y);
        _localRotation.z = radians(rotation.z);
        _worldTransformChanged = true;
    }

    public PVector getWorldRotation() {
        return _worldRotation;
    }

    // set x rotation in degrees
    public void setRotationX(float deg) {
        _localRotation.x = radians(deg);
        _worldTransformChanged = true;
    }

    // add x rotation in degrees
    public void addRotationX(float deltaDegree) {
        _localRotation.x += radians(deltaDegree);
        _worldTransformChanged = true;
    }

    // set y rotation in degrees
    public void setRotationY(float deg) {
        _localRotation.y = radians(deg);
        _worldTransformChanged = true;
    }

    // add y rotation in degrees
    public void addRotationY(float deltaDegree) {
        _localRotation.y += radians(deltaDegree);
        _worldTransformChanged = true;
    }

    // set z rotation in degrees
    public void setRotationZ(float deg) {
        _localRotation.z = radians(deg);
        _worldTransformChanged = true;
    }

    // add z rotation in degrees
    public void addRotationZ(float deltaDegree) {
        _localRotation.z += radians(deltaDegree);
        _worldTransformChanged = true;
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

    public PVector getColor() {
        return _color;
    }

    public void setColor(PVector col) {
        _color = col;
    }

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