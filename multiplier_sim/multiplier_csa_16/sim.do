vlib work
vlib grlib

vcom -quiet  -93  -work work   csa_adder.vhd
vcom -quiet  -93  -work work   carry_select_adder.vhd
vcom -quiet  -93  -work work   mlite_pack.vhd
vcom -quiet  -93  -work work   mult.vhd
vcom -quiet  -93  -work work   multiplier_tree_radix16_sim/multiplier_tree_radix16.vhd
vcom -quiet  -93  -work work   mult_csa_16.vhd
vcom -quiet  -93  -work work   tb_multiplier.vhd
vcom -quiet  -93  -work work   TxtUtil_pkg.vhd

vsim -voptargs=+acc work.multiplier_tb
do wave.do

config wave -signalnamewidth 2
radix hex
set NumericStdNoWarnings 1
set StdArithNoWarnings 1

run 2500 ns
stop
