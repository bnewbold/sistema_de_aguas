int atxy(int x, int y)
{
  return (y << 6) + x;
}

// ----------------------------------------------------------------------
//     qrand: quick random numbers
// ----------------------------------------------------------------------

static uint16_t lfsr = 1;

static void qrandSeed(int seed)
{
  if (seed) {
    lfsr = seed;
  } else {
    lfsr = 0x947;
  }
}

static byte qrand1()    // a random bit
{
  lfsr = (lfsr >> 1) ^ (-(lfsr & 1) & 0xb400);
  return lfsr & 1;
}

static byte qrand(byte n) // n random bits
{
  byte r = 0;
  while (n--)
    r = (r << 1) | qrand1();
  return r;
}
