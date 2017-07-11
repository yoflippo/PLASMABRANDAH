vlib work
vlib grlib

vcom -quiet  -93  -work grlib  ../simlib/grlib/stdlib/version.vhd
vcom -quiet  -93  -work grlib  ../simlib/grlib/stdlib/stdlib.vhd
vcom -quiet  -93  -work grlib  ../simlib/grlib/stdlib/stdio.vhd
vcom -quiet  -93  -work work   ../simlib/micron/ddr_sdram/mti_pkg.vhd
vcom -quiet  -93  -work work   ../simlib/micron/ddr_sdram/mt46v16m16.vhd
vcom -quiet  -93  -work work   ../rtl/mlite_pack.vhd
vcom -quiet  -93  -work work   ../rtl/cache_ram.vhd
vcom -quiet  -93  -work work   ../rtl/cache_ram_bb.vhd
vcom -quiet  -93  -work work   ../rtl/cache_bb.vhd
vcom -quiet  -93  -work work   ../rtl/cache.vhd
vcom -quiet  -93  -work work   ../rtl/clk_gen.vhd
vcom -quiet  -93  -work work   sim_tb_cache.vhd


vsim -t ps -novopt -L unisim work.sim_tb_cache

onerror {resume}
#Log all the objects in design. These will appear in .wlf file#
log -r /*
#View sim_tb_top signals in waveform#

add wave -position insertpoint  \
sim:/sim_tb_cache/status
add wave -r -group Cache_BB1_all sim:/sim_tb_cache/cache_BB1/*
add wave -position insertpoint  \
sim:/sim_tb_cache/status
add wave -r -group cache_set_ass_all sim:/sim_tb_cache/cache_set_ass/*
add wave -group Cache_BB1 sim:/sim_tb_cache/cache_BB1/*
add wave -group cache_set_ass sim:/sim_tb_cache/cache_set_ass/*
add wave -position insertpoint  \
sim:/sim_tb_cache/cache_set_ass/cache_data/block_r_do(1) \
sim:/sim_tb_cache/cache_set_ass/cache_data/block_r_do(0)
add wave -position insertpoint  \
sim:/sim_tb_cache/cache_set_ass/cache_data/block_w_do(1) \
sim:/sim_tb_cache/cache_set_ass/cache_data/block_w_do(0)
add wave -position insertpoint  \
sim:/sim_tb_cache/cache_set_ass/cache_data/flag
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
run 1us
stop