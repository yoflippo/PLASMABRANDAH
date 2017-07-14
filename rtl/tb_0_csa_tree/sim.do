vlib work
vlib grlib

vcom -quiet  -93  -work work   ../mlite_pack.vhd
vcom -quiet  -93  -work work   ../TxtUtil_pkg.vhd
vcom -quiet  -93  -work work   tb_multiplier_tree_radix16.vhd
vcom -quiet  -93  -work work   ../csa_adder.vhd
vcom -quiet  -93  -work work   ../multiplier_tree_radix16.vhd
vcom -quiet  -93  -work work   ../random.vhd
 
vsim -voptargs=+acc work.tb_multiplier_tree_radix16


add wave -position insertpoint -group TB sim:/tb_multiplier_tree_radix16/*
add wave -position insertpoint -group -expand Stimuli sim:/tb_multiplier_tree_radix16/prStimuli/*
add wave -position insertpoint -group UUT sim:/tb_multiplier_tree_radix16/UUT/*

configure wave -namecolwidth 326
configure wave -valuecolwidth 90
configure wave -justifyvalue left

config wave -signalnamewidth 2
radix hex
set NumericStdNoWarnings 1
set StdArithNoWarnings 1

run -all
stop
