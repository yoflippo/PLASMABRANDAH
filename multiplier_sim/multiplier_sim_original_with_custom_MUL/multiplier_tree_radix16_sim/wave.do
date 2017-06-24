onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_multiplier_tree_radix16/SimFinished
add wave -noupdate /tb_multiplier_tree_radix16/Clk
add wave -noupdate /tb_multiplier_tree_radix16/Rst
add wave -noupdate /tb_multiplier_tree_radix16/a
add wave -noupdate /tb_multiplier_tree_radix16/a2
add wave -noupdate /tb_multiplier_tree_radix16/a4
add wave -noupdate /tb_multiplier_tree_radix16/a8
add wave -noupdate /tb_multiplier_tree_radix16/oldsum
add wave -noupdate /tb_multiplier_tree_radix16/oldcar
add wave -noupdate /tb_multiplier_tree_radix16/out_sum
add wave -noupdate /tb_multiplier_tree_radix16/out_car
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb_multiplier_tree_radix16/UUT/ia
add wave -noupdate /tb_multiplier_tree_radix16/UUT/i2a
add wave -noupdate /tb_multiplier_tree_radix16/UUT/i4a
add wave -noupdate /tb_multiplier_tree_radix16/UUT/i8a
add wave -noupdate /tb_multiplier_tree_radix16/UUT/ioldsum
add wave -noupdate /tb_multiplier_tree_radix16/UUT/ioldcar
add wave -noupdate /tb_multiplier_tree_radix16/UUT/osum
add wave -noupdate /tb_multiplier_tree_radix16/UUT/ocar
add wave -noupdate /tb_multiplier_tree_radix16/UUT/a
add wave -noupdate /tb_multiplier_tree_radix16/UUT/a2
add wave -noupdate /tb_multiplier_tree_radix16/UUT/a4
add wave -noupdate /tb_multiplier_tree_radix16/UUT/a8
add wave -noupdate /tb_multiplier_tree_radix16/UUT/output_csa_sum_1
add wave -noupdate /tb_multiplier_tree_radix16/UUT/output_csa_car_1
add wave -noupdate /tb_multiplier_tree_radix16/UUT/output_csa_sum_2
add wave -noupdate /tb_multiplier_tree_radix16/UUT/output_csa_car_2
add wave -noupdate /tb_multiplier_tree_radix16/UUT/output_csa_sum_3
add wave -noupdate /tb_multiplier_tree_radix16/UUT/output_csa_car_3
add wave -noupdate /tb_multiplier_tree_radix16/UUT/sum1_to_csa3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {126 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 312
configure wave -valuecolwidth 111
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
WaveRestoreZoom {0 ns} {590 ns}
