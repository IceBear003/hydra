onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_sram_state/clk
add wave -noupdate /tb_sram_state/rst_n
add wave -noupdate /tb_sram_state/ecc_wr_en
add wave -noupdate /tb_sram_state/ecc_wr_addr
add wave -noupdate /tb_sram_state/ecc_din
add wave -noupdate /tb_sram_state/ecc_rd_en
add wave -noupdate /tb_sram_state/ecc_rd_addr
add wave -noupdate /tb_sram_state/ecc_dout
add wave -noupdate /tb_sram_state/jt_wr_en
add wave -noupdate /tb_sram_state/jt_wr_addr
add wave -noupdate /tb_sram_state/jt_din
add wave -noupdate /tb_sram_state/jt_rd_en
add wave -noupdate /tb_sram_state/jt_rd_addr
add wave -noupdate /tb_sram_state/jt_dout
add wave -noupdate /tb_sram_state/wr_or
add wave -noupdate /tb_sram_state/wr_op
add wave -noupdate /tb_sram_state/delta_free_space
add wave -noupdate /tb_sram_state/delta_page_amount
add wave -noupdate /tb_sram_state/wr_port
add wave -noupdate /tb_sram_state/rd_op
add wave -noupdate /tb_sram_state/rd_port
add wave -noupdate /tb_sram_state/rd_addr
add wave -noupdate /tb_sram_state/request_port
add wave -noupdate /tb_sram_state/page_amount
add wave -noupdate /tb_sram_state/null_ptr
add wave -noupdate /tb_sram_state/free_space
add wave -noupdate /glbl/GSR
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {44 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
configure wave -timelineunits ps
update
WaveRestoreZoom {50042 ps} {1049998 ps}
