onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group TB /tb_multiplier_tree_radix16/SimFinished
add wave -noupdate -expand -group TB /tb_multiplier_tree_radix16/Clk
add wave -noupdate -expand -group TB /tb_multiplier_tree_radix16/Rst
add wave -noupdate -expand -group TB /tb_multiplier_tree_radix16/a
add wave -noupdate -expand -group TB /tb_multiplier_tree_radix16/a2
add wave -noupdate -expand -group TB /tb_multiplier_tree_radix16/a4
add wave -noupdate -expand -group TB /tb_multiplier_tree_radix16/a8
add wave -noupdate -expand -group TB /tb_multiplier_tree_radix16/oldsum
add wave -noupdate -expand -group TB /tb_multiplier_tree_radix16/oldcar
add wave -noupdate -expand -group TB /tb_multiplier_tree_radix16/out_sum
add wave -noupdate -expand -group TB /tb_multiplier_tree_radix16/out_car
add wave -noupdate -expand -group TB /tb_multiplier_tree_radix16/randomnumber
add wave -noupdate -expand -group Stimuli /tb_multiplier_tree_radix16/prStimuli/vSimResult
add wave -noupdate -expand -group Stimuli /tb_multiplier_tree_radix16/prStimuli/v_ia
add wave -noupdate -expand -group Stimuli /tb_multiplier_tree_radix16/prStimuli/v_i2a
add wave -noupdate -expand -group Stimuli /tb_multiplier_tree_radix16/prStimuli/v_i4a
add wave -noupdate -expand -group Stimuli /tb_multiplier_tree_radix16/prStimuli/v_i8a
add wave -noupdate -expand -group Stimuli /tb_multiplier_tree_radix16/prStimuli/v_ioldsum
add wave -noupdate -expand -group Stimuli /tb_multiplier_tree_radix16/prStimuli/v_ioldcar
add wave -noupdate -expand -group Stimuli /tb_multiplier_tree_radix16/prStimuli/v_outsum
add wave -noupdate -expand -group Stimuli /tb_multiplier_tree_radix16/prStimuli/v_outcar
add wave -noupdate -expand -group Stimuli /tb_multiplier_tree_radix16/prStimuli/vResult
add wave -noupdate -group UUT /tb_multiplier_tree_radix16/UUT/ia
add wave -noupdate -group UUT /tb_multiplier_tree_radix16/UUT/i2a
add wave -noupdate -group UUT /tb_multiplier_tree_radix16/UUT/i4a
add wave -noupdate -group UUT /tb_multiplier_tree_radix16/UUT/i8a
add wave -noupdate -group UUT /tb_multiplier_tree_radix16/UUT/ioldsum
add wave -noupdate -group UUT /tb_multiplier_tree_radix16/UUT/ioldcar
add wave -noupdate -group UUT /tb_multiplier_tree_radix16/UUT/osumm
add wave -noupdate -group UUT /tb_multiplier_tree_radix16/UUT/ocar
add wave -noupdate -group UUT /tb_multiplier_tree_radix16/UUT/a
add wave -noupdate -group UUT /tb_multiplier_tree_radix16/UUT/a2
add wave -noupdate -group UUT /tb_multiplier_tree_radix16/UUT/a4
add wave -noupdate -group UUT /tb_multiplier_tree_radix16/UUT/a8
add wave -noupdate -group UUT /tb_multiplier_tree_radix16/UUT/output_csa_sum_1
add wave -noupdate -group UUT /tb_multiplier_tree_radix16/UUT/output_csa_car_1
add wave -noupdate -group UUT /tb_multiplier_tree_radix16/UUT/output_csa_sum_2
add wave -noupdate -group UUT /tb_multiplier_tree_radix16/UUT/output_csa_car_2
add wave -noupdate -group UUT /tb_multiplier_tree_radix16/UUT/output_csa_sum_3
add wave -noupdate -group UUT /tb_multiplier_tree_radix16/UUT/output_csa_car_3
add wave -noupdate -group UUT /tb_multiplier_tree_radix16/UUT/sum1_to_csa3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2540 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 326
configure wave -valuecolwidth 90
configure wave -justifyvalue left
configure wave -signalnamewidth 2
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {2502 ns} {2578 ns}
