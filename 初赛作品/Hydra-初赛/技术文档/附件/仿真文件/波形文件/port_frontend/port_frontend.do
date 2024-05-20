onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_port/clk
add wave -noupdate /tb_port/rst_n
add wave -noupdate /tb_port/wr_sop
add wave -noupdate /tb_port/wr_eop
add wave -noupdate /tb_port/wr_vld
add wave -noupdate /tb_port/wr_data
add wave -noupdate /tb_port/state
add wave -noupdate /tb_port/cnt
add wave -noupdate /tb_port/data_up
add wave -noupdate /tb_port/eop_t
add wave -noupdate /tb_port/eop_ti
add wave -noupdate /tb_port/dest_port
add wave -noupdate /tb_port/data
add wave -noupdate /tb_port/length
add wave -noupdate /tb_port/data_vld
add wave -noupdate /tb_port/new_packet_into_buf
add wave -noupdate /glbl/GSR
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {0 ps} {256 ns}
