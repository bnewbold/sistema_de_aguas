

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
        jaws_closed = 20;
        break;
      case 'S':
        swimy += SWIM_SPEED;
        jaws_closed = 20;
        break;
      case 'A':
        swimx -= SWIM_SPEED;
        jaws_closed = 20;
        break;
      case 'D':
        swimx += SWIM_SPEED;
        jaws_closed = 20;
        break;
      case ' ':
        jaws_closed = 20;
        break;
      default:
        break;
    }
  }
}
