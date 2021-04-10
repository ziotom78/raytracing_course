#version 3.7; // 3.7

global_settings{
  assumed_gamma 1.0
}

#default { 
  finish { 
    ambient 0.1 
    diffuse 0.9 
  }
}

#include "colors.inc"
#include "textures.inc"

// camera ----------------------------------
camera {
  location  <0.0,  3.0, -10.0>
  look_at   <0.0,  0.0,   0.0>
  right x*image_width/image_height
  angle 75 
}

// sun -------------------------------------
light_source{
  <0.85, 1.8, 0>*10
  color White
}

object {
  union {
    box {
      <-1, -1, -1>, <1, 1, 1>
      pigment { Red }
      rotate 90 * clock * x
    }
    
    cylinder {
      -2*x, 2*x, 0.05
      pigment { rgb <0.5, 0.5, 0.5> }
    }
  }
  
  translate -5*x
}


object {
  union {
    box {
      <-1, -1, -1>, <1, 1, 1>
      pigment { Green }
      rotate 90 * clock * y
    }
    cylinder {
      -2*y, 2*y, 0.05
      pigment { rgb <0.5, 0.5, 0.5> }
    }
  }
}


object {
  union {
    box {
      <-1, -1, -1>, <1, 1, 1>
      pigment { Blue }
      rotate 90 * clock * z
    }
    cylinder {
      -2*z, 2*z, 0.05
      pigment { rgb <0.5, 0.5, 0.5> }
    }
  }
  
  translate 5*x
}
