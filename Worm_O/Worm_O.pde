/*    Dean Mysliwiec - Final Project Game - Slither.io Inspired    */

import ddf.minim.*; // Imported library for audio file playback

Minim minim;
AudioPlayer BackgroundMusic;

int gameState = 0;  // Start Screen = 1, Game Over = 2

float playerX, playerY;
float playerSize = 20;
float playerSpeed = 2;

ArrayList<PVector> wormSegments;  // Worm length segments
ArrayList<PVector> foodDots;     // Food dots collected
ArrayList<PVector> poisonDots;   // Poison dots collected

// Prepare with PImage
PImage WormImage;
PImage StartEndBackgroundImage;
PImage GameBackgroundImage;
PImage BirdImage;
PImage HeadImage1;
PImage HeadImage2;
PImage HeadImage3;
PImage SelectedHead;

boolean button1Selected = false;
boolean button2Selected = false;
boolean button3Selected = false;


int foodCount = 0;    // The score

void setup() {
  size(600, 400);
  minim = new Minim(this);
  BackgroundMusic = minim.loadFile("neon-gaming-128925.mp3");
  BackgroundMusic.play();
  StartEndBackgroundImage = loadImage("pexels-skylar-kang-6044820.jpg");
  GameBackgroundImage = loadImage("pexels-eva-bronzini-7599547.jpg");
  WormImage = loadImage("Inchworm.png");
  BirdImage = loadImage("Bird.png");
  HeadImage1 = loadImage("Smile3.png");
  HeadImage2 = loadImage("Smile2.png");
  HeadImage3 = loadImage("Smile.png");
  
  //Default head if none selected
  SelectedHead = HeadImage1;
  
  noStroke();
  initializeGame();
}

void draw() {
  if (gameState == 0) {
    drawStartScreen();
  } 
  else if (gameState == 1) {
    drawGamePlay();
  } 
  else if (gameState == 2) {
    drawGameOverScreen();
  }
}

void drawGamePlay() {
  background(255);
  image(GameBackgroundImage, 0, 0, width, height);
  
  // Move worm towards the mouse
  float angle = atan2(mouseY - playerY, mouseX - playerX);
  playerX += cos(angle) * playerSpeed;
  playerY += sin(angle) * playerSpeed;
  
  // Draw worm & segments
  drawWorm();
  
  // Draw food dots
  drawFoodDots();
  
  // Draw poison dots
  drawPoisonDots();
  
  // Score Board
  fill(255, 0, 0);
  textSize(25);
  textAlign(CENTER, CENTER);
  text("Score: " + foodCount, width / 2, 20);
}

void initializeGame() {
  playerX = width / 2;
  playerY = height / 2;
  
  wormSegments = new ArrayList<PVector>();
  foodDots = new ArrayList<PVector>();
  poisonDots = new ArrayList<PVector>();
  
  wormSegments.add(new PVector(playerX, playerY));
  
  // Initialize set amount of food dots
  for (int i = 0; i < 10; i++) {
    spawnFoodDot();
  }
  
  // Initialize set amount of poison dots
  for (int i = 0; i < 5; i++) {
    spawnPoisonDot();
  }
}

void drawWorm() {
  // Draw the player
  fill(0, 255, 0);
  for (PVector segment : wormSegments) {
    ellipse(segment.x, segment.y, playerSize, playerSize);
  }
  if(SelectedHead == HeadImage1)
  {
    image(SelectedHead, playerX - playerSize / 2, playerY - playerSize / 2, 23, 23);
  }
  else if(SelectedHead == HeadImage2)
  {
    image(SelectedHead, playerX - playerSize / 3, playerY - playerSize / 3.8, 12, 12);
  }
  else if(SelectedHead == HeadImage3)
  {
    image(SelectedHead, playerX - playerSize / 2, playerY - playerSize / 1.5, 28, 28);
  }
  
  // Stops player's worm from getting longer infinitely on screen
  if (wormSegments.size() > 1) {
    wormSegments.remove(wormSegments.size() - 1);
  }
  
  wormSegments.add(0, new PVector(playerX, playerY));
}

void drawFoodDots() {
  // Draw and check collisions with food dots
  for (int i = 0; i < foodDots.size(); i++) {
    PVector foodDot = foodDots.get(i);
    
    // Colors of food dots
    int foodColor = color(139, 69, 19);  // Default
    switch (i % 6) {
      case 0:
        foodColor = color(56, 130, 133);  // Dark blue
        break;
      case 1:
        foodColor = color(128, 0, 128);  // Purple
        break;
      case 2:
        foodColor = color(0, 0, 255);    // Blue
        break;
      case 3:
        foodColor = color(255, 160, 0);  // Orange
        break;
      case 4:
        foodColor = color(255, 190, 200);  // Pink
        break;
      case 5:
        foodColor = color(255, 240, 0);  // Yellow
        break;
    }
    
    fill(foodColor);
    ellipse(foodDot.x, foodDot.y, 10, 10);
    
    // Move some of the food dots randomly
    if (i % 2 == 0) {
      float angle = random(TWO_PI);
      float speed = 2;
      moveDot(foodDot, cos(angle) * speed, sin(angle) * speed, true);
    }

    // Check for collision
    float distance = dist(playerX, playerY, foodDot.x, foodDot.y);
    if (distance < playerSize / 2) {
      foodCount++;
      spawnFoodDot();
      // If food grabbed, add length to the player worm
      wormSegments.add(new PVector(playerX, playerY));
      foodDots.remove(i);
    }
  }
}

void drawPoisonDots() {
  fill(0, 255, 0);
  
  // Draw and check for collision with poison dot
  for (int i = 0; i < poisonDots.size(); i++) {
    PVector poisonDot = poisonDots.get(i);
    ellipse(poisonDot.x, poisonDot.y, 10, 10);
    
    // Check for collision with player
    float distance = dist(playerX, playerY, poisonDot.x, poisonDot.y);
    if (distance < playerSize / 2) {
      gameState = 2;  // Game over if collision 
    }
  }

  // Move a couple poison dots towards the player
  for (int i = 0; i < poisonDots.size(); i++) {
    if (i % 2 == 0) {
      PVector poisonDot = poisonDots.get(i);
      float speed = 0.005 * i;
      moveDot(poisonDot, (playerX - poisonDot.x) * speed, (playerY - poisonDot.y) * speed, true);
    }
  }
}

void moveDot(PVector dot, float dx, float dy, boolean wrapAround) {
  dot.x += dx;
  dot.y += dy;
  
  if (wrapAround) {
    // Wrap around the screen
    dot.x = (dot.x + width) % width;
    dot.y = (dot.y + height) % height;
  }
}

void spawnFoodDot() {
  foodDots.add(new PVector(random(width), random(height)));
}

void spawnPoisonDot() {
  poisonDots.add(new PVector(random(width), random(height)));
}

void drawStartScreen() {
  background(200);
  image(StartEndBackgroundImage, 0, 0, width, height);
  image(WormImage, width / 2 - WormImage.width / 2, 135);
  textSize(24);
  textAlign(CENTER, CENTER);

  // Draw buttons to select different heads
  drawButton(50, height - 50, 50, 30, "Head 1", HeadImage1, button1Selected);
  drawButton(150, height - 50, 50, 30, "Head 2", HeadImage2, button2Selected);
  drawButton(250, height - 50, 50, 30, "Head 3", HeadImage3, button3Selected);
  fill(129, 200, 200);
  textSize(23);
  text("Welcome to Worm-O!", width / 2, height / 3.8);
  textSize(16);
  fill(255, 155, 155);
  text("Click to Play", width / 2, height / 2);
  fill(100, 200, 80);
  text("Avoid the poisonous green food!", width / 2, height / 1.5);
  textSize(16);
  text("Beware!  Some will chase you!!!", width / 2, height / 1.35);
}

void drawButton(float x, float y, float w, float h, String label, PImage image, boolean selected) {
  fill(100, 100, 80);
  rect(x, y, w, h);

  fill(255);
  textSize(16);
  text(label, x + w / 2, y + h / 2 + 5);

  if (selected) {
    imageMode(CENTER);
    image(image, x + w / 2, y + h / 2 - 10, 28, 28);
    imageMode(CORNER);
  }
}


void drawGameOverScreen() {
  background(200);
  image(StartEndBackgroundImage, 0, 0, width, height);
  imageMode(CENTER);
  image(BirdImage, width / 2, height / 5, 120, 120);
  imageMode(CORNER);
  fill(255, 155, 155);
  textSize(24);
  textAlign(CENTER, CENTER);
  text("Game Over, Click to start again!", width / 2, height / 2 - 20);
  text("Final Score: " + foodCount, width / 2, height / 2 + 20);
  
  // Draw buttons to select different heads
  drawButton(50, height - 50, 50, 30, "Head 1", HeadImage1, button1Selected);
  drawButton(150, height - 50, 50, 30, "Head 2", HeadImage2, button2Selected);
  drawButton(250, height - 50, 50, 30, "Head 3", HeadImage3, button3Selected);
}


void mousePressed() {
  if (gameState == 0 || gameState == 2) {
    // Check button clicks
    if (mouseX > 50 && mouseX < 100 && mouseY > height - 50 && mouseY < height - 20) {
      SelectedHead = HeadImage1;
      button1Selected = !button1Selected;
      button2Selected = false;
      button3Selected = false;
    } else if (mouseX > 150 && mouseX < 200 && mouseY > height - 50 && mouseY < height - 20) {
      SelectedHead = HeadImage2;
      button2Selected = !button2Selected;
      button1Selected = false;
      button3Selected = false;
    } else if (mouseX > 250 && mouseX < 300 && mouseY > height - 50 && mouseY < height - 20) {
      SelectedHead = HeadImage3;
      button3Selected = !button3Selected;
      button1Selected = false;
      button2Selected = false;
    } else {
      gameState = 1;  // Start game
      foodCount = 0;  // Reset the score
      initializeGame();
      loop();
    }
  }
}
