onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_controller/clk
add wave -noupdate /tb_controller/rst_n
add wave -noupdate /tb_controller/wr_sop
add wave -noupdate /tb_controller/wr_eop
add wave -noupdate /tb_controller/wr_vld
add wave -noupdate /tb_controller/wr_data
add wave -noupdate /tb_controller/ready
add wave -noupdate /tb_controller/state
add wave -noupdate /tb_controller/cnt
add wave -noupdate /tb_controller/k
add wave -noupdate /tb_controller/data_up
add wave -noupdate /tb_controller/i
add wave -noupdate /tb_controller/j
add wave -noupdate /tb_controller/eop_t
add wave -noupdate /tb_controller/eop_ti
add wave -noupdate /tb_controller/wrr_en
add wave -noupdate /tb_controller/rd_sop
add wave -noupdate /tb_controller/rd_eop
add wave -noupdate /tb_controller/rd_vld
add wave -noupdate /tb_controller/rd_data
add wave -noupdate /glbl/GSR
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1161354 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 778
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
WaveRestoreZoom {1032233 ps} {1240261 ps}
