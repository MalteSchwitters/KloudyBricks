/**
 * Malte Schwitters 2017, für das WPM Interaktive 3D-Graphik mit Processing
 * 
 * Simple renderable quad. Does not use Processing box(...) function, but verticies.
 */
public class Quad extends RenderableObject {

    private PVector _size = new PVector(0, 0, 0); 

    public Quad() {
    }

    public Quad(String id) {
        super(id);
    }

    @Override
    public List<PVector> loadGeometry() {
        objectType = QUADS;
        List<PVector> vertics = new ArrayList<PVector>();
        PVector min = PVector.mult(_size, -0.5);
        PVector max = PVector.mult(_size, 0.5);

        vertics.add(new PVector(min.x, max.y, max.z));
        vertics.add(new PVector(max.x, max.y, max.z));
        vertics.add(new PVector(max.x, min.y, max.z));
        vertics.add(new PVector(min.x, min.y, max.z));

        vertics.add(new PVector(max.x, max.y, max.z));
        vertics.add(new PVector(max.x, max.y, min.z));
        vertics.add(new PVector(max.x, min.y, min.z));
        vertics.add(new PVector(max.x, min.y, max.z));

        vertics.add(new PVector(max.x, max.y, min.z));
        vertics.add(new PVector(min.x, max.y, min.z));
        vertics.add(new PVector(min.x, min.y, min.z));
        vertics.add(new PVector(max.x, min.y, min.z));

        vertics.add(new PVector(min.x, max.y, min.z));
        vertics.add(new PVector(min.x, max.y, max.z));
        vertics.add(new PVector(min.x, min.y, max.z));
        vertics.add(new PVector(min.x, min.y, min.z));
        
        vertics.add(new PVector(min.x, max.y, min.z));
        vertics.add(new PVector(max.x, max.y, min.z));
        vertics.add(new PVector(max.x, max.y, max.z));
        vertics.add(new PVector(min.x, max.y, max.z));

        vertics.add(new PVector(min.x, min.y, min.z));
        vertics.add(new PVector(max.x, min.y, min.z));
        vertics.add(new PVector(max.x, min.y, max.z));
        vertics.add(new PVector(min.x, min.y, max.z));
        
        return vertics;
    }

    public PVector getSize() {
        return _size;
    }

    public void setSize(PVector size) {
        _size = size;
        clearGeometry();
    }
}
