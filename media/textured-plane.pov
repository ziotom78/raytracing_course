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
  location  <0.0 , 1.0 ,-3.0>
  look_at   <0.0 , 0.0 , 0.0>
  right x*image_width/image_height
  angle 75 
}

// sun -------------------------------------
light_source{
  <0.85, 1.8, 10>
  color White*3
}

// ground ----------------------------------
plane{ 
  z, 0
  pigment {
    image_map {
      png "earth-from-space-small.png"
      map_type 0
      interpolate 2
    }
  }
  rotate 90*x
  rotate 30*y
  scale 0.5
} // end of plane
