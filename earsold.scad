// Approximation of Firebox II rackmount bracket with rack holes

module bracket() {
    thickness = 3; // Metal thickness in mm
    height = 70;
    width = 50; // Width of the central bracket portion

    rack_hole_dia = 4;
    Total_rack_width = 482.60;
    Internal_rack_space = 450.85;
    Rack_hole_space = 465.12;
    rack_spacing = 465.1; // Horizontal spacing for 19-inch rack
    rack_hole_y1 = 20; // Distance from top
    rack_hole_y2 = height - 20; // Distance from bottom
    device_width = 394; //device width in mm
    flange_depth = (Total_rack_width - device_width)/2; //depth of flange
    // Slot size parameters
    slot_dia = 6.35; // 1/4 inch diameter
    slot_len = 9;    // total length of slot
    slot_offset_from_edge = 3;
    
    // Compute slot center Z
    slot_center_z = flange_depth - (3+ slot_len); //flange_depth - slot_offset_from_edge - slot_dia/2;

    // Base plate with mounting holes
    difference() {
        cube([width, height, thickness]);

        // Internal mounting holes (for device, 37.5mm apart)
        translate([20, (70-37.5)/2, 0])
            cylinder(h=thickness+1, d=4, $fn=30);
        translate([20 , (70-37.5)/2 + 37.5, 0])
            cylinder(h=thickness+1, d=4, $fn=30);

        
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

bracket();
