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
  look_at   <0.0 , 1.0 , 0.0>
  right x*image_width/image_height
  angle 75 
}

// sun -------------------------------------
light_source{
  <0.85, 1.8, 0>
  color White
}

// ground ----------------------------------
plane{ 
  <0,1,0>, 0
  texture{
    pigment{ color rgb<0.22,0.45,0>}
    finish { phong 0.1 }
  } // end of texture
} // end of plane

// objects in scene ------------------------
sphere{ 
  <0,0,0>, 0.03
  texture {
    pigment{ color rgb<1,1,1>*10}
    finish { 
      phong 1 
    }
  } // end of texture
  translate<0.85,1.8,0>
  no_shadow
} // end of sphere
