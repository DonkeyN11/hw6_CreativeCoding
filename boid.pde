class Boid{
  PMatrix3D matrix;
  float speed;
  color colour;
  
  Boid(){
    matrix = new PMatrix3D();
    matrix.translate(random(-width/2,width/2),random(-height/2,height/2),random(-height/2,height/2));
    matrix.rotateY(random(TWO_PI));
    matrix.rotateX(random(TWO_PI));
    // random speed
    speed = random(1.0,2.0);
    // random HSB color
    colour = color(random(0,256),204,204);
  }
  
  void reset(){
    matrix.reset();
    matrix.translate(random(-width/2,width/2),random(-height/2,height/2),random(-height/2,height/2));
    matrix.rotateY(random(TWO_PI));
    matrix.rotateX(random(TWO_PI));
  }
  
  void move(Boid [] flock){
    // the inverse "undoes" how you would get to this boid:
    // applying it views the world relative to this boid
    PMatrix3D inverse = new PMatrix3D(matrix);
    inverse.invert();
    // look for centre of nearby boids and their average heading
    boolean cohere = false;
    boolean separate = false;
    PVector neighbourcentre = new PVector();
    PVector neighbourdir = new PVector();
    PVector kernelcentre = new PVector();
    
    for (int i = 0; i < flock.length; i++) {
      if (flock[i] != this) {
        // take the position of the other boid,
        // and then apply the position relative to this boid
        PMatrix3D mat_i = new PMatrix3D(flock[i].matrix);
        mat_i.preApply(inverse);
        // now it is simple to find the position of the other
        // boid relative to this one:
        PVector p_i = pos(mat_i);
        float separation = p_i.mag();
        if (separation < width / 4) { 
          PVector d_i = dir(mat_i);
          // check to see if in field of view
          if (d_i.z > -0.25) {
            neighbourcentre.add(p_i);
            neighbourdir.add(d_i);
            cohere = true;
            if (separation < 10) {
              kernelcentre.add(p_i);
              separate = true;
            }
          }
        }
      }
    }
    // if too close, then fly away from other boids,
    // otherwise fly towards them
    if (separate) {
      if (kernelcentre.x > 0) {
        matrix.rotate(-PI/12,0,1,0);
      }
      else {
        matrix.rotate(PI/12,0,1,0);
      }
    }
    else if (cohere) {
      // find direction to centre (for cohesion)
      neighbourcentre.normalize();
      // find direction of neighbours (for alignment)
      neighbourdir.normalize();
      // now turn to these
      PVector desiredir = new PVector();
      desiredir.add(neighbourcentre);
      desiredir.add(neighbourdir);
      desiredir.normalize();
      //
      float ang = acos(desiredir.z);
      if (ang > 0.01) {
        matrix.rotate(ang*0.1,-desiredir.y,desiredir.x,0.0);
      }
    }
    matrix.translate(0,0,speed);
  }
  
  //void drawBoid(){
    //fill(colour);
    //pushMatrix();
    //applyMatrix(matrix);
    //beginShape();
    //vertex(-6,0,-8);
    //vertex(0,0,8);
    //vertex(6,0,-8);
    //endShape(CLOSE);
    //beginShape();
    //vertex(0,3,-8);
    //vertex(0,0,8);
    //vertex(0,0,-8);
    //vertex(0,-3,8);
    //endShape(CLOSE);
    //popMatrix();
  //}
  void drawBoid(){
    
  fill(colour);
  pushMatrix();
  applyMatrix(matrix);
  fill(126);//tail
  noStroke();
  ellipse(-8, 0, 2, 1);
  rotate(PI/40);
  ellipse(-8, 0, 2, 1);
  rotate(-PI/20);
  ellipse(-8, 0, 2, 1);
  rotate(PI/40);
 
  rotate(PI/4);//mouth
  rect(0, -5, 3, 3);
  rotate(-PI/4);
 
  fill(200);
  beginShape();//body
  vertex(-8, 0);
  bezierVertex(-8, 0, 0, -6, 3, -5);
  bezierVertex(3, -5, 7, -3, 3, 4);
  bezierVertex(3, 4, 0, 6, -8, 0);
  endShape();
 
  fill(126);//eye
  translate(4, -4);
  ellipse(-0.5, 0.5, 3, 3);
 
  fill(0);
  ellipse(0, 0, 1, 1);


  popMatrix();

  }
  
}

PVector pos(PMatrix3D matrix){
  return new PVector(matrix.m03,matrix.m13,matrix.m23);
}

PVector dir(PMatrix3D matrix){
  return new PVector(matrix.m02,matrix.m12,matrix.m22);
}
