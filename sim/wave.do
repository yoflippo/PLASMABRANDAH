onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/SYS_CLK
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/SYS_RESET
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/RS232_DCE_RXD
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/RS232_DCE_TXD
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/SD_CK_P
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/SD_CK_N
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/SD_CKE
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/SD_BA
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/SD_A
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/SD_CS
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/SD_RAS
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/SD_CAS
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/SD_WE
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/SD_DQ
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/SD_UDM
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/SD_UDQS
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/SD_LDM
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/SD_LDQS
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/LED
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/address
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/data_write
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/data_read
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/byte_we
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/pause
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/no_ddr_start
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/no_ddr_stop
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/gpio0_out
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/gpio0_in
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/dcm_lock
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/clk_2x
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/clk
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/init_done
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/sys_clk_in
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/reset_in
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/reset
add wave -noupdate -group plasma_top /sim_tb_top/u1_plasma_top/reset_cpu
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/clk
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/clk_2x
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/reset_in
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/address
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/byte_we
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/data_w
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/data_r
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/no_start
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/no_stop
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/pause
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/init_done
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/SD_CK_P
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/SD_CK_N
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/SD_CKE
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/SD_BA
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/SD_A
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/SD_CS
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/SD_RAS
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/SD_CAS
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/SD_WE
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/SD_DQ
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/SD_UDM
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/SD_UDQS
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/SD_LDM
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/SD_LDQS
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/initiating
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/address_init
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/byte_we_init
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/address_ddr
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/byte_we_ddr
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/SD_CKE_ddr
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/active_ddr
add wave -noupdate -group ddr /sim_tb_top/u1_plasma_top/u2_ddr/pause_ddr
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/clk
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/reset
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/address_next
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/byte_we_next
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cpu_address
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/mem_busy
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_ram_enable
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_ram_byte_we
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_ram_address
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_ram_data_w
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_ram_data_r
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_access
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_checking
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_miss
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/state_reg
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/state
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/state_next
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_address
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_tag_in
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_tag_reg
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_tag_out
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_we
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_data/block0/ram_byte3/DO
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_data/block0/ram_byte3/DOP
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_data/block0/ram_byte3/ADDR
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_data/block0/ram_byte3/CLK
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_data/block0/ram_byte3/DI
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_data/block0/ram_byte3/DIP
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_data/block0/ram_byte3/EN
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_data/block0/ram_byte3/SSR
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_data/block0/ram_byte3/WE
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_tag/DO
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_tag/DOP
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_tag/ADDR
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_tag/CLK
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_tag/DI
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_tag/DIP
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_tag/EN
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_tag/SSR
add wave -noupdate -group cache /sim_tb_top/u1_plasma_top/u1_plasma/opt_cache2/u_cache/cache_tag/WE
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/clk
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/reset_in
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/a
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/b
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/mult_func
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/c_mult
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/pause_out
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/mode_reg
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/negate_reg
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/sign_reg
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/sign2_reg
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/count_reg
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/aa_reg
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/bb_reg
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/mul_plier_cus
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/mul_cand_cus
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/upper_reg
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/lower_reg
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/a_neg
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/b_neg
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/sum
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/custom_mul_finished
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/resultL
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/resultH
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/resultLFin
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/resultHFin
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/baseline
add wave -noupdate -expand -group multiplier -divider variables
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/mult_proc/vResultBig
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/mult_proc/vSign_value
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/mult_proc/vSign_a_bit
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/mult_proc/vSign_b_bit
add wave -noupdate -expand -group multiplier /sim_tb_top/u1_plasma_top/u1_plasma/u1_cpu/u8_mult/mult_proc/vSigned_mul
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 262
configure wave -valuecolwidth 105
configure wave -justifyvalue left
configure wave -signalnamewidth 3
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {7823 ps}
