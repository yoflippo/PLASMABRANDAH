vlib work
vlib grlib

vcom -quiet  -93  -work work   ../mlite_pack.vhd
vcom -quiet  -93  -work work   ../TxtUtil_pkg.vhd

vcom -quiet  -93  -work work   ../csa_adder.vhd
vcom -quiet  -93  -work work   ../mult.vhd
vcom -quiet  -93  -work work   ../multiplier_tree_radix16.vhd
vcom -quiet  -93  -work work   ../mult_csa.vhd
vcom -quiet  -93  -work work   tb_multiplier.vhd
vcom -quiet  -93  -work work   ../random.vhd

vsim -voptargs=+acc work.multiplier_tb

add wave -expand -position insertpoint -group TB sim:/multiplier_tb/*
add wave -expand -position insertpoint -group TB -divider VAR sim:/multiplier_tb/prStimuli/*
add wave -expand -position insertpoint -group UUT  sim:/multiplier_tb/UUT/*
add wave -expand -position insertpoint -group UUT  -divider VAR sim:/multiplier_tb/UUT/pMulProcess/*
configure wave -namecolwidth 230
configure wave -valuecolwidth 89

config wave -signalnamewidth 2
radix hex
set NumericStdNoWarnings 1
set StdArithNoWarnings 1

run -all
stop
