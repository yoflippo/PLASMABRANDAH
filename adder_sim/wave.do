onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group UUT /adder_tb/UUT/a
add wave -noupdate -group UUT /adder_tb/UUT/b
add wave -noupdate -group UUT /adder_tb/UUT/do_add
add wave -noupdate -group UUT /adder_tb/UUT/c
add wave -noupdate -group UUT /adder_tb/UUT/byte1_a
add wave -noupdate -group UUT /adder_tb/UUT/byte2_a
add wave -noupdate -group UUT /adder_tb/UUT/byte3_a
add wave -noupdate -group UUT /adder_tb/UUT/byte4_a
add wave -noupdate -group UUT /adder_tb/UUT/byte1_b
add wave -noupdate -group UUT /adder_tb/UUT/byte2_b
add wave -noupdate -group UUT /adder_tb/UUT/byte3_b
add wave -noupdate -group UUT /adder_tb/UUT/byte4_b
add wave -noupdate -group UUT /adder_tb/UUT/adder1
add wave -noupdate -group UUT /adder_tb/UUT/adder2_0
add wave -noupdate -group UUT /adder_tb/UUT/adder2_1
add wave -noupdate -group UUT /adder_tb/UUT/adder3_0
add wave -noupdate -group UUT /adder_tb/UUT/adder3_1
add wave -noupdate -group UUT /adder_tb/UUT/adder4_0
add wave -noupdate -group UUT /adder_tb/UUT/adder4_1
add wave -noupdate -group UUT /adder_tb/UUT/carry_0
add wave -noupdate -group UUT /adder_tb/UUT/carry_1
add wave -noupdate -group UUT /adder_tb/UUT/carry_2
add wave -noupdate -group UUT /adder_tb/UUT/partresult1
add wave -noupdate -group UUT /adder_tb/UUT/partresult2
add wave -noupdate -group UUT /adder_tb/UUT/result
add wave -noupdate -expand -group TB /adder_tb/SimFinished
add wave -noupdate -expand -group TB /adder_tb/Clk
add wave -noupdate -expand -group TB /adder_tb/Rst
add wave -noupdate -expand -group TB /adder_tb/a
add wave -noupdate -expand -group TB /adder_tb/b
add wave -noupdate -expand -group TB /adder_tb/c
add wave -noupdate -expand -group TB /adder_tb/do_add
add wave -noupdate -expand -group TB /adder_tb/result_bv_adder
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {129 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 178
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ns} {1312 ns}
