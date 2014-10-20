import java.util.*;
import javax.swing.*;
import java.io.File;

int POLYGON_FILL = 0;
int POLYGON_UNION = 1;
int CONVEX_HULL = 2;
int EXTRA_CREDIT = 3;
int INVALID = -1;

int DEFAULT_MODE = 100;
int INPUT_MODE = 101;

void ColorPixel(int x, int y, color c) {
  int pixelIndex = y*width+x;
  pixels[pixelIndex] = c;
  updatePixels();
}

boolean AreColorsSame(color c1, color c2) {
  if ((red(c1)==red(c2))&&(green(c1)==green(c2))&&(blue(c1)==blue(c2))) {
    return true;
  }
  else {
    return false;
  }
}

void FloodFill(int x, int y, color checkColor, color newColor) {
  color currentColor = get(x,y);
  
  if (AreColorsSame(checkColor,newColor)) {
    return;
  }
  Stack st = new Stack();
  
  Point currentPoint = new Point(x,y);
  st.push(currentPoint);

  while(!st.empty()) {
    currentPoint = (Point)st.pop();
    ColorPixel(currentPoint.x, currentPoint.y,newColor);
    
    currentColor = get(currentPoint.x+1,currentPoint.y);
    if(AreColorsSame(currentColor,checkColor)) {
      st.push(new Point(currentPoint.x+1,currentPoint.y));
    }
    currentColor = get(currentPoint.x-1,currentPoint.y);
    if(AreColorsSame(currentColor,checkColor)) {
      st.push(new Point(currentPoint.x-1,currentPoint.y));
    }
    currentColor = get(currentPoint.x,currentPoint.y+1);
    if(AreColorsSame(currentColor,checkColor)) {
      st.push(new Point(currentPoint.x,currentPoint.y+1));
    }
    currentColor = get(currentPoint.x,currentPoint.y-1);
    if(AreColorsSame(currentColor,checkColor)) {
      st.push(new Point(currentPoint.x,currentPoint.y-1));
    }
  } 
}

double determinant(Point p1, Point p2, Point p3) {
  return (p1.x*p2.y + p1.y*p3.x + p2.x*p3.y) - (p1.x*p3.y + p1.y*p2.x + p2.y*p3.x);
}

Comparator<Point> xPointCompare = new Comparator<Point>() {
  public int compare(Point p1, Point p2) {
    if(p1.x != p2.x) {
      return p1.x - p2.x;
    }
    else {
      if(p1.y != p2.y) {
        return p2.y - p1.y;
      }
      else {
        return 1;
      }
    }
  }
};
  
Comparator<Point> yPointCompare = new Comparator<Point>() {
  public int compare(Point p1, Point p2) {
    if(p1.y != p2.y) {
      return p1.y - p2.y;
    }
    else {
      if(p1.x != p2.x) {
        return p2.x - p1.x; 
      } 
      else {
        return 1; 
      }
    }
  }
};

Point IntersectionFinder(Segment seg1,Segment seg2) {
  // coefficients for a1*x + b1*y = c1 forms of the lines
  double a1 = seg1.p1.y - seg1.p2.y;
  double b1 = seg1.p2.x - seg1.p1.x;
  double c1 = b1*seg1.p1.y + a1*seg1.p1.x;
  double a2 = seg2.p1.y - seg2.p2.y;
  double b2 = seg2.p2.x - seg2.p1.x;
  double c2 = b2*seg2.p1.y + a2*seg2.p1.x;
  
  double x = 0;
  double y = 0;
  
  //find the intersection point
  double det = a1*b2-a2*b1;
  if (det == 0) {
    //lines are parallel in this case
    return null;
  }
  else {
    x = (b2*c1 - b1*c2)/det;
    y = (a1*c2 - a2*c1)/det;
  }
  
  //check to make sure (x,y) is a point on the line segments
  int seg1xMin = Math.min(seg1.p1.x,seg1.p2.x);
  int seg1xMax = Math.max(seg1.p1.x,seg1.p2.x);
  int seg1yMin = Math.min(seg1.p1.y,seg1.p2.y);
  int seg1yMax = Math.max(seg1.p1.y,seg1.p2.y);
  int seg2xMin = Math.min(seg2.p1.x,seg2.p2.x);
  int seg2xMax = Math.max(seg2.p1.x,seg2.p2.x);
  int seg2yMin = Math.min(seg2.p1.y,seg2.p2.y);
  int seg2yMax = Math.max(seg2.p1.y,seg2.p2.y);
  if ( ((x>=seg1xMin)&&(x<=seg1xMax)) && ((y>=seg1xMin)&&(y<=seg1yMax)) && ((x>=seg2xMin)&&(x<=seg2xMax)) && ((y>=seg2xMin)&&(y<=seg2yMax)) ) {
    x = Math.round(x);
    y = Math.round(y);
    return new Point((int)x,(int)y);
  }
  else {
    return null;
  }
}

class Point {
  public int x;
  public int y;

  public Point() {
    x = 0;
    y = 0;
  }

  public Point(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  public boolean equals(Object obj) {
    if(!(obj instanceof Point)) {
      return false;
    }  
    else {
      return (((Point)obj).x == x && ((Point)obj).y == y);
    }
  }
  
  public String toString() {
    return "(" + this.x + ", " + this.y + ")";  
  }
}

class Segment {
  public Point p1;
  public Point p2;
  public color pColor;

  public Segment() {
    p1 = new Point(0, 0);
    p2 = new Point(0, 0);
    pColor = color(0,0,0);
  }
  
  public Segment(Point p1, Point p2) {
    this.p1 = new Point(p1.x, p1.y);
    this.p2 = new Point(p2.x, p2.y);
    pColor = color(0,0,0);  
  }

  public Segment(Point p1, Point p2, color pColor) {
    this.p1 = new Point(p1.x, p1.y);
    this.p2 = new Point(p2.x, p2.y);
  }
  
  public boolean equals(Object obj) {
    if(!(obj instanceof Segment)) {
      return false;
    }
    else {
      return (((Segment)obj).p1 == p1 && ((Segment)obj).p2 == p2 || ((Segment)obj).p2 == p1 && ((Segment)obj).p1 == p2);
    }
  }
  
  public boolean intersects(Segment seg) {
    return (int)Math.signum(determinant(p1, p2, seg.p1)) != (int)Math.signum(determinant(p1, p2, seg.p2)); 
  }

  public void sortPointsX() {
    if (p2.x < p1.x) {
      Point temp = p1;
      p1 = p2;
      p2 = temp;
    } 
    else if (p2.x == p1.x) {
      if (p2.y < p1.y) {
        Point temp = p1;
        p1 = p2;
        p2 = p1;
      }
    }
  }
  
  public void sortPointsY() {
    if (p2.y < p1.y) {
      Point temp = p1;
      p1 = p2;
      p2 = temp;
    } 
    else if (p2.y == p1.y) {
      if (p2.x < p1.x) {
        Point temp = p1;
        p1 = p2;
        p2 = p1;
      }
    }
  }

  public void drawLine() {
    // Implementation of the Bresenhaum line-drawing algorithm
    sortPointsX();
    int dx = p2.x - p1.x;
    int dy = p2.y - p1.y;
    int tdx = dx+dx;
    int tdy = dy+dy;
    if(dx != 0 && Math.abs(dy) <= Math.abs(dx)) {
      int y = p1.y;
      int p = tdy - dx;
      int inc = (tdy > 0) ? 1 : -1;
      tdy = Math.abs(tdy);
      for(int i = p1.x; i < p2.x; i++) {
        ColorPixel(i,y,pColor);
        if(p >= 0) {
            y += inc;
            p += tdy - tdx;
        }
        else {
          p += tdy;
        }
      }  
    }
    else if(dy != 0) {
      sortPointsY();
      dx = p2.x - p1.x;
      dy = p2.y - p1.y;
      tdx = dx+dx;
      tdy = dy+dy;
      int x = p1.x;
      int p = tdx - dy;
      int inc = (tdx > 0) ? 1 : -1;
      tdx = Math.abs(tdx);
      for(int i = p1.y; i < p2.y; i++) {
        ColorPixel(x,i,pColor);
        if(p >= 0) {
          x += inc;
          p += tdx - tdy;
        }  
        else { 
          p += tdx;
        }
      }
    }
    else if(dx == 0) {
      sortPointsY();
      for(int i = p1.y; i < p2.y; i++) {
        set(p1.x, i, 0); 
      }
    }
    else if(dy == 0) {
      for(int i = p1.x; i < p2.x; i++) {
        set(i, p1.y, 0);
      }  
    }
    ColorPixel(p1.x, p1.y, pColor);
    ColorPixel(p2.x, p2.y, pColor);
  }
}

class Polygon {
  public ArrayList<Point> vertices;
  public ArrayList<Segment> segments;
  public color fillColor;
  public color borderColor;
  
  public Polygon() {
    vertices = new ArrayList<Point>();  
    segments = new ArrayList<Segment>();
    fillColor = color(255, 255, 255);
    borderColor = color(0, 0, 0);
  }
  
  public Polygon(ArrayList<Point> vlist) {
    this();
    this.vertices = vlist;
    generateLineSegments();
  }
  
  public ArrayList<Segment> generateLineSegments() {
    generateLineSegments(borderColor);
    return segments;  
  }
  
  public ArrayList<Segment> generateLineSegments(color polygonColor) {
    borderColor = polygonColor;
    segments = new ArrayList<Segment>();
    for(int i = 1; i < vertices.size(); i++) {
      segments.add(new Segment(vertices.get(i-1),vertices.get(i),polygonColor));
    }
    if(vertices.size() > 0) {
      segments.add(new Segment(vertices.get(vertices.size()-1),vertices.get(0),polygonColor));
    }  
    return segments;
  }
  
  public void drawPolygon(color polygonColor) {
    borderColor = polygonColor;
    generateLineSegments();
    for(Segment s : segments) {
      s.drawLine();
    }
  }
  
  public void colorPolygon(color polygonColor) {
    fillColor = polygonColor;
    if(vertices.size() > 0) {
      Point lowestx = vertices.get(0);
      Point highestx = vertices.get(0);
      Point lowesty = vertices.get(0);
      Point highesty = vertices.get(0);
      for(int i = 1; i < vertices.size(); i++) {
        if (vertices.get(i).x < lowestx.x) {
          lowestx = vertices.get(i);
        }
        if (vertices.get(i).x > highestx.x) {
          highestx = vertices.get(i);
        }
        if (vertices.get(i).y < lowesty.y) {
          lowesty = vertices.get(i);
        }
        if (vertices.get(i).y > highesty.y) {
          highesty = vertices.get(i);
        }
      }
      int meanx = (int)(lowestx.x + highestx.x)/2;
      int meany = (int)(lowesty.y + highesty.y)/2;
      
      color currentColor = get(meanx,meany);
      FloodFill(meanx,meany,currentColor,polygonColor);   
    } 
  }
}

class Intersection {

  public Point intersect;
  public Segment segment1;
  public Segment segment2;
  
  public Intersection() {
    intersect = new Point();
    segment1 = new Segment();
    segment2 = new Segment();
  }
  
  public Intersection(Point intsersect, Segment seg1, Segment seg2) {
    this.intersect = intersect;
    this.segment1 = seg1;
    this.segment2 = seg2;  
  }
  
  public boolean liesOnSegment(Segment seg) {
    if(seg == segment1 || seg == segment2)
      return true;
    else
      return false;
  }
  
}

class ConvexHull {
  
  public ArrayList<Point> points;
  public ArrayList<Point> hull;
  
  public ConvexHull() { 
    points = new ArrayList<Point>();
    hull = new ArrayList<Point>();
  }
  
  public void drawHull() {
    // Generate line segments
    ArrayList<Segment> segments = new ArrayList<Segment>();
    Point previous = (hull.size() > 0) ? hull.get(0) : null;
    for(int i = 1; i < hull.size(); i++) {
      segments.add(new Segment(previous, hull.get(i))); 
      previous = hull.get(i);
    }
    if(hull.size() > 0) {
      segments.add(new Segment(hull.get(0), hull.get(hull.size()-1)));  
    }
    
    // Draw line segments
    for(Segment s : segments) {
      s.drawLine();  
    }
  }
  
  public void computeConvexHull() {
    if(points.size() > 1) {
      Collections.sort(points, xPointCompare);
      Point leftMost = points.get(0);
      Point rightMost = points.get(points.size()-1);
      points.remove(leftMost);
      points.remove(rightMost);
      
      ArrayList<Point> topPoints = new ArrayList();
      ArrayList<Point> bottomPoints = new ArrayList();
      for(Point p : points) {
         if(determinant(leftMost, rightMost, p) > 0) {
           topPoints.add(p); 
         }
         else {
           bottomPoints.add(p);  
         }
      }
      
      ArrayList<Point> topHull = new ArrayList<Point>();
      topHull.add(leftMost);
      if(topPoints.size() > 0) {
        for(Point p : topPoints) {
          topHull.add(p);
          double det = 0;
          if(topHull.size() > 2) {
            det = determinant(topHull.get(topHull.size()-3),
                                                  topHull.get(topHull.size()-2),
                                                  topHull.get(topHull.size()-1));
            if(det < 0) {
              //println(det);
            }  
          }
          while(topHull.size() > 2 && determinant(topHull.get(topHull.size()-3),
                                                  topHull.get(topHull.size()-2),
                                                  topHull.get(topHull.size()-1)) >= 0) {
            
            topHull.remove(topHull.size()-2);                                                     
          }
        } 
      }
      
      ArrayList<Point> bottomHull = new ArrayList<Point>();
      bottomHull.add(rightMost);
      if(bottomPoints.size() > 0) {
        for(int i = bottomPoints.size()-1; i >= 0; i--) {
          bottomHull.add(bottomPoints.get(i));
          double det = 0;
          if(topHull.size() > 2) {
            det = determinant(topHull.get(topHull.size()-3),
                                                  topHull.get(topHull.size()-2),
                                                  topHull.get(topHull.size()-1));
            if(det < 0) {
              //println(det);
            }  
          }
          while(bottomHull.size() > 2 && determinant(bottomHull.get(bottomHull.size()-3),
                                                     bottomHull.get(bottomHull.size()-2),
                                                     bottomHull.get(bottomHull.size()-1)) >= 0) {
            bottomHull.remove(bottomHull.size()-2);                                            
          } 
        }   
      }
      
      hull = topHull;
      hull.addAll(bottomHull);
    }
    else {
      hull = new ArrayList<Point>(points); 
    }
  }
}

interface Task {
  public void performTask();
}

class PolygonTask implements Task {
 
  Polygon polygon;
  
  public PolygonTask() {
    polygon = new Polygon();  
  }
  
  public void performTask() {
    fill(255, 255, 255);
    println("Performing Polygon Task.");
    polygon.drawPolygon(color(0));
    polygon.colorPolygon(color(255, 0, 0));
  }
  
}

class PolygonUnionTask implements Task {
 
  Polygon polygon1;
  Polygon polygon2;
  
  public PolygonUnionTask() {
    polygon1 = new Polygon();
    polygon2 = new Polygon();  
  }
  
  public void performTask() {
    // Given two convex polygons finds the union polygon and colors it in.
    fill(255, 255, 255);
    println("Performing Polygon Union Task.");
    polygon1.generateLineSegments();
    polygon2.generateLineSegments();
    
    ArrayList<Intersection> intersections = new ArrayList<Intersection>();
    for(Segment seg1 : polygon1.segments) {
      for(Segment seg2 : polygon2.segments) {
        if(seg1.intersects(seg2)) {
            Point intersect = IntersectionFinder(seg1, seg2);
            Intersection intersection = new Intersection(intersect, seg1, seg2);
            intersections.add(intersection);
        }
      }  
    }
    
    // TODO:
    // What is left is to traverse a polygon and check at each vertex if one needs to switch polygons
    // All the while draw the valid segments and any intermediate segments due to intersection points
  }
  
}

class ConvexHullTask implements Task {
  
  ConvexHull H;
  
  public ConvexHullTask() { 
    H = new ConvexHull();
  }
  
  public void performTask() {
    fill(255, 255, 255);
    println("Performing Convex Hull Task.");
    H.computeConvexHull();
    H.drawHull();
  }

}

class Parser {
  
  public String filename;
  public int currentTask;
  public int mode;
  ArrayList<Task> tasks;
  
  public Parser() {
    tasks = new ArrayList<Task>();
    currentTask = INVALID;
    mode = DEFAULT_MODE;
    String defaultFilename = "/home/nurc-08/sketchbook/project_1/project_java/input.txt"; 
    
    File inputFile = null;
    Scanner fileReader = null;
    if(mode == INPUT_MODE) {
      boolean fileSelected = false;
      while(!fileSelected) {
        Object option = JOptionPane.showInputDialog(null, "Type the name of the file or hit cancel to use the file browser", "Configuration", JOptionPane.PLAIN_MESSAGE, null, null,"");
        if(option == null) {
          JFileChooser chooser = new JFileChooser();
          int choice = chooser.showOpenDialog(null);
          if (choice == JFileChooser.APPROVE_OPTION) {
            File chosenFile = chooser.getSelectedFile();
            fileSelected = true;
          }
          else {
            int useDefaultFile = JOptionPane.showConfirmDialog(null, "Use the default file?", "Configuration", JOptionPane.YES_NO_OPTION);   
            if(useDefaultFile == JOptionPane.YES_OPTION) {
              try {
                filename = defaultFilename;
                inputFile = new File(filename);
                fileReader = new Scanner(inputFile);
                fileSelected = true; 
              }
              catch(Exception e) {
                  int exitOption = JOptionPane.showConfirmDialog(null, defaultFilename, "Bad Default", JOptionPane.YES_NO_OPTION); 
                  if(exitOption == JOptionPane.YES_OPTION) {
                    System.exit(1);
                  }
                  else {
                    fileSelected = false;  
                  }
              }
            }
          }
        }
        else {
          try {
           filename = (String)option; 
           inputFile = new File(filename);
           fileReader = new Scanner(inputFile);
           fileSelected = true;
          }
          catch(Exception e) {
            JOptionPane.showMessageDialog(null, "Invalid filename. Please try again.");
          }
        }
      }
    }
    else {
      try {
        filename = defaultFilename;
        inputFile = new File(filename);
        fileReader = new Scanner(inputFile);
      }
      catch(Exception e) {
        JOptionPane.showMessageDialog(null, "Could not open default file."); 
      }
    }
    
    String line;
    int polygonSelect = 1;
    Task taskBuffer = new PolygonTask();
    while(fileReader != null && fileReader.hasNextLine()) {
      line = fileReader.nextLine().trim().toUpperCase();
      if(line.equals("P")) { 
        currentTask = POLYGON_FILL;
        taskBuffer = new PolygonTask();
        tasks.add(taskBuffer); 
      }
      else if(line.equals("U, P1, P2")) {  
        currentTask = POLYGON_UNION;
        taskBuffer = new PolygonUnionTask();
        tasks.add(taskBuffer); 
      }
      else if(line.equals("H, S")) {  
        currentTask = CONVEX_HULL;
        taskBuffer = new ConvexHullTask();
        tasks.add(taskBuffer);
      }
      else if(currentTask != INVALID) {
        if(line.equals("P1")) {
          polygonSelect = 1;  
        }
        else if(line.equals("P2")) {
          polygonSelect = 2;  
        }
        else {
          // Parse the points using the split function
          String[] strValues = line.split(" ");
          Integer[] values = new Integer[strValues.length];
          Point p = new Point();
          for(int i = 0; i < values.length; i++) {
            values[i] = Integer.parseInt(strValues[i]);  
          }
          if(values.length >= 2) {
            p.x = values[0];
            p.y = values[1];
          }
          
          if(currentTask == POLYGON_FILL) {
            ((PolygonTask)taskBuffer).polygon.vertices.add(p);   
          }
          else if(currentTask == POLYGON_UNION) {
            if(polygonSelect == 1) {
              ((PolygonUnionTask)taskBuffer).polygon1.vertices.add(p);
            }
            else {
              ((PolygonUnionTask)taskBuffer).polygon2.vertices.add(p);
            }  
          }
          else if(currentTask == CONVEX_HULL) {
              ((ConvexHullTask)taskBuffer).H.points.add(p);
          }
        } 
      }
    }
  }
}

void setup() {
  size(600,600);
  loadPixels();
  color pink = color(255,102,204);
  color black = color(0,0,0);
  /*geom_controller = new ControlP5(this);
  canv = new GeomCanvas();
  geom_controller.addCanvas(canv);*/
  fill(color(255, 255, 255));
  frameRate(30);
  
  Point s1p1 = new Point(50,50);
  Point s1p2 = new Point(80,140);
  Segment s1 = new Segment(s1p1,s1p2,black);
  Point s2p1 = new Point(40,70);
  Point s2p2 = new Point(90,70);
  Segment s2 = new Segment(s2p1,s2p2,black);
  s1.drawLine();
  s2.drawLine();
  
  Point intersect = IntersectionFinder(s1,s2);
  if (intersect != null) {
    ColorPixel(intersect.x,intersect.y,pink);
    println("Intersection Found.");
  }
  
  // Bresenham line-drawing Test Code
  // Test line: Generates two random coordinates and drawes a line between them
  Random rg = new Random();
  int tx1 = rg.nextInt(width);
  int ty1 = rg.nextInt(height);
  int tx2 = rg.nextInt(width);
  int ty2 = rg.nextInt(height);
  Point tp1 = new Point(tx1, ty1);
  Point tp2 = new Point(tx2, ty2);
  Segment s = new Segment(tp1, tp2);
  s.drawLine();
  
  // Convex Hull Test Code
  ConvexHull ch = new ConvexHull();
  ArrayList<Point> alp = new ArrayList();
  for(int i = 0; i < 100; i++) {
    int x = rg.nextInt(350)+150;
    int y = rg.nextInt(350)+150;
    Point pi = new Point(x,y);
    while(alp.contains(pi)) {
      x = rg.nextInt(350)+150;
      y = rg.nextInt(350)+150;
      pi = new Point(x,y);
    }
    set(x, y, 0);
    alp.add(pi);  
  }
  ch.points = alp; 
  ch.computeConvexHull();
  ch.drawHull();

  updatePixels();
  Parser taskParser = new Parser();
  
  
  
  for(int i = 0; i < taskParser.tasks.size(); i++) {
    taskParser.tasks.get(i).performTask();
  }
}
