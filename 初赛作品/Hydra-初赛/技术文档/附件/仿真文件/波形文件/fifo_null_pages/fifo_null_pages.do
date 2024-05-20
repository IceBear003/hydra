onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_fifo_null_pages/sys_clk
add wave -noupdate /tb_fifo_null_pages/rst_n
add wave -noupdate /tb_fifo_null_pages/pop_head
add wave -noupdate /tb_fifo_null_pages/head_addr
add wave -noupdate /tb_fifo_null_pages/push_tail
add wave -noupdate /tb_fifo_null_pages/tail_addr
add wave -noupdate /glbl/GSR
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {995318 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 251
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
WaveRestoreZoom {5269162 ps} {6180607 ps}
