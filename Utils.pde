/**
 y* Malte Schwitters 2017, Interactive 3D-Graphic with Processing
 * 
 * Static utility functions for common operations like vector rotation. 
 */
public PVector unrotateVector(PVector translation, PVector rotation) {
    PVector rotatedTranslation = translation;
    rotatedTranslation = rotateVectorX(rotatedTranslation, -rotation.x);
    rotatedTranslation = rotateVectorY(rotatedTranslation, -rotation.y);
    rotatedTranslation = rotateVectorZ(rotatedTranslation, -rotation.z);
    return rotatedTranslation;
}

public PVector rotateVector(PVector translation, PVector rotation) {
    PVector rotatedTranslation = translation;
    rotatedTranslation = rotateVectorZ(rotatedTranslation, rotation.z);
    rotatedTranslation = rotateVectorY(rotatedTranslation, rotation.y);
    rotatedTranslation = rotateVectorX(rotatedTranslation, rotation.x);
    return rotatedTranslation;
}

public PVector rotateVectorX(PVector vec, float angle) {
    PVector rotatedTranslation = new PVector();
    float c = (float) Math.cos(angle);
    float s = (float) Math.sin(angle);
    rotatedTranslation.x = vec.x;
    rotatedTranslation.y = c * vec.y + -s * vec.z;
    rotatedTranslation.z = s * vec.y + c * vec.z;
    return rotatedTranslation;
}

public PVector rotateVectorY(PVector vec, float angle) {
    PVector rotatedTranslation = new PVector();
    float c = (float) Math.cos(angle);
    float s = (float) Math.sin(angle);
    rotatedTranslation.x = c * vec.x + s * vec.z;
    rotatedTranslation.y = vec.y;
    rotatedTranslation.z = -s * vec.x + c * vec.z;
    return rotatedTranslation;
}

public PVector rotateVectorZ(PVector vec, float angle) {
    PVector rotatedTranslation = new PVector();
    float c = (float) Math.cos(angle);
    float s = (float) Math.sin(angle);
    rotatedTranslation.x = c * vec.x + -s * vec.y;
    rotatedTranslation.y = s * vec.x + c * vec.y;
    rotatedTranslation.z = vec.z;
    return rotatedTranslation;
}

public PVector minVector(PVector a, PVector b) {
    PVector result = new PVector();
    result.x = Math.min(a.x, b.x);
    result.y = Math.min(a.y, b.y);
    result.z = Math.min(a.z, b.z);
    return result;
}

public PVector maxVector(PVector a, PVector b) {
    PVector result = new PVector();
    result.x = Math.max(a.x, b.x);
    result.y = Math.max(a.y, b.y);
    result.z = Math.max(a.z, b.z);
    return result;
}

/**
 * Saves the current highscore to highScore.txt. The file only saves the best highscore.
 */
public void saveHighScore(int highscore) {
    try {
        PrintWriter writer = new PrintWriter(new BufferedWriter(new FileWriter("highScore.txt")));
        writer.write(String.valueOf(highscore));
        writer.close();
    } catch (Exception e) {
        println("Cannot write highscore");
    }
}

/**
 * Reads the current highscore from highScore.txt.
 */
public int loadHighScore() {
    try {
        BufferedReader br = new BufferedReader(new FileReader("highScore.txt"));
        String text = br.readLine();
        br.close();
        if (text != null) {
            return Integer.valueOf(text);
        }
    }
    catch (Exception e) {
        println("Cannot read highscore");
    }
    return 0;
}