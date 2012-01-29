#include <SPI.h>
#include <GD.h>

#include "allsewage.h" // http://gameduino.com/results/b2f4c588/
#include "sprites.h"   // http://gameduino.com/results/16fe50de/

#define JAWS_OPEN     0
#define JAWS_CLOSED   1
#define SWIM_SPEED    1
#define FLOW_SPEED    2

#define KEY_UP(x)      ((x >> 7) & 0x01)
#define KEY_DOWN(x)    ((x >> 6) & 0x01)
#define KEY_LEFT(x)    ((x >> 5) & 0x01)
#define KEY_RIGHT(x)   ((x >> 4) & 0x01)
#define KEY_C(x)       ((x >> 3) & 0x01)
#define KEY_V(x)       ((x >> 2) & 0x01)
#define KEY_SPACE(x)   ((x >> 1) & 0x01)
#define KEY_ESCAPE(x)  ((x >> 0) & 0x01)
static boolean last_space = false;

static unsigned int t = 0;
static uint16 swimx, swimy;
static int8 swimvx, swimvy;
static uint16 narcox, narcoy;
static int8 narcovx, narcovy;
static uint8 swim_jaws;
static unsigned int scrollx = 0;
static unsigned int scrolly = 0;
static unsigned char inchar;
static boolean sunk_ship = false;
static uint8 enemy_id, swimmer_id;
static uint8 touching_swimmer, touching_enemy;

static void draw_standing_all(int x, int y) {
  draw_sprite(x     , y     , 36, 0, 1);
  draw_sprite(x     , y + 16, 45, 0, 0);
}

static void draw_narco(int x, int y, boolean sunk) {
  if(!sunk) {
    draw_sprite(x     , y + 00, 03, 0, 1);
    draw_sprite(x + 16, y + 00, 04, 0, 1);
    // periscope!
    enemy_id = GD.spr;
    draw_sprite(x + 32, y + 00, 05, 0, 1);
    draw_sprite(x + 48, y + 00, 6, 0, 1);
    draw_sprite(x + 64, y + 00, 7, 0, 1);
    draw_sprite(x + 80, y + 00, 8, 0, 1);
    draw_sprite(x     , y + 16, 12, 0, 1);
    draw_sprite(x + 16, y + 16, 13, 0, 1);
    draw_sprite(x + 32, y + 16, 14, 0, 1);
    draw_sprite(x + 48, y + 16, 15, 0, 1);
    draw_sprite(x + 64, y + 16, 16, 0, 1);
    draw_sprite(x + 80, y + 16, 17, 0, 1);
    draw_sprite(x     , y + 32, 21, 0, 1);
    draw_sprite(x + 16, y + 32, 22, 0, 1);
    draw_sprite(x + 32, y + 32, 23, 0, 1);
    draw_sprite(x + 48, y + 32, 24, 0, 1);
    draw_sprite(x + 64, y + 32, 25, 0, 1);
    draw_sprite(x + 80, y + 32, 26, 0, 1);
    draw_sprite(x     , y + 48, 30, 0, 1);
    draw_sprite(x + 16, y + 48, 31, 0, 1);
    draw_sprite(x + 32, y + 48, 32, 0, 1);
    draw_sprite(x + 48, y + 48, 33, 0, 1);
    draw_sprite(x + 64, y + 48, 34, 0, 1);
    draw_sprite(x + 80, y + 48, 35, 0, 1);
  } else {
    draw_sprite(x     , y + 00, 39, 0, 1);
    draw_sprite(x + 16, y + 00, 40, 0, 1);
    draw_sprite(x + 32, y + 00, 41, 0, 1);
    draw_sprite(x + 48, y + 00, 42, 0, 1);
    draw_sprite(x + 64, y + 00, 43, 0, 1);
    draw_sprite(x + 80, y + 00, 44, 0, 1);
    draw_sprite(x     , y + 16, 48, 0, 1);
    draw_sprite(x + 16, y + 16, 49, 0, 1);
    draw_sprite(x + 32, y + 16, 50, 0, 1);
    draw_sprite(x + 48, y + 16, 51, 0, 1);
    draw_sprite(x + 64, y + 16, 52, 0, 1);
    draw_sprite(x + 80, y + 16, 53, 0, 1);
    draw_sprite(x     , y + 32, 57, 0, 1);
    draw_sprite(x + 16, y + 32, 58, 0, 1);
    draw_sprite(x + 32, y + 32, 59, 0, 1);
    draw_sprite(x + 48, y + 32, 60, 0, 1);
    draw_sprite(x + 64, y + 32, 61, 0, 1);
    draw_sprite(x + 80, y + 32, 62, 0, 1);
    draw_sprite(x     , y + 48, 66, 0, 1);
    draw_sprite(x + 16, y + 48, 67, 0, 1);
    draw_sprite(x + 32, y + 48, 68, 0, 1);
    draw_sprite(x + 48, y + 48, 69, 0, 1);
    draw_sprite(x + 64, y + 48, 70, 0, 1);
    draw_sprite(x + 80, y + 48, 71, 0, 1);
  }
}

static void draw_explosion(int x, int y) {
    draw_sprite(x + 00, y + 00, 54, 0, 1);
    draw_sprite(x + 16, y + 00, 55, 0, 1);
    draw_sprite(x + 00, y + 16, 63, 0, 1);
    draw_sprite(x + 16, y + 16, 64, 0, 1);
}

static void draw_swim(int x, int y, boolean is_open) {
  draw_sprite(x     , y     , 0, 0, 0);
  draw_sprite(x + 16, y     , 1, 0, 0);
  draw_sprite(x     , y + 16, 9, 0, 0);
  draw_sprite(x + 16, y + 16, 10, 0, 0);
  draw_sprite(x + 32, y + 16, 11, 0, 0);
  swimmer_id = GD.spr;
  if(is_open) {
    draw_sprite(x + 32, y     , 2, 0, 0);
  } else {
    draw_sprite(x + 32, y     , 20, 0, 0);
  }
}

void static old_process_keypress() {
  if(SerialUSB.available()) {
    inchar = SerialUSB.read();
    while(SerialUSB.available()) {
      inchar = SerialUSB.read();
    }
    SerialUSB.println(inchar, 16);
    switch(inchar) {
      case 'w':
        swimy -= SWIM_SPEED;
        break;
      case 's':
        swimy += SWIM_SPEED;
        break;
      case 'a':
        swimx -= SWIM_SPEED;
        break;
      case 'd':
        swimx += SWIM_SPEED;
        break;
      case 'W':
        swimy -= SWIM_SPEED;
        swim_jaws = 20;
        break;
      case 'S':
        swimy += SWIM_SPEED;
        swim_jaws = 20;
        break;
      case 'A':
        swimx -= SWIM_SPEED;
        swim_jaws = 20;
        break;
      case 'D':
        swimx += SWIM_SPEED;
        swim_jaws = 20;
        break;
      case ' ':
        swim_jaws = 20;
        break;
      default:
        break;
    }
  }
}

void static process_keypress() {
  if(SerialUSB.available()) {
    inchar = SerialUSB.read();
    while(SerialUSB.available()) {
      inchar = SerialUSB.read();
    }
    SerialUSB.println(inchar, 2);
    swimvx = 0;
    swimvy = 0;
    if (KEY_LEFT(inchar)) { swimvx -= SWIM_SPEED; }
    if (KEY_RIGHT(inchar)) { swimvx += SWIM_SPEED; }
    if (KEY_UP(inchar)) { swimvy -= SWIM_SPEED; }
    if (KEY_DOWN(inchar)) { swimvy += SWIM_SPEED; }
    if (KEY_SPACE(inchar) and !last_space) { swim_jaws = 20; }
    if (!KEY_SPACE(inchar)) { swim_jaws = 0; }
    last_space = KEY_SPACE(inchar);
    if (KEY_ESCAPE(inchar)) {
      sunk_ship = false;
      narcoy = 150;
    }
  }
}

void setup()
{
  pinMode(BOARD_BUTTON_PIN, INPUT);
  swimx = 20;
  swimy = 20;
  narcox = 180;
  narcoy = 150;
  narcovy = -1;
  
  delay(250);
  GD.begin();
  
  GD.wr(JK_MODE, 1);
  
  for (byte y = 0; y < 64; y++)
    GD.copy(RAM_PIC + y * 64, allsewage_pic + y * 64, 64);
  GD.copy(RAM_CHR, allsewage_chr, sizeof(allsewage_chr));
  GD.copy(RAM_PAL, allsewage_pal, sizeof(allsewage_pal));

  GD.copy(PALETTE16A, sprite_sprpal, sizeof(sprite_sprpal));
  GD.copy(RAM_SPRIMG, sprite_sprimg, sizeof(sprite_sprimg));


  GD.__wstartspr(0);
  draw_standing_all(0,0);
  GD.__end();
}

void loop() 
{
  GD.waitvblank();
  
  // ------- do graphics drawing
  
  // check collisions
  touching_swimmer = GD.rd(COLLISION + swimmer_id);
  touching_enemy = GD.rd(COLLISION + enemy_id);
  
  // scroll background
  GD.wr16(SCROLL_X, scrollx);
  GD.__wstartspr(0);
  draw_standing_all(10,270);
  draw_narco(narcox, narcoy, sunk_ship);
  if (sunk_ship) {
    for (uint8 i = 0; i < 5; i++) {
      draw_explosion(narcox+random(96)-8, narcoy+random(64)-8);
    }
  }
  draw_swim(swimx,swimy, (swim_jaws == 0));
  GD.__end();
  
  // -------- do logic stuff
  scrollx += ((t % FLOW_SPEED) == 0);
  //swimx = (swimx + 1) % 400;
  if(swim_jaws > 0) {
    swim_jaws -= 1;
  }
  
  process_keypress();

/*
  if(touching_swimmer != 255) {
    SerialUSB.print("Enemy: ");
    SerialUSB.println(enemy_id, 10);
    SerialUSB.print("Swimmer: ");
    SerialUSB.println(swimmer_id, 10);
    SerialUSB.print("Touching swimmer: ");
    SerialUSB.println(touching_swimmer, 10);
  }

  if(touching_enemy != 255) {
    SerialUSB.print("Enemy: ");
    SerialUSB.println(enemy_id, 10);
    SerialUSB.print("Swimmer: ");
    SerialUSB.println(swimmer_id, 10);
    SerialUSB.print("Touching enemy: ");
    SerialUSB.println(touching_enemy, 10);
  }
*/  
  if (swim_jaws > 15 and (touching_swimmer == enemy_id || touching_enemy == swimmer_id)) {
    sunk_ship = true;
  }
  swimx = ((swimx + swimvx) % 400);
  swimy = ((swimy + swimvy) % 300);

  if(!sunk_ship) {
    if(narcoy > 170) { narcovy = -1; }
    if(narcoy < 130) { narcovy = 1; }
  } else {
    narcovy = 1;
    if(narcoy > 400) { narcovy = 0; }
  }
  narcoy += narcovy;
  t += 1;
}
