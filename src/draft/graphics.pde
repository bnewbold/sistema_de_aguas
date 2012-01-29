
//static extern enemy_sprid;

// ================  INIT ===================
static void init_sprites() {
  GD.copy(PALETTE16A, sprite_sprpal, sizeof(sprite_sprpal));
  GD.copy(RAM_SPRIMG, sprite_sprimg, sizeof(sprite_sprimg));
}

static void clear_all_sprites() {
  for (int i = 0; i < 256; i++) {
    GD.sprite(i, 400, 400, 0, 0, 0);
  }
}

static void init_splashpage() {
  for (byte y = 0; y < 64; y++)
    GD.copy(RAM_PIC + y * 64, allsewage_pic + y * 64, 64);
  GD.copy(RAM_CHR, allsewage_chr, sizeof(allsewage_chr));
  GD.copy(RAM_PAL, allsewage_pal, sizeof(allsewage_pal));
  
  GD.__wstartspr(0);
  for (int rand_count = 0; rand_count < 20; rand_count += 1) {
    draw_standing_all(random(400),random(300));
  }
  GD.__end();
  
}

static void init_background() {
  for (byte y = 0; y < 64; y++)
    GD.copy(RAM_PIC + y * 64, allsewage_pic + y * 64, 64);
  GD.copy(RAM_CHR, allsewage_chr, sizeof(allsewage_chr));
  GD.copy(RAM_PAL, allsewage_pal, sizeof(allsewage_pal));
}

// ================  TRASH MANAGEMENT ===================

#define DEAD_TRASH_SPRID  54
#define NUM_TRASH         20
#define STUCKX            100

struct trash_item {
  int8 vx;
  int16 x, y;
  uint8 sprid, collid;
  boolean stuck;
};

static trash_item trash_bag[NUM_TRASH];
static uint8 trash_count, trash_stuck;

static uint8 get_stuck() {
  return trash_stuck;
}


static void init_trash() {
  for (int i = 0; i < NUM_TRASH; i++) {
    trash_bag[i].x = 400;
    trash_bag[i].y = 400;
    trash_bag[i].vx = 0;
    trash_bag[i].sprid = 0xFF;
    trash_bag[i].stuck = false;
    trash_bag[i].collid = 0xFF;
  }
  trash_count = 0;
  trash_stuck = 0;
}

static void cleanup_trash() {
  for (int i = 0; i < NUM_TRASH; i++) {
    if(trash_bag[i].x < 0) {
      trash_count -= 1;
      trash_bag[i].x = 400;
      trash_bag[i].y = 400;
      trash_bag[i].vx = 0;
      trash_bag[i].sprid = 0xFF;
      trash_bag[i].stuck = false;
    }
  }
}

static void add_trash() {
  if (trash_count == NUM_TRASH) return;
  int i;
  for (i = 0; i < NUM_TRASH; i++) {
    if(trash_bag[i].sprid == 0xFF) {
      trash_bag[i].x = 400;
      trash_bag[i].y = 25 + random(200);
      trash_bag[i].vx = 3 + random(5);
      trash_bag[i].sprid = 36;
      trash_bag[i].collid = 255;
      break;
    }
  }
}

static void update_trash() {
  for (int i = 0; i < NUM_TRASH; i++) {
    if (trash_bag[i].sprid == 0xFF) continue;
    if (trash_bag[i].stuck) continue;
    trash_bag[i].x -= ((t % (2*scrollvx)) == 0);
    if ((t % trash_bag[i].vx) == 0) {
      trash_bag[i].x -= 1;
    }
    if (trash_bag[i].sprid != DEAD_TRASH_SPRID && trash_bag[i].x <= STUCKX) {
      trash_bag[i].stuck = true;
      trash_bag[i].x = STUCKX;
      trash_stuck += 1;
    }
  }
}

static void check_trash(int cid) {
  for (int i = 0; i < NUM_TRASH; i++) {
    if (cid == trash_bag[i].collid) {
      trash_bag[i].sprid = DEAD_TRASH_SPRID;
      if (trash_bag[i].stuck) {
        trash_bag[i].stuck = false;
        trash_stuck -= 1;
      }
    }
  }
}
  
// ================  DRAWING ===================
static void draw_all_trash() {
  for (int i = 0; i < NUM_TRASH; i++) {
    if (trash_bag[i].sprid == 0xFF) continue;
    trash_bag[i].collid = GD.spr;
    draw_sprite(trash_bag[i].x,
                trash_bag[i].y,
                trash_bag[i].sprid,
                0,
                TARGET_GROUP);
  }
}
static void draw_standing_all(int x, int y) {
  draw_sprite(x     , y     , 36, 0, 1);
  draw_sprite(x     , y + 16, 45, 0, 0);
}

static void draw_narco(int x, int y, boolean sunk) {
  if(!sunk) {
    draw_sprite(x     , y + 00, 03, 0, 1);
    draw_sprite(x + 16, y + 00, 04, 0, 1);
    // periscope!
    enemy_sprid = GD.spr;
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
    draw_sprite(x + 00, y + 00, 54, 0, 0);
    draw_sprite(x + 16, y + 00, 55, 0, 0);
    draw_sprite(x + 00, y + 16, 63, 0, 0);
    draw_sprite(x + 16, y + 16, 64, 0, 0);
}

static void draw_swim(int x, int y, boolean is_open) {
  draw_sprite(x     , y     , 0, 0, 0);
  draw_sprite(x + 16, y     , 1, 0, 0);
  draw_sprite(x     , y + 16, 9, 0, 0);
  draw_sprite(x + 16, y + 16, 10, 0, 0);
  draw_sprite(x + 32, y + 16, 11, 0, 0);
  if(is_open) {
    weapon_sprid = GD.spr;
    draw_sprite(x + 32, y     , 2, 0, 0);
    draw_sprite(400, 400, 20, 0, 0);
  } else {
    draw_sprite(400, 400, 2, 0, 0);
    weapon_sprid = GD.spr;
    draw_sprite(x + 32, y     , 20, 0, 0);
  }
}
