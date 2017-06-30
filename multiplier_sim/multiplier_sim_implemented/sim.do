vlib work
vlib grlib

vcom -quiet  -93  -work work   mlite_pack.vhd
vcom -quiet  -93  -work work   csa_adder.vhd
vcom -quiet  -93  -work work   mult.vhd
vcom -quiet  -93  -work work   multiplier_tree_radix16_sim/multiplier_tree_radix16.vhd
vcom -quiet  -93  -work work   mult_csa_16.vhd
vcom -quiet  -93  -work work   TxtUtil_pkg.vhd
vcom -quiet  -93  -work work   tb_multiplier.vhd
vcom -quiet  -93  -work work   adder.vhd

vsim -voptargs=+acc work.multiplier_tb

--add  wave -position insertpoint -group TB  sim:/multiplier_tb/*
--add wave -position insertpoint -group TB -divider var sim:/multiplier_tb/prStimuli/*
--add  wave -group UUT sim:/multiplier_tb/UUT/*
--add wave -position insertpoint -group UUT -divider var sim:/multiplier_tb/UUT/mult_proc/*
--add wave -position insertpoint -group CUSTOM_MUL sim:/multiplier_tb/UUT/CUSTUM_MULT/*
--add wave -position insertpoint -group CUSTOM_MUL -divider var sim:/multiplier_tb/UUT/CUSTUM_MULT/pMulProcess/*
do wave.do



config wave -signalnamewidth 2
radix hex
set NumericStdNoWarnings 1
set StdArithNoWarnings 1

run 1000 ns
stop
