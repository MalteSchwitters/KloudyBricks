public class BackgroundHouse extends RenderableObject {

    private Quad _house = new Quad();

    public BackgroundHouse() {
        addChild(_house);
        setHasCollision(false);
    }

    @Override
    public void render(PGraphics g) {
        stroke(64, 64, 64);
        super.render(g);
        noStroke();
    }

    @Override
    public void setColorInherit(PVector c) {
        //super.setColorInherit(new PVector(c.x -55, c.y -55, c.z - 55));
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
