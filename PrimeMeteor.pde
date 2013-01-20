//
// PrimeMeteor : by kazunori nanji 20110508
//   for 9leap 
//
// 
//
/* @pjs preload="PMBG.png"; */
//
PFont font;
PImage bg;
boolean GameOver;
ObjectList DL;
Enemy enemy;
Multi multi;
ButtonList BL;
Score score;
String WaitClick = "Prime Meteor\n\nClick to START!";

// defines
int EndLine = 194;
float MaxLevel = 14;

void setup() {
  size(320, 320);
  frameRate(20);

  font = createFont("FFScala", 24);
  textFont(font);
  bg = loadImage("PMBG.png");

  // class
  DL = new ObjectList();
  BL = new ButtonList();
  score = new Score(4, #ffffff);

  enemy = new Enemy();
  multi = new Multi(EndLine + 4);

  // Buttons
  BL.add(new Button(  7, 258, 54, 54,  2, #000000)); // for 2
  BL.add(new Button( 70, 258, 54, 54,  3, #000000)); // for 3
  BL.add(new Button(133, 258, 54, 54,  5, #000000)); // for 5
  BL.add(new Button(196, 258, 54, 54,  7, #000000)); // for 7
  BL.add(new Button(259, 258, 54, 54, 11, #000000)); // for 11
  BL.add(new Button(  0, 194, 64, 50, -1, #000000)); // for Clear
  BL.add(new Button( 65, 194, 256,50,  0, #000000)); // for Enter

  GameOver = true;
  image(bg, 0, 0);
}

// 
class Update {
  Update() {
    DL.add(this);
  }
  void update() {}
}

//
class ObjectList {
  ArrayList dlist;

  ObjectList() {
    dlist = new ArrayList();
  }

  void add(Update u) {
    dlist.add(u);
  }

  void update() {
    Update d;
    for (int i = dlist.size() - 1; i >= 0; i--) {
      d = (Update)dlist.get(i);
      d.update();
    }
  }
}

// 
class Score extends Update {
  int score;
  float sy, level;
  color sc;

  Score(float y, color c) {
    sy = y;
    sc = c;
    clear();
  }

  void clear() {
    score = 0;
    level = 1.5;
  }

  int addScore(int s) {
    score += s;
    return score;
  }

  int addLevel(float l) {
    level += l;
    if (level > MaxLevel)
      level = MaxLevel;

    return (int)level;
  }

  void update() {
    noStroke();
    fill(sc);
    textSize(16);
    // score
    textAlign(RIGHT, TOP);
    text("SCORE: " + score, width, sy);
    // level
    textAlign(LEFT, TOP);
    text("LEVEL: " + (int)level, 0, sy);
  }
}

//
//
class Enemy extends Update {
  int number, level;
  float px, py, dy;
  Enemy() {
    px = width / 2;
    dy = 1.0;
    clear();
    getEnumber(1);
  }

  // getEnumber
  int getEnumber(int level) {
    int res = 1;
    int[] na = {2,2,2,2,3,3,3,3,5,5,5,7,7,11}; // Max Level 14

    int i, t, ri1, ri2;
    int imax = na.length - 1;
    for (i = 0; i <= imax; i++) {
      ri1 = (int)random(0, imax);
      ri2 = (int)random(0, imax);
      t = na[ri1];
      na[ri1] = na[ri2];
      na[ri2] = t;
    }

    for (i = 0; i < level; i++) {
        res *= na[i];
    }

    return res;
  }
  
  //  clear
  void clear() {
    int old = number;
    do { // check same number
      number = getEnumber((int)score.level);
    } while(old == number);
    py = 0;
  }
  
  //  attack
  void attack(int p) {
    if (number == p) {
      score.addScore(number);
      score.addLevel(0.25);
      clear();
    } else if ((number % p) == 0) {
      number /= p;
    }
  }

  //  update
  void update() {
    py += dy;

    textSize(32);
    textAlign(CENTER, BOTTOM);

    for(int c = 64; c < 255; c += 24) {
      fill(color(c, 0, 0, c));
      text(number, px + random(-2, 2), py - (255 - c) / 6);
    }
    fill(255);
    text(number, px, py);

    if (py > EndLine + 6) {
      GameOver = true;

      int s = score.score;
      link("http://9leap.net/games/138/result/?score="+str(s)+
           "&result=Score :" + str(s) + "<br>Thank you for your playing!");
    }
  }
}

//
class Button extends Update {
  int bx, by, bw, bh, number; 
  color bc;
  Button(int x, int y, int w, int h, int num, color c) {
    bx = x;
    by = y;
    bw = w;
    bh = h;
    number = num;
    bc = c;
  }

  boolean check_rect(int x, int y) {
    if (bx <= x  && x <= bx + bw && by <= y && y <= by + bh)
      return true;
    else
      return false;
  }

  void check(int x, int y) {
    if (check_rect(x, y)) {
      switch (number) {
      case 0:   // Enter
        enemy.attack(multi.mul);
        multi.clear();
        break;
      case -1:  // Clear
        multi.clear();
        break;
      default:  // Multi
        multi.addNumber(number);
        break;
      }
    }
  }

  void update() {
    if (bc != #000000) {
      noStroke();
      fill(bc);
      rect(bx,by,bw,bh);
    }
  }
}

//
class ButtonList {
  ArrayList blist;

  ButtonList() {
    blist = new ArrayList();
  }

  void add(Button b) {
    blist.add(b);
  }

  void check() {
    Button b;
    for (int i = blist.size() - 1; i >= 0; i--) {
      b = (Button)blist.get(i);
      b.check(mouseX, mouseY);
    }
  }
}

class Multi extends Update {
  int mul;
  float mh;
  String mstr;
  
  Multi(float h) {
    mh = h;
    clear();
  }

  void addNumber(int n) {
    mul *= n;
    mstr += "x" + str(n);
  }

  void clear() {
    mul = 1;
    mstr = "1";
  }

  void update() {
    noStroke();

    fill(0, 0, 0);
    textSize(24);
    textAlign(LEFT, TOP); 
    //text(mstr + '=', 0, mh);
    text(mstr, 0, mh);

    textAlign(RIGHT, TOP);
    text(mul, width, mh);
  }
}

// Button Check
void mouseClicked() {
  if (GameOver) {
    GameOver = false;
    WaitClick = "GAME OVER!";
    // replay
    score.clear();
    enemy.clear();
    multi.clear();
  } else {
    BL.check();
  }
}

//
void draw() {
  if (GameOver) {
    fill(#ffffff);
    textSize(32);
    textAlign(CENTER, CENTER);
    text(WaitClick, width/2, height/3);
  } else {
    //background(0);
    image(bg, 0, 0);

    DL.update();  // call all update()
  }
}
