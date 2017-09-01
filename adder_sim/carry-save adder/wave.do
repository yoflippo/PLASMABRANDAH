onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /adder_tb/SimFinished
add wave -noupdate /adder_tb/Clk
add wave -noupdate /adder_tb/a
add wave -noupdate /adder_tb/b
add wave -noupdate /adder_tb/c
add wave -noupdate /adder_tb/sum
add wave -noupdate /adder_tb/carry
add wave -noupdate -divider UUT
add wave -noupdate /adder_tb/UUT/ia
add wave -noupdate /adder_tb/UUT/ib
add wave -noupdate /adder_tb/UUT/ic
add wave -noupdate /adder_tb/UUT/osum
add wave -noupdate /adder_tb/UUT/ocarry
add wave -noupdate /adder_tb/UUT/sum
add wave -noupdate /adder_tb/UUT/car
add wave -noupdate -divider SHORT
add wave -noupdate /adder_tb/UUT_S/ia
add wave -noupdate /adder_tb/UUT_S/ib
add wave -noupdate /adder_tb/UUT_S/ic
add wave -noupdate /adder_tb/UUT_S/osum
add wave -noupdate /adder_tb/UUT_S/ocarry
add wave -noupdate /adder_tb/UUT_S/sum
add wave -noupdate /adder_tb/UUT_S/car
add wave -noupdate /adder_tb/carryAndSum
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {126 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 203
configure wave -valuecolwidth 199
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {90 ns} {250 ns}
