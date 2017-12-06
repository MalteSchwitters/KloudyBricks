/**
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * Part of the level
 */
public class LineRunnerChunk extends RenderableObject {

    private final float _chunkWidth = 200;
    private final float _speed = 0.15;

    private float _offset;

    private Quad _obstacle1 = new Quad();
    private Quad _obstacle2 = new Quad();
    private Quad _obstacle3 = new Quad();
    private Quad _obstacle4 = new Quad();

    public LineRunnerChunk(int index) {
        super("Chunk " + index);
        _offset = index * _chunkWidth;

        _obstacle1.setTranslation(new PVector(0, 0, 10));
        _obstacle1.setSize(new PVector(20, 20, 20));
        _obstacle1.getCollision().setKeyword(Collision.COLLISION_OBSTACLE);
        addChild(_obstacle1);

        _obstacle2.setTranslation(new PVector(0, 30, 10));
        _obstacle2.setSize(new PVector(20, 20, 20));
        _obstacle2.getCollision().setKeyword(Collision.COLLISION_OBSTACLE);
        addChild(_obstacle2);

        _obstacle3.setTranslation(new PVector(0, 60, 10));
        _obstacle3.setSize(new PVector(20, 20, 20));
        _obstacle3.getCollision().setKeyword(Collision.COLLISION_OBSTACLE);
        addChild(_obstacle3);

        _obstacle4.setTranslation(new PVector(0, 90, 80));
        _obstacle4.setSize(new PVector(20, 20, 20));
        _obstacle4.getCollision().setKeyword(Collision.COLLISION_OBSTACLE);
        addChild(_obstacle4);

        clearObstacles();
    }

    @Override
    public void render(PGraphics g) {
        float y = (getPlayTime() * _speed + _offset) % (_chunkWidth * World.chunkCount) - _chunkWidth * World.chunkCount / 2;
        if (y < getTranslation().y && gameStarted) {
            randomizeObstacles();
            ui.incrementScore();
        }
        if (!gameStarted) {
            clearObstacles();
        }
        setTranslation(new PVector(0, y, -100));
        super.render(g);
    }

    public void clearObstacles() {
        _obstacle1.setEnabled(false);
        _obstacle2.setEnabled(false);
        _obstacle3.setEnabled(false);
        _obstacle4.setEnabled(false);
    } 

    public void randomizeObstacles() {
        float type = random(4);
        if (type <= 1) {
            _obstacle1.setEnabled(true);
            _obstacle2.setEnabled(true);
            _obstacle3.setEnabled(true);
            _obstacle4.setEnabled(false);
        } else if (type <= 2) {
            _obstacle1.setEnabled(false);
            _obstacle2.setEnabled(true);
            _obstacle3.setEnabled(true);
            _obstacle4.setEnabled(false);
        } else if (type <= 3) {
            _obstacle1.setEnabled(false);
            _obstacle2.setEnabled(false);
            _obstacle3.setEnabled(true);
            _obstacle4.setEnabled(false);
        } else {
            _obstacle1.setEnabled(false);
            _obstacle2.setEnabled(false);
            _obstacle3.setEnabled(false);
            _obstacle4.setEnabled(true);
        }
    }

    private long getPlayTime() {
        return System.currentTimeMillis() - startTime;
    }

}
