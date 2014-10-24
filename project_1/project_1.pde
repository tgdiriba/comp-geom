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

boolean COMPLETE = false;

Parser taskParser;
int taskIndex = 0;

void ColorPixel(int x, int y, color c) {
  int pixelIndex = y*width+x;
  pixels[pixelIndex] = c;
  updatePixels();
}

void ColorPixel(Point p, color c) {
  ColorPixel(p.x, p.y, c);  
}

void setPixelColor(int x, int y, color c) {
  int pixelIndex = y*width+x;
  pixels[pixelIndex] = c;
}

void clearScreen() {
  for(int i = 0; i < width*height; i++) {
    pixels[i] = color(255,255,255);
  }  
  updatePixels();
}

boolean AreColorsSame(color c1, color c2) {
  if ((red(c1)==red(c2))&&(green(c1)==green(c2))&&(blue(c1)==blue(c2))) {
    return true;
  } else {
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
    // setPixelColor(currentPoint.x, currentPoint.y, newColor);
    
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
  updatePixels(); 
}

double determinant(Point p1, Point p2, Point p3) {
  return (p1.x*p2.y + p1.y*p3.x + p2.x*p3.y) - (p1.x*p3.y + p1.y*p2.x + p2.y*p3.x);
}

Comparator<Point> xPointCompare = new Comparator<Point>() {
  public int compare(Point p1, Point p2) {
    if (p1.x != p2.x) {
      return p1.x - p2.x;
    } else {
      if (p1.y != p2.y) {
        return p2.y - p1.y;
      } else {
        return 1;
      }
    }
  }
};

Comparator<Point> yPointCompare = new Comparator<Point>() {
  public int compare(Point p1, Point p2) {
    if (p1.y != p2.y) {
      return p1.y - p2.y;
    } else {
      return p2.x - p1.x;
    }
  }
};

Comparator<Endpoint> endpointCompareX = new Comparator<Endpoint>() {
  
  int compare(Endpoint a, Endpoint b) {
    if(a.point == b.point) {
      // If their points are the same ones on a segment then check angle instead
      double am = ((double)(a.getSibling().x - a.point.x))/((double)(a.getSibling().y - a.point.y));
      double bm = ((double)(b.getSibling().x - b.point.x))/((double)(b.getSibling().y - b.point.y));
      if(am == Double.POSITIVE_INFINITY || am == Double.NEGATIVE_INFINITY) {
        return a.getSibling().x - b.getSibling().x;
      }
      else if(am == 0.0) {
        return -1;
      }
      else if(bm == 0.0) {
        return 1;
      }
      else {
        if(am > 0 && bm > 0)
          return (int)(am - bm);
        else if(am > 0)
          return -1;
        else
          return 1;
      }
    }
    else {
      return a.point.x - b.point.x;
    }    
  }
  
};

Comparator<Endpoint> endpointCompareY = new Comparator<Endpoint>() {
  
  int compare(Endpoint a, Endpoint b) {
    if(a.point.y != b.point.y)
      return -1*(a.point.y - b.point.y);
    else
      return -1*(a.getSibling().y - b.getSibling().y);
  }
  
};

Comparator<Endpoint> matchingEndpointCompare = new Comparator<Endpoint>() {
  
  int compare(Endpoint a, Endpoint b) {
    if(a.segment == b.segment) {
      return 0;
    }
    else {
      return a.point.x - b.point.x;
    }
  }
  
};

Comparator<Endpoint> endpointSharingPoint = new Comparator<Endpoint>() {
  
  int compare(Endpoint a, Endpoint b) {
    if(a.point == b.point) {
      return 0;
    }
    else {
      return a.point.y - b.point.y;
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
  if ( IsPointOnSegment(new Point((int)x,(int)y),seg1) && IsPointOnSegment(new Point((int)x,(int)y),seg2)) {
    x = Math.round(x);
    y = Math.round(y);
    return new Point((int)x,(int)y);
  }
  else {
    return null;
  }
}

boolean IsPointOnSegment(Point pt, Segment seg) {
  int segxMin = Math.min(seg.p1.x,seg.p2.x);
  int segxMax = Math.max(seg.p1.x,seg.p2.x);
  int segyMin = Math.min(seg.p1.y,seg.p2.y);
  int segyMax = Math.max(seg.p1.y,seg.p2.y);
  
  int b = seg.p2.x-seg.p1.x;
  int a = seg.p1.y-seg.p2.y;
  float c = b*seg.p1.y+a*seg.p1.x;
  float test = abs(c-(b*pt.y+a*pt.x));
  
  //if it is on the extended line
  if (test < 1000) {    
    // if it is on the length of the segment
    if ( ((pt.x>=segxMin)&&(pt.x<=segxMax)) && ((pt.y>=segyMin)&&(pt.y<=segyMax)) ) { 
      return true;
    }
    else {
      return false;
    }
  }
  else {
    return false;
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
    if (!(obj instanceof Point)) {
      return false;
    } else {
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
    pColor = color(0, 0, 0);
  }

  public Segment(Point p1, Point p2) {
    this.p1 = new Point(p1.x, p1.y);
    this.p2 = new Point(p2.x, p2.y);
    pColor = color(0, 0, 0);
  }

  public Segment(Point p1, Point p2, color pColor) {
    this.p1 = new Point(p1.x, p1.y);
    this.p2 = new Point(p2.x, p2.y);
  }
  
  public int computeY(int x) {
    if(x < p1.x && x > p2.x || x < p2.x && x > p1.x) {
      // Make sure that x is in the right range
      double m = slope();
      double b = p1.y-(m*p1.x);
      return (int)(m*x+b);
    }
    return -1;
  }
  
  public int computeX(int y) {
    sortPointsY();
    if(y < p2.y && y > p1.y) {
      // Make sure that y is in the right range
      double m = slope(); 
      double b = p1.y-(m*p1.x);
      if(m == Double.POSITIVE_INFINITY || m == Double.NEGATIVE_INFINITY) {
        // Vertical line
        return p1.x;
      }
      else if(m == 0.0) {
        // Horizontal line
        return p1.y;  
      }
      else {
        return ((int)((double)(y-b)/m));
      }
    }
    return -1;
  }

  public boolean equals(Object obj) {
    if (!(obj instanceof Segment)) {
      return false;
    } else {
      return (((Segment)obj).p1 == p1 && ((Segment)obj).p2 == p2 || ((Segment)obj).p2 == p1 && ((Segment)obj).p1 == p2);
    }
  }

  public boolean intersects(Segment seg) {
    return (int)Math.signum(determinant(p1, p2, seg.p1)) != (int)Math.signum(determinant(p1, p2, seg.p2));
  }
  
  public double slope() {
    return (double)(p2.y-p1.y)/(p2.x-p1.x);
  }
  
  public Point bresenhamIntersection(Segment seg) {
    if(intersects(seg)) {
      // Calculates the bresenham intersection point of the two segments
      double m1 = slope();
      double b1 = p1.y-(m1*p1.x);
      double m2 = seg.slope();
      double b2 = seg.p1.y-(m2*seg.p1.x);
      double px;
      double py;
      if(m1 == Double.POSITIVE_INFINITY || m1 == Double.NEGATIVE_INFINITY) {
        // Vertical line
        px = p1.x;
        if(m2 == 0.0)
          py = seg.p1.y;
        else
          py = (m2*p1.x) + b2;
      }
      else if(m1 == 0.0) {
        // Horizontal line
        py = p1.y;
        if(m2 == Double.POSITIVE_INFINITY || m2 == Double.NEGATIVE_INFINITY)
          px = seg.p1.x;
        else
          px = (p2.y - b2)/m2;
      }
      else {
        // Regular line intersection
        double numerator = b2-b1;
        double denominator = m1-m2;
        if(denominator == 0) {
          // Coincident or Parallel lines
          return null;  
        }
        py = numerator / denominator;
        px = (m1*b2 - m2*b1) / denominator;
      }
      Point I = new Point((int)px, (int)py);
      return I;
    }
    else {
      return null;
    }
  }

  public void sortPointsX() {
    if (p2.x < p1.x) {
      Point temp = p1;
      p1 = p2;
      p2 = temp;
    } else if (p2.x == p1.x) {
      if (p2.y < p1.y) {
        Point temp = p1;
        p1 = p2;
        p2 = temp;
      }
    }
  }

  public void sortPointsY() {
    if (p2.y < p1.y) {
      Point temp = p1;
      p1 = p2;
      p2 = temp;
    } else if (p2.y == p1.y) {
      if (p2.x < p1.x) {
        Point temp = p1;
        p1 = p2;
        p2 = temp;
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
    if (dx != 0 && Math.abs(dy) <= Math.abs(dx)) {
      int y = p1.y;
      int p = tdy - dx;
      int inc = (tdy > 0) ? 1 : -1;
      tdy = Math.abs(tdy);
      for (int i = p1.x; i < p2.x; i++) {
        ColorPixel(i, y, pColor);
        if (p >= 0) {
          y += inc;
          p += tdy - tdx;
        } else {
          p += tdy;
        }
      }
    } else if (dy != 0) {
      sortPointsY();
      dx = p2.x - p1.x;
      dy = p2.y - p1.y;
      tdx = dx+dx;
      tdy = dy+dy;
      int x = p1.x;
      int p = tdx - dy;
      int inc = (tdx > 0) ? 1 : -1;
      tdx = Math.abs(tdx);
      for (int i = p1.y; i < p2.y; i++) {
        ColorPixel(x, i, pColor);
        if (p >= 0) {
          x += inc;
          p += tdx - tdy;
        } else { 
          p += tdx;
        }
      }
    } else if (dx == 0) {
      sortPointsY();
      for (int i = p1.y; i < p2.y; i++) {
        set(p1.x, i, 0);
      }
    } else if (dy == 0) {
      sortPointsX();
      for (int i = p1.x; i < p2.x; i++) {
        set(i, p1.y, 0);
      }
    }
    ColorPixel(p1.x, p1.y, pColor);
    ColorPixel(p2.x, p2.y, pColor);
  }
  
  public String toString() {
    return "\nP1 : " + p1.toString() + "\nP2: " + p2.toString() + "\n\n";  
  }
  
}

class Polygon {
  // Polygon where points are in the couter-clockwise order
  
  public ArrayList<Point> vertices;
  public ArrayList<Segment> segments;
  public color fillColor;
  public color borderColor;
  public color polygonColor;

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
  
  public Polygon(ArrayList<Point> vlist, color polygonColor) {
    this.vertices = vlist;
    generateLineSegments(polygonColor);
    this.polygonColor = polygonColor;
  }
  
  public PriorityQueue<Endpoint> generateEndpointQueue(Comparator<Endpoint> comparator) {
    generateLineSegments();
    PriorityQueue<Endpoint> endpointQueue = new PriorityQueue<Endpoint>(segments.size()*2,comparator);
    for(int i = 0; i < segments.size(); i++) {
      segments.get(i).sortPointsY();
      println(segments.get(i));
      Endpoint ep1 = new Endpoint(segments.get(i).p1, segments.get(i));
      Endpoint ep2 = new Endpoint(segments.get(i).p2, segments.get(i));
      endpointQueue.add(ep1);
      endpointQueue.add(ep2);
    }
    return endpointQueue;
  }
  
  public void planeSweepColor(color c) {
    println("Starting plane sweep");
    PriorityQueue<Endpoint> events = generateEndpointQueue(endpointCompareY);
    BST<Endpoint> status = new BST<Endpoint>(endpointCompareX);
    while(events.peek() != null) {
      Endpoint endpoint = events.poll();
      println(endpoint.startY);
      println(endpoint.endY);
      // Check if the current endpoint has its pair inside the tree. If not insert into the tree.
      // If so, use that pair to see if the other segment connected to it is in the tree.
      // If so, run colorBetweenSegmentsX
      // Remove the points of that particular segment from the tree and continue.
      Endpoint pair = new Endpoint(endpoint.getSibling(), endpoint.segment);
      ArrayList<Node<Endpoint>> candidates = status.findAllNodes(pair);
      Node<Endpoint> match = null;
      Node<Endpoint> neighbor = null;
      for(Node<Endpoint> ne : candidates) {
        // Compare to see if it belongs to the same segment
        if(ne.value.segment == endpoint.segment) {
          match = ne;
        }
        else {
          neighbor = ne;
        }
      }
      
      if(match != null && neighbor == null) {
        neighbor = match.getLeftNeighbor();
        if(neighbor != null) {
          colorBetweenSegmentsX(neighbor.value.segment, match.value.segment, neighbor.value.startY, match.value.endY, c);
          neighbor.value.startY = match.value.endY+1;
          status.deleteNode(match);
        }
        else {
          neighbor = match.getRightNeighbor();  
          if(neighbor != null) {
            colorBetweenSegmentsX(match.value.segment, neighbor.value.segment, neighbor.value.startY, match.value.endY, c);
            neighbor.value.startY = match.value.endY+1;
            status.deleteNode(match);
          }
        }
      }
      else if(match != null && neighbor != null) {
        colorBetweenSegmentsX(match.value.segment, neighbor.value.segment, neighbor.value.startY, match.value.endY, c);
        println(neighbor.value.startY + " " + match.value.endY);
        println(neighbor.value);
        println(match.value);
        neighbor.value.startY = match.value.endY+1;
        println("Deleting Node " + match.value);
        status.deleteNode(match);
      }
      else if(match == null) {
        println("Inserting Node " + endpoint);
        status.insert(endpoint);  
      }
      
    }
  }
  
  public Segment getClippedLineSegment(Segment seg) {
    generateLineSegments();
    ArrayList<Segment> clipped = new ArrayList<Segment>();
    for(int i = 0; i < segments.size(); i++) {
      Segment polygonSegment = segments.get(i);
      Point intersect = polygonSegment.bresenhamIntersection(seg); 
      if(intersect != null) {
          // Find out the direction of the convex polygon and determine which side of line is inside of polygon
          int modIndex = ((((i-1)%segments.size())+segments.size())%segments.size());
          if((int)Math.signum(determinant(intersect, polygonSegment.p1, seg.p1))
             == (int)Math.signum(determinant(polygonSegment.p2, polygonSegment.p1, segments.get(modIndex).p1))) {
            clipped.add(new Segment(intersect, seg.p1));
          }
          else {
            clipped.add(new Segment(intersect, seg.p2));  
          }
      }
    }
    
    Segment clippedLineSegment = null;
    if(clipped.size() == 1) {
      // Segment ends inside of the polygon
      clippedLineSegment = clipped.get(0);
    }
    else if(clipped.size() == 2) {
      clippedLineSegment = new Segment();
      if(clipped.get(0).p1 != clipped.get(1).p1 && clipped.get(0).p1 != clipped.get(1).p2) {
        clippedLineSegment.p1 = clipped.get(0).p1;
        if(clipped.get(0).p2 != clipped.get(1).p1)
          clippedLineSegment.p2 = clipped.get(1).p1;
        else
          clippedLineSegment.p2 = clipped.get(1).p2;
      }
      else if(clipped.get(1).p1 != clipped.get(1).p1 && clipped.get(1).p1 != clipped.get(1).p2) {
        clippedLineSegment.p1 = clipped.get(1).p1;
        if(clipped.get(0).p2 != clipped.get(1).p1)
          clippedLineSegment.p2 = clipped.get(1).p1;
        else
          clippedLineSegment.p2 = clipped.get(1).p2;  
      }
    }
    
    return clippedLineSegment;  
  }

  public ArrayList<Segment> generateLineSegments() {
    generateLineSegments(borderColor);
    return segments;
  }

  public ArrayList<Segment> generateLineSegments(color polygonColor) {
    borderColor = polygonColor;
    segments = new ArrayList<Segment>();
    for (int i = 1; i < vertices.size (); i++) {
      segments.add(new Segment(vertices.get(i-1), vertices.get(i), polygonColor));
    }
    if (vertices.size() > 0) {
      segments.add(new Segment(vertices.get(vertices.size()-1), vertices.get(0), polygonColor));
    }  
    return segments;
  }

  public void drawPolygon() {
    generateLineSegments();
    for (Segment s : segments) {
      s.drawLine();
    }
  }

  public void colorPolygon(color polygonColor) {
    fillColor = polygonColor;
    if (vertices.size() > 0) {
      Point lowestx = vertices.get(0);
      Point highestx = vertices.get(0);
      Point lowesty = vertices.get(0);
      Point highesty = vertices.get(0);
      for (int i = 1; i < vertices.size (); i++) {
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

      color currentColor = get(meanx, meany);
      FloodFill(meanx, meany, currentColor, polygonColor);
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
    if (seg == segment1 || seg == segment2)
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
    for (int i = 1; i < hull.size (); i++) {
      segments.add(new Segment(previous, hull.get(i))); 
      previous = hull.get(i);
    }
    if (hull.size() > 0) {
      segments.add(new Segment(hull.get(0), hull.get(hull.size()-1)));
    }

    // Draw line segments
    for (Segment s : segments) {
      s.drawLine();
    }
  }

  public void computeConvexHull() {
    if (points.size() > 1) {
      Collections.sort(points, xPointCompare);
      Point leftMost = points.get(0);
      Point rightMost = points.get(points.size()-1);
      points.remove(leftMost);
      points.remove(rightMost);

      ArrayList<Point> topPoints = new ArrayList();
      ArrayList<Point> bottomPoints = new ArrayList();
      for (Point p : points) {
        if (determinant(leftMost, rightMost, p) > 0) {
          topPoints.add(p);
        } else {
          bottomPoints.add(p);
        }
      }

      ArrayList<Point> topHull = new ArrayList<Point>();
      topHull.add(leftMost);
      if (topPoints.size() > 0) {
        for (Point p : topPoints) {
          topHull.add(p);
          double det = 0;
          if (topHull.size() > 2) {
            det = determinant(topHull.get(topHull.size()-3), 
            topHull.get(topHull.size()-2), 
            topHull.get(topHull.size()-1));
            if (det < 0) {
              //println(det);
            }
          }
          while (topHull.size () > 2 && determinant(topHull.get(topHull.size()-3), 
          topHull.get(topHull.size()-2), 
          topHull.get(topHull.size()-1)) >= 0) {

            topHull.remove(topHull.size()-2);
          }
        }
      }

      ArrayList<Point> bottomHull = new ArrayList<Point>();
      bottomHull.add(rightMost);
      if (bottomPoints.size() > 0) {
        for (int i = bottomPoints.size ()-1; i >= 0; i--) {
          bottomHull.add(bottomPoints.get(i));
          double det = 0;
          if (topHull.size() > 2) {
            det = determinant(topHull.get(topHull.size()-3), 
            topHull.get(topHull.size()-2), 
            topHull.get(topHull.size()-1));
            if (det < 0) {
              //println(det);
            }
          }
          while (bottomHull.size () > 2 && determinant(bottomHull.get(bottomHull.size()-3), 
          bottomHull.get(bottomHull.size()-2), 
          bottomHull.get(bottomHull.size()-1)) >= 0) {
            bottomHull.remove(bottomHull.size()-2);
          }
        }
      }

      hull = topHull;
      hull.addAll(bottomHull);
    } else {
      hull = new ArrayList<Point>(points);
    }
  }
}

void DrawUnion(Polygon poly1, Polygon poly2, color borderColor, color fillColor) {
  //Find the all the intersection points between the two polygons
  poly1.generateLineSegments();
  poly2.generateLineSegments();
  ArrayList<Point> intersects = new ArrayList();
  for(Segment s1 : poly1.segments) {
    for(Segment s2 : poly2.segments) {
      if (IntersectionFinder(s1,s2)!=null) {
        int x = IntersectionFinder(s1,s2).x;
        int y = IntersectionFinder(s1,s2).y;
        intersects.add(new Point(x,y));
      }
    }
  }
  print("All intersection points: ",intersects,"\n");
  if (intersects.isEmpty()) {
    print("polygons do not intersect. No union found.\n");
    return;
  }
  
  //Find the smallest x coordinate vertex in the set, which is guaranteed to be part of the union
  int poly1LeastXindex = 0;
  for(int i = 1; i<poly1.vertices.size(); i++) {
    if (poly1.vertices.get(i).x < poly1.vertices.get(poly1LeastXindex).x) {
      poly1LeastXindex = i;
    }
  }  
  int poly2LeastXindex = 0;
  for(int i = 1; i<poly2.vertices.size(); i++) {
    if (poly2.vertices.get(i).x < poly2.vertices.get(poly1LeastXindex).x) {
      poly2LeastXindex = i;
    }
  }
  
  //Draw from the leftmost vertex, switching which polygon to draw if we hit an intersection
  boolean polychoose1;
  boolean intersected = false;
  int count = 0;
  //if the smallest x coordinate vertex beongs to the first polygon, that's the polygon we start drawing from
  if (poly1.vertices.get(poly1LeastXindex).x < poly2.vertices.get(poly2LeastXindex).x) {
    //get the start point from the correct polygon
    polychoose1 = true;
    Point startPoint = poly1.vertices.get(poly1LeastXindex);
    Point currentPoint = startPoint;
    print(poly1LeastXindex);
    
    //get the first segment corresponding to the start point
    Segment seg = new Segment(currentPoint, poly1.vertices.get(0),borderColor);
    if (poly1LeastXindex != poly1.vertices.size()-1) {
      seg = new Segment(currentPoint, poly1.vertices.get(poly1LeastXindex+1),borderColor);
    } 
    print("cp: ",currentPoint.x,"   ",currentPoint.y,"\n\n");
    
    //Start drawing segments, switching the polygon we draw every time we hit an intersection and stopping when we come full circle
    //If there is an intersection for a segment, we draw the segment from our current point only up to the intersection point
    do {
      ArrayList<Point> intersectionList = new ArrayList();
      print("cp: ",currentPoint.x,"   ",currentPoint.y,"\n");
      print("seg.p1: ",seg.p1.x,"    ",seg.p1.y,"\n");
      print("seg.p2: ",seg.p2.x,"    ",seg.p2.y,"\n");
      
      // we store all intersections of a segment and use the one that is closest to our current point in case a segment has multiple intersections
      for (Point intersection : intersects) {
        if (IsPointOnSegment(intersection,seg) && ((intersection.x!=currentPoint.x)||(intersection.y!=currentPoint.y))) {
          intersectionList.add(new Point(intersection.x,intersection.y));
        }
      }
      if (!intersectionList.isEmpty()) {
        // calculate the distance to intersection and use the closest intersection point
        Point closestIntersect = intersectionList.get(0);
        double distance = 100000000;
        double distanceTemp = 0;
        for (Point intersection : intersectionList) {
          distanceTemp = (Math.pow(currentPoint.x-intersection.x,2) + Math.pow(currentPoint.y-intersection.y,2));
          print(intersection,distanceTemp,"\n");
          if (distanceTemp < distance) {
            closestIntersect = intersection;
            distance = distanceTemp;
          }
        }
        intersected = true;
        seg.p2 = closestIntersect;
        seg.drawLine();
        currentPoint = closestIntersect;
        polychoose1 = !polychoose1;              //switch the polygon to draw if there was an intersection
      }
      
      //if there is no intersection, we just draw the line segment as it is
      if (!intersected) {
        currentPoint = seg.p2;
        seg.drawLine();
      }
      //if there was no intersection, the next segment is the one with the start point that is the same as our current point
      if (polychoose1 && !intersected) {
        for (Segment s : poly1.segments) {
          if (IsPointOnSegment(currentPoint, s) && ((s.p1.x==currentPoint.x)&&(s.p1.y==currentPoint.y))) {
            seg.p1 = s.p1;
            seg.p2 = s.p2;
            break;
          }
        }
      }
      // same as above but we search the other polygon if that is the polygon we are currently on
      else if (!polychoose1 && !intersected) {
        for (Segment s : poly2.segments) {
          if (IsPointOnSegment(currentPoint, s) && ((s.p1.x==currentPoint.x)&&(s.p1.y==currentPoint.y))) {
            seg.p1 = s.p1;
            seg.p2 = s.p2;
            break;
          }
        }
      }
      // if there was an intersection, the starting point of our next segment to draw should be the intersection point, which is also currentPoint in this case
      else if (polychoose1 && intersected) {
        for (Segment s : poly1.segments) {
          if (IsPointOnSegment(currentPoint,s)) {
            seg.p1 = currentPoint;
            seg.p2 = s.p2;
            break;
          }
        }
      }
      else {
        for (Segment s : poly2.segments) {
          if (IsPointOnSegment(currentPoint,s)) {
            seg.p1 = currentPoint;
            seg.p2 = s.p2;
            break;
          }
        }
      }
      intersected = false;
      count++;                  // if infinite loop occurs for whatever reason, we stop drawing after 100 iterations
    } while ( ((startPoint.x!=currentPoint.x) || (startPoint.y!=currentPoint.y)) && (count < 100));
  }
  //else statement is the same as the above if but starts on the other polygon
  else {
    polychoose1 = false;
    Point startPoint = poly2.vertices.get(poly2LeastXindex);
    Point currentPoint = startPoint;
    Segment seg = new Segment(currentPoint, poly2.vertices.get(0),borderColor);
    if (poly2LeastXindex != poly2.vertices.size()-1) {
      seg = new Segment(currentPoint, poly2.vertices.get(poly2LeastXindex+1),borderColor);
    }
    print("cp: ",currentPoint.x,"   ",currentPoint.y,"\n\n");
    do {
      ArrayList<Point> intersectionList = new ArrayList();
      print("cp: ",currentPoint.x,"   ",currentPoint.y,"\n");
      print("seg.p1: ",seg.p1.x,"    ",seg.p1.y,"\n");
      print("seg.p2: ",seg.p2.x,"    ",seg.p2.y,"\n");
      for (Point intersection : intersects) {
        if (IsPointOnSegment(intersection,seg) && ((intersection.x!=currentPoint.x)||(intersection.y!=currentPoint.y))) {
          intersectionList.add(new Point(intersection.x,intersection.y));
        }
      }
      if (!intersectionList.isEmpty()) {
        Point closestIntersect = intersectionList.get(0);
        double distance = 100000000;
        double distanceTemp = 0;
        for (Point intersection : intersectionList) {
          distanceTemp = (Math.pow(currentPoint.x-intersection.x,2) + Math.pow(currentPoint.y-intersection.y,2));
          print(intersection,distanceTemp,"\n");
          if (distanceTemp < distance) {
            closestIntersect = intersection;
            distance = distanceTemp;
          }
        }
        intersected = true;
        seg.p2 = closestIntersect;
        seg.drawLine();
        currentPoint = closestIntersect;
        polychoose1 = !polychoose1;
      }
      if (!intersected) {
        print(seg.p2,"\n");
        currentPoint = seg.p2;
        seg.drawLine();
      }
      if (polychoose1 && !intersected) {
        for (Segment s : poly1.segments) {
          if (IsPointOnSegment(currentPoint, s) && ((s.p1.x==currentPoint.x)&&(s.p1.y==currentPoint.y))) {
            seg.p1 = s.p1;
            seg.p2 = s.p2;
            break;
          }
        }
      }
      else if (!polychoose1 && !intersected) {
        for (Segment s : poly2.segments) {
          if (IsPointOnSegment(currentPoint, s) && ((s.p1.x==currentPoint.x)&&(s.p1.y==currentPoint.y))) {
            seg.p1 = s.p1;
            seg.p2 = s.p2;
            break;
          }
        }
      }
      else if (polychoose1 && intersected) {
        for (Segment s : poly1.segments) {
          if (IsPointOnSegment(currentPoint,s)) {
            seg.p1 = currentPoint;
            seg.p2 = s.p2;
            break;
          }
        }
      }
      else {
        for (Segment s : poly2.segments) {
          if (IsPointOnSegment(currentPoint,s)) {
            seg.p1 = currentPoint;
            seg.p2 = s.p2;
            break;
          }
        }
      }
      intersected = false;
      count++;
    } while ( ((startPoint.x!=currentPoint.x) || (startPoint.y!=currentPoint.y)) && (count<1));
  }
  //poly1.colorPolygon(fillColor);
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
    polygon.drawPolygon();
    polygon.planeSweepColor(color(255, 0, 0));
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
    clearScreen();
    // Given two convex polygons finds the union polygon and colors it in.
    DrawUnion(polygon1,polygon2,color(0,0,0),color(255,102,204));
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

class SegmentClippingTask implements Task {
  
  Polygon polygon;
  Segment segment;
  
  public SegmentClippingTask() {
    polygon = new Polygon();
    segment = new Segment();  
  }
  
  public void performTask() {
    polygon.drawPolygon();
    Segment clippedLineSegment = polygon.getClippedLineSegment(segment);
    if(clippedLineSegment != null) {
      clippedLineSegment.drawLine();  
    }
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
    String defaultFilename = "/home/nurc-08/sketchbook/shared-repo/project_1/input.txt"; 

    File inputFile = null;
    Scanner fileReader = null;
    if (mode == INPUT_MODE) {
      boolean fileSelected = false;
      while (!fileSelected) {
        Object option = JOptionPane.showInputDialog(null, "Type the full path of the file or hit cancel to use the file browser", "Configuration", JOptionPane.PLAIN_MESSAGE, null, null, "");
        if (option == null) {
          JFileChooser chooser = new JFileChooser();
          int choice = chooser.showOpenDialog(null);
          if (choice == JFileChooser.APPROVE_OPTION) {
            File chosenFile = chooser.getSelectedFile();
            try {
              fileReader = new Scanner(chosenFile);
            }
            catch(Exception e) {
              println("File was not found");  
            }
            fileSelected = true;
          } else {
            int useDefaultFile = JOptionPane.showConfirmDialog(null, "Use the default file?", "Configuration", JOptionPane.YES_NO_OPTION);   
            if (useDefaultFile == JOptionPane.YES_OPTION) {
              try {
                filename = defaultFilename;
                inputFile = new File(filename);
                fileReader = new Scanner(inputFile);
                fileSelected = true;
              }
              catch(Exception e) {
                int exitOption = JOptionPane.showConfirmDialog(null, defaultFilename, "Bad Default", JOptionPane.YES_NO_OPTION); 
                if (exitOption == JOptionPane.YES_OPTION) {
                  System.exit(1);
                } else {
                  fileSelected = false;
                }
              }
            }
            else {
              System.exit(0);  
            }
          }
        } else {
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
    } else {
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
    int clippingSelect = 0;
    boolean firstPoint = true;
    Task taskBuffer = new PolygonTask();
    while (fileReader != null && fileReader.hasNextLine ()) {
      line = fileReader.nextLine().trim().toUpperCase();
      if (line.equals("P")) { 
        currentTask = POLYGON_FILL;
        taskBuffer = new PolygonTask();
        tasks.add(taskBuffer);
      } else if (line.equals("U, P1, P2")) {
        currentTask = POLYGON_UNION;
        taskBuffer = new PolygonUnionTask();
        polygonSelect = 1;
        tasks.add(taskBuffer);
      } else if (line.equals("H, S")) { 
        currentTask = CONVEX_HULL;
        taskBuffer = new ConvexHullTask();
        tasks.add(taskBuffer);
      } else if(line.equals("P, S")) { 
        currentTask = EXTRA_CREDIT;
        taskBuffer = new SegmentClippingTask();
        clippingSelect = 0;
        tasks.add(taskBuffer);
      } else if (currentTask != INVALID) {
        if (line.equals("P1")) {
          polygonSelect = 1;
        } else if (line.equals("P2")) {
          polygonSelect = 2;
        } else if(line.equals("POL")) {
          clippingSelect = 0;
        } else if(line.equals("S")) {
          clippingSelect = 1;
          firstPoint = true;
        } else {
          // Parse the points using the split function
          String[] strValues = line.split(" ");
          Integer[] values = new Integer[strValues.length];
          Point p = new Point();
          for (int i = 0; i < values.length; i++) {
            values[i] = Integer.parseInt(strValues[i]);
          }
          if (values.length >= 2) {
            p.x = values[0];
            p.y = values[1];
          }

          if (currentTask == POLYGON_FILL) {
            ((PolygonTask)taskBuffer).polygon.vertices.add(p);
            println("Adding polygon");
          } else if (currentTask == POLYGON_UNION) {
            if (polygonSelect == 1) {
              ((PolygonUnionTask)taskBuffer).polygon1.vertices.add(p);
            } else {
              ((PolygonUnionTask)taskBuffer).polygon2.vertices.add(p);
            }
          } else if (currentTask == CONVEX_HULL) {
            ((ConvexHullTask)taskBuffer).H.points.add(p);
          } else if(currentTask == EXTRA_CREDIT) {
            if(clippingSelect == 0) {
              ((SegmentClippingTask)taskBuffer).polygon.vertices.add(p);
            }
            else {
              if(firstPoint) {
                ((SegmentClippingTask)taskBuffer).segment.p1 = p;
                firstPoint = false;
              }
              else {
                ((SegmentClippingTask)taskBuffer).segment.p2 = p;
                firstPoint = true;
              }
            }
          }
        }
      }
    }
    if (fileReader != null) {
      fileReader.close();
    }
  }
}

void colorBetweenSegmentsX(Segment seg1, Segment seg2, int startY, int endY, color c) {
  // Colors between two segments horizontally
  if(seg1.p1.x > seg2.p2.x) {
    Segment temp = seg1;
    seg1 = seg2;
    seg2 = temp;  
  }
  //seg1.sortPointsY();
  //seg2.sortPointsY();
  if(startY > endY) {
    int temp = startY;
    startY = endY;
    endY = temp;  
  }
  //int pointMinY = Math.max(seg1.p1.y, seg2.p1.y);
  //int pointMaxY = Math.min(seg1.p2.y, seg2.p2.y);
  //startY = Math.max(startY, pointMinY);
  //endY = Math.min(endY, pointMaxY);
  println("Coloring starting at " + startY + " and ending at " + endY);
  for(int i = startY; i <= endY; i++) {
    int s1x = seg1.computeX(i);
    int s2x = seg2.computeX(i);
    if(s1x != -1 && s2x != -1) {
      for(int j = s1x; j <= s2x; j++) {
        // ColorPixel(j, i, c);
        setPixelColor(j, i, c);
      }
    }  
  }
  updatePixels();
} 

class Endpoint {
  Point point;
  Segment segment;
  
  int startY;
  int endY;
  
  public Endpoint() {
    point = null;
    segment = null;  
  }
  
  public Endpoint(Point point, Segment seg) {
    this.point = point;
    this.segment = seg;  
    startY = Math.max(segment.p1.y, segment.p2.y);
    endY = Math.min(segment.p1.y, segment.p2.y);
  }
  
  public Point getSibling() {
    if(point != null && segment != null) {
      if(segment.p1 == point) {
        return segment.p2;
      }  
      return segment.p1;
    }
    return null;
  }
  
  public boolean isLowerEndpoint() {
    if(point != null) {
      if(point.y < getSibling().y) {
        return true;
      }
      else {
        return false;  
      }
    }
    return false;
  }
  
  public boolean isUpperEndpoint() {
    if(point != null) {
      if(point.y > getSibling().y) {
        return true;
      }
      else {
        return false;  
      }
    }
    return false;
  }
  
  String toString() {
    String conversion = "Point (";
    if(point.y < getSibling().y) {
      conversion += "Lower";
    }
    else if(point.y > getSibling().y) {
      conversion += "Upper";  
    }
    else {
      if(point.x < getSibling().x) {
        conversion += "Lower";
      }
      else if(point.x > getSibling().x) {
        conversion += "Upper";
      }
      else {
        conversion += "Degenerate"; 
      }
    }
    conversion += "): " + point + " " + getSibling();
    return conversion;
  }
  
}

class BST<T> {
    Node<T> root;
    Comparator<? super T> comparator;
    private int elementCount;
    
    public BST() {
      comparator = null;
      root = null;
    }
    
    public BST(Node<T> node) {
      this.comparator = null;
      this.root = node;  
      elementCount = 0;
    }
    
    public BST(Comparator<? super T> comparator) {
      this.root = null;
      this.comparator = comparator;   
      elementCount = 0;
    }
    
    public BST(Node<T> node, Comparator<? super T> comparator) {
      if(node != null) {
        this.root = node;
        elementCount = 1;
      }
      else {
        elementCount = 0;
      }
      this.comparator = comparator;
    }
    
    int size() {
      return elementCount;
    }
    
    public void printBreadthFirstNodes() {
      int levelNumber = 0;
      for(LinkedList< Node<T> > level : getBreadthFirstNodes()) {
        println("Iterating over level " + levelNumber);
        for(Node<T> np : level) {
          println(np.value);
        }
        levelNumber++;
      }
    }
    
    public LinkedList< LinkedList< Node<T> > > getBreadthFirstNodes() {
      LinkedList< LinkedList< Node<T> > > sorted = new LinkedList< LinkedList< Node<T> > >();
      sorted.add(new LinkedList< Node<T> >());
      Node<T> element = root;
      if(root != null)
        sorted.getFirst().addFirst(element);
      println(sorted.size());
      
      boolean complete = false;
      LinkedList< Node<T> > currentQueue = new LinkedList< Node<T> >();
      while(!complete) {    
        for(Node<T> e: sorted.getLast()) {
          if(e.left != null) {
            currentQueue.addFirst(e.left);
          }
          if(e.right != null) {
            currentQueue.addFirst(e.right);
          }
        }
        
        if(currentQueue.size() == 0) {
          complete = true;
        }
        else {
          sorted.addLast(currentQueue);
          currentQueue = new LinkedList< Node<T> >();
        }
      }  
      return sorted;
    }
    
    int nodeCompare(Node<T> node1, Node<T> node2) {
      if(comparator == null)
        return 0;
      else
        return (int)Math.signum(comparator.compare(node1.value, node2.value));
    }
    
    Node<T> insert(T nv) {
      return insert(new Node<T>(nv));  
    }
    
    Node<T> insert(Node<T> n) {
      if(root != null) {
        boolean complete = false;
        Node<T> parent = root;
        while(!complete) {
          if(nodeCompare(n, parent) <= 0) {
            if(parent.left == null) {
              parent.left = n;
              n.parent = parent;
              elementCount++;
              complete = true;       
            }   
            else {
              parent = parent.left;  
            }
          } 
          else {
            if(parent.right == null) {
              parent.right = n;  
              n.parent = parent;
              elementCount++;
              complete = true;
            }
            else {
              parent = parent.right;  
            }
          }
        }
      }
      else {
        root = n;
        n.parent = null;
        elementCount++;
      }
      return n;
    }
    
    public void deleteNode(Node<T> r) {
      elementCount--;
      if(r.left != null && r.right != null) {
          Node<T> substitute = r.getRightNeighbor();
          substitute.parent.right = null;
          substitute.parent = r.parent;
          substitute.left = r.left;
          if(r.isLeftChild()) {
             r.parent.left = substitute;
          } 
          else if(r.isRightChild()) {
            r.parent.right = substitute;
          }
          else {
            // Must be root
            root = substitute;
          }
        }
        else if(r.left != null || r.right != null) {
          if(r.isLeftChild()) {
            if(r.left != null) {
              r.parent.left = r.left;
              r.left.parent = r.parent;
            }
            else {
              r.parent.left = r.right;
              r.right.parent = r.parent;
            }
          } 
          else if(r.isRightChild()) {
            if(r.left != null) {
              if(r.parent != null)
                r.parent.right = r.left;
              else
                root = r.left;
              r.left.parent = r.parent;
            }
            else {
              if(r.parent != null)
                r.parent.left = r.right;
              else
                root = r.right;  
              r.right.parent = r.parent;
            } 
          } 
        }
        else {
          if(r.parent != null) {
            if(r.isLeftChild())
              r.parent.left = null;
            else
              r.parent.right = null;
          }
          else {
            root = null;  
          }
       }
    }
    
    public int removeAllNodes(T V) {
      return removeAllNodes(V, comparator);  
    }
    
    public int removeAllNodes(T V, Comparator<? super T> C) {
      // BST node removal
      //ArrayList<Node<T>> nodes = findAllNodes(V, C);
      int count = 0;
      Node<T> node = findNode(V, C);
      while(node != null) {
        println(node.value);
        deleteNode(node);
        node = findNode(V, C);
        count++;
      } 
      return count;
    }
    
    public ArrayList< Node<T> > findAllNodes(T V) {
      return findAllNodes(V, comparator);  
    }
    
    public ArrayList< Node<T> > findAllNodes(T V, Comparator<? super T> C) {
      ArrayList<Node<T>> nodes = new ArrayList<Node<T>>();
      if(root != null) {
        Node<T> parent = root;
        while(true) {
          if(parent == null) {
            return nodes;
          }
          else {
            println(parent.value);
            if(C.compare(V, parent.value) < 0) {
              parent = parent.left;   
            }
            else if(C.compare(V, parent.value) > 0) {
              parent = parent.right;
            }
            else {
              nodes.add(parent);
              parent = parent.left;
            }
          }
        }
      }
      else {
        return nodes;
      }  
    }
    
    public Node<T> findNode(T V) {
      return findNode(V, comparator);  
    }
      
    public Node<T> findNode(T V, Comparator<? super T> C) {
      if(root != null) {
        Node<T> parent = root;
        while(true) {
          if(parent == null) {
            return null;
          }
          else {
            if(C.compare(V, parent.value) < 0) {
              parent = parent.left;   
            }
            else if(C.compare(V, parent.value) > 0) {
              parent = parent.right;
            }
            else {
              return parent;
            }
          }
        }
      }
      else {
        return null;
      }  
    }
    
}

class Node<T> {
  Node<T> left;
  Node<T> right;
  Node<T> parent;
  T value;
  
  public Node() {
    left = right = parent = null;
  }
  
  public Node(T v) {
    this();
    this.value = v; 
  }
  
  boolean isLeftChild() {
    if(parent != null) {
      if(this == parent.left) {
        return true;
      }
    }  
    return false;
  }
  
  boolean isRightChild() {
    if(parent != null) {
      if(this == parent.right) {
        return true; 
      } 
    }  
    return false;
  }
  
  Node<T> getLeftNeighbor() {
    Node<T> leftNeighbor = null;
    if(left != null) {
      leftNeighbor = left;
      while(leftNeighbor.right != null) {
        leftNeighbor = leftNeighbor.right;
      }
    }
    else if(parent != null) {
      if(isRightChild()) {
        leftNeighbor = parent;  
      }
      else {
        leftNeighbor = parent;
        while(leftNeighbor != null && !leftNeighbor.isRightChild())
          leftNeighbor = leftNeighbor.parent;
        if(leftNeighbor != null)
          leftNeighbor = leftNeighbor.parent;
      }
      leftNeighbor = parent;
    }
    return leftNeighbor;
  }
  
  Node<T> getRightNeighbor() {
    Node<T> rightNeighbor = null;
    if(right != null) {
      rightNeighbor = right;
      while(rightNeighbor.left != null)
        rightNeighbor = rightNeighbor.left;
    }
    else if(parent != null) {
      if(parent.isLeftChild()) {
        rightNeighbor = parent.parent;
      }
      else {
        rightNeighbor = parent;
        while(rightNeighbor != null && !rightNeighbor.isLeftChild())
          rightNeighbor = rightNeighbor.parent;
        if(rightNeighbor != null && !rightNeighbor.isLeftChild())
          rightNeighbor = null;
      }
    }
    return rightNeighbor;
  }
  
}

Point generatePointY(int y) {
  return new Point(1, y);  
}

void setup() {
  size(600, 600);
  loadPixels();
  clearScreen();
  
  taskParser = new Parser();
}

void draw() {
  boolean continuation = false;
  if(!COMPLETE) {
    if(taskIndex < taskParser.tasks.size()) {
      if(taskIndex == 0) {
        continuation = true;
      }
      else {
        int c = JOptionPane.showConfirmDialog(null, "Continue?", "Next Task", JOptionPane.YES_NO_OPTION);
        if(c == JOptionPane.YES_OPTION) {
          continuation = true;
        }  
        else {
          continuation = false;
          COMPLETE = true;
        }
      }
    }
    else {
      int done = JOptionPane.showConfirmDialog(null, "Do you want to run another file?", "Complete", JOptionPane.YES_NO_OPTION);
      taskIndex = 0;
      if(done != JOptionPane.YES_OPTION)
        COMPLETE = true;
      else
        taskParser = new Parser();
    }
    if(continuation) {
      clearScreen();
      taskParser.tasks.get(taskIndex).performTask();
      taskIndex++;  
    }
  }
}