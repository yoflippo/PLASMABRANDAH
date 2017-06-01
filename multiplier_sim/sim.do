


add wave -position insertpoint  \
sim:/multiplier_tb/Clk \
sim:/multiplier_tb/Rst \
sim:/multiplier_tb/a \
sim:/multiplier_tb/b \
sim:/multiplier_tb/mult_func \
sim:/multiplier_tb/c_mult \
sim:/multiplier_tb/pause_out

config wave -signalnamewidth 3

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

run 1000 ns
stop
