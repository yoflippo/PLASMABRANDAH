vlib work
vlib grlib

vcom -quiet  -93  -work work   mlite_pack.vhd
vcom -quiet  -93  -work work   mult.vhd
vcom -quiet  -93  -work work   TxtUtil_pkg.vhd
vcom -quiet  -93  -work work   tb_multiplier.vhd

vsim -voptargs=+acc work.multiplier_tb

add  wave -position insertpoint -group TB  sim:/multiplier_tb/*
add  wave -group UUT sim:/multiplier_tb/UUT/*

config wave -signalnamewidth 1

#Change radix to Hexadecimal#
radix hex
#Supress Numeric Std package and Arith package warnings.#
#For VHDL designs we get some warnings due to unknown values on some signals at startup#
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0#
#We may also get some Arithmetic packeage warnings because of unknown values on#
#some of the signals that are used in an Arithmetic operation.#
#In order to suppress these warnings, we use following two commands#
set NumericStdNoWarnings 1
set StdArithNoWarnings 1

run 10000 ns
stop
