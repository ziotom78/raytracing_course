#version 3.7; // 3.7

// Dice definition taken from 
// https://commons.wikimedia.org/wiki/User:Ed_g2s/Dice.pov

#declare DiceColor = color red 1 green .95 blue .65;
#declare DotColor = color red .1 green .1 blue .1;


#declare DiceBody = intersection {
	box { <-1, -1, -1>, <1, 1, 1> scale 0.5 }
	superellipsoid { <0.7, 0.7>  scale 0.63 }
}

#declare Middle = sphere { <0, 0.6, 0>, 0.13 }

#declare Corners1 = union {
	sphere { <-.25, .6, -.25>, 0.13 }
	sphere { <.25, .6, .25>, 0.13 }
}

#declare Corners2 = union {
	sphere { <-.25, .6, .25>, 0.13 }
	sphere { <.25, .6, -.25>, 0.13 }
}

#declare Middles = union {
	sphere { <-.25, .6, 0>, 0.13 }
	sphere { <.25, .6, 0>, 0.13 }
}

#declare One = Middle

#declare Two = Corners1

#declare Three = union {
	object { Middle }
	object { Corners1 }
}

#declare Four = union {
	object { Corners1 }
	object { Corners2 }
}

#declare Five = union {
	object { Four }
	object { One }
}

#declare Six = union {
	object { Corners1 }
	object { Corners2 }
	object { Middles }
}

#declare DiceInterior = interior { ior 1.5 }
#declare DiceFinish = finish { phong 0.1 specular 0.5 ambient 0.4 }

#macro Dice(Color)
difference {
	object {
		DiceBody
		pigment { color Color }
		interior { DiceInterior }
		finish { DiceFinish }
	}
	union {
		object { One rotate -90*z }
		object { Two }
		object { Three rotate -90*x }
		object { Four rotate 90*x }
		object { Five rotate 180*x }
		object { Six rotate 90*z }
		pigment { White }
		finish { ambient 0.5 roughness 0.5 }

	}
	bounded_by { box { <-0.52, -0.52, -0.52>, <0.52, 0.52, 0.52> } }
}
#end

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

object {
  object {
    Dice(color rgb <1, 0, 0>)
    scale 2

#if (clock < 1.0)
    rotate 90 * clock * x
#else
    rotate 90 * x
    rotate 90 * (clock - 1) * y
#end
  }
  
  translate -3*x
}

object {
  object {
    Dice(color rgb <0, 1, 0>)
    scale 2

#if (clock < 1.0)
    rotate 90 * clock * y
#else
    rotate 90 * y
    rotate 90 * (clock - 1) * x
#end
  }
  
  translate 3*x
}
