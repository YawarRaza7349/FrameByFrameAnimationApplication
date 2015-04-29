import java.util.*;

List<PImage> frames; // list of the frames of the user's animation
List<Boolean> bools; // has the frame at the corresponding index been modified?
int index; // index of the current frame being drawn to
boolean keyReleased; // was a key just released?
PGraphics buffer; // current buffer that the user is drawing on
color left; // color used when drawing with the left mouse button
color right; // color used when drawing with the right mouse button ("erasing")
color[] colors; // color palette available
int selection; // current mode of the application
int brush; // brush size
String input; // textual input given with keyboard commands
boolean onionSkins; // are onion skins on?

// different modes the application can be in
final int DRAW = 0; // similar to other applications' "pencil"/"brush" tools
final int FILL = 1; // similar to other applications' "paint bucket" tool
final int COLOR = 2; // user types in the command to set a color of their color palette
final int BRUSH = 3; // user types in the command to set the size of their brush

void fillRegion(int x, int y, color c)
{
  // keeps track of whether a pixel has been colored in to avoid redundant operations
  BitSet bits = new BitSet(buffer.width * buffer.height);
  bits.clear();
  buffer.loadPixels();
  color orig = buffer.pixels[y * buffer.width + x];
  if(c == orig)
  {
    return;
  }
  // the queue used for the breadth-first outward filling of pixels from the mouse click point
  ArrayDeque<Integer> ad = new ArrayDeque<Integer>();
  ad.add(y * buffer.width + x);
  while(!ad.isEmpty())
  {
    int a = ad.remove();
    if(a >= buffer.pixels.length || a < 0 || bits.get(a))
    {
      continue;
    }
    // only set a contiguous region of the exact same color as the original mouse click point
    if(buffer.pixels[a] != orig)
    {
      bits.set(a);
      continue;
    }
    buffer.pixels[a] = c;
    bits.set(a);
    ad.add(a - 1);
    ad.add(a + 1);
    ad.add(a - width);
    ad.add(a + width);
    ad.add(a - width - 1);
    ad.add(a - width + 1);
    ad.add(a + width - 1);
    ad.add(a + width + 1);
  }
  buffer.updatePixels();
}

void setup()
{
  size(1840, 960);
  background(255);
  index = 0;
  frames = new ArrayList<PImage>();
  bools = new ArrayList<Boolean>();
  int fileNum = 0;
  PImage currImage;
  while((currImage = loadImage("frames/" + fileNum + ".png")) != null)
  {
    frames.add(currImage);
    ++fileNum;
    bools.add(false);
  }
  // start a new sequence of frames since one doesn't already exist
  if(frames.size() == 0)
  {
    PGraphics img = createGraphics(width, height);
    img.beginDraw();
    img.fill(255);
    img.noStroke();
    img.rect(0, 0, width, height);
    img.endDraw();
    frames.add(img.get());
    bools.add(false);
  }
  buffer = createGraphics(width, height);
  buffer.beginDraw();
  buffer.image(frames.get(0), 200, 0);
  buffer.noSmooth();
  buffer.endDraw();
  left = #000000;
  right = #FFFFFF;
  colors = new color[12];
  for(int i = 0; i < colors.length; ++i)
  {
    colors[i] = #FFFFFF;
  }
  selection = DRAW;
  brush = 10;
  input = "";
  onionSkins = true;
}

void draw()
{
  try
  {
    background(255);
    line(199, 0, 199, height);
    line(1640, 0, 1640, height);
    
    if(onionSkins)
    {
      if(index > 1)
      {
        image(frames.get(index - 2).get(), 200, 0);
      }
      // fade previous frames to emphasize the current frame that the user is editing
      tint(255, 170);
      if(index != 0)
      {
        image(frames.get(index - 1).get(), 200, 0);
      }
      tint(255, 170);
    }
    image(buffer.get(200, 0, 1440, height), 200, 0);
    noTint();
    
    // buttons for changing the mode
    fill(255);
    // highlight current mode
    stroke(selection == DRAW ? #FF0000 : 0);
    rect(50, 50, 100, 100);
    stroke(selection == FILL ? #FF0000 : 0);
    rect(50, 200, 100, 100);
    stroke(selection == COLOR ? #FF0000 : 0);
    rect(50, 350, 100, 100);
    stroke(selection == BRUSH ? #FF0000 : 0);
    rect(50, 500, 100, 100);
    stroke(0);
    
    fill(0);
    textFont(createFont("Ubuntu Condensed", 36));
    textAlign(CENTER, CENTER);
    text("Draw", 100, 100);
    text("Fill", 100, 250);
    text(str(brush), 100, 550);
    textSize(18);
    text(input, 100, 650); 
    
    // show the current "brush" and "erase" colors
    fill(right);
    rect(83, 383, 67, 67);
    fill(left);
    rect(50, 350, 67, 67);
    
    // show the color palette
    for(int i = 0; i < colors.length; ++i)
    {
      fill(colors[i]);
      rect(1665, 25 + 75 * i, 150, 50);
    }
    
    if(mousePressed)
    {
      if(mouseButton == LEFT)
      {
        // clicking various on-screen buttons
        if(mouseX < 150 && mouseX > 50 && mouseY < 150 && mouseY > 50)
        {
          selection = DRAW;
          input = "";
        }
        if(mouseX < 150 && mouseX > 50 && mouseY < 300 && mouseY > 200)
        {
          selection = FILL;
          input = "";
        }
        if(mouseX < 150 && mouseX > 50 && mouseY < 450 && mouseY > 350)
        {
          selection = COLOR;
          input = "";
        }
        if(mouseX < 150 && mouseX > 50 && mouseY < 600 && mouseY > 500)
        {
          selection = BRUSH;
          input = "";
        }
        if(mouseX > 1665 && mouseX < 1815)
        {
          for(int i = 0; i < colors.length; ++i)
          {
            if(mouseY > 25 + 75 * i && mouseY < 75 * (i + 1))
            {
              left = colors[i];
              break;
            }
          }
        }
        if(mouseX >= 200 && mouseX < 1640)
        {
          switch(selection)
          {
            case COLOR:
            case BRUSH:
              selection = DRAW;
            case DRAW:
              // freeform drawing as a series of small lines
              buffer.beginDraw();
              buffer.strokeWeight(brush);
              buffer.stroke(left);
              buffer.line(pmouseX, pmouseY, mouseX, mouseY);
              buffer.endDraw();
              bools.set(index, true);
              break;
            case FILL:
              fillRegion(mouseX, mouseY, left);
              break;
          }
        }
      }
      else
      {
        if(mouseX > 1665 && mouseX < 1815)
        {
          for(int i = 0; i < colors.length; ++i)
          {
            if(mouseY > 25 + 75 * i && mouseY < 75 * (i + 1))
            {
              // select an "erase" color by right-clicking on the color palette, instead of left-clicking
              right = colors[i];
              break;
            }
          }
        }
        if(mouseX >= 200 && mouseX < 1640)
        {
          switch(selection)
          {
            case COLOR:
            case BRUSH:
              selection = DRAW;
            case DRAW:
              buffer.beginDraw();
              buffer.strokeWeight(brush);
              buffer.stroke(right);
              buffer.line(pmouseX, pmouseY, mouseX, mouseY);
              buffer.endDraw();
              bools.set(index, true);
            case FILL:
              fillRegion(mouseX, mouseY, right);
              break;
          }
        }
      }
    }
    
    if(keyReleased)
    {
      // move to the previous frame
      if(keyCode == LEFT)
      {
        // save the buffer to the appropriate frame in the frames list
        frames.set(index, buffer.get(200, 0, 1440, height));
        PImage copy = frames.get(index).get();
        //copy.filter(INVERT);
        //frames.get(index).mask(copy);
        // add a frame before the initial frame
        if(index == 0)
        {
          PGraphics img = createGraphics(width, height);
          img.beginDraw();
          img.fill(255);
          img.noStroke();
          img.rect(0, 0, width, height);
          img.endDraw();
          frames.add(0, img.get());
          bools.add(0, false);
        }
        else
        {
          --index;
        }
        buffer.beginDraw();
        buffer.background(255);
        buffer.image(frames.get(index), 200, 0);
        buffer.endDraw();
        keyReleased = false;
        return;
      }
      // move to the next frame
      if(keyCode == RIGHT)
      {
        frames.set(index, buffer.get(200, 0, 1440, height));
        PImage copy = frames.get(index).get();
        //copy.filter(INVERT);
        //frames.get(index).mask(copy);
        ++index;
        // add a frame after the final frame
        if(index == frames.size())
        {
          PGraphics img = createGraphics(width, height);
          img.beginDraw();
          img.fill(255);
          img.noStroke();
          img.rect(0, 0, width, height);
          img.endDraw();
          frames.add(img.get());
          bools.add(false);
        }
        buffer.beginDraw();
        buffer.background(255);
        buffer.image(frames.get(index), 200, 0);
        buffer.endDraw();
        keyReleased = false;
        return;
      }
      // clear buffer
      if(keyCode == DELETE)
      {
        buffer.beginDraw();
        buffer.background(255);
        buffer.pushStyle();
        buffer.fill(255);
        buffer.noStroke();
        buffer.rect(0, 0, width, height);
        buffer.popStyle();
        buffer.endDraw();
        keyReleased = false;
        return;
      }
      // save the animation
      if(key == 's')
      {
        frames.set(index, buffer.get(200, 0, 1440, height));
        for(int i = 0; i < frames.size(); ++i)
        {
          // only save frames if they've been modified
          if(bools.get(i))
          {
            frames.get(i).save("frames/" + i + ".png");
          }
        }
        keyReleased = false;
      }
      keyReleased = false;
    }
  }
  // if anything bad happens, save the user's work
  catch(Exception e)
  {
    for(int i = 0; i < frames.size(); ++i)
    {
      if(bools.get(i))
      {
        frames.get(i).save("frames/" + i + ".png");
      }
    }
  }
}

void keyReleased()
{
  keyReleased = true;
}

void keyTyped()
{
  if(key != CODED)
  {
    if(key == BACKSPACE && input.length() != 0)
    {
      input = input.substring(0, input.length() - 1);
    }
    // execute command
    else if(key == ENTER || key == RETURN)
    {
      switch(selection)
      {
        case COLOR: // syntax: "<palette index> <red 0-255> <green 0-255> <blue 0-255>"
          String[] tokens = splitTokens(input);
          if(tokens.length == 4)
          {
            colors[int(tokens[0])] = color(int(tokens[1]), int(tokens[2]), int(tokens[3]));
          }
          input = "";
          selection = DRAW;
          break;
        case BRUSH: // syntax: "<brush size>"
          try
          {
            brush = int(input);
          }
          catch(Exception e)
          {
          }
          input = "";
          selection = DRAW;
          break;
      }
    }
    else
    {
      // only allow numeric or space input
      if((selection == COLOR || selection == BRUSH) && ((key >= '0' && key <= '9') || key == ' '))
      {
        input += str(key);
      }
      else if(key == ' ')
      {
        onionSkins = !onionSkins;
      }
    }
  }
}
