onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group TB /multiplier_tb/SimFinished
add wave -noupdate -group TB /multiplier_tb/Clk
add wave -noupdate -group TB /multiplier_tb/Rst
add wave -noupdate -group TB /multiplier_tb/a
add wave -noupdate -group TB /multiplier_tb/b
add wave -noupdate -group TB /multiplier_tb/mult_func
add wave -noupdate -group TB /multiplier_tb/c_mult
add wave -noupdate -group TB /multiplier_tb/c_mult2
add wave -noupdate -group TB /multiplier_tb/pause_out
add wave -noupdate -group TB -divider var
add wave -noupdate -group TB /multiplier_tb/prStimuli/vSimResult
add wave -noupdate -group TB /multiplier_tb/prStimuli/v_ia
add wave -noupdate -group TB /multiplier_tb/prStimuli/v_ib
add wave -noupdate -group TB /multiplier_tb/prStimuli/v_cl
add wave -noupdate -group TB /multiplier_tb/prStimuli/v_ch
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/clk
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/reset_in
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/a
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/b
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/mult_func
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/c_mult
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/c_mult2
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/pause_out
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/mode_reg
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/negate_reg
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/sign_reg
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/sign2_reg
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/count_reg
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/aa_reg
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/bb_reg
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/aa_reg2
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/bb_reg2
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/upper_reg
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/lower_reg
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/a_neg
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/b_neg
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/sum
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/finished
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/resultL
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/resultH
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/resultLFin
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/resultHFin
add wave -noupdate -expand -group UUT -divider var
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/mult_proc/count
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/mult_proc/resultBig
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/mult_proc/sign_value
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/mult_proc/sign_a_bit
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/mult_proc/sign_b_bit
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/mult_proc/signed_mul
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1900 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 183
configure wave -valuecolwidth 139
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
WaveRestoreZoom {1689 ns} {2349 ns}
