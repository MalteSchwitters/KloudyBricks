/**
 * Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * User interface, holds all UI components
 */
class HUD implements Renderable {

    private Animation _zoomAnim = new ZoomAnimation();
    private float _textPositionZ = 0;
    
    private boolean _hidden = false;
    private String _hint;
    private int _score = 0;
    private int _lastScore = 0;
    private int _highScore = 0;


    public HUD() {
        _highScore = loadHighScore();
    }

    @Override
    public void render(PGraphics g) {
        _zoomAnim.tick();
        textFont(font);
        textAlign(CENTER, CENTER);

        float centerW = width / 2;
        float centerH = height / 2;
        if (!_hidden) {
            if (gameStarted) {
                textSize(48);
                if (_score > 0) {
                    outlinedText(g, String.valueOf(_score), centerW, 100);
                } else {
                    textSize(32);
                    outlinedText(g, _hint, centerW, 100);
                }
            } else {

                image(logo, centerW - 320, centerH - 150);

                textSize(32);
                outlinedText(g, "Press any key to start game!", centerW, height - 200);
                
                if (_lastScore > 0) {
                    textSize(32);
                    outlinedText(g, "SCORE: " + _lastScore + "    HIGH SCORE: " + _highScore, centerW, 150);
                }
            }
        }
        if (settings.drawFps) {
            textAlign(LEFT, CENTER);
            textSize(24);
            outlinedText(g, (int) frameRate + " fps", 10, 32, 0);
        }
    }

    private void outlinedText(PGraphics g, String text, float x, float y, float z) {
        fill(10);
        float thinkness = 2;
        text(text, x - thinkness, y, z);
        text(text, x + thinkness, y, z);
        text(text, x, y - thinkness, z);
        text(text, x, y + thinkness, z);
        text(text, x - thinkness, y - thinkness, z);
        text(text, x + thinkness, y + thinkness, z);
        text(text, x + thinkness, y - thinkness, z);
        text(text, x - thinkness, y + thinkness, z);
        fill(240);
        text(text, x, y, z);
    }

    private void outlinedText(PGraphics g, String text, float x, float y) {
        outlinedText(g, text, x, y, _textPositionZ);
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
        // logo cannot be "zoomed"
        // _zoomAnim.play(null, 0.2);
    }

    public void showHint(String hint) {
        _hint = hint;
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