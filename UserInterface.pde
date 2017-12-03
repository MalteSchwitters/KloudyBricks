/**
 * Malte Schwitters 2017, für das WPM Interaktive 3D-Graphik mit Processing
 * 
 * User interface, holds all UI components
 */
class UserInterface implements Renderable {

    private int _score = 0;

    public UserInterface() {

    }

    @Override
    public void render(PGraphics g) {
        // draw score
        if (gameStarted) {
            textSize(64);
            String score = String.valueOf(_score);
            text(score, width / 2 - textWidth(score) / 2, 100);
            textSize(24);
            text((int) frameRate + " fps", 10, 32);
        } else {
            textSize(64);
            String hint = "Press any key to start game";
            text(hint, width / 2 - textWidth(hint) / 2, height / 2 - 50);
            textSize(32);
            String hint2 = "Avoid obstacles, press space to jump";
            text(hint2, width / 2 - textWidth(hint2) / 2, height / 2 + 50);
        }
    }

    public void incrementScore() {
        _score++;
    }

    public void onDead() {
        _score = 0;
    }
}