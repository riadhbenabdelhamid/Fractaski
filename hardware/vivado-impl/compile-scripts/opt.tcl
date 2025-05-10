open_checkpoint $outputDir/post_synth.dcp
set time_1 [clock seconds]
opt_design -directive ExploreWithRemap
report_methodology -file $outputDir/post_opt_methodology.rpt
report_qor_assessment -file $outputDir/post_opt_qor_assessment.rpt
report_qor_suggestions -file $outputDir/post_opt_qor_suggestions.rpt
set time_2 [clock seconds]
puts "Elapsed time (Opt step)= [expr [expr $time_2 - $time_1] / 3600] : [expr [expr [expr $time_2 - $time_1] / 60] % 60] : [expr [expr $time_2 - $time_1] % 60]"
write_checkpoint -force $outputDir/post_opt
