onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group TB /multiplier_tb/SimFinished
add wave -noupdate -expand -group TB /multiplier_tb/Clk
add wave -noupdate -expand -group TB /multiplier_tb/Rst
add wave -noupdate -expand -group TB /multiplier_tb/multiplier
add wave -noupdate -expand -group TB /multiplier_tb/multiplicand
add wave -noupdate -expand -group TB /multiplier_tb/resultH
add wave -noupdate -expand -group TB /multiplier_tb/resultL
add wave -noupdate -expand -group TB /multiplier_tb/finished
add wave -noupdate -expand -group TB -divider VAR
add wave -noupdate -expand -group TB /multiplier_tb/prStimuli/vSimResult
add wave -noupdate -expand -group TB /multiplier_tb/prStimuli/ia
add wave -noupdate -expand -group TB /multiplier_tb/prStimuli/ib
add wave -noupdate -expand -group TB /multiplier_tb/prStimuli/vresult
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/iclk
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/ireset
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/iMultiplier
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/iMultiplicand
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/oFinished
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/oResultL
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/oResultH
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/counter
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/do_add
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/a
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/a2
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/a4
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/a8
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/oldsum
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/oldcar
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/sum
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/car
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/part_vResult
add wave -noupdate -expand -group UUT -divider VAR
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/pMulProcess/vCounter
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/pMulProcess/vcar_out_bv
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/pMulProcess/vBv_adder_out
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/pMulProcess/vResult
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/pMulProcess/vStarted
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/pMulProcess/vAlmostFinished
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/pMulProcess/vFinished
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/pMulProcess/resultH
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/pMulProcess/vTmpResultH
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/pMulProcess/vMulPliOld
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/pMulProcess/vMulCanOld
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {598 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 249
configure wave -valuecolwidth 160
configure wave -justifyvalue left
configure wave -signalnamewidth 2
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
WaveRestoreZoom {470 ns} {770 ns}
