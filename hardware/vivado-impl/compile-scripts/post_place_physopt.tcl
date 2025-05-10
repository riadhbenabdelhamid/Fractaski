# This script is a slightly modified version based on the one in the following web link : 
# https://hwjedi.wordpress.com/2017/02/09/vivado-non-project-mode-part-iii-phys-opt-looping/
set time_1 [clock seconds]
open_checkpoint $outputDir/post_place.dcp
set WNS [ get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup] ]

# Post Place PhysOpt Looping
#set NLOOPS 8
set NLOOPS 12
set WNS_SRCH_STR "WNS="
set TNS_SRCH_STR "TNS="

if {$WNS < 0.000} {
    # add over constraining
    #set_clock_uncertainty 0.100 [get_clocks CLKOUT0]
    set_clock_uncertainty 0.100 [get_clocks clkout0]
    #set_clock_uncertainty 0.200 [get_clocks clkout0]
    #set_clock_uncertainty 0.300 [get_clocks clkout0]
    set TNS [ exec grep $TNS_SRCH_STR vivado.log | tail -1 | sed -n -e "s/^.*$TNS_SRCH_STR//p" | cut -d\  -f 1]
    set TNS_ITER_PREV $TNS

    for {set i 0} {$i < $NLOOPS} {incr i} {
        phys_opt_design -slr_crossing_opt -retime
        set WNS [ exec grep $WNS_SRCH_STR vivado.log | tail -1 | sed -n -e "s/^.*$WNS_SRCH_STR//p" | cut -d\  -f 1]
        if {$WNS >= 0.000} {
            break
        }

        phys_opt_design -directive AggressiveExplore
        # get WNS / TNS by getting lines with the search string in it (grep),
        # get the last line only (tail -1),
        # extracting everything after the search string (sed), and
        # cutting just the first value out (cut). whew!
        set WNS [ exec grep $WNS_SRCH_STR vivado.log | tail -1 | sed -n -e "s/^.*$WNS_SRCH_STR//p" | cut -d\  -f 1]
        if {$WNS >= 0.000} {
            break
        }

        phys_opt_design -directive AggressiveFanoutOpt
        set WNS [ exec grep $WNS_SRCH_STR vivado.log | tail -1 | sed -n -e "s/^.*$WNS_SRCH_STR//p" | cut -d\  -f 1]
        if {$WNS >= 0.000} {
            break
        }

        phys_opt_design -directive AlternateReplication
        set WNS [ exec grep $WNS_SRCH_STR vivado.log | tail -1 | sed -n -e "s/^.*$WNS_SRCH_STR//p" | cut -d\  -f 1]
        if {$WNS >= 0.000} {
            break
        }

        set TNS [ exec grep $TNS_SRCH_STR vivado.log | tail -1 | sed -n -e "s/^.*$TNS_SRCH_STR//p" | cut -d\  -f 1]
        if {($TNS == $TNS_ITER_PREV) || $WNS >= 0.000} {
            break
        }
        set TNS_ITER_PREV $TNS
    }

    # remove over constraining
    set_clock_uncertainty 0 [get_clocks clkout0]
    #set_clock_uncertainty 0 [get_clocks CLKOUT0]

}
report_timing_summary -file $outputDir/post_place_physopt_tim.rpt
report_design_analysis -logic_level_distribution \
                         -of_timing_paths [get_timing_paths -max_paths 5000 \
                           -slack_lesser_than 0] \
                             -file $outputDir/post_place_physopt_design_analysis.rpt
report_methodology -file $outputDir/post_place_physopt_methodology.rpt
report_qor_suggestions -file $outputDir/post_place_physopt_suggestions.rpt
write_checkpoint -force $outputDir/post_place_physopt.dcp
set time_2 [clock seconds]
puts "Elapsed time (post_place_physopt step)= [expr [expr $time_2 - $time_1] / 3600] : [expr [expr [expr $time_2 - $time_1] / 60] % 60] : [expr [expr $time_2 - $time_1] % 60]"
