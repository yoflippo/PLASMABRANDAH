
# PlanAhead Launch Script for Post PAR Floorplanning, created by Project Navigator

create_project -name pdp_ISE -dir "/home/pdp/New_Repository/PLASMABRANDAH/pdp_ISE/planAhead_run_2" -part xc4vfx60ff1152-11
set srcset [get_property srcset [current_run -impl]]
set_property design_mode GateLvl $srcset
set_property edif_top_file "/home/pdp/New_Repository/PLASMABRANDAH/pdp_ISE/top_ml410.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/pdp/New_Repository/PLASMABRANDAH/pdp_ISE} }
set_property target_constrs_file "ml410.ucf" [current_fileset -constrset]
add_files [list {ml410.ucf}] -fileset [get_property constrset [current_run]]
link_design
read_xdl -file "/home/pdp/New_Repository/PLASMABRANDAH/pdp_ISE/top_ml410.xdl"
if {[catch {read_twx -name results_1 -file "/home/pdp/New_Repository/PLASMABRANDAH/pdp_ISE/top_ml410.twx"} eInfo]} {
   puts "WARNING: there was a problem importing \"/home/pdp/New_Repository/PLASMABRANDAH/pdp_ISE/top_ml410.twx\": $eInfo"
}
