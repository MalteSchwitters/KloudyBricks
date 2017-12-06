/**
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * Collsion object, that handles bounding box and collision calculations for a RenderableObeject. Only works
 * for polygone objects, as the objects verticies are needed for bounding box calculation!
 */
public class Collision implements Renderable {

    // Collision type, used to check with what kind of object overlapped
    public static final String COLLISION_DEFAULT = "default";
    public static final String COLLISION_FLOOR = "floor";
    public static final String COLLISION_OBSTACLE = "obstacle";
    public static final String COLLISION_ACTOR = "actor";
    public static final String COLLISION_TRIGGER = "trigger";

    // currently detected cullisions, needed for the end overlap event
    private List<RenderableObject> _collidesWith = new ArrayList<RenderableObject>();
    
    // collision properties
    private RenderableObject _collisionFor;
    private PVector _boundingBoxTranslation = new PVector();
    private PVector _boundingBoxSize = new PVector();
    private PVector _extendedBoundingBoxTranslation = new PVector();
    private PVector _extendedBoundingBoxSize = new PVector();
    private String _keyword = COLLISION_DEFAULT;

    public Collision(RenderableObject target) {
        _collisionFor = target;
    }

    @Override
    public void render(PGraphics g) {
        // collision can be rendered for debugging using the specified keys in the settings
        PVector boxTranslation = _boundingBoxTranslation;
        PVector boxSize = _boundingBoxSize;

        // if the bounding box has no size, then we don't have a collision to render
        if (boxSize.mag() != 0) {
            g.pushMatrix();
            g.translate(boxTranslation.x, boxTranslation.y, boxTranslation.z);
            // move to the center of the collision, as box is rendered with centered translation
            g.translate(boxSize.x / 2, boxSize.y / 2, boxSize.z / 2);
            g.stroke(150, 0, 0);
            g.fill(150, 0, 0, 5);
            g.box(boxSize.x, boxSize.y, boxSize.z);
            g.popMatrix();
        }

        // render collision of child objects
        for (RenderableObject child : _collisionFor.getChildren()) {
            if (child.hasCollision()) {
                child.getCollision().render(g);
            }
        }
    }

    /**
     * Calculates the bounding box of the collision. 
     */
    public void calculateBoundingBox(List<PVector> vertics) {
        clearCollision();
        if (_collisionFor.isEnabled()) {
            PVector boundingBoxMin = new PVector();
            PVector boundingBoxMax = new PVector();

            for (PVector vert : vertics) {
                PVector rotatedVert = unrotateVector(vert, _collisionFor.getWorldRotation());
                boundingBoxMin = minVector(boundingBoxMin, rotatedVert);
                boundingBoxMax = maxVector(boundingBoxMax, rotatedVert);
            }
            _boundingBoxSize = PVector.sub(boundingBoxMax, boundingBoxMin);
            _boundingBoxTranslation = PVector.add(boundingBoxMin, _collisionFor.getWorldTranslation());
            recalculateExtendedBoundingBox();
        }
    }

    /**
     * Resets the bounding box and ends all overlaps.
     */
    public void clearCollision() {
        _boundingBoxTranslation = new PVector(0, 0, 0);
        _boundingBoxSize = new PVector(0, 0, 0);
        for (RenderableObject col : _collidesWith) {
            _collisionFor.onEndOverlap(col, col.getCollision()._keyword);
            col.onEndOverlap(_collisionFor, _keyword);
        }
        _collidesWith.clear();
        recalculateExtendedBoundingBox();
    }

    public void setKeyword(String keyword) {
        _keyword = keyword;
    }

    private void beginOverlap(RenderableObject other) {
        if (!_collidesWith.contains(other)) {
            _collidesWith.add(other);
            _collisionFor.onBeginOverlap(other, other.getCollision()._keyword);
            other.onBeginOverlap(_collisionFor, _keyword);
            other.onBeginOverlap(_collisionFor, _keyword);
        }
    }

    private void endOverlap(RenderableObject other) {
        if (_collidesWith.contains(other)) {
            _collidesWith.remove(other);
            _collisionFor.onEndOverlap(other, other.getCollision()._keyword);
            other.onEndOverlap(_collisionFor, _keyword);
        }
    }

    private void extendBoundingBox(RenderableObject object) {        
        if (object == null || object.getCollision()._extendedBoundingBoxSize.mag() == 0) {
            // child has no collision
            return;
        }
        Collision collision = object.getCollision();
        if (_extendedBoundingBoxSize.mag() == 0) {
            _extendedBoundingBoxTranslation = collision._extendedBoundingBoxTranslation.copy();
            _extendedBoundingBoxSize = collision._extendedBoundingBoxSize.copy();
        } else {
            PVector aMin = _extendedBoundingBoxTranslation.copy();
            PVector bMin = collision._extendedBoundingBoxTranslation;
            PVector aMax = PVector.add(aMin, _extendedBoundingBoxSize);
            PVector bMax = PVector.add(bMin, collision._extendedBoundingBoxSize);
            _extendedBoundingBoxTranslation = minVector(aMin, bMin);
            _extendedBoundingBoxSize = maxVector(aMax, bMax).sub(_extendedBoundingBoxTranslation);
        }
    }

    private void recalculateExtendedBoundingBox() {
        _extendedBoundingBoxTranslation = _boundingBoxTranslation;
        _extendedBoundingBoxSize = _boundingBoxSize;
        for (RenderableObject child : _collisionFor.getChildren()) {
            //child.getCollision().recalculateExtendedBoundingBox();
            extendBoundingBox(child);
        }
        if (_collisionFor.getParent() != null) {
            _collisionFor.getParent().getCollision().recalculateExtendedBoundingBox();
        }
    }

    public boolean checkCollision(Collision other) {        
        if (other == this) {
            return false;
        }
        
        // First test extended bounding boxes of both collisions, If these don't overlap
        // then the two boxes are far enough from each other so that children don't overlap
        // as well.
        PVector aTranslation = _extendedBoundingBoxTranslation;
        PVector aSize = _extendedBoundingBoxSize;
        PVector bTranslation = other._extendedBoundingBoxTranslation;
        PVector bSize = other._extendedBoundingBoxSize;
        if (!checkCollision(aTranslation, aSize, bTranslation, bSize)) {
            // TODO children
            endOverlap(other._collisionFor);
            return false;
        }

        // The extended bounding boxes overlap, we may have a collision. First check own collision
        boolean collides = false;
        aTranslation = _boundingBoxTranslation;
        aSize = _boundingBoxSize;
        bTranslation = other._boundingBoxTranslation;
        bSize = other._boundingBoxSize;
        if (checkCollision(aTranslation, aSize, bTranslation, bSize)) {
            beginOverlap(other._collisionFor);
            collides = true;
        } else {
            endOverlap(other._collisionFor);
        }

        // Check if children of other collide with self 
        for (RenderableObject child : other._collisionFor.getChildren()) {
            if (_collisionFor.checkCollision(child)) {
                collides = true;
            }
        }

        // Check if children collide with other
        for (RenderableObject child : _collisionFor.getChildren()) {
            if (child.checkCollision(other._collisionFor)) {
                collides = true;
            }
        }
        return collides;
    }

    public boolean checkCollision(PVector aTranslation, PVector aSize, PVector bTranslation, PVector bSize) {
        if (aTranslation.x > bTranslation.x + bSize.x) {
            return false;
        }
        if (aTranslation.y > bTranslation.y + bSize.y) {
            return false;
        }
        if (aTranslation.z > bTranslation.z + bSize.z) {
            return false;
        }
        if (bTranslation.x > aTranslation.x + aSize.x) {
            return false;
        }
        if (bTranslation.y > aTranslation.y + aSize.y) {
            return false;
        }
        if (bTranslation.z > aTranslation.z + aSize.z) {
            return false;
        }
        return true;
    }
}
