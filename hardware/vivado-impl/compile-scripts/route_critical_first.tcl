#open_checkpoint $outputDir/post_place_physopt.dcp
open_checkpoint $outputDir/post_preroute.dcp
#open_checkpoint $outputDir/post_route.dcp
set time_1 [clock seconds]

set WHS [ get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -hold] ]

if { $WHS < 0.000 } {
    route_design -unroute
    # Get the nets in the top 10 critical paths, assign to $preRoutes 
    set preRoutes [get_nets -of [get_timing_paths -hold -max_paths 10]]
    # route $preRoutes first with the smallest possible delay 
    route_design -nets [get_nets $preRoutes] -auto_delay
    # preserve the routing for $preRoutes and continue with the rest of the design 
    route_design -directive AggressiveExplore -preserve -tns_cleanup
}

set time_2 [clock seconds]
puts "Elapsed time (Route step)= [expr [expr $time_2 - $time_1] / 3600] : [expr [expr [expr $time_2 - $time_1] / 60] % 60] : [expr [expr $time_2 - $time_1] % 60]"
report_timing_summary -file $outputDir/post_route_timing_summary.rpt
report_methodology -file $outputDir/post_route_methodology.rpt
report_qor_suggestions -file $outputDir/post_route_qor_suggestions.rpt
write_checkpoint -force $outputDir/post_route.dcp
