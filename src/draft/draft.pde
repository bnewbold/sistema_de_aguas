#include <SPI.h>
#include <GD.h>

#include "background.h" // http://gameduino.com/results/3514e886/
#include "splash.h"     // http://gameduino.com/results/fe36d9fd/
#include "allsewage.h"  // http://gameduino.com/results/b2f4c588/
#include "sprites.h"    // http://gameduino.com/results/16fe50de/

#define SWIM_SPEED    1

#define WEAPON_GROUP  0
#define TARGET_GROUP  1

#define NUM_TRASH         32  // ugh, redefined

#define KEY_UP(x)      ((x >> 7) & 0x01)
#define KEY_DOWN(x)    ((x >> 6) & 0x01)
#define KEY_LEFT(x)    ((x >> 5) & 0x01)
#define KEY_RIGHT(x)   ((x >> 4) & 0x01)
#define KEY_C(x)       ((x >> 3) & 0x01)
#define KEY_V(x)       ((x >> 2) & 0x01)
#define KEY_SPACE(x)   ((x >> 1) & 0x01)
#define KEY_ESCAPE(x)  ((x >> 0) & 0x01)

static boolean last_key_space = false;  // last keypress a spacebar?
static unsigned int t = 0;  // global game counter

static uint16 swimx, swimy;  // swimmer position
static int8 swimvx, swimvy;  // velocity
static int8 weapon_sprid;
static uint8 jaws_closed;      // swimmer weapon state

static uint16 narcox, narcoy;
static int8 narcovx, narcovy;
static uint8 narco_sprid;
static boolean narco_sunk;
static uint8 enemy_sprid;


static unsigned int scrollx;  // background scroll
static unsigned int scrolly;
static int8 scrollvx; // background scroll speed (128 is one pixel/frame)

static uint16 trash_rate;
static unsigned char inchar;
static uint8 touching_weapon, touching_enemy;

void static process_keypress() {
  if(SerialUSB.available()) {
    inchar = SerialUSB.read();
    while(SerialUSB.available()) {
      inchar = SerialUSB.read();
    }
    //SerialUSB.println(inchar, 2);
    swimvx = 0;
    swimvy = 0;
    if (KEY_LEFT(inchar)) { swimvx -= SWIM_SPEED; }
    if (KEY_RIGHT(inchar)) { swimvx += SWIM_SPEED; }
    if (KEY_UP(inchar)) { swimvy -= SWIM_SPEED; }
    if (KEY_DOWN(inchar)) { swimvy += SWIM_SPEED; }
    if (KEY_SPACE(inchar) and !last_key_space) { jaws_closed = 20; }
    if (!KEY_SPACE(inchar)) { jaws_closed = 0; }
    last_key_space = KEY_SPACE(inchar);
    if (KEY_ESCAPE(inchar)) {
      clear_all_sprites();
      narco_sunk = false;
      narcoy = 150;
    }
  }
}

boolean static wait_screen() {
  if(SerialUSB.available()) {
    inchar = SerialUSB.read();
    while(SerialUSB.available()) {
      inchar = SerialUSB.read();
    }

    if (KEY_SPACE(inchar)) { return true; }
    if (KEY_ESCAPE(inchar)) { return true; }
    return false;
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
  trash_rate = 100;
  scrollx = 0;
  scrolly = 3;
  t = 0;
  
  delay(250);
  GD.begin();
  
  GD.wr(JK_MODE, 1);
  
  init_sprites();  // called twice
  GD.waitvblank();
  init_splashpage();
  
  while(!wait_screen()) {
    delay(100);
  }
  clear_all_sprites();
  GD.waitvblank();
  init_background();
  init_sprites();
  init_trash();
  
  add_trash();
  add_trash();
  add_trash();
}

void loop() 
{
  GD.waitvblank();
  
  // ------- do graphics drawing
  
  // check collisions
  touching_weapon = GD.rd(COLLISION + weapon_sprid);
  touching_enemy = GD.rd(COLLISION + enemy_sprid);
  
  // scroll background
  GD.wr16(SCROLL_X, scrollx);
  GD.wr16(SCROLL_Y, scrolly);
  GD.__wstartspr(0);
  //draw_standing_all(10,270);
  draw_all_trash();
  if (t > (72 * 30)) {
    draw_narco(narcox, narcoy, narco_sunk);
    if (narco_sunk) {
      for (uint8 i = 0; i < 5; i++) {
        draw_explosion(narcox+random(96)-8, narcoy+random(64)-8);
      }
    }
  }
  draw_swim(swimx,swimy, (jaws_closed == 0));
  GD.__end();
  
  // -------- do logic stuff
  scrollx += ((t % scrollvx) == 0);
  //swimx = (swimx + 1) % 400;
  if(jaws_closed > 0) {
    jaws_closed -= 1;
  }
  
  update_trash();
  cleanup_trash();
  
  process_keypress();
 
  if (jaws_closed > 15 and (touching_weapon == enemy_sprid || touching_enemy == weapon_sprid)) {
    narco_sunk = true;
  }
  
  if (jaws_closed > 15 and (touching_weapon != 255)) {
    check_trash(touching_weapon);
  }
  
  swimx = (swimx + swimvx);
  swimy = (swimy + swimvy);
  if (swimx > 380) swimx = 380;
  if (swimx < 32) swimx = 32;
  if (swimy > 250) swimy = 250;
  if (swimy < 50) swimy = 50;

  if(!narco_sunk) {
    if(narcoy > 170) { narcovy = -1; }
    if(narcoy < 130) { narcovy = 1; }
  } else {
    narcovy = 1;
    if(narcoy > 400) { narcovy = 0; }
  }
  if ((t % trash_rate) == 0 && (random(3) == 1)) {
    add_trash();
  }
  
  scrollvx = get_stuck() + 2;
  
  narcoy += narcovy;
  t += 1;
}
