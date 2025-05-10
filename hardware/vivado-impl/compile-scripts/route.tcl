open_checkpoint $outputDir/post_place_physopt.dcp
set time_1 [clock seconds]
route_design -directive AggressiveExplore -tns_cleanup 
set time_2 [clock seconds]
puts "Elapsed time (Route step)= [expr [expr $time_2 - $time_1] / 3600] : [expr [expr [expr $time_2 - $time_1] / 60] % 60] : [expr [expr $time_2 - $time_1] % 60]"
report_methodology -file $outputDir/post_preroute_methodology.rpt
report_qor_suggestions -file $outputDir/post_preroute_qor_suggestions.rpt
report_timing_summary -file $outputDir/post_preroute_timing_summary.rpt
write_checkpoint -force $outputDir/post_preroute.dcp
#write_checkpoint -force $outputDir/post_route.dcp
