#D&D Map Creator
####_Build quality D&D Battlemaps on-the-fly!_

![Screenshot](pics/ss2.png)

##Installation
The easiest way to install this software:

- Download the source
- Install [LÖVE](https://love2d.org)
- OS X and Linux
 - On the command-line, run `/path/to/love Dnd-Map-Explorer/main.lua`
- Windows
 - Drag the whole folder `/DnD-Map-Explorer` onto your love executable

##Documentation

###Controls

_**Key** - Function_

####Drawing/Erasing
- _**C** - Change current color_
- _**D** - Hold down to draw with currently selected color_
- _**E** - Hold down to erase_
- _**J** - Hit twice to draw filled rectangle with currently selected color, once to choose first corner and again to choose opposite corner_
- _**K** - Hit twice to draw outlined rectangle with currently selected color, once to choose first corner and again to choose opposite corner_
- _**L** - Hit twice to draw line with currently selected color, once to choose begin point, again to choose end point_
- _**N** - Clear the grid_
- _**R-Shift** - Toggle fog editing_

####Grid Functions
- _**G** - Toggle gridlines_
- _**A** - Load a map, continue pressing to cycle through available maps. Press **Return** to load the selected map_
- _**S** - Save the current map to a file_
- _**-** - Zoom out_
- _**=** - Zoom in_

####Token Functions
- _**T** - Open new token dialog_
- _**Y** - Open token edit/delete dialog_
- _**M** - Toggle token snapping-to-grid_

####Network Functions
- _**B** - Connects to the server (if in Client mode)_
