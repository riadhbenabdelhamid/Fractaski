open_checkpoint $outputDir/post_opt.dcp
set place_directive ExtraPostPlacementOpt
set time_1 [clock seconds]
place_design -directive ${place_directive} -verbose
set time_2 [clock seconds]
puts "Elapsed time (Place step)= [expr [expr $time_2 - $time_1] / 3600] : [expr [expr [expr $time_2 - $time_1] / 60] % 60] : [expr [expr $time_2 - $time_1] % 60]"
report_methodology -file $outputDir/post_place_methodology.rpt
report_qor_suggestions -file $outputDir/post_place_qor_suggestions.rpt
write_checkpoint -force $outputDir/post_place.dcp
