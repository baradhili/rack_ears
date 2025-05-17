// == Customizer Settings ==

production_mode = "Laser Cut"; // [Laser Cut, 3D Print]

// == Dimensions ==
thickness = 3; // [2:10] // Metal/Plastic thickness in mm
height = 70; // [50:100] // Height of bracket
width = 70; // [20:100] // Width of central bracket portion

// == Rack Mounting Parameters ==
Total_rack_width = 482.60; // Total width of rack (19")
device_width = 254; // [200:482.60] // Width of device
flange_depth = (Total_rack_width - device_width)/2; // Depth of flange

// == Hole and Slot Sizes ==
mount_hole_dia = 4; // [3:6] // Mounting hole diameter
holes = "Two"; // [Two, Four]
mount_setback = 20.0; //[1.0:30.0] //setback for first mounting hole
mount_hole_y_spacing = 37.5; //[10:70] // spacing between device mount holes
mount_hole_x_spacing = 37.5; //[10:70] // spacing between device mount holes

// == Rack holes ==
slot_dia = 6.35; // Slot diameter (6.35 = 1/4")
slot_len = 9;  // Total length of slot
slot_offset_from_edge = 3; // Slot offset from flange edge

// == laser markup ==
bend_mark_len = 15; //[1:20] // length of bend marker for dxf export

// == Derived Parameters ==
slot_center_z = flange_depth - (3 + slot_len); // Position of slot center along flange
u_height = round(((height + 0.794)/44.45)*2)/2; //get teh u number to 1 decimal point
hole_positions = get_mounting_holes(u_height);
echo("hole positions: ",hole_positions);
rack_hole_y1 = hole_positions[0];  // First (top-most) hole
rack_hole_y2 = hole_positions[1];  // Last (bottom-most) hole




// == Main Module ==

function raw_mounting_holes(nU) = let(
    full_Us = ceil(nU),
    hole_offsets = [6.35, 22.225, 38.1]  // Positions within each U
)
[
    for (u = [0 : full_Us - 1])
        for (offset = hole_offsets)
            u * 44.45 + offset
];

function filter_holes(nested_holes, max_height) = let(
    // Flatten the nested list
    flat = [
        // Iterate over each sublist
        for (pair = nested_holes)
            // Iterate over each value in the pair
            for (h = pair)
                h
    ],
    // Filter out any values > max_height make sure it leave at least 3mm on the border
    filtered = [
        for (h = flat)
            if (h <= max_height-6.35) h
    ],
    first = filtered[0],
    last  = filtered[len(filtered) - 1]
)
[first, last];

function get_mounting_holes(nU) =
    filter_holes(raw_mounting_holes(nU), nU * 44.45);

module bracket_3d() {
    difference() {
        cube([width, height, thickness]);

        // Internal mounting holes (for device, 37.5mm apart)
        // Two holes: one set
        // Four holes: two sets, spaced by mount_hole_x_spacing
        for (i = [0 : (holes == "Four" ? 1 : 0)]) {
            translate([mount_setback + i * mount_hole_x_spacing, (height - mount_hole_y_spacing)/2, 0])
                cylinder(h=thickness+1, d=mount_hole_dia, $fn=30);
            translate([mount_setback + i * mount_hole_x_spacing, (height - mount_hole_y_spacing)/2 + mount_hole_y_spacing, 0])
                cylinder(h=thickness+1, d=mount_hole_dia, $fn=30);
        }
    }

    // Flange
    translate([0, 0, thickness])
        difference() {
            cube([thickness, height, flange_depth]);

            // Rack mount holes - elongated (1/4 inch diameter, slotted)
            translate([-0.1, rack_hole_y1, slot_center_z])
                rotate([90, 0, 90])
                    hull() {
                        translate([0, 0, 0])
                            cylinder(h = thickness + 1, d = slot_dia, $fn = 30);
                        translate([0, slot_len - slot_dia, 0])
                            cylinder(h = thickness + 1, d = slot_dia, $fn = 30);
                    }

            translate([-0.1, rack_hole_y2, slot_center_z])
                rotate([90, 0, 90])
                    hull() {
                        translate([0, 0, 0])
                            cylinder(h = thickness + 1, d = slot_dia, $fn = 30);
                        translate([0, slot_len - slot_dia, 0])
                            cylinder(h = thickness + 1, d = slot_dia, $fn = 30);
                    }
        }
}

module flat_bracket_2d() {
    difference() {
        // Base outline: main plate + flange
        union() {
            // Main vertical plate
            translate([-width,0]) square([width, height], center = false);

            // Flange (unfolded to the right of the main plate) 
            square([flange_depth, height], center = false);
        }

        // Mounting holes
        for (i = [0 : (holes == "Four" ? 1 : 0)]) {
            translate([-1*(mount_setback + i * mount_hole_x_spacing), (height - mount_hole_y_spacing)/2, 0])
                cylinder(h=thickness+1, d=mount_hole_dia, $fn=30);
            translate([-1*(mount_setback + i * mount_hole_x_spacing), (height - mount_hole_y_spacing)/2 + mount_hole_y_spacing, 0])
                cylinder(h=thickness+1, d=mount_hole_dia, $fn=30);
        }

        // Rack mount slots in flange
        // Slot 1
        translate([width + slot_center_z, rack_hole_y1]) {
                hull() {
                    circle(d = slot_dia);
                    translate([slot_len - slot_dia, 0]) circle(d = slot_dia);
                }
        }

        // Slot 2
        translate([width + slot_center_z, rack_hole_y2]) {
                hull() {
                    circle(d = slot_dia);
                    translate([slot_len - slot_dia, 0]) circle(d = slot_dia);
                }
        }
    }
    // == Bend Markers: 1mm segments, 1mm outside the bend line ==
    // Position: at the bend between main plate and flange (x = width)
    // Offset 1mm outside the part on both sides

    // Left marker (1mm to the left of the bend line)
    translate([0 , 0]) {
        // Vertical line segment, 15mm long, centered vertically
        translate([0, -1*(bend_mark_len+1)]) {
            color("red")square([0.1, bend_mark_len], center = false); // Solid line
        }
    }

    // Right marker (1mm to the right of the bend line)
    translate([0, 0]) {
        translate([0, height+1]) {
            color("red")square([0.1, bend_mark_len], center = false); // Solid line
        }
    }
}

// == Production Mode Switch ==
if (production_mode == "3D Print") {
    bracket_3d();
} else {
    flat_bracket_2d();
}