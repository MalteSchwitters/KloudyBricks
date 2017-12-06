/**
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * Block to be used as a house in the background .
 */
public class BackgroundHouse extends RenderableObject {

    private Quad _house = new Quad();

    public BackgroundHouse() {
        addChild(_house);
        setHasCollision(false);
    }

    @Override
    public void setColorInherit(PVector c) {
        float delta = -45;
        super.setColorInherit(new PVector(c.x + delta, c.y + delta, c.z + delta));
    }

    public void randomize() {
        float w = random(30) + 50;
        float h = random(350) + 150;
        _house.setSize(new PVector(w, w, h));
        _house.setRotation(new PVector(0, 0, random(20) - 20));
        _house.setTranslation(new PVector(-random(200), 0, 0));
    }
}