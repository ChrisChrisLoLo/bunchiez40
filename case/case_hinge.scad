// units are in mm

$fa = 0.1;
$fs = 0.1;

//// MODULES 
module rounding2d(r) {
    offset(r = r) offset(delta = -r) children(0);
}

module fillet2d(r) {
    offset(r = -r) offset(delta = r) children(0);
}

function filletDepth(r, d, i) = r * cos(asin(d * i / r));

module topBottomFillet(b = 0, t = 2, r = 1, s = 4, e = 1) {
    if (e == 1) {        
        topFilletPeice(t = t, r = r, s = s) children(0);
        bottomFilletPeice(b = b, r = r, s = s) children(0);
        
        render()
        difference() {
            children(0);
            
            translate([0, 0, t - r])
            linear_extrude(r + 1)
            offset(delta = 1e5)
            projection()
            children(0);
            
            translate([0, 0, b - 1])
            linear_extrude(r + 1)
            offset(delta = 1e5)
            projection()
            children(0);
            
        }
    }
    if (e == 0) children(0);
}

module topFillet(t = 2, r = 1, s = 4, e = 1) {
    if (e == 1) {
        topFilletPeice(t = t, r = r, s = s) children(0);
        
        render()
        difference() {
            children(0);
            translate([0, 0, t-r])
            linear_extrude(r + 1)
            offset(delta = 1e5)
            projection()
            children(0);
        }
    }
    if (e == 0) children(0);
}

module bottomFillet(b = 0, r = 1, s = 4, e = 1) {
    if (e == 1) {
        bottomFilletPeice(b = b, r = r, s = s) children(0);
        
        render()
        difference() {
            children(0);
            translate([0, 0, b - r - 1])
            linear_extrude(r + 1)
            offset(delta = 1e5)
            projection()
            children(0);
        }
    }
    if (e == 0) children(0);
}

module topFilletPeice(t = 2, r = 1, s = 4) {
    d = r/s;
        
    for (i = [0:s]) {
        x = filletDepth(r, d, i);
        z = d * (s - i + 1);                  
        translate([0, 0, t - z]) 
        linear_extrude(d) 
        offset(delta = -r + x) 
        projection(true) 
        translate([0, 0, -t + z])
        children(0);
    }
}

module bottomFilletPeice(b = 0, r =1, s = 4) {
    d = r/s;
        
    for (i = [0:s]) {
        x = filletDepth(r, d, i);
        z = d * (s - i);
        translate([0, 0, b + z]) 
        linear_extrude(d) 
        offset(delta = -r + x) 
        projection(true)
        translate([0, 0, b - z])
        children(0);
    }
}


//// CONSTANTS
// Choc spacing dimensions
KEY_LENGTH = 10;
KEY_WIDTH = 10;

// Choc plate cutout dimensions
KEY_CUTOUT_X = 8;
KEY_CUTOUT_Y = KEY_CUTOUT_X;
KEY_CUTOUT_RADIUS = 0.5;

// Case constants
INNER_FILLET_RADIUS = 2.0; // internal fillet
OUTER_FILLET_RADIUS = 3.0; // external fillet
CORNER_FILLET_RADIUS = 1.0; // use to round out case

FLOOR_LIP_LENGTH = 1.1;

WALL_MARGIN = 0.3; // gap between pcb and case for one side
PCB_TOLERANCE = 0.3 + WALL_MARGIN; // accounts for pcb cutout tolerance

TOTAL_WALL_WIDTH = 3.0;
INNER_WALL_WIDTH = FLOOR_LIP_LENGTH;
OUTER_WALL_WIDTH = TOTAL_WALL_WIDTH - INNER_WALL_WIDTH;

NUM_KEYS_X = 12;
NUM_KEYS_Y = 4;

// Dimensions
PCB_LENGTH = KEY_LENGTH * NUM_KEYS_X;
PCB_WIDTH = KEY_WIDTH * NUM_KEYS_Y;

CASE_INNER_LENGTH = PCB_LENGTH + (PCB_TOLERANCE*2);
CASE_INNER_WIDTH = PCB_WIDTH + (PCB_TOLERANCE*2);

CASE_INNER_WALL_LENGTH = CASE_INNER_LENGTH + (INNER_WALL_WIDTH*2);
CASE_INNER_WALL_WIDTH = CASE_INNER_WIDTH + (INNER_WALL_WIDTH*2);

CASE_OUTER_WALL_LENGTH = CASE_INNER_WALL_LENGTH + (OUTER_WALL_WIDTH*2);
CASE_OUTER_WALL_WIDTH = CASE_INNER_WALL_WIDTH + (OUTER_WALL_WIDTH*2);

PLATE_HEIGHT = 1.2; // Height of the integrated plate
FLOOR_HEIGHT = 1.6; // Height of the PCB bottom
CASE_UPPER_HEIGHT = 0; // Height of the wall above the plate
CASE_INNER_WALL_HEIGHT = PLATE_HEIGHT+10; //TODO; can probably be lower
CASE_OUTER_WALL_HEIGHT = CASE_INNER_WALL_HEIGHT+FLOOR_HEIGHT+CASE_UPPER_HEIGHT; // Height of the outer case
SCREW_POLE_HEIGHT = CASE_INNER_WALL_HEIGHT;
SCREW_POLE_INNER_HEIGHT = SCREW_POLE_HEIGHT - 3.5;

SCREW_POLE_OUTER_RADIUS = 3.7/2;
SCREW_POLE_INNER_RADIUS = 1.6/2;

// Modules
module case_inner_square(height, corner_radius) {
    linear_extrude(height)
        rounding2d(corner_radius)
        square([CASE_INNER_LENGTH,CASE_INNER_WIDTH], center = true);
}

module case_inner_wall_square(height, corner_radius) {
    linear_extrude(height)
        rounding2d(corner_radius)
        square([CASE_INNER_WALL_LENGTH,CASE_INNER_WALL_WIDTH], center = true);
}

module case_outer_wall_square(height, corner_radius) {
    translate([0,0,-CASE_UPPER_HEIGHT])
        linear_extrude(height)
        rounding2d(corner_radius)
        square([CASE_OUTER_WALL_LENGTH,CASE_OUTER_WALL_WIDTH], center = true);
}

module key_cutout_square() {
    linear_extrude(PLATE_HEIGHT+0.01)
        rounding2d(KEY_CUTOUT_RADIUS)
        square([KEY_CUTOUT_X,KEY_CUTOUT_Y], center = true);
}

module key_flexture(key_x, key_y, key_difference, spring_thickness) {
    base_thickness = 0; // base thickness is used to give more strength for the base

    linear_extrude(0.2)
        union(){
            // NOTE: springs should be turned into a module
            // towards key
            translate([-KEY_CUTOUT_X/4,(+key_y/2)+((key_difference/2)/2)+(spring_thickness/2),0])
                square([spring_thickness+base_thickness, key_difference/2], center = true);
            translate([+KEY_CUTOUT_X/4,(+key_y/2)+((key_difference/2)/2)+(spring_thickness/2),0])
                square([spring_thickness+base_thickness, key_difference/2], center = true);
            // towards cutout
            translate([+KEY_CUTOUT_X/4,(+key_y/2)+((key_difference/2)/2)-(spring_thickness/2),0])
                square([spring_thickness, key_difference/2], center = true);
            translate([-KEY_CUTOUT_X/4,(+key_y/2)+((key_difference/2)/2)-(spring_thickness/2),0])
                square([spring_thickness, key_difference/2], center = true);
            // re-enforcement
            
            translate([0,(+key_y/2)+0.2,0])
                square([key_x-1.5, 0.5], center = true);
        };
    
    // tab on key to prevent it from lifting out of the case
    tab_thickness = 0.5;
    translate([0,(-key_y/2),0.7])
        linear_extrude(tab_thickness)
        square([5,1.4], center = true);
        
    tab_thickness = 0.5;
    translate([0,(-key_y/2)-(key_difference/2)])
        linear_extrude(tab_thickness)
        
        square([5,1.4], center = true);
}

module key_square() {
    spring_thickness = 0.5;
    key_height = 3;
    key_difference = 2;
    key_x = KEY_CUTOUT_X-key_difference;
    key_y = KEY_CUTOUT_Y-key_difference;
    union(){
        translate([0,0,-key_height+PLATE_HEIGHT])
            union(){
                linear_extrude(key_height)
                    rounding2d(KEY_CUTOUT_RADIUS)
                    square([key_x,key_y], center = true);
            };
        key_flexture(key_x, key_y, key_difference, spring_thickness);
    }
}

module key_cutout_matrix() {
    for (i = [0:NUM_KEYS_X-1]){
        for (j = [0:NUM_KEYS_Y-1]){
            if (i!=5 && i!=6){ // We don't want key cutouts on the middle cols
                translate([KEY_LENGTH*(i-((NUM_KEYS_X/2)-0.5)),KEY_WIDTH*(j-(NUM_KEYS_Y/2)+0.5),0])
                    key_cutout_square();
            }    
        }
    }
}

module key_matrix(){
    for (i = [0:NUM_KEYS_X-1]){
        for (j = [0:NUM_KEYS_Y-1]){
            if (i!=5 && i!=6){ // We don't want key cutouts on the middle cols
                translate([KEY_LENGTH*(i-((NUM_KEYS_X/2)-0.5)),KEY_WIDTH*(j-(NUM_KEYS_Y/2)+0.5),0])
                    key_square();
            }    
        }
    }
}

module screw_pole() {
    height_diff = SCREW_POLE_HEIGHT-SCREW_POLE_INNER_HEIGHT;
    difference(){
        linear_extrude(SCREW_POLE_HEIGHT)
            circle(SCREW_POLE_OUTER_RADIUS);
        
        translate([0,0,height_diff])
        linear_extrude(SCREW_POLE_INNER_HEIGHT)
            circle(SCREW_POLE_INNER_RADIUS);
    }
}

module screw_pole_matrix() {
    for (i = [0:NUM_KEYS_X]){
        for (j = [0:NUM_KEYS_Y]){
            if (
                (i==1  && j==1)  ||
                (i==11 && j==1)  ||
                (i==4  && j==2)  ||
                (i==8  && j==2)  ||
                (i==1  && j==3)  ||
                (i==11 && j==3)
            ){
                translate([KEY_LENGTH*(i-((NUM_KEYS_X/2))),KEY_WIDTH*(j-(NUM_KEYS_Y/2)),0])
                    screw_pole();
            }    
        }
    }
}

module usb_cutout() {
    cutout_width = 11;
    cutout_height = 5;
    
    cutout_pos_height = 6.5;
    
    rotate([90,0,0])
        translate([0,cutout_pos_height,-40])
        linear_extrude(TOTAL_WALL_WIDTH+0.01+20)
        rounding2d(1.0)
        square([cutout_width, cutout_height], center=true);
}

module middle_plate_cutout() {
    padding = 1;
    width = (KEY_LENGTH-padding )* 2;
    length = (KEY_WIDTH*NUM_KEYS_Y)+(PCB_TOLERANCE*2);
    
    linear_extrude(PLATE_HEIGHT+(CASE_UPPER_HEIGHT/2)+0.01)
        // rounding2d(0.5)
        square([width, length], center = true);
}


module switch_cutout() {
    cutout_width = 16;
    cutout_height = 32;
    
    cutout_pos_height = FLOOR_HEIGHT + 2;
    
        linear_extrude(TOTAL_WALL_WIDTH+0.01+20)
        rounding2d(1.0)
        square([cutout_width, cutout_height], center=true);
}

module reset_cutout() {
    cutout_width = 6;
    cutout_height = 2.5;
    
    cutout_pos_height = FLOOR_HEIGHT + 2;
    
    rotate([90,0,0])
        translate([-14.5,cutout_pos_height,-45])
        linear_extrude(TOTAL_WALL_WIDTH+0.01+10)
        rounding2d(1.0)
        square([cutout_width, cutout_height], center=true);
}

if (true){
    difference(){
        union(){
            difference(){
                case_inner_square(PLATE_HEIGHT,INNER_FILLET_RADIUS);
                //middle_plate_cutout();
            }


            difference(){
                case_inner_wall_square(CASE_INNER_WALL_HEIGHT,INNER_FILLET_RADIUS);
                case_inner_square(CASE_INNER_WALL_HEIGHT+0.01,INNER_FILLET_RADIUS);
            }
            
            difference(){
                topBottomFillet(b = -CASE_UPPER_HEIGHT, t = CASE_INNER_WALL_HEIGHT+FLOOR_HEIGHT, r = 2, s = 20, e=0)
                case_outer_wall_square(CASE_OUTER_WALL_HEIGHT, OUTER_FILLET_RADIUS);
                case_inner_wall_square(CASE_OUTER_WALL_HEIGHT+0.01, INNER_FILLET_RADIUS); // delete lower portion
            }
        }
        key_cutout_matrix();
        usb_cutout();
        switch_cutout();
        reset_cutout();
    }
}
// usb_cutout();
//screen_cutout();


module case_floor_holes() {
    m2_hole_radius = (2.2/2);

    for (i = [0:NUM_KEYS_X]){
        for (j = [0:NUM_KEYS_Y]){
            if (
                (i==1  && j==1)  ||
                (i==11 && j==1)  ||
                (i==4  && j==2)  ||
                (i==8  && j==2)  ||
                (i==1  && j==3)  ||
                (i==11 && j==3)
            ){
                translate([KEY_LENGTH*(i-((NUM_KEYS_X/2))),KEY_WIDTH*(j-(NUM_KEYS_Y/2)),0])
                    circle(m2_hole_radius);
            }    
        }
    }
}

// case Floor. Generally consists of a piece of pcb or acrylic
module case_floor() {
    plate_height = 1.57;
    margin = 1;
    
    translate([0,0,CASE_INNER_WALL_HEIGHT+0.01+0])
    difference(){
        linear_extrude(plate_height)
            rounding2d(INNER_FILLET_RADIUS)
            // Want the plate to rest in the middle of the case lip,
            // hence we subtract half of the inner wall width once on each side
            square([CASE_INNER_WALL_LENGTH-(INNER_WALL_WIDTH*2/2),CASE_INNER_WALL_WIDTH-(INNER_WALL_WIDTH*2/2)], center = true);
            //square([CASE_INNER_WALL_LENGTH,CASE_INNER_WALL_WIDTH], center = true);
        linear_extrude(plate_height+0.01)
            case_floor_holes();
    }
}

if (false){
    case_floor();
}

if (true){
    key_matrix();
}