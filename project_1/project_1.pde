import controlP5.*;
import java.util.Comparator;
import java.util.Collections;
import java.util.Random;

ControlP5 geom_controller;
Canvas canv;

public Comparator<Point> xPointCompare = new Comparator<Point>() {
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
  
public static Comparator<Point> yPointCompare = new Comparator<Point>() {
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
  
  public String toString() {
    return "(" + this.x + ", " + this.y + ")";  
  }
}

class Segment {
  public Point p1;
  public Point p2;

  public Segment() {
    p1 = new Point(0, 0);
    p2 = new Point(0, 0);
  }

  public Segment(Point p1, Point p2) {
    this.p1 = p1;
    this.p2 = p2;
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

  public void drawLine(PApplet app) {
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
        app.set(i,y,0);
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
        app.set(x,i,0);
        if(p >= 0) {
          x += inc;
          p += tdx - tdy;
        }  
        else { 
          p += tdx;
        }
      }
    }
    app.set(p1.x, p1.y, 0);
    app.set(p2.x, p2.y, 0);
  }
}

class ConvexHull {
  
  public ArrayList<Point> points;
  public ArrayList<Point> hull;
  
  public int determinant(Point p1, Point p2, Point p3) {
    return (p1.x*p2.y + p1.y*p3.x + p2.x*p3.y) - (p1.x*p3.y + p1.y*p2.x + p2.y*p3.x);
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
          while(topHull.size() > 2 && determinant(topHull.get(topHull.size()-3),
                                                  topHull.get(topHull.size()-2),
                                                  topHull.get(topHull.size()-1)) > 0) {
            topHull.remove(topHull.size()-2);                                                     
          }
        } 
      }
      
      ArrayList<Point> bottomHull = new ArrayList<Point>();
      bottomHull.add(rightMost);
      if(bottomPoints.size() > 0) {
        for(int i = bottomPoints.size()-1; i >= 0; i--) {
          bottomHull.add(bottomPoints.get(i));
          while(bottomHull.size() > 2 && determinant(bottomHull.get(bottomHull.size()-3),
                                                     bottomHull.get(bottomHull.size()-2),
                                                     bottomHull.get(bottomHull.size()-1)) > 0) {
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

class GeomCanvas extends Canvas {

  public void setup(PApplet app) {
    app.size(600, 600);
    app.background(255, 255, 255);
    app.frameRate(30);
    
    
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
    s.drawLine(app);
    // Real line
    app.stroke(1);
    app.line(tp1.x, tp1.y, tp2.x, tp2.y);
    
    
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
      app.set(x, y, 0);
      alp.add(pi);  
    }
    alp.add(new Point(100,500));
    alp.add(new Point(500,100));
    alp.add(new Point(100,100));
    alp.add(new Point(500,500));
    alp.add(new Point(50,300));
    alp.add(new Point(550,300));
    ch.points = alp; 
    ch.computeConvexHull();
    // Displaying Convex Hull
    Point previous = (ch.hull.size() > 0) ? ch.hull.get(0) : null;
    for(int i = 1; i < ch.hull.size(); i++) {
      app.line(previous.x, previous.y, ch.hull.get(i).x, ch.hull.get(i).y);
      previous = ch.hull.get(i);
    }
    if(ch.hull.size() > 0) {
      app.line(ch.hull.get(0).x, ch.hull.get(0).y, ch.hull.get(ch.hull.size()-1).x, ch.hull.get(ch.hull.size()-1).y);  
    }
  }

  public void draw(PApplet app) {
    
  }
}

void setup() {
  geom_controller = new ControlP5(this);
  canv = new GeomCanvas();
  geom_controller.addCanvas(canv);
}

