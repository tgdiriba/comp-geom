Project 1 Instruction
===

This code takes inputs through a file whose path can be provided in two ways.
When run the user will be prompted to either enter the entire path of the input text file or select it from a file chooser.

The format of the input file is as laid out in the project specifications with a additional element for the extra credit.

Line Clipping Test Cases
---
In order to test the line clipping code, additional test cases may be appended to the input file in the following format:

P, C

POL

X1, Y1

X2, Y2
.
.
.

XN, YN

S

X1 Y1

X2, Y2


Where the P, C indicates that this is a test case for line clipping while POL starts the vertices for the polygon in counterclockwise order. And S starts the two points for the line segment.

Bug Considerations
---
There are some issues with drawing tight polygon bounds resulting in polygons being open when they should be closed. This may cause problems with the flood fill algorithm.
