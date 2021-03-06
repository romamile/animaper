import processing.svg.*;
import gifAnimation.*;


class ribbon {
  
  int index = -1;
  int prevIndex = -1;
  int indexRez = -1;
  
  float tms;
  int sampling;
  
  toggle tick;
  boolean loop = true, playing = true, moving = false, speed = false;
   
  ArrayList< cell > listCell;
 
  ribbon() {
    tms = 300;
    sampling = 6;
    tick = new toggle();
    tick.setSpanMs(floor(tms));
    tick.reset(false);
    
    listCell = new ArrayList< cell >();
    
  }
  
  void exportPNG(String _baseName) {
    for(int i = 0; i<listCell.size(); ++i)
      listCell.get(i).img.save("./rez/" + _baseName + i + ".png");
  }
  
  void exportGIF(String _baseName, PApplet _parent) {
    
    GifMaker gifExport = new GifMaker(_parent, "./rez/" + _baseName + ".gif");
    gifExport.setRepeat(0);        // make it an "endless" animation
    gifExport.setTransparent(0,0,0);
    
    
    for(cell refCell : listCell) {
      gifExport.setDelay(floor(tms));
      gifExport.addFrame(refCell.img);
    }
  
    gifExport.finish();  

  }
  
  void exportSVG(String _baseName) {
    
    for(int ii = 0; ii<listCell.size(); ++ii) {
        
      int ref = 0;
      PGraphics svg = createGraphics(wZone, hZone, SVG, "./rez/" + _baseName + ii + ".svg");
      svg.beginDraw();
      svg.noStroke();
      
      for(areaCore refA : listCell.get(ii).listAreaCore) {
        
        if(refA.myArea.listContour.size() == 0)
          return;
          
        svg.fill(refA.c.r*255, refA.c.g*255, refA.c.b*255);
            
             
        svg.beginShape();
  
        // 1) Exterior part of shape, clockwise winding
        for (vec2i itPos : refA.myArea.listContour.get(0)) {
          if(ref%sampling==0)
            svg.vertex(itPos.x, itPos.y);
          ref++;
        }
        svg.vertex(refA.myArea.listContour.get(0).get(0).x, refA.myArea.listContour.get(0).get(0).y);
      
          // 2) Interior part of shape, counter-clockwise winding
          for (int i = 1; i < refA.myArea.listContour.size(); ++i) {
            svg.beginContour();
            
            //for (int j = myArea.listContour.get(i).size() -1; j >= 0; --j) {
            //  s.vertex(myArea.listContour.get(i).get(j).x, myArea.listContour.get(i).get(j).y);
            //}
            for (vec2i itPos : refA.myArea.listContour.get(i)) {
              if(ref%sampling==0)
                svg.vertex(itPos.x, itPos.y);
              ref++;
            }
            svg.vertex(refA.myArea.listContour.get(i).get(0).x, refA.myArea.listContour.get(i).get(0).y);
            svg.endContour();
          }
      
        svg.endShape(); 
        
        
      
      }
      
  
      svg.dispose();
      svg.endDraw();
    }

  }
  
  void clear() {
    tick.setSpanMs(floor(tms));
    tick.reset(false);    
    listCell.clear();
    index = -1;
    prevIndex = -1;
    
  }
 
  void addCell( cell _cell) {
    
    prevIndex = index;
    index++;
    listCell.add( index, new cell(_cell) );
  }
  
  void delCurrentCell() {
    if(index != -1)
      listCell.remove(index);

    index--;
    
    if(index > listCell.size() -1 || index < 0)
      index = 0;
}
  
  void timeUp() {
    tms /= 1.1;
    tick.setSpanMs(floor(tms));
  }
  
  void timeDown() {
    tms *= 1.1;    
    tick.setSpanMs(floor(tms));
  }
    
  void moveUp() {
    if(index != -1 && index + 1 < listCell.size()) {
      Collections.swap(listCell, index, index+1); 
    }
    indexUp();
  }
  
  void moveDown() {
    if(index != -1 && index > 0 && listCell.size() > 1) {
      Collections.swap(listCell, index, index-1); 
    }
    indexDown();
  }
  
  void indexUp() {
    int locPrevIndex = index;
    if(listCell.size() == 0) {
      index = -1;
      return;
    }
    
    if(listCell.size() == 1) {
      index = 0;
      return;
    }
    
    index = (index + 1) % (listCell.size());
    
    if(index != locPrevIndex)
      prevIndex = locPrevIndex;
  }
  
  
  void indexDown() {
    int locPrevIndex = index;

    if(listCell.size() == 0) {
      index = -1;
      return;
    }
    
    if(listCell.size() == 1) {
      index = 0;
      return;
    }
    
    index = (index + listCell.size() -1) % (listCell.size());
    if(index != locPrevIndex)
      prevIndex = locPrevIndex;
  }
 
  void play() {
    playing = true;
  }
   
  void stop() {
    playing = false;
/*
if(prevIndex < listCell.size()) {
      index = prevIndex;
    } else {
      index = -1;
      prevIndex = -1;
    }
*/  }
  
  void update() {
    
    if(indexRez == -1  && listCell.size() > 0) {
      indexRez = 0; 
    }
    
    if(indexRez != -1 && playing && listCell.size() > 1)  
      if(tick.getState()) {
        tick.reset(false);        
         // move up
      indexRez = (indexRez + 1) % (listCell.size());
      }
  }

  void draw(float _k) {
    
    if(index > listCell.size()-1)
      index = -1;

    if(index != -1) {
    //  for(areaCore itAreaCore : listCell.get(index).listAreaCore )
    //    itAreaCore.draw(_k);

      myPtxInter.mFbo.tint(255, 64);  // Display at half opacity
      myPtxInter.mFbo.image(listCell.get(index).img, 0, 0);
      myPtxInter.mFbo.tint(255, 255);    
    }
  }
  
  void drawRez() {
        
    if(indexRez > listCell.size()-1)
      indexRez = -1;

    myPtxInter.mFbo.pushMatrix();
    myPtxInter.mFbo.translate(wFbo/2, 0);
    if(indexRez != -1)
      for(areaCore itAreaCore : listCell.get(indexRez).listAreaCore )
        itAreaCore.draw();
    myPtxInter.mFbo.popMatrix();
  }
  
  
  void drawUI() {
    
    //Mignatures
    for(int i = 0; i < listCell.size(); ++i) {
      for(areaCore itAreaCore : listCell.get(i).listAreaCore )
        itAreaCore.drawMig(i);
    }
    
    
    myPtxInter.mFbo.fill(255);
    myPtxInter.mFbo.stroke(255);
    myPtxInter.mFbo.strokeWeight(2);
    myPtxInter.mFbo.beginShape(LINES);
  
    myPtxInter.mFbo.vertex(0, hFbo*rMig);
    myPtxInter.mFbo.vertex(wFbo, hFbo*rMig);
    
    myPtxInter.mFbo.vertex(wFbo/2, 0);
    myPtxInter.mFbo.vertex(wFbo/2, hFbo);
    
    // list of cells
    for(int i = 0; i<maxNbrCells; ++i) {
      
    myPtxInter.mFbo.vertex(i * wCell, hFbo*rMig);
    myPtxInter.mFbo.vertex(i * wCell, 0);
    }
  
    myPtxInter.mFbo.endShape();
    
    // The stylus
    if(index != -1) {
      myPtxInter.mFbo.strokeWeight(3);
      myPtxInter.mFbo.stroke(255, 0, 0, 180);
      myPtxInter.mFbo.noFill();
      myPtxInter.mFbo.beginShape();
      
      myPtxInter.mFbo.vertex((index+1) * wCell, hFbo*rMig);
      myPtxInter.mFbo.vertex((index+1) * wCell, 0);
      myPtxInter.mFbo.vertex(index * wCell, 0);
      myPtxInter.mFbo.vertex(index * wCell, hFbo*rMig);
    
      myPtxInter.mFbo.endShape(CLOSE);
    }
  }
}
