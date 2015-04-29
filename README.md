# FrameByFrameAnimationApplication
This is an application I created while I was taking a required 2D Animation course for my major. I liked working at home, but didn't want to have to buy Photoshop for my personal computer, so I decided to create a little Processing program to do basic image editing operations on a series of frames so I could do the bulk of the work at home, and import the frames into Photoshop later to create the final animation. As the semester went on, I added a few extra features, like [onion skinning](http://en.wikipedia.org/wiki/Onion_skinning).

## How to use
### Setup and Saving
This is a [Processing](https://processing.org/) program, so you need to download Processing to use it from source. If you have an existing set of frames you'd like to use, place them in a `frames` folder next to the `.pde` file, with the files named `0.png`, `1.png`, and so forth. Otherwise, the first time you save any frames, the folder will be created next to the `.pde` file. To save your animation, press the `s` key, which will save the frames in sequencially numbered `.png` files in the `frames` folder. If you wish to work on a new animation, copy the files in the `frames` folder elsewhere, and remove all files from the `frames` folder.

### Basic operations
While in draw mode, left-click and drag to start drawing with the primary color, and right-click and drag to start drawing with the secondary color (useful for erasing if it is set as your canvas's background color). While in fill mode, left-click to fill a contiguous region of pixels (which are all the same color) with the primary color, and right-click to fill with the secondary color. To enter either of these modes, click the corresponding button on the left side of the screen (or simply start drawing on the canvas to enter draw mode).

The right side of the application is your color palette. Left-click one of the boxes of your color palette to change your primary color to the color shown in that box, and right-click to change your secondary color. Your color palette has twelve colors, which are all initially set to white, but each color can be changed at any time, persisting until the application is closed.

### Modifying settings
Click the button showing your current primary and secondary colors (left side, third from the top). This enters a mode where you can enter a command that lets you set a palette color. Type these numbers, separated by spaces: the index of the palette you want to set the color of (where the top is index 0, and increases as it goes down), then the red, green, and blue components of the color you'd like to set (where each component is an integer ranging from 0 to 255). So if you want to change the top box of your palette to red, you'd enter `0 255 0 0`, then press Enter/Return.

The button under that (left side, fourth from the top) shows your current brush size. Click it and type in a new brush size (a non-negative integer), followed by pressing Enter/Return, to set a new brush size.

### Onion skinning
By default, the application will show a slightly faded version of the current frame, a moderately faded version of the previous frame, and a heavily faded version of the frame before the previous frame. Any modifications you make to the canvas will only be to the current frame. If onion skinning is disabled, you will see a true color version of the current frame only. To toggle between onion skinning being enabled or disabled, press the spacebar key in either draw mode or fill mode.
