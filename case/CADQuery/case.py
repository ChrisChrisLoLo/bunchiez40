import cadquery as cq

## CONSTANTS
# Choc spacing dimensions
KEY_LENGTH = 10
KEY_WIDTH = 10

# Choc plate cutout dimensions
KEY_CUTOUT_X = 8
KEY_CUTOUT_Y = KEY_CUTOUT_X
KEY_CUTOUT_RADIUS = 0.5

# Case constants
INNER_FILLET_RADIUS = 2.0 # internal fillet
OUTER_FILLET_RADIUS = 3.0 # external fillet
CORNER_FILLET_RADIUS = 1.0 # use to round out case

FLOOR_LIP_LENGTH = 1.1

WALL_MARGIN = 0.3 # gap between pcb and case for one side
PCB_TOLERANCE = 0.3 + WALL_MARGIN # accounts for pcb cutout tolerance

TOTAL_WALL_WIDTH = 3.0
INNER_WALL_WIDTH = FLOOR_LIP_LENGTH
OUTER_WALL_WIDTH = TOTAL_WALL_WIDTH - INNER_WALL_WIDTH

NUM_KEYS_X = 12
NUM_KEYS_Y = 4

# Dimensions
PCB_LENGTH = KEY_LENGTH * NUM_KEYS_X
PCB_WIDTH = KEY_WIDTH * NUM_KEYS_Y

CASE_INNER_LENGTH = PCB_LENGTH + (PCB_TOLERANCE*2)
CASE_INNER_WIDTH = PCB_WIDTH + (PCB_TOLERANCE*2)

CASE_INNER_WALL_LENGTH = CASE_INNER_LENGTH + (INNER_WALL_WIDTH*2)
CASE_INNER_WALL_WIDTH = CASE_INNER_WIDTH + (INNER_WALL_WIDTH*2)

CASE_OUTER_WALL_LENGTH = CASE_INNER_WALL_LENGTH + (OUTER_WALL_WIDTH*2)
CASE_OUTER_WALL_WIDTH = CASE_INNER_WALL_WIDTH + (OUTER_WALL_WIDTH*2)

PLATE_HEIGHT = 2.2 # 1.2 # Height of the integrated plate
FLOOR_HEIGHT = 1.6 # Height of the PCB bottom
CASE_UPPER_HEIGHT = 0 # Height of the wall above the plate
CASE_INNER_WALL_HEIGHT = PLATE_HEIGHT+6 #TODO; can probably be lower
CASE_OUTER_WALL_HEIGHT = CASE_INNER_WALL_HEIGHT+FLOOR_HEIGHT+CASE_UPPER_HEIGHT # Height of the outer case
SCREW_POLE_HEIGHT = CASE_INNER_WALL_HEIGHT
# no holes
SCREW_POLE_INNER_HEIGHT = SCREW_POLE_HEIGHT - 3.5

SCREW_POLE_OUTER_RADIUS = 3.1/2
SCREW_POLE_INNER_RADIUS = 1.6/2

# silly alias to cut down on verbosity
def wp():
    return cq.Workplane("XY")

def case_inner_square(height, corner_radius):
    wp().box(CASE_INNER_LENGTH,CASE_INNER_LENGTH,height).edges("|Z").fillet(corner_radius)

def case_inner_wall_square(height,corner_radius):
    wp().box(CASE_INNER_WALL_LENGTH,CASE_INNER_WALL_LENGTH,height).edges("|Z").fillet(corner_radius)

def case_outer_wall_square(height,corner_radius):
    wp().box(CASE_OUTER_WALL_LENGTH,CASE_OUTER_WALL_WIDTH,height).translate(0,0,-CASE_UPPER_HEIGHT).edges("|Z").fillet(corner_radius)

def key_cutout_square():
    wp().box(KEY_CUTOUT_X,KEY_CUTOUT_Y,PLATE_HEIGHT+0.01).edges("|Z").fillet(KEY_CUTOUT_RADIUS)

def key_cutout_matrix():
    for i in range(NUM_KEYS_X-1):
        for j in range(NUM_KEYS_Y-1):
            if (i!=5 and j!=5): # we don't want keys in the middle
                key_cutout_square().translate(KEY_LENGTH*(i-((NUM_KEYS_X/2)-0.5)),KEY_WIDTH*(j-(NUM_KEYS_Y/2)+0.5),0)

def screw_pole():
    pass

def screw_hole():
    pass

def screw_pole_matrix():
    pass

def screw_hole_matrix():
    pass

def standoff():
    pass

def standoff_matrix():
    pass

def usb_cutout():
    pass

def switch_cutout():
    pass



case_inner_square(PLATE_HEIGHT,INNER_FILLET_RADIUS)
case_inner_wall_square(CASE_INNER_WALL_HEIGHT,INNER_FILLET_RADIUS)
case_inner_square(CASE_INNER_WALL_HEIGHT+0.01,INNER_FILLET_RADIUS)

