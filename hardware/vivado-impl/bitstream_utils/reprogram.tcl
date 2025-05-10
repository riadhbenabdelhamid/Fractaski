open_checkpoint ../../vivado-runs/post_route_physopt.dcp
set_param tcl.collectionResultDisplayLimit 1024

set outputDir ../$env(RUN_DIR)

#get a list of instance paths
set bram_instances [split [get_cells -hierarchical -filter { NAME=~ *instr_and_data_mem/RAM_reg }] " "]

#get a list of instance placements
set xy_locations [split [get_property LOC [get_cells -hierarchical -filter { PRIMITIVE_TYPE=~ *bram.RAMB36* }]] " "]

# Check that exactly 2048 arguments (1024 names + 1024 locations) are provided
#if {[llength $bram_instances] != 1024} {
#    puts "Usage: design contains a different amount of cores than 1024"
#    exit 1
#}

# Read the file containing 32-bit words (one per line)
#set fileName "../../../../software/runs/template-mandelbrot.inst"
set fileName $env(HEX_PROG_NAME).inst
set fp [open $fileName "r"]
set fileContent [read $fp]
close $fp

# Split file content into lines and remove any empty lines
set wordList {}
foreach line [split $fileContent "\n"] {
    set trimmed [string trim $line]
    if {$trimmed ne ""} {
        lappend wordList $trimmed
    }
}

# Normalize each word: Remove "0x" if present and ensure 8 hex digits
set formattedWords {}
foreach word $wordList {
    #set word [format "%08x" [expr {$word}]]  ;# Ensure 8-digit hex format
    lappend formattedWords $word
}

# Calculate the number of words per BRAM
set numBram 64
set wordsPerBram 1024

# Group words into 256-bit INIT_xx values (8 words per INIT_xx)
set numGroups [expr {$wordsPerBram / 8}]
set final_string {}
for {set group 0} {$group < $numGroups} {incr group} {
    set start [expr {$group * 8}]
    set groupWords {}
    # Organize words from left (highest index) to right (lowest index)
    # That is, for each group, the leftmost word is word[start+7] and rightmost is word[start]
    for {set i 7} {$i >= 0} {incr i -1} {
        lappend groupWords [lindex $formattedWords [expr {$start + $i}]]
    }
    # Concatenate the eight words into one long string
    set concatenated [join $groupWords ""]
    # Prepend "256'h" to the sequence
    lappend finalString "256'h$concatenated"
    #puts $finalString
}

puts $finalString

# For each BRAM, apply its corresponding section of the input data
for {set b 0} {$b < $numBram} {incr b} {
    set bram_name [lindex $bram_instances $b]
    set xy_location [lindex $xy_locations $b]

    # Apply the INIT_xx properties
    for {set i 0} {$i < 128} {incr i} {
        set initProp [format "INIT_%02X" $i]
        set initVal [lindex $finalString $i]
        #set_property $initProp $initVal $bram_cell
        set_property $initProp $initVal [get_cells $bram_name]
    }
}

# Write the modified design to a new checkpoint and bitstream
set time_1 [clock seconds]
write_checkpoint -force $outputDir/modified_program_post_route.dcp
set time_2 [clock seconds]
puts "Elapsed time (update post route dcp)= [expr [expr $time_2 - $time_1] / 3600] : [expr [expr [expr $time_2 - $time_1] / 60] % 60] : [expr [expr $time_2 - $time_1] % 60]"
set time_1 [clock seconds]
write_bitstream -force $outputDir/updated_design.bit
set time_2 [clock seconds]
puts "Elapsed time (Update Bitstream step)= [expr [expr $time_2 - $time_1] / 3600] : [expr [expr [expr $time_2 - $time_1] / 60] % 60] : [expr [expr $time_2 - $time_1] % 60]"

puts "Successfully updated all BRAMs!"

