height = 60;
width_bottom = 13;
width_top = 5;

gap = 0.15;

$fa = 5;
$fs = 0.1;

// derived variables
radius_bottom = width_bottom/2;
radius_top = width_top/2;
connector_length = 2*width_bottom;

divider();
translate([40,0,0])
    connector_straight();
translate([80,0,0])
    connector_t();
translate([120,0,0])
    connector_x();

module profile(length=150) {
    rotate([90,0,0]) {
        linear_extrude(height=length) {
            polygon([
                [-radius_bottom, 0],
                [radius_bottom, 0],
                [radius_top, height-radius_top],
                [-radius_top, height-radius_top]
            ]);
            translate([0, height-radius_top])
                circle(r=radius_top);
        }
    }
}

module profile_90degree() {
    difference() {
        cube([0.5*connector_length, 0.5*connector_length, height-radius_top]);
        translate([0.5*connector_length, 0.5*connector_length]) {
            rotate_extrude() {
                polygon([
                    [0, 0],
                    [0.5*connector_length-radius_bottom, 0],
                    [0.5*connector_length-radius_top, height-radius_top],
                    [0, height-radius_top]
                ]);
            }
        }
    }
    intersection() {
        translate([0, 0, height-radius_top])
            cube([0.5*connector_length, 0.5*connector_length, radius_top]);
        translate([0.5*connector_length, 0.5*connector_length]) {
            rotate_extrude() {
                translate([0.5*connector_length, height-radius_top])
                    circle(r=radius_top);
            }
        }
    }
    difference() {
        translate([0, 0, height-radius_top])
            cube([0.5*connector_length, 0.5*connector_length, radius_top]);
        translate([0.5*connector_length, 0.5*connector_length, height-radius_top])
            cylinder(h=radius_top, r=0.5*connector_length);
    }
}


module fitting(male=true) {
    gap = male ? gap : 0;  // shrink male piece a little bit
    connector_length = radius_bottom;
    linear_extrude(height=height-radius_top-gap, scale=width_top/width_bottom) {
        polygon([
            [-0.3*radius_bottom+gap, 0],
            [0.3*radius_bottom-gap, 0],
            [0.5*radius_bottom-gap, connector_length],
            [-0.5*radius_bottom+gap, connector_length]
        ]);
        translate([0,connector_length]) {
            circle(r=0.6*radius_bottom-gap);
            // add "air channel" for female piece
            if (!male)
                square([0.2*radius_bottom, 0.9*radius_bottom]);
        }
    }
}

module divider(length=100) {
    difference() {
        profile(length);
        rotate([0,0,180])
            fitting(male=false);
        translate([0,-length,0])
            fitting(male=false);
    }
}

module connector_straight() {
    translate([0,0.5*connector_length,0]) {
        union() {
            profile(connector_length);
            fitting(male=true);
            translate([0,-connector_length,0])
                rotate([0,0,180])
                    fitting(male=true);
        }
    }
}

module connector_x() {
    union() {
        for (r=[0, 90, 180, 270]) {
            rotate([0,0,r]) {
                translate([0,0.5*connector_length,0])
                    fitting(male=true);
                profile_90degree();
            }
        }
    }
}

module connector_t() {
    union() {
        for (r=[0, 90, 180]) {
            rotate([0,0,r])
                translate([0,0.5*connector_length,0])
                    fitting(male=true);
        }
        for (r=[90, 180]) {
            rotate([0,0,r])
                profile_90degree();
        }
        translate([0,0.5*connector_length,0])
            profile(connector_length);
    }
}