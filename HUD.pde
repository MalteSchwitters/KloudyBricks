/**
 * Malte Schwitters 2017, für das WPM Interaktive 3D-Graphik mit Processing
 * 
 * User interface, holds all UI components
 */
class HUD implements Renderable {

    private boolean _hidden = false;

    private int _score = 0;
    private int _lastScore = 0;
    private int _highScore = 0;

    public HUD() {
        _highScore = loadHighScore();
    }

    @Override
    public void render(PGraphics g) {
        if (settings.drawFps) {
            textSize(24);
            text((int) frameRate + " fps", 10, 32);
        }
        if (!_hidden) {
            if (gameStarted) {
                String score = String.valueOf(_score);
                textSize(64);
                text(score, width / 2 - textWidth(score) / 2, 100);
            } else {
                if (_lastScore > 0) {
                    String score = "SCORE: " + _lastScore + "     HIGH SCORE: " + _highScore;
                    textSize(32);
                    text(score, width / 2 - textWidth(score) / 2, 100);
                }
                String hint = "Press any key to start game";
                textSize(64);
                text(hint, width / 2 - textWidth(hint) / 2, height / 2 - 50);
                String hint2 = "Avoid obstacles, press space to jump";
                textSize(32);
                text(hint2, width / 2 - textWidth(hint2) / 2, height / 2 + 50);
            }
        }
    }

    public void incrementScore() {
        _score++;
    }

    public void hideAll() {
        _hidden = true;
    }

    public void showHighScore() {
        _lastScore = _score;
        if (_score > _highScore) {
            _highScore = _score;
            saveHighScore(_highScore);
        }
        _score = 0;
        _hidden = false;
    }
}