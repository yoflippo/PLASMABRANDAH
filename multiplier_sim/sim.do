vlib work
vlib grlib

vcom -quiet  -93  -work work   mlite_pack.vhd
vcom -quiet  -93  -work work   mult.vhd
vcom -quiet  -93  -work work   TxtUtil_pkg.vhd
vcom -quiet  -93  -work work   tb_multiplier.vhd
vcom -quiet  -93  -work work   adder.vhd

vsim -voptargs=+acc work.multiplier_tb

--add  wave -position insertpoint -group TB  sim:/multiplier_tb/*
--add  wave -group UUT sim:/multiplier_tb/UUT/*
do wave.do

config wave -signalnamewidth 2
radix hex
set NumericStdNoWarnings 1
set StdArithNoWarnings 1

run 1500 ns
stop
