public class LineRunnerChunk extends RenderableObject {

    private final float _chunkWidth = 200;
    private final float _speed = 0.15;

    private float _offset;

    private Quad _obstacle1 = new Quad();
    private Quad _obstacle2 = new Quad();
    private Quad _obstacle3 = new Quad();
    private Quad _obstacle4 = new Quad();
    
    private BackgroundHouse _background1 = new BackgroundHouse();
    private BackgroundHouse _background2 = new BackgroundHouse();
    private BackgroundHouse _background3 = new BackgroundHouse();
    private BackgroundHouse _background4 = new BackgroundHouse();


    public LineRunnerChunk(int index) {
        super("Chunk " + index);
        _offset = index * _chunkWidth;
        float backgroundOffset = _chunkWidth / 4;
        
        _background1.setTranslation(new PVector(-150, backgroundOffset * -2, -100));
        _background1.setHasCollision(false);
        addChild(_obstacle1);
        
        _background2.setTranslation(new PVector(-250, backgroundOffset * -1, -100));
        _background2.setHasCollision(false);
        addChild(_obstacle2);
        
        _background3.setTranslation(new PVector(-150, backgroundOffset * 0, -100));
        _background3.setHasCollision(false);
        addChild(_obstacle3);

        _background4.setTranslation(new PVector(-200, backgroundOffset * 1, -100));
        _background4.setHasCollision(false);
        addChild(_obstacle4);

        _obstacle1.setTranslation(new PVector(0, 0, 10));
        _obstacle1.setSize(new PVector(20, 20, 20));
        _obstacle1.getCollision().setKeyword(Collision.COLLISION_OBSTACLE);
        addChild(_background1);

        _obstacle2.setTranslation(new PVector(0, 30, 10));
        _obstacle2.setSize(new PVector(20, 20, 20));
        _obstacle2.getCollision().setKeyword(Collision.COLLISION_OBSTACLE);
        addChild(_background2);

        _obstacle3.setTranslation(new PVector(0, 60, 10));
        _obstacle3.setSize(new PVector(20, 20, 20));
        _obstacle3.getCollision().setKeyword(Collision.COLLISION_OBSTACLE);
        addChild(_background3);

        _obstacle4.setTranslation(new PVector(0, 90, 80));
        _obstacle4.setSize(new PVector(20, 20, 20));
        _obstacle4.getCollision().setKeyword(Collision.COLLISION_OBSTACLE);
        addChild(_background4);

        clearObstacles();
        randomizeBackground();
    }

    @Override
    public void render(PGraphics g) {
        float y = (getPlayTime() * _speed + _offset) % (_chunkWidth * World.chunkCount) - _chunkWidth * World.chunkCount / 2;
        if (y < getTranslation().y) {
            if (gameStarted) {
                randomizeObstacles();
                ui.incrementScore();
            }
            randomizeBackground();
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

    private void randomizeBackground() {
        _background1.randomize();
        _background2.randomize();
        _background3.randomize();
        _background4.randomize();
    }

    private long getPlayTime() {
        return System.currentTimeMillis() - startTime;
    }

}
