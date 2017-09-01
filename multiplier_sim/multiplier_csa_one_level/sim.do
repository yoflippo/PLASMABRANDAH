vlib work
vlib grlib

vcom -quiet  -93  -work work   mlite_pack.vhd
vcom -quiet  -93  -work work   multiplier_csa_level.vhd
vcom -quiet  -93  -work work   TxtUtil_pkg.vhd
vcom -quiet  -93  -work work   multiplier_csa_level_tb.vhd
vcom -quiet  -93  -work work   adder_carry_save.vhd
 
vsim -voptargs=+acc work.multiplier_csa_level_tb

--add  wave -position insertpoint -group TB  sim:/multiplier_tb/*
--add  wave -group UUT sim:/multiplier_tb/UUT/*
--do wave.do

config wave -signalnamewidth 2
radix hex
set NumericStdNoWarnings 1
set StdArithNoWarnings 1

run 1500 ns
stop
