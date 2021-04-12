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

#declare Axes = union {
  cylinder { 0, 2 * x, 0.05 }
  cylinder { 0, 2 * y, 0.05 }
  cylinder { 0, -2 * z, 0.05 }
  
  pigment { color rgb <0.7, 0.7 0.7> }
}

// camera ----------------------------------
camera {
  location  <0.0,  3.0, -8.0>
  look_at   <0.0,  0.0,  0.0>
  right x*image_width/image_height
  angle 75 
}

// sun -------------------------------------
light_source{
  <0.85, 1.8, 0>*10
  color White
}

union {
  object {
    box { <-1, -1, -1>, <1, 1, 1> }
    pigment { color Red }

#if (clock < 1.0)
    rotate 90 * clock * y
#else
    rotate 90 * y
    translate -(clock - 1) * 1.5 * x
#end
  }
  
  object {
    Axes
  }
  
  translate -3*x
}

union {
  object {
    box { <-1, -1, -1>, <1, 1, 1> }
    pigment { color Green }

#if (clock < 1.0)
    translate -clock * 1.5 * x
#else
    translate -1.5 * x
    rotate 90 * (clock - 1) * y
#end
  }
  
  object {
    Axes
  }
  
  translate 3*x
}
