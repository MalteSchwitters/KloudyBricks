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
        if (_visible) {
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