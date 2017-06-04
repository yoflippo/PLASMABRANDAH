vlib work
vlib grlib

vcom -quiet  -93  -work work   adder.vhd
vcom -quiet  -93  -work work   mlite_pack.vhd
vcom -quiet  -93  -work work   tb_adder.vhd
vcom -quiet  -93  -work work   TxtUtil_pkg.vhd

vsim -voptargs=+acc work.adder_tb

--add wave -group UUT -position insertpoint sim:/adder_tb/UUT/*
--add wave -group TB -position insertpoint sim:/adder_tb/*

config wave -signalnamewidth 1
radix hex


#For VHDL designs we get some warnings due to unknown values on some signals at startup#
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0#
#We may also get some Arithmetic packeage warnings because of unknown values on#
#some of the signals that are used in an Arithmetic operation.#
#In order to suppress these warnings, we use following two commands#
set NumericStdNoWarnings 1  
set StdArithNoWarnings 1

do wave.do

run 1200 ns
stop
