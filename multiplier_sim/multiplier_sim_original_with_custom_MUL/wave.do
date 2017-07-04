onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group TB /multiplier_tb/SimFinished
add wave -noupdate -expand -group TB /multiplier_tb/Clk
add wave -noupdate -expand -group TB /multiplier_tb/Rst
add wave -noupdate -expand -group TB /multiplier_tb/a
add wave -noupdate -expand -group TB /multiplier_tb/b
add wave -noupdate -expand -group TB /multiplier_tb/mult_func
add wave -noupdate -expand -group TB /multiplier_tb/c_mult
add wave -noupdate -expand -group TB /multiplier_tb/c_mult2
add wave -noupdate -expand -group TB /multiplier_tb/pause_out
add wave -noupdate -expand -group TB -divider var
add wave -noupdate -expand -group TB /multiplier_tb/prStimuli/vSimResult
add wave -noupdate -expand -group TB /multiplier_tb/prStimuli/v_ia
add wave -noupdate -expand -group TB /multiplier_tb/prStimuli/v_ib
add wave -noupdate -expand -group TB /multiplier_tb/prStimuli/v_cl
add wave -noupdate -expand -group TB /multiplier_tb/prStimuli/v_ch
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
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/custom_mul_finished
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/resultL
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/resultH
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/resultLFin
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/resultHFin
add wave -noupdate -expand -group UUT -divider var
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/mult_proc/vCount
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/mult_proc/vResultBig
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/mult_proc/vSign_value
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/mult_proc/vSign_a_bit
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/mult_proc/vSign_b_bit
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/mult_proc/vSigned_mul
add wave -noupdate -expand -group UUT /multiplier_tb/UUT/mult_proc/vTemp
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/iclk
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/ireset
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/iMultiplier
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/iMultiplicand
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/oFinished
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/oResultL
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/oResultH
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/counter
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/do_add
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/a
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/a2
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/a4
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/a8
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/oldsum
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/oldcar
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/sum
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/car
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/part_vResult
add wave -noupdate -expand -group CUSTOM_MUL -divider var
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/pMulProcess/vCounter
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/pMulProcess/vcar_out_bv
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/pMulProcess/vBv_adder_out
add wave -noupdate -expand -group CUSTOM_MUL -expand /multiplier_tb/UUT/CUSTUM_MULT/pMulProcess/vResult
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/pMulProcess/vStarted
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/pMulProcess/vFinished
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/pMulProcess/vResultH
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/pMulProcess/vCarH
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/pMulProcess/vSumH
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/pMulProcess/vMulPliOld
add wave -noupdate -expand -group CUSTOM_MUL /multiplier_tb/UUT/CUSTUM_MULT/pMulProcess/vMulCanOld
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10280 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 256
configure wave -valuecolwidth 100
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
WaveRestoreZoom {9762 ns} {10398 ns}
