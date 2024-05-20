onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_ecc/data
add wave -noupdate /tb_ecc/code
add wave -noupdate /tb_ecc/cr_data
add wave -noupdate /tb_ecc/clk
add wave -noupdate /tb_ecc/rst_n
add wave -noupdate /tb_ecc/cnt
add wave -noupdate /tb_ecc/c
add wave -noupdate /tb_ecc/enable_d
add wave -noupdate /tb_ecc/enable_e
add wave -noupdate /glbl/GSR
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 307
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
WaveRestoreZoom {115110 ps} {141310 ps}
