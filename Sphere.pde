/**
 * Malte Schwitters 2017, für das WPM Interaktive 3D-Graphik mit Processing
 * 
 * Simple renderable sphere. Does not use Processing sphere(...) function, but verticies.
 */
public class Sphere extends RenderableObject {

    private float _radius = 1.0;
    private int _subs = 16;

    public Sphere() {
    }

    public Sphere(String id) {
        super(id);
    }

    @Override
    public List<PVector> loadGeometry() {
        // could be optimized by calculating only a quad and then mirroring it
        objectType = QUADS;
        List<PVector> vertics = new ArrayList<PVector>();
        PVector radius = new PVector(_radius, 0, 0);
        float angle = radians(360.0 / (float)_subs);
        float az1, az2, ay1, ay2;

        for (float z = 0; z < _subs; z++) {
            for (float y = 0; y < _subs; y++) {
                az1 = z * angle;
                az2 = (z + 1) * angle;
                ay1 = y * angle;
                ay2 = (y + 1) * angle;
                vertics.add(rotateVector(radius, new PVector(0, ay1, az1)));
                vertics.add(rotateVector(radius, new PVector(0, ay2, az1)));
                vertics.add(rotateVector(radius, new PVector(0, ay2, az2)));
                vertics.add(rotateVector(radius, new PVector(0, ay1, az2)));
            }
        }   
        return vertics;
    }

    public float getRadius() {
        return _radius;
    }

    public void setRadius(float radius) {
        _radius = radius;
        clearGeometry();
    }

    public int getSubdivisions() {
        return _subs;
    }
    
    public void setSubdivisions(int subs) {
        _subs = subs;
    }
}
