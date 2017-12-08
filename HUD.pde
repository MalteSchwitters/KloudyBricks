/**
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * User interface, holds all UI components
 */
class HUD implements Renderable {

    private Animation _zoomAnim = new ZoomAnimation();
    private boolean _hidden = false;
    private int _score = 0;
    private int _lastScore = 0;
    private int _highScore = 0;
    private float _textPositionZ = 0;

    public HUD() {
        _highScore = loadHighScore();
    }

    @Override
    public void render(PGraphics g) {
        _zoomAnim.tick();
        textFont(font);
        textAlign(CENTER, CENTER);
        if (!_hidden) {
            if (gameStarted) {
                textSize(60);
                outlinedText(g, String.valueOf(_score), width / 2, 100);
            } else {
                textSize(64);
                outlinedText(g, "Press any key to start game", width / 2, height / 2 - 50);
                
                textSize(32);
                outlinedText(g, "Avoid obstacles, press space to jump", width / 2, height / 2 + 50);
                
                if (_lastScore > 0) {
                    textSize(32);
                    outlinedText(g, "SCORE: " + _lastScore + "     HIGH SCORE: " + _highScore, width / 2, 200);
                }
            }
        }
        if (settings.drawFps) {
            textAlign(LEFT, CENTER);
            textSize(24);
            outlinedText(g, (int) frameRate + " fps", 10, 32);
        }
    }

    private void outlinedText(PGraphics g, String text, float x, float y) {
        fill(10);
        text(text, x - 2, y, _textPositionZ);
        text(text, x + 2, y, _textPositionZ);
        text(text, x, y - 2, _textPositionZ);
        text(text, x, y + 2, _textPositionZ);
        fill(240);
        text(text, x, y, _textPositionZ);
    }

    public void incrementScore() {
        _score++;
        _zoomAnim.play(null, 0.2);
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
        _zoomAnim.play(null, 0.2);
    }

    /**
     * Zooms in the text by animationg th z position
     */
    private class ZoomAnimation extends Animation {
    
        @Override
        public void animate(RenderableObject target, float t) {
            _textPositionZ = 50 * t;
        }
    }
}