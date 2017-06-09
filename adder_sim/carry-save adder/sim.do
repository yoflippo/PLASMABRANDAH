vlib work
vlib grlib

vcom -quiet  -93  -work work   csa_adder.vhd
vcom -quiet  -93  -work work   mlite_pack.vhd
vcom -quiet  -93  -work work   tb_adder.vhd
vcom -quiet  -93  -work work   TxtUtil_pkg.vhd

vsim -voptargs=+acc work.adder_tb

--add wave -group UUT -position insertpoint sim:/adder_tb/UUT/*
--add wave -group TB -position insertpoint sim:/adder_tb/*

config wave -signalnamewidth 1
radix hex

set NumericStdNoWarnings 1  
set StdArithNoWarnings 1

do wave.do

run 1200 ns
stop
