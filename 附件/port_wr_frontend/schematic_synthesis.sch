# File saved with Nlview 6.8.11  2018-08-07 bk=1.4403 VDI=40 GEI=35 GUI=JA:9.0 non-TLS-threadsafe
# 
# non-default properties - (restore without -noprops)
property attrcolor #000000
property attrfontsize 8
property autobundle 1
property backgroundcolor #ffffff
property boxcolor0 #000000
property boxcolor1 #000000
property boxcolor2 #000000
property boxinstcolor #000000
property boxpincolor #000000
property buscolor #008000
property closeenough 5
property createnetattrdsp 2048
property decorate 1
property elidetext 40
property fillcolor1 #ffffcc
property fillcolor2 #dfebf8
property fillcolor3 #f0f0f0
property gatecellname 2
property instattrmax 30
property instdrag 15
property instorder 1
property marksize 12
property maxfontsize 15
property maxzoom 6.25
property netcolor #19b400
property objecthighlight0 #ff00ff
property objecthighlight1 #ffff00
property objecthighlight2 #00ff00
property objecthighlight3 #ff6666
property objecthighlight4 #0000ff
property objecthighlight5 #ffc800
property objecthighlight7 #00ffff
property objecthighlight8 #ff00ff
property objecthighlight9 #ccccff
property objecthighlight10 #0ead00
property objecthighlight11 #cefc00
property objecthighlight12 #9e2dbe
property objecthighlight13 #ba6a29
property objecthighlight14 #fc0188
property objecthighlight15 #02f990
property objecthighlight16 #f1b0fb
property objecthighlight17 #fec004
property objecthighlight18 #149bff
property objecthighlight19 #eb591b
property overlapcolor #19b400
property pbuscolor #000000
property pbusnamecolor #000000
property pinattrmax 20
property pinorder 2
property pinpermute 0
property portcolor #000000
property portnamecolor #000000
property ripindexfontsize 8
property rippercolor #000000
property rubberbandcolor #000000
property rubberbandfontsize 15
property selectattr 0
property selectionappearance 2
property selectioncolor #0000ff
property sheetheight 44
property sheetwidth 68
property showmarks 1
property shownetname 0
property showpagenumbers 1
property showripindex 4
property timelimit 1
#
module new port_wr_frontend work:port_wr_frontend:NOFILE -nosplit
load symbol RAMB18E1 hdi_primitives BOX pin CLKARDCLK input.left pin CLKBWRCLK input.left pin ENARDEN input.left pin ENBWREN input.left pin REGCEAREGCE input.left pin REGCEB input.left pin RSTRAMARSTRAM input.left pin RSTRAMB input.left pin RSTREGARSTREG input.left pin RSTREGB input.left pinBus DOADO output.right [15:0] pinBus DOBDO output.right [15:0] pinBus DOPADOP output.right [1:0] pinBus DOPBDOP output.right [1:0] pinBus ADDRARDADDR input.left [13:0] pinBus ADDRBWRADDR input.left [13:0] pinBus DIADI input.left [15:0] pinBus DIBDI input.left [15:0] pinBus DIPADIP input.left [1:0] pinBus DIPBDIP input.left [1:0] pinBus WEA input.left [1:0] pinBus WEBWE input.left [3:0] fillcolor 1
load symbol LUT2 hdi_primitives BOX pin O output.right pin I0 input.left pin I1 input.left fillcolor 1
load symbol BUFG hdi_primitives BUF pin O output pin I input fillcolor 1
load symbol IBUF hdi_primitives BUF pin O output pin I input fillcolor 1
load symbol LUT4 hdi_primitives BOX pin O output.right pin I0 input.left pin I1 input.left pin I2 input.left pin I3 input.left fillcolor 1
load symbol OBUF hdi_primitives BUF pin O output pin I input fillcolor 1
load symbol FDRE hdi_primitives GEN pin Q output.right pin C input.clk.left pin CE input.left pin D input.left pin R input.left fillcolor 1
load symbol FDSE hdi_primitives GEN pin Q output.right pin C input.clk.left pin CE input.left pin D input.left pin S input.left fillcolor 1
load symbol LUT6 hdi_primitives BOX pin O output.right pin I0 input.left pin I1 input.left pin I2 input.left pin I3 input.left pin I4 input.left pin I5 input.left fillcolor 1
load symbol LUT5 hdi_primitives BOX pin O output.right pin I0 input.left pin I1 input.left pin I2 input.left pin I3 input.left pin I4 input.left fillcolor 1
load symbol LUT3 hdi_primitives BOX pin O output.right pin I0 input.left pin I1 input.left pin I2 input.left fillcolor 1
load symbol LUT1 hdi_primitives BOX pin O output.right pin I0 input.left fillcolor 1
load symbol FDCE hdi_primitives GEN pin Q output.right pin C input.clk.left pin CE input.left pin CLR input.left pin D input.left fillcolor 1
load symbol CARRY4 hdi_primitives BOX pin CI input.left pin CYINIT input.left pinBus CO output.right [3:0] pinBus O output.right [3:0] pinBus DI input.left [3:0] pinBus S input.left [3:0] fillcolor 1
load port wr_sop input -pg 1 -y 3340
load port xfer_data_vld output -pg 1 -y 4070
load port clk input -pg 1 -y 2800
load port wr_eop input -pg 1 -y 3360
load port rst_n input -pg 1 -y 3100
load port match_suc input -pg 1 -y 2570
load port pause output -pg 1 -y 1480
load port wr_vld input -pg 1 -y 2870
load portBus xfer_data output [15:0] -attr @name xfer_data[15:0] -pg 1 -y 3090
load portBus new_length output [8:0] -attr @name new_length[8:0] -pg 1 -y 1920
load portBus new_prior output [2:0] -attr @name new_prior[2:0] -pg 1 -y 860
load portBus new_dest_port output [3:0] -attr @name new_dest_port[3:0] -pg 1 -y 150
load portBus cur_dest_port output [3:0] -attr @name cur_dest_port[3:0] -pg 1 -y 80
load portBus cur_prior output [2:0] -attr @name cur_prior[2:0] -pg 1 -y 880
load portBus wr_data input [15:0] -attr @name wr_data[15:0] -pg 1 -y 1230
load portBus cur_length output [8:0] -attr @name cur_length[8:0] -pg 1 -y 1940
load inst cur_prior_OBUF[0]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 790
load inst new_dest_port_OBUF[0]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 150
load inst wr_length[3]_i_1 LUT4 hdi_primitives -attr @cell(#000000) LUT4 -pg 1 -lvl 8 -y 2750
load inst xfer_ptr[2]_i_1 LUT3 hdi_primitives -attr @cell(#000000) LUT3 -pg 1 -lvl 22 -y 1610
load inst xfer_ptr[5]_i_1 LUT6 hdi_primitives -attr @cell(#000000) LUT6 -pg 1 -lvl 22 -y 2070
load inst xfer_state[1]_i_7 LUT5 hdi_primitives -attr @cell(#000000) LUT5 -pg 1 -lvl 29 -y 3380
load inst cur_dest_port_OBUF[1]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 290
load inst cur_length_OBUF[1]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 1630
load inst cur_length_reg[8] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 34 -y 2810
load inst wr_data_IBUF[4]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 19 -y 1510
load inst wr_ptr[5]_i_1 LUT6 hdi_primitives -attr @cell(#000000) LUT6 -pg 1 -lvl 23 -y 4280
load inst wr_ptr_reg[2] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 24 -y 3850
load inst xfer_data_OBUF[8]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 3650
load inst xfer_state[1]_i_8 LUT5 hdi_primitives -attr @cell(#000000) LUT5 -pg 1 -lvl 25 -y 2110
load inst xfer_data_vld_OBUF_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 4070
load inst xfer_state[1]_i_9 LUT5 hdi_primitives -attr @cell(#000000) LUT5 -pg 1 -lvl 25 -y 2260
load inst new_dest_port_reg[1] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 33 -y 350
load inst cur_length_reg[5] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 34 -y 2360
load inst new_length_reg[6] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 20 -y 2470
load inst pause_reg FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 34 -y 1480
load inst wr_data_IBUF[10]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 19 -y 1930
load inst xfer_ptr_reg[5] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 23 -y 2310
load inst cur_dest_port_OBUF[0]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 80
load inst cur_length_reg[2] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 34 -y 1810
load inst end_ptr_reg[4] FDSE hdi_primitives -attr @cell(#000000) FDSE -pg 1 -lvl 28 -y 3590
load inst wr_data_IBUF[1]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 19 -y 1300
load inst wr_length[5]_i_1 LUT6 hdi_primitives -attr @cell(#000000) LUT6 -pg 1 -lvl 12 -y 2790
load inst xfer_ptr_reg[0] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 23 -y 1310
load inst new_dest_port_OBUF[3]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 560
load inst wr_length[1]_i_1 LUT2 hdi_primitives -attr @cell(#000000) LUT2 -pg 1 -lvl 4 -y 2820
load inst end_ptr_reg[1] FDSE hdi_primitives -attr @cell(#000000) FDSE -pg 1 -lvl 28 -y 3080
load inst new_length_reg[3] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 20 -y 2020
load inst rst_n_IBUF_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 18 -y 3100
load inst wr_data_IBUF[8]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 19 -y 1790
load inst xfer_data_OBUF[11]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 3860
load inst xfer_data_OBUF[4]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 3370
load inst new_dest_port_reg[0] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 33 -y 200
load inst new_length_OBUF[6]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 2880
load inst wr_data_IBUF[12]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 19 -y 2070
load inst wr_data_IBUF[2]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 19 -y 1370
load inst wr_length_reg[6] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 16 -y 2860
load inst new_length_OBUF[2]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 2130
load inst new_length_OBUF[8]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 3020
load inst new_length_reg[0] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 20 -y 1570
load inst wr_data_IBUF[0]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 19 -y 1230
load inst wr_length[8]_i_1 LUT2 hdi_primitives -attr @cell(#000000) LUT2 -pg 1 -lvl 2 -y 3170
load inst wr_ptr[1]_i_1 LUT2 hdi_primitives -attr @cell(#000000) LUT2 -pg 1 -lvl 23 -y 3780
load inst wr_ptr_reg[0] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 24 -y 3250
load inst cur_dest_port_OBUF[3]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 640
load inst cur_prior_reg[2] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 34 -y 1140
load inst wr_length[8]_i_2 LUT4 hdi_primitives -attr @cell(#000000) LUT4 -pg 1 -lvl 19 -y 2930
load inst wr_state_reg[0] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 24 -y 3470
load inst wr_data_IBUF[14]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 19 -y 2210
load inst wr_length[8]_i_3 LUT6 hdi_primitives -attr @cell(#000000) LUT6 -pg 1 -lvl 14 -y 2850
load inst wr_length_reg[0] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -y 2830
load inst wr_length_reg[5] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 13 -y 2820
load inst end_ptr_reg[2] FDSE hdi_primitives -attr @cell(#000000) FDSE -pg 1 -lvl 28 -y 3230
load inst wr_length[7]_i_1 LUT3 hdi_primitives -attr @cell(#000000) LUT3 -pg 1 -lvl 17 -y 2870
load inst xfer_data_OBUF[13]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 4000
load inst new_length[8]_i_1 LUT4 hdi_primitives -attr @cell(#000000) LUT4 -pg 1 -lvl 19 -y 3110
load inst new_dest_port_reg[3] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 33 -y 650
load inst cur_prior_OBUF[1]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 1000
load inst cur_prior_OBUF[2]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 1140
load inst new_length_OBUF[5]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 2810
load inst cur_dest_port_reg[1] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 34 -y 280
load inst new_length_OBUF[1]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 2060
load inst wr_length[2]_i_1 LUT3 hdi_primitives -attr @cell(#000000) LUT3 -pg 1 -lvl 6 -y 2750
load inst xfer_ptr[3]_i_1 LUT4 hdi_primitives -attr @cell(#000000) LUT4 -pg 1 -lvl 22 -y 1750
load inst cur_length_reg[7] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 34 -y 2660
load inst new_length_reg[8] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 20 -y 2800
load inst xfer_ptr_reg[2] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 23 -y 1620
load inst xfer_state[0]_i_1 LUT6 hdi_primitives -attr @cell(#000000) LUT6 -pg 1 -lvl 27 -y 2460
load inst cur_length_reg[4] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 34 -y 2160
load inst new_prior_OBUF[1]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 930
load inst new_length_reg[5] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 20 -y 2320
load inst cur_dest_port_reg[0] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 34 -y 80
load inst cur_length_reg[1] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 34 -y 1630
load inst cur_length_OBUF[8]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 2740
load inst cur_prior_reg[0] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 34 -y 790
load inst xfer_data_OBUF[2]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 3230
load inst xfer_data_OBUF[6]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 3510
load inst new_dest_port_reg[2] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 33 -y 500
load inst new_prior_reg[2] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 33 -y 1150
load inst wr_data_IBUF[15]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 19 -y 2280
load inst wr_length_reg[8] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 20 -y 3180
load inst wr_ptr_reg[5] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 24 -y 4300
load inst xfer_data_OBUF[9]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 3720
load inst xfer_ptr[0]_i_1 LUT1 hdi_primitives -attr @cell(#000000) LUT1 -pg 1 -lvl 22 -y 1330
load inst end_ptr_reg[0] FDSE hdi_primitives -attr @cell(#000000) FDSE -pg 1 -lvl 28 -y 2920
load inst new_length_reg[2] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 20 -y 1870
load inst wr_ptr[3]_i_1 LUT4 hdi_primitives -attr @cell(#000000) LUT4 -pg 1 -lvl 23 -y 4000
load inst wr_state[1]_i_1 LUT4 hdi_primitives -attr @cell(#000000) LUT4 -pg 1 -lvl 25 -y 3560
load inst wr_state_reg[0]_i_2 CARRY4 hdi_primitives -attr @cell(#000000) CARRY4 -pinBusAttr CO @name CO[3:0] -pinBusAttr O @name O[3:0] -pinBusAttr O @attr n/c -pinBusAttr DI @name DI[3:0] -pinBusAttr S @name S[3:0] -pg 1 -lvl 22 -y 3130
load inst xfer_data_OBUF[1]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 3160
load inst xfer_ptr_reg[1] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 23 -y 1460
load inst match_suc_IBUF_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 26 -y 2630
load inst wr_data_IBUF[9]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 19 -y 1860
load inst wr_state[1]_i_2 LUT1 hdi_primitives -attr @cell(#000000) LUT1 -pg 1 -lvl 22 -y 2340
load inst xfer_ptr[4]_i_1 LUT5 hdi_primitives -attr @cell(#000000) LUT5 -pg 1 -lvl 22 -y 1890
load inst xfer_state[1]_i_10 LUT5 hdi_primitives -attr @cell(#000000) LUT5 -pg 1 -lvl 25 -y 2440
load inst end_ptr_reg[7] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 29 -y 3700
load inst buffer_reg RAMB18E1 hdi_primitives -attr @cell(#000000) RAMB18E1 -pinBusAttr DOADO @name DOADO[15:0] -pinBusAttr DOADO @attr n/c -pinBusAttr DOBDO @name DOBDO[15:0] -pinBusAttr DOPADOP @name DOPADOP[1:0] -pinBusAttr DOPADOP @attr n/c -pinBusAttr DOPBDOP @name DOPBDOP[1:0] -pinBusAttr DOPBDOP @attr n/c -pinBusAttr ADDRARDADDR @name ADDRARDADDR[13:0] -pinBusAttr ADDRBWRADDR @name ADDRBWRADDR[13:0] -pinBusAttr DIADI @name DIADI[15:0] -pinBusAttr DIBDI @name DIBDI[15:0] -pinBusAttr DIPADIP @name DIPADIP[1:0] -pinBusAttr DIPBDIP @name DIPBDIP[1:0] -pinBusAttr WEA @name WEA[1:0] -pinBusAttr WEBWE @name WEBWE[3:0] -pg 1 -lvl 34 -y 3070
load inst new_length_OBUF[3]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 2260
load inst new_dest_port_OBUF[2]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 380
load inst buffer_reg_i_1 LUT2 hdi_primitives -attr @cell(#000000) LUT2 -pg 1 -lvl 29 -y 2850
load inst xfer_state[1]_i_11 LUT4 hdi_primitives -attr @cell(#000000) LUT4 -pg 1 -lvl 24 -y 2260
load inst clk_IBUF_BUFG_inst BUFG hdi_primitives -attr @cell(#000000) BUFG -pg 1 -lvl 2 -y 2800
load inst cur_length_OBUF[7]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 2660
load inst cur_length_OBUF[5]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 2330
load inst wr_length_reg[2] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 7 -y 2940
load inst wr_length_reg[7] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 18 -y 2920
load inst cur_prior_reg[1] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 34 -y 990
load inst new_length_OBUF[0]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 1920
load inst wr_ptr[0]_i_1 LUT1 hdi_primitives -attr @cell(#000000) LUT1 -pg 1 -lvl 23 -y 3600
load inst xfer_data_vld_reg FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 34 -y 3590
load inst wr_data_IBUF[13]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 19 -y 2140
load inst wr_sop_IBUF_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 22 -y 3290
load inst xfer_data_OBUF[5]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 3440
load inst clk_IBUF_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 1 -y 2800
load inst wr_eop_IBUF_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 22 -y 3360
load inst wr_state_reg[1] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 26 -y 3560
load inst cur_dest_port_OBUF[2]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 460
load inst cur_dest_port_reg[3] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 34 -y 640
load inst cur_length_OBUF[6]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 2400
load inst wr_data_IBUF[6]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 19 -y 1650
load inst wr_length[0]_i_1 LUT1 hdi_primitives -attr @cell(#000000) LUT1 -pg 1 -lvl 2 -y 2700
load inst wr_length_reg[1] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 5 -y 2830
load inst new_prior_reg[0] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 33 -y 800
load inst wr_ptr_reg[3] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 24 -y 4000
load inst xfer_ptr_reg[4] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 23 -y 2160
load inst cur_length_OBUF[3]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 1850
load inst xfer_data_OBUF[10]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 3790
load inst xfer_state_reg[1] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 32 -y 2290
load inst cur_length_reg[6] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 34 -y 2510
load inst new_length_reg[7] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 20 -y 2650
load inst pause_i_1 LUT6 hdi_primitives -attr @cell(#000000) LUT6 -pg 1 -lvl 33 -y 2610
load inst wr_data_IBUF[3]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 19 -y 1440
load inst cur_length_reg[3] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 34 -y 1960
load inst new_length_OBUF[4]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 2470
load inst end_ptr_reg[5] FDSE hdi_primitives -attr @cell(#000000) FDSE -pg 1 -lvl 28 -y 3790
load inst cur_dest_port_reg[2] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 34 -y 460
load inst pause_i_2 LUT6 hdi_primitives -attr @cell(#000000) LUT6 -pg 1 -lvl 32 -y 2420
load inst wr_data_IBUF[7]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 19 -y 1720
load inst wr_state[0]_i_1 LUT6 hdi_primitives -attr @cell(#000000) LUT6 -pg 1 -lvl 23 -y 3160
load inst xfer_ptr[1]_i_1 LUT2 hdi_primitives -attr @cell(#000000) LUT2 -pg 1 -lvl 22 -y 1520
load inst new_dest_port_OBUF[1]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 220
load inst pause_i_3 LUT5 hdi_primitives -attr @cell(#000000) LUT5 -pg 1 -lvl 32 -y 2590
load inst xfer_ptr_reg[3] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 23 -y 1940
load inst cur_length_OBUF[0]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 1320
load inst new_length_reg[4] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 20 -y 2170
load inst pause_i_4 LUT3 hdi_primitives -attr @cell(#000000) LUT3 -pg 1 -lvl 31 -y 2590
load inst wr_state[0]_i_3 LUT6 hdi_primitives -attr @cell(#000000) LUT6 -pg 1 -lvl 21 -y 2810
load inst xfer_state_reg[0] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 28 -y 2700
load inst cur_length_reg[0] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 34 -y 1320
load inst cur_dest_port[3]_i_1 LUT4 hdi_primitives -attr @cell(#000000) LUT4 -pg 1 -lvl 33 -y 2120
load inst new_prior_reg[1] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 33 -y 950
load inst pause_OBUF_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 1480
load inst wr_length[4]_i_1 LUT5 hdi_primitives -attr @cell(#000000) LUT5 -pg 1 -lvl 10 -y 2770
load inst wr_ptr_reg[4] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 24 -y 4150
load inst wr_state[0]_i_4 LUT6 hdi_primitives -attr @cell(#000000) LUT6 -pg 1 -lvl 21 -y 2990
load inst cur_length_OBUF[2]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 1780
load inst new_length_reg[1] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 20 -y 1720
load inst new_prior_OBUF[2]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 1240
load inst wr_state[0]_i_5 LUT6 hdi_primitives -attr @cell(#000000) LUT6 -pg 1 -lvl 21 -y 3190
load inst xfer_data_OBUF[3]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 3300
load inst wr_data_IBUF[5]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 19 -y 1580
load inst wr_length[6]_i_1 LUT2 hdi_primitives -attr @cell(#000000) LUT2 -pg 1 -lvl 15 -y 2860
load inst wr_length_reg[4] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 11 -y 2820
load inst wr_ptr_reg[1] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 24 -y 3650
load inst xfer_state[1]_i_1 LUT6 hdi_primitives -attr @cell(#000000) LUT6 -pg 1 -lvl 31 -y 2420
load inst wr_ptr[2]_i_1 LUT3 hdi_primitives -attr @cell(#000000) LUT3 -pg 1 -lvl 23 -y 3870
load inst wr_ptr[4]_i_1 LUT5 hdi_primitives -attr @cell(#000000) LUT5 -pg 1 -lvl 23 -y 4130
load inst xfer_state[1]_i_2 LUT6 hdi_primitives -attr @cell(#000000) LUT6 -pg 1 -lvl 30 -y 3000
load inst cur_length_OBUF[4]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 1990
load inst wr_data_IBUF[11]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 19 -y 2000
load inst xfer_data_OBUF[0]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 3090
load inst xfer_state[1]_i_3 LUT6 hdi_primitives -attr @cell(#000000) LUT6 -pg 1 -lvl 26 -y 2220
load inst end_ptr_reg[3] FDSE hdi_primitives -attr @cell(#000000) FDSE -pg 1 -lvl 28 -y 3430
load inst wr_vld_IBUF_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 2 -y 2870
load inst xfer_data_OBUF[15]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 4210
load inst xfer_data_OBUF[7]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 3580
load inst xfer_state[1]_i_4 LUT6 hdi_primitives -attr @cell(#000000) LUT6 -pg 1 -lvl 26 -y 2440
load inst new_length_OBUF[7]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 2950
load inst end_ptr[5]_i_1 LUT2 hdi_primitives -attr @cell(#000000) LUT2 -pg 1 -lvl 27 -y 3600
load inst new_prior_OBUF[0]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 860
load inst wr_length_reg[3] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 9 -y 2820
load inst xfer_data_OBUF[14]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 4140
load inst xfer_state[1]_i_5 LUT6 hdi_primitives -attr @cell(#000000) LUT6 -pg 1 -lvl 29 -y 2970
load inst end_ptr[7]_i_1 LUT4 hdi_primitives -attr @cell(#000000) LUT4 -pg 1 -lvl 28 -y 3890
load inst xfer_data_OBUF[12]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 35 -y 3930
load inst xfer_state[1]_i_6 LUT6 hdi_primitives -attr @cell(#000000) LUT6 -pg 1 -lvl 29 -y 3200
load net wr_data_IBUF[10] -attr @rip(#000000) 10 -pin buffer_reg DIADI[10] -pin new_length_reg[3] D -pin wr_data_IBUF[10]_inst O
load net xfer_data_vld -port xfer_data_vld -pin xfer_data_vld_OBUF_inst O
netloc xfer_data_vld 1 35 1 NJ
load net wr_data_IBUF[9] -attr @rip(#000000) 9 -pin buffer_reg DIADI[9] -pin new_length_reg[2] D -pin wr_data_IBUF[9]_inst O
load net xfer_ptr_reg[3] -attr @rip(#000000) 7 -pin buffer_reg ADDRBWRADDR[7] -pin pause_i_1 I2 -pin xfer_ptr[3]_i_1 I3 -pin xfer_ptr[4]_i_1 I3 -pin xfer_ptr[5]_i_1 I0 -pin xfer_ptr_reg[3] Q -pin xfer_state[1]_i_10 I1 -pin xfer_state[1]_i_11 I0 -pin xfer_state[1]_i_7 I4
load net wr_length[8]_i_3_n_0 -pin wr_length[6]_i_1 I0 -pin wr_length[7]_i_1 I0 -pin wr_length[8]_i_2 I1 -pin wr_length[8]_i_3 O
netloc wr_length[8]_i_3_n_0 1 14 5 3080 2760 NJ 2760 3440 3020 NJ 3020 3930J
load net xfer_data[12] -attr @rip(#000000) 12 -port xfer_data[12] -pin xfer_data_OBUF[12]_inst O
load net xfer_state3[2] -pin xfer_ptr[2]_i_1 O -pin xfer_ptr_reg[2] D
netloc xfer_state3[2] 1 22 1 5180
load net xfer_data_OBUF[1] -attr @rip(#000000) DOBDO[1] -pin buffer_reg DOBDO[1] -pin xfer_data_OBUF[1]_inst I
load net wr_eop -port wr_eop -pin wr_eop_IBUF_inst I
netloc wr_eop 1 0 22 NJ 3360 NJ 3360 NJ 3360 NJ 3360 NJ 3360 NJ 3360 NJ 3360 NJ 3360 NJ 3360 NJ 3360 NJ 3360 NJ 3360 NJ 3360 NJ 3360 NJ 3360 NJ 3360 NJ 3360 NJ 3360 NJ 3360 NJ 3360 NJ 3360 NJ
load net p_0_in__0[1] -pin wr_ptr[1]_i_1 O -pin wr_ptr_reg[1] D
netloc p_0_in__0[1] 1 23 1 5540
load net cur_length_OBUF[0] -pin cur_length_OBUF[0]_inst I -pin cur_length_reg[0] Q
netloc cur_length_OBUF[0] 1 34 1 N
load net new_length_OBUF[2] -pin cur_length_reg[2] D -pin new_length_OBUF[2]_inst I -pin new_length_reg[2] Q -pin wr_state[0]_i_5 I2
netloc new_length_OBUF[2] 1 20 15 4640 1860 NJ 1860 NJ 1860 NJ 1860 NJ 1860 NJ 1860 NJ 1860 NJ 1860 NJ 1860 NJ 1860 NJ 1860 NJ 1860 NJ 1860 8590 2080 8950J
load net new_dest_port_OBUF[3] -pin cur_dest_port_reg[3] D -pin new_dest_port_OBUF[3]_inst I -pin new_dest_port_reg[3] Q
netloc new_dest_port_OBUF[3] 1 33 2 8530 560 N
load net end_ptr[1] -pin end_ptr_reg[1] Q -pin xfer_state[1]_i_5 I5
netloc end_ptr[1] 1 28 1 N
load net new_length_OBUF[7] -pin cur_length_reg[7] D -pin new_length_OBUF[7]_inst I -pin new_length_reg[7] Q -pin wr_state[0]_i_3 I4
netloc new_length_OBUF[7] 1 20 15 4660 2690 NJ 2690 NJ 2690 NJ 2690 NJ 2690 NJ 2690 NJ 2690 6750J 2600 NJ 2600 NJ 2600 7710J 2700 7930J 2760 NJ 2760 8590 2950 NJ
load net cur_length[5] -attr @rip(#000000) 5 -port cur_length[5] -pin cur_length_OBUF[5]_inst O
load net wr_length[8]_i_1_n_0 -pin wr_length[8]_i_1 O -pin wr_length_reg[0] R -pin wr_length_reg[1] R -pin wr_length_reg[2] R -pin wr_length_reg[3] R -pin wr_length_reg[4] R -pin wr_length_reg[5] R -pin wr_length_reg[6] R -pin wr_length_reg[7] R -pin wr_length_reg[8] R
netloc wr_length[8]_i_1_n_0 1 2 18 480 3120 NJ 3120 840 3030 NJ 3030 1220 3040 NJ 3040 1680 2900 NJ 2900 2100 2960 NJ 2960 2620 3040 2800J 3000 NJ 3000 3280 2980 NJ 2980 3680 3220 3870J 3240 4300J
load net pause_i_3_n_0 -pin pause_i_1 I1 -pin pause_i_3 O
netloc pause_i_3_n_0 1 32 1 N
load net xfer_data[5] -attr @rip(#000000) 5 -port xfer_data[5] -pin xfer_data_OBUF[5]_inst O
load net wr_state[0]_i_5_n_0 -attr @rip(#000000) 0 -pin wr_state[0]_i_5 O -pin wr_state_reg[0]_i_2 S[0]
load net pause_i_4_n_0 -pin pause_i_3 I1 -pin pause_i_4 O
netloc pause_i_4_n_0 1 31 1 NJ
load net <const0> -ground -pin buffer_reg REGCEAREGCE -pin buffer_reg REGCEB -pin buffer_reg RSTRAMARSTRAM -pin buffer_reg RSTRAMB -pin buffer_reg RSTREGARSTREG -pin buffer_reg RSTREGB -pin buffer_reg DIPADIP[1] -pin buffer_reg DIPADIP[0] -pin buffer_reg DIPBDIP[1] -pin buffer_reg DIPBDIP[0] -pin buffer_reg WEBWE[3] -pin buffer_reg WEBWE[2] -pin buffer_reg WEBWE[1] -pin buffer_reg WEBWE[0] -pin cur_dest_port_reg[0] R -pin cur_dest_port_reg[1] R -pin cur_dest_port_reg[2] R -pin cur_dest_port_reg[3] R -pin cur_length_reg[0] R -pin cur_length_reg[1] R -pin cur_length_reg[2] R -pin cur_length_reg[3] R -pin cur_length_reg[4] R -pin cur_length_reg[5] R -pin cur_length_reg[6] R -pin cur_length_reg[7] R -pin cur_length_reg[8] R -pin cur_prior_reg[0] R -pin cur_prior_reg[1] R -pin cur_prior_reg[2] R -pin end_ptr_reg[7] R -pin new_dest_port_reg[0] R -pin new_dest_port_reg[1] R -pin new_dest_port_reg[2] R -pin new_dest_port_reg[3] R -pin new_length_reg[0] R -pin new_length_reg[1] R -pin new_length_reg[2] R -pin new_length_reg[3] R -pin new_length_reg[4] R -pin new_length_reg[5] R -pin new_length_reg[6] R -pin new_length_reg[7] R -pin new_length_reg[8] R -pin new_prior_reg[0] R -pin new_prior_reg[1] R -pin new_prior_reg[2] R -pin pause_reg R -pin wr_state_reg[0]_i_2 CI -pin wr_state_reg[0]_i_2 DI[3] -pin wr_state_reg[0]_i_2 DI[2] -pin wr_state_reg[0]_i_2 DI[1] -pin wr_state_reg[0]_i_2 DI[0] -pin wr_state_reg[0]_i_2 S[3]
load net cur_dest_port_OBUF[1] -pin cur_dest_port_OBUF[1]_inst I -pin cur_dest_port_reg[1] Q
netloc cur_dest_port_OBUF[1] 1 34 1 8970
load net wr_state[0]_i_4_n_0 -attr @rip(#000000) 1 -pin wr_state[0]_i_4 O -pin wr_state_reg[0]_i_2 S[1]
load net wr_data[10] -attr @rip(#000000) wr_data[10] -port wr_data[10] -pin wr_data_IBUF[10]_inst I
load net xfer_data[11] -attr @rip(#000000) 11 -port xfer_data[11] -pin xfer_data_OBUF[11]_inst O
load net xfer_state3[1] -pin xfer_ptr[1]_i_1 O -pin xfer_ptr_reg[1] D
netloc xfer_state3[1] 1 22 1 5260
load net xfer_data_OBUF[0] -attr @rip(#000000) DOBDO[0] -pin buffer_reg DOBDO[0] -pin xfer_data_OBUF[0]_inst I
load net new_length_OBUF[1] -pin cur_length_reg[1] D -pin new_length_OBUF[1]_inst I -pin new_length_reg[1] Q -pin wr_state[0]_i_5 I4
netloc new_length_OBUF[1] 1 20 15 4560 1720 NJ 1720 NJ 1720 NJ 1720 NJ 1720 NJ 1720 NJ 1720 NJ 1720 NJ 1720 NJ 1720 NJ 1720 NJ 1720 NJ 1720 8570 2060 NJ
load net wr_state2 -attr @rip(#000000) CO[2] -pin wr_state[0]_i_1 I1 -pin wr_state_reg[0]_i_2 CO[2]
load net wr_length_reg__0[8] -pin wr_length[8]_i_2 I3 -pin wr_length_reg[8] Q -pin wr_state[0]_i_3 I3
netloc wr_length_reg__0[8] 1 18 3 3950 3260 NJ 3260 4580
load net cur_length[4] -attr @rip(#000000) 4 -port cur_length[4] -pin cur_length_OBUF[4]_inst O
load net new_length[8]_i_1_n_0 -pin new_dest_port_reg[0] CE -pin new_dest_port_reg[1] CE -pin new_dest_port_reg[2] CE -pin new_dest_port_reg[3] CE -pin new_length[8]_i_1 O -pin new_length_reg[0] CE -pin new_length_reg[1] CE -pin new_length_reg[2] CE -pin new_length_reg[3] CE -pin new_length_reg[4] CE -pin new_length_reg[5] CE -pin new_length_reg[6] CE -pin new_length_reg[7] CE -pin new_length_reg[8] CE -pin new_prior_reg[0] CE -pin new_prior_reg[1] CE -pin new_prior_reg[2] CE
netloc new_length[8]_i_1_n_0 1 19 14 4240 1490 NJ 1490 NJ 1490 5240J 1540 NJ 1540 NJ 1540 NJ 1540 NJ 1540 NJ 1540 NJ 1540 NJ 1540 NJ 1540 NJ 1540 8170
load net wr_data_IBUF[0] -attr @rip(#000000) 0 -pin buffer_reg DIADI[0] -pin new_dest_port_reg[0] D -pin wr_data_IBUF[0]_inst O
load net clk -port clk -pin clk_IBUF_inst I
netloc clk 1 0 1 NJ
load net xfer_data[6] -attr @rip(#000000) 6 -port xfer_data[6] -pin xfer_data_OBUF[6]_inst O
load net xfer_data_vld_OBUF -pin xfer_data_vld_OBUF_inst I -pin xfer_data_vld_reg Q
netloc xfer_data_vld_OBUF 1 34 1 8950J
load net xfer_data[10] -attr @rip(#000000) 10 -port xfer_data[10] -pin xfer_data_OBUF[10]_inst O
load net new_length[5] -attr @rip(#000000) 5 -port new_length[5] -pin new_length_OBUF[5]_inst O
load net xfer_state3[0] -pin xfer_ptr[0]_i_1 O -pin xfer_ptr_reg[0] D
netloc xfer_state3[0] 1 22 1 N
load net <const1> -power -pin buffer_reg ADDRARDADDR[13] -pin buffer_reg ADDRARDADDR[12] -pin buffer_reg ADDRARDADDR[11] -pin buffer_reg ADDRARDADDR[10] -pin buffer_reg ADDRARDADDR[3] -pin buffer_reg ADDRARDADDR[2] -pin buffer_reg ADDRARDADDR[1] -pin buffer_reg ADDRARDADDR[0] -pin buffer_reg ADDRBWRADDR[13] -pin buffer_reg ADDRBWRADDR[12] -pin buffer_reg ADDRBWRADDR[11] -pin buffer_reg ADDRBWRADDR[10] -pin buffer_reg ADDRBWRADDR[3] -pin buffer_reg ADDRBWRADDR[2] -pin buffer_reg ADDRBWRADDR[1] -pin buffer_reg ADDRBWRADDR[0] -pin buffer_reg DIBDI[15] -pin buffer_reg DIBDI[14] -pin buffer_reg DIBDI[13] -pin buffer_reg DIBDI[12] -pin buffer_reg DIBDI[11] -pin buffer_reg DIBDI[10] -pin buffer_reg DIBDI[9] -pin buffer_reg DIBDI[8] -pin buffer_reg DIBDI[7] -pin buffer_reg DIBDI[6] -pin buffer_reg DIBDI[5] -pin buffer_reg DIBDI[4] -pin buffer_reg DIBDI[3] -pin buffer_reg DIBDI[2] -pin buffer_reg DIBDI[1] -pin buffer_reg DIBDI[0] -pin buffer_reg WEA[1] -pin buffer_reg WEA[0] -pin end_ptr_reg[7] CE -pin pause_reg CE -pin wr_state_reg[0] CE -pin wr_state_reg[0]_i_2 CYINIT -pin wr_state_reg[1] CE -pin xfer_data_vld_reg CE -pin xfer_state_reg[0] CE -pin xfer_state_reg[1] CE
load net cur_dest_port_OBUF[2] -pin cur_dest_port_OBUF[2]_inst I -pin cur_dest_port_reg[2] Q
netloc cur_dest_port_OBUF[2] 1 34 1 N
load net wr_data[11] -attr @rip(#000000) wr_data[11] -port wr_data[11] -pin wr_data_IBUF[11]_inst I
load net new_length_OBUF[0] -pin cur_length_reg[0] D -pin new_length_OBUF[0]_inst I -pin new_length_reg[0] Q -pin wr_state[0]_i_5 I1
netloc new_length_OBUF[0] 1 20 15 4540 1700 NJ 1700 NJ 1700 NJ 1700 NJ 1700 NJ 1700 NJ 1700 NJ 1700 NJ 1700 NJ 1700 NJ 1700 NJ 1700 8170J 1680 8610 1730 8970J
load net new_dest_port_OBUF[1] -pin cur_dest_port_reg[1] D -pin new_dest_port_OBUF[1]_inst I -pin new_dest_port_reg[1] Q
netloc new_dest_port_OBUF[1] 1 33 2 8450 200 8970J
load net p_0_in[4] -pin wr_length[4]_i_1 O -pin wr_length_reg[4] D
netloc p_0_in[4] 1 10 1 2100
load net wr_length_reg__0[7] -pin wr_length[7]_i_1 I2 -pin wr_length[8]_i_2 I2 -pin wr_length_reg[7] Q -pin wr_state[0]_i_3 I5
netloc wr_length_reg__0[7] 1 16 5 3480 3000 NJ 3000 3890 2880 4280J 2920 NJ
load net cur_length[3] -attr @rip(#000000) 3 -port cur_length[3] -pin cur_length_OBUF[3]_inst O
load net new_length[1] -attr @rip(#000000) 1 -port new_length[1] -pin new_length_OBUF[1]_inst O
load net new_dest_port[2] -attr @rip(#000000) 2 -port new_dest_port[2] -pin new_dest_port_OBUF[2]_inst O
load net wr_data[2] -attr @rip(#000000) wr_data[2] -port wr_data[2] -pin wr_data_IBUF[2]_inst I
load net xfer_data[3] -attr @rip(#000000) 3 -port xfer_data[3] -pin xfer_data_OBUF[3]_inst O
load net xfer_data_OBUF[7] -attr @rip(#000000) DOBDO[7] -pin buffer_reg DOBDO[7] -pin xfer_data_OBUF[7]_inst I
load net wr_data_IBUF[1] -attr @rip(#000000) 1 -pin buffer_reg DIADI[1] -pin new_dest_port_reg[1] D -pin wr_data_IBUF[1]_inst O
load net new_prior_OBUF[0] -pin cur_prior_reg[0] D -pin new_prior_OBUF[0]_inst I -pin new_prior_reg[0] Q
netloc new_prior_OBUF[0] 1 33 2 8630 890 8970J
load net wr_data[3] -attr @rip(#000000) wr_data[3] -port wr_data[3] -pin wr_data_IBUF[3]_inst I
load net clk_IBUF_BUFG -pin buffer_reg CLKARDCLK -pin buffer_reg CLKBWRCLK -pin clk_IBUF_BUFG_inst O -pin cur_dest_port_reg[0] C -pin cur_dest_port_reg[1] C -pin cur_dest_port_reg[2] C -pin cur_dest_port_reg[3] C -pin cur_length_reg[0] C -pin cur_length_reg[1] C -pin cur_length_reg[2] C -pin cur_length_reg[3] C -pin cur_length_reg[4] C -pin cur_length_reg[5] C -pin cur_length_reg[6] C -pin cur_length_reg[7] C -pin cur_length_reg[8] C -pin cur_prior_reg[0] C -pin cur_prior_reg[1] C -pin cur_prior_reg[2] C -pin end_ptr_reg[0] C -pin end_ptr_reg[1] C -pin end_ptr_reg[2] C -pin end_ptr_reg[3] C -pin end_ptr_reg[4] C -pin end_ptr_reg[5] C -pin end_ptr_reg[7] C -pin new_dest_port_reg[0] C -pin new_dest_port_reg[1] C -pin new_dest_port_reg[2] C -pin new_dest_port_reg[3] C -pin new_length_reg[0] C -pin new_length_reg[1] C -pin new_length_reg[2] C -pin new_length_reg[3] C -pin new_length_reg[4] C -pin new_length_reg[5] C -pin new_length_reg[6] C -pin new_length_reg[7] C -pin new_length_reg[8] C -pin new_prior_reg[0] C -pin new_prior_reg[1] C -pin new_prior_reg[2] C -pin pause_reg C -pin wr_length_reg[0] C -pin wr_length_reg[1] C -pin wr_length_reg[2] C -pin wr_length_reg[3] C -pin wr_length_reg[4] C -pin wr_length_reg[5] C -pin wr_length_reg[6] C -pin wr_length_reg[7] C -pin wr_length_reg[8] C -pin wr_ptr_reg[0] C -pin wr_ptr_reg[1] C -pin wr_ptr_reg[2] C -pin wr_ptr_reg[3] C -pin wr_ptr_reg[4] C -pin wr_ptr_reg[5] C -pin wr_state_reg[0] C -pin wr_state_reg[1] C -pin xfer_data_vld_reg C -pin xfer_ptr_reg[0] C -pin xfer_ptr_reg[1] C -pin xfer_ptr_reg[2] C -pin xfer_ptr_reg[3] C -pin xfer_ptr_reg[4] C -pin xfer_ptr_reg[5] C -pin xfer_state_reg[0] C -pin xfer_state_reg[1] C
netloc clk_IBUF_BUFG 1 2 32 440 2910 NJ 2910 820 2910 NJ 2910 1220 2860 NJ 2860 1640 2740 1920J 2680 2100 2700 NJ 2700 2620 2700 2900J 2740 NJ 2740 3260 2780 NJ 2780 3660 2780 NJ 2780 4220 2960 NJ 2960 NJ 2960 5280 3000 5520 3550 5780J 3530 6120 3270 NJ 3270 6770 3670 7090 2350 NJ 2350 NJ 2350 7930 1210 8190 1700 8490
load net new_length[4] -attr @rip(#000000) 4 -port new_length[4] -pin new_length_OBUF[4]_inst O
load net wr_length_reg__0[6] -pin wr_length[6]_i_1 I1 -pin wr_length[7]_i_1 I1 -pin wr_length[8]_i_2 I0 -pin wr_length_reg[6] Q -pin wr_state[0]_i_3 I0
netloc wr_length_reg__0[6] 1 14 7 3100 2940 NJ 2940 3460 2840 NJ 2840 3930 2860 4300J 2900 4520J
load net new_dest_port_OBUF[2] -pin cur_dest_port_reg[2] D -pin new_dest_port_OBUF[2]_inst I -pin new_dest_port_reg[2] Q
netloc new_dest_port_OBUF[2] 1 33 2 8430 380 N
load net p_0_in[5] -pin wr_length[5]_i_1 O -pin wr_length_reg[5] D
netloc p_0_in[5] 1 12 1 2600
load net new_length[0] -attr @rip(#000000) 0 -port new_length[0] -pin new_length_OBUF[0]_inst O
load net cur_length[2] -attr @rip(#000000) 2 -port cur_length[2] -pin cur_length_OBUF[2]_inst O
load net cur_prior_OBUF[2] -pin cur_prior_OBUF[2]_inst I -pin cur_prior_reg[2] Q
netloc cur_prior_OBUF[2] 1 34 1 N
load net xfer_data_OBUF[6] -attr @rip(#000000) DOBDO[6] -pin buffer_reg DOBDO[6] -pin xfer_data_OBUF[6]_inst I
load net wr_data[1] -attr @rip(#000000) wr_data[1] -port wr_data[1] -pin wr_data_IBUF[1]_inst I
load net new_dest_port[3] -attr @rip(#000000) 3 -port new_dest_port[3] -pin new_dest_port_OBUF[3]_inst O
load net new_prior[2] -attr @rip(#000000) 2 -port new_prior[2] -pin new_prior_OBUF[2]_inst O
load net xfer_data[9] -attr @rip(#000000) 9 -port xfer_data[9] -pin xfer_data_OBUF[9]_inst O
load net xfer_state[1]_i_1_n_0 -pin xfer_state[1]_i_1 O -pin xfer_state_reg[1] D
netloc xfer_state[1]_i_1_n_0 1 31 1 7950
load net xfer_data[4] -attr @rip(#000000) 4 -port xfer_data[4] -pin xfer_data_OBUF[4]_inst O
load net end_ptr[5]_i_1_n_0 -pin end_ptr[5]_i_1 O -pin end_ptr_reg[0] CE -pin end_ptr_reg[1] CE -pin end_ptr_reg[2] CE -pin end_ptr_reg[3] CE -pin end_ptr_reg[4] CE -pin end_ptr_reg[5] CE
netloc end_ptr[5]_i_1_n_0 1 27 1 6790
load net wr_state[0]_i_1_n_0 -pin wr_state[0]_i_1 O -pin wr_state_reg[0] D
netloc wr_state[0]_i_1_n_0 1 23 1 5500
load net wr_data_IBUF[2] -attr @rip(#000000) 2 -pin buffer_reg DIADI[2] -pin new_dest_port_reg[2] D -pin wr_data_IBUF[2]_inst O
load net wr_data[4] -attr @rip(#000000) wr_data[4] -port wr_data[4] -pin wr_data_IBUF[4]_inst I
load net new_length[3] -attr @rip(#000000) 3 -port new_length[3] -pin new_length_OBUF[3]_inst O
load net p_0_in__0[5] -pin wr_ptr[5]_i_1 O -pin wr_ptr_reg[5] D
netloc p_0_in__0[5] 1 23 1 N
load net xfer_ptr_reg[0] -attr @rip(#000000) 4 -pin buffer_reg ADDRBWRADDR[4] -pin pause_i_2 I1 -pin xfer_ptr[0]_i_1 I0 -pin xfer_ptr[1]_i_1 I0 -pin xfer_ptr[2]_i_1 I0 -pin xfer_ptr[3]_i_1 I1 -pin xfer_ptr[4]_i_1 I1 -pin xfer_ptr[5]_i_1 I2 -pin xfer_ptr_reg[0] Q -pin xfer_state[1]_i_10 I3 -pin xfer_state[1]_i_11 I2 -pin xfer_state[1]_i_3 I2 -pin xfer_state[1]_i_4 I4 -pin xfer_state[1]_i_5 I4 -pin xfer_state[1]_i_7 I2 -pin xfer_state[1]_i_8 I1
load net cur_dest_port_OBUF[0] -pin cur_dest_port_OBUF[0]_inst I -pin cur_dest_port_reg[0] Q
netloc cur_dest_port_OBUF[0] 1 34 1 N
load net cur_length_OBUF[8] -pin cur_length_OBUF[8]_inst I -pin cur_length_reg[8] Q
netloc cur_length_OBUF[8] 1 34 1 8950
load net cur_dest_port[2] -attr @rip(#000000) 2 -port cur_dest_port[2] -pin cur_dest_port_OBUF[2]_inst O
load net wr_length_reg__0[5] -pin wr_length[5]_i_1 I5 -pin wr_length[8]_i_3 I0 -pin wr_length_reg[5] Q -pin wr_state[0]_i_4 I3
netloc wr_length_reg__0[5] 1 11 10 2400 2740 NJ 2740 2880 3060 NJ 3060 NJ 3060 NJ 3060 NJ 3060 NJ 3060 NJ 3060 NJ
load net cur_prior[2] -attr @rip(#000000) 2 -port cur_prior[2] -pin cur_prior_OBUF[2]_inst O
load net cur_prior_OBUF[1] -pin cur_prior_OBUF[1]_inst I -pin cur_prior_reg[1] Q
netloc cur_prior_OBUF[1] 1 34 1 8970
load net new_dest_port[0] -attr @rip(#000000) 0 -port new_dest_port[0] -pin new_dest_port_OBUF[0]_inst O
load net p_0_in[6] -pin wr_length[6]_i_1 O -pin wr_length_reg[6] D
netloc p_0_in[6] 1 15 1 N
load net wr_data[0] -attr @rip(#000000) wr_data[0] -port wr_data[0] -pin wr_data_IBUF[0]_inst I
load net xfer_data[1] -attr @rip(#000000) 1 -port xfer_data[1] -pin xfer_data_OBUF[1]_inst O
load net xfer_data_OBUF[5] -attr @rip(#000000) DOBDO[5] -pin buffer_reg DOBDO[5] -pin xfer_data_OBUF[5]_inst I
load net match_suc -port match_suc -pin match_suc_IBUF_inst I
netloc match_suc 1 0 26 NJ 2570 NJ 2570 NJ 2570 NJ 2570 NJ 2570 NJ 2570 NJ 2570 NJ 2570 NJ 2570 NJ 2570 NJ 2570 NJ 2570 NJ 2570 NJ 2570 NJ 2570 NJ 2570 NJ 2570 NJ 2570 NJ 2570 NJ 2570 NJ 2570 NJ 2570 5260J 2590 NJ 2590 5760J 2630 NJ
load net xfer_data[8] -attr @rip(#000000) 8 -port xfer_data[8] -pin xfer_data_OBUF[8]_inst O
load net wr_state_reg[0]_i_2_n_2 -attr @rip(#000000) CO[1] -pin wr_state_reg[0]_i_2 CO[1]
load net xfer_state[1]_i_7_n_0 -pin xfer_state[1]_i_2 I4 -pin xfer_state[1]_i_7 O
netloc xfer_state[1]_i_7_n_0 1 29 1 7470
load net wr_state_reg[0]_i_2_n_3 -attr @rip(#000000) CO[0] -pin wr_state_reg[0]_i_2 CO[0]
load net new_length[2] -attr @rip(#000000) 2 -port new_length[2] -pin new_length_OBUF[2]_inst O
load net wr_data_IBUF[3] -attr @rip(#000000) 3 -pin buffer_reg DIADI[3] -pin new_dest_port_reg[3] D -pin wr_data_IBUF[3]_inst O
load net wr_data[5] -attr @rip(#000000) wr_data[5] -port wr_data[5] -pin wr_data_IBUF[5]_inst I
load net xfer_state13_out -pin xfer_state[0]_i_1 I5 -pin xfer_state[1]_i_1 I5 -pin xfer_state[1]_i_4 O
netloc xfer_state13_out 1 26 5 6410 2650 6710J 2560 NJ 2560 NJ 2560 7770
load net p_0_in__0[4] -pin wr_ptr[4]_i_1 O -pin wr_ptr_reg[4] D
netloc p_0_in__0[4] 1 23 1 N
load net xfer_state[1]_i_8_n_0 -pin xfer_state[1]_i_3 I0 -pin xfer_state[1]_i_4 I3 -pin xfer_state[1]_i_8 O
netloc xfer_state[1]_i_8_n_0 1 25 1 6120
load net cur_length_OBUF[7] -pin cur_length_OBUF[7]_inst I -pin cur_length_reg[7] Q
netloc cur_length_OBUF[7] 1 34 1 N
load net xfer_ptr_reg[1] -attr @rip(#000000) 5 -pin buffer_reg ADDRBWRADDR[5] -pin pause_i_2 I5 -pin xfer_ptr[1]_i_1 I1 -pin xfer_ptr[2]_i_1 I1 -pin xfer_ptr[3]_i_1 I0 -pin xfer_ptr[4]_i_1 I2 -pin xfer_ptr[5]_i_1 I1 -pin xfer_ptr_reg[1] Q -pin xfer_state[1]_i_10 I4 -pin xfer_state[1]_i_11 I1 -pin xfer_state[1]_i_5 I3 -pin xfer_state[1]_i_7 I3 -pin xfer_state[1]_i_8 I2
load net wr_length_reg__0[4] -pin wr_length[4]_i_1 I4 -pin wr_length[5]_i_1 I4 -pin wr_length[8]_i_3 I5 -pin wr_length_reg[4] Q -pin wr_state[0]_i_4 I5
netloc wr_length_reg__0[4] 1 9 12 1940 2740 NJ 2740 2360 2720 NJ 2720 2920 2720 NJ 2720 NJ 2720 NJ 2720 3640J 2800 3950J 2900 4260J 2980 4520J
load net new_dest_port_OBUF[0] -pin cur_dest_port_reg[0] D -pin new_dest_port_OBUF[0]_inst I -pin new_dest_port_reg[0] Q
netloc new_dest_port_OBUF[0] 1 33 2 8430 180 8970J
load net cur_dest_port[3] -attr @rip(#000000) 3 -port cur_dest_port[3] -pin cur_dest_port_OBUF[3]_inst O
load net rst_n -port rst_n -pin rst_n_IBUF_inst I
netloc rst_n 1 0 18 NJ 3100 NJ 3100 NJ 3100 NJ 3100 NJ 3100 NJ 3100 NJ 3100 NJ 3100 NJ 3100 NJ 3100 NJ 3100 NJ 3100 NJ 3100 NJ 3100 NJ 3100 NJ 3100 NJ 3100 NJ
load net wr_sop -port wr_sop -pin wr_sop_IBUF_inst I
netloc wr_sop 1 0 22 NJ 3340 NJ 3340 NJ 3340 NJ 3340 NJ 3340 NJ 3340 NJ 3340 NJ 3340 NJ 3340 NJ 3340 NJ 3340 NJ 3340 NJ 3340 NJ 3340 NJ 3340 NJ 3340 NJ 3340 NJ 3340 NJ 3340 NJ 3340 NJ 3340 4900J
load net xfer_data_OBUF[4] -attr @rip(#000000) DOBDO[4] -pin buffer_reg DOBDO[4] -pin xfer_data_OBUF[4]_inst I
load net xfer_state[1] -pin buffer_reg_i_1 I1 -pin cur_dest_port[3]_i_1 I2 -pin xfer_state[0]_i_1 I3 -pin xfer_state[1]_i_1 I3 -pin xfer_state_reg[1] Q
netloc xfer_state[1] 1 26 7 6450 2840 NJ 2840 7210 2480 NJ 2480 7710 2170 NJ 2170 8170
load net new_dest_port[1] -attr @rip(#000000) 1 -port new_dest_port[1] -pin new_dest_port_OBUF[1]_inst O
load net new_prior[0] -attr @rip(#000000) 0 -port new_prior[0] -pin new_prior_OBUF[0]_inst O
load net p_0_in[7] -pin wr_length[7]_i_1 O -pin wr_length_reg[7] D
netloc p_0_in[7] 1 17 1 3640
load net xfer_data[7] -attr @rip(#000000) 7 -port xfer_data[7] -pin xfer_data_OBUF[7]_inst O
load net xfer_data[2] -attr @rip(#000000) 2 -port xfer_data[2] -pin xfer_data_OBUF[2]_inst O
load net wr_data[13] -attr @rip(#000000) wr_data[13] -port wr_data[13] -pin wr_data_IBUF[13]_inst I
load net cur_length[8] -attr @rip(#000000) 8 -port cur_length[8] -pin cur_length_OBUF[8]_inst O
load net wr_ptr_reg__0[2] -attr @rip(#000000) 6 -pin buffer_reg ADDRARDADDR[6] -pin end_ptr_reg[2] D -pin pause_i_1 I4 -pin pause_i_2 I3 -pin pause_i_4 I2 -pin wr_ptr[2]_i_1 I2 -pin wr_ptr[3]_i_1 I2 -pin wr_ptr[4]_i_1 I0 -pin wr_ptr[5]_i_1 I3 -pin wr_ptr_reg[2] Q -pin xfer_state[1]_i_8 I4
load net p_0_in__0[3] -pin wr_ptr[3]_i_1 O -pin wr_ptr_reg[3] D
netloc p_0_in__0[3] 1 23 1 N
load net pause_OBUF -pin pause_OBUF_inst I -pin pause_reg Q
netloc pause_OBUF 1 34 1 NJ
load net xfer_state1 -pin xfer_state[0]_i_1 I2 -pin xfer_state[1]_i_1 I2 -pin xfer_state[1]_i_3 O
netloc xfer_state1 1 26 5 6430 2610 6670J 2520 NJ 2520 NJ 2520 7730
load net wr_data_IBUF[4] -attr @rip(#000000) 4 -pin buffer_reg DIADI[4] -pin new_prior_reg[0] D -pin wr_data_IBUF[4]_inst O
load net wr_vld -port wr_vld -pin wr_vld_IBUF_inst I
netloc wr_vld 1 0 2 NJ 2870 NJ
load net wr_sop_IBUF -pin wr_sop_IBUF_inst O -pin wr_state[0]_i_1 I0
netloc wr_sop_IBUF 1 22 1 5240J
load net wr_data[6] -attr @rip(#000000) wr_data[6] -port wr_data[6] -pin wr_data_IBUF[6]_inst I
load net p_0_in[0] -pin wr_length[0]_i_1 O -pin wr_length_reg[0] D
netloc p_0_in[0] 1 2 1 420
load net cur_length_OBUF[6] -pin cur_length_OBUF[6]_inst I -pin cur_length_reg[6] Q
netloc cur_length_OBUF[6] 1 34 1 8970
load net end_ptr[7] -pin end_ptr[7]_i_1 I2 -pin end_ptr_reg[7] Q -pin xfer_state[1]_i_2 I5
netloc end_ptr[7] 1 27 3 6870 3710 7210J 3800 7490
load net cur_dest_port[0] -attr @rip(#000000) 0 -port cur_dest_port[0] -pin cur_dest_port_OBUF[0]_inst O
load net wr_length_reg__0[3] -pin wr_length[3]_i_1 I3 -pin wr_length[4]_i_1 I3 -pin wr_length[5]_i_1 I0 -pin wr_length[8]_i_3 I1 -pin wr_length_reg[3] Q -pin wr_state[0]_i_4 I0
netloc wr_length_reg__0[3] 1 7 14 1460 2720 NJ 2720 1880 2700 2140J 2680 2340 2760 2560J 2900 2820 3040 NJ 3040 NJ 3040 NJ 3040 NJ 3040 NJ 3040 4280J 3000 NJ
load net cur_prior[0] -attr @rip(#000000) 0 -port cur_prior[0] -pin cur_prior_OBUF[0]_inst O
load net match_suc_IBUF -pin cur_dest_port[3]_i_1 I1 -pin match_suc_IBUF_inst O -pin xfer_state[0]_i_1 I0 -pin xfer_state[1]_i_1 I0
netloc match_suc_IBUF 1 26 7 6390 2430 NJ 2430 NJ 2430 NJ 2430 7670 2150 NJ 2150 NJ
load net wr_data_IBUF[13] -attr @rip(#000000) 13 -pin buffer_reg DIADI[13] -pin new_length_reg[6] D -pin wr_data_IBUF[13]_inst O
load net xfer_state[0] -pin buffer_reg_i_1 I0 -pin cur_dest_port[3]_i_1 I3 -pin xfer_state[0]_i_1 I4 -pin xfer_state[1]_i_1 I4 -pin xfer_state_reg[0] Q
netloc xfer_state[0] 1 26 7 6490 2670 6730J 2580 7230 2500 NJ 2500 7690 2190 NJ 2190 NJ
load net wr_data[12] -attr @rip(#000000) wr_data[12] -port wr_data[12] -pin wr_data_IBUF[12]_inst I
load net new_prior[1] -attr @rip(#000000) 1 -port new_prior[1] -pin new_prior_OBUF[1]_inst O
load net pause0 -pin pause_i_1 O -pin pause_reg D
netloc pause0 1 33 1 8530
load net xfer_state[1]_i_6_n_0 -pin xfer_state[1]_i_2 I2 -pin xfer_state[1]_i_6 O
netloc xfer_state[1]_i_6_n_0 1 29 1 7410
load net cur_length[7] -attr @rip(#000000) 7 -port cur_length[7] -pin cur_length_OBUF[7]_inst O
load net p_0_in__0[2] -pin wr_ptr[2]_i_1 O -pin wr_ptr_reg[2] D
netloc p_0_in__0[2] 1 23 1 5580
load net xfer_state[1]_i_5_n_0 -pin xfer_state[1]_i_2 I1 -pin xfer_state[1]_i_5 O
netloc xfer_state[1]_i_5_n_0 1 29 1 7410
load net wr_state[0] -pin end_ptr[5]_i_1 I1 -pin end_ptr[7]_i_1 I1 -pin new_length[8]_i_1 I1 -pin wr_length[8]_i_1 I0 -pin wr_state[0]_i_1 I4 -pin wr_state[1]_i_1 I2 -pin wr_state_reg[0] Q
netloc wr_state[0] 1 1 27 170 3240 NJ 3240 NJ 3240 NJ 3240 NJ 3240 NJ 3240 NJ 3240 NJ 3240 NJ 3240 NJ 3240 NJ 3240 NJ 3240 NJ 3240 NJ 3240 NJ 3240 NJ 3240 NJ 3240 3910 3420 NJ 3420 NJ 3420 NJ 3420 5280 3750 NJ 3750 5760 3670 NJ 3670 6470 3670 6710
load net wr_ptr_reg__0[3] -attr @rip(#000000) 7 -pin buffer_reg ADDRARDADDR[7] -pin end_ptr_reg[3] D -pin pause_i_1 I3 -pin pause_i_4 I0 -pin wr_ptr[3]_i_1 I3 -pin wr_ptr[4]_i_1 I3 -pin wr_ptr[5]_i_1 I0 -pin wr_ptr_reg[3] Q -pin xfer_state[1]_i_10 I0 -pin xfer_state[1]_i_3 I4
load net end_ptr[7]_i_1_n_0 -pin end_ptr[7]_i_1 O -pin end_ptr_reg[7] D
netloc end_ptr[7]_i_1_n_0 1 28 1 7230
load net cur_length_OBUF[5] -pin cur_length_OBUF[5]_inst I -pin cur_length_reg[5] Q
netloc cur_length_OBUF[5] 1 34 1 8970
load net xfer_data_OBUF[14] -attr @rip(#000000) DOBDO[14] -pin buffer_reg DOBDO[14] -pin xfer_data_OBUF[14]_inst I
load net wr_data_IBUF[5] -attr @rip(#000000) 5 -pin buffer_reg DIADI[5] -pin new_prior_reg[1] D -pin wr_data_IBUF[5]_inst O
load net wr_length_reg__0[2] -pin wr_length[2]_i_1 I2 -pin wr_length[3]_i_1 I2 -pin wr_length[4]_i_1 I0 -pin wr_length[5]_i_1 I3 -pin wr_length[8]_i_3 I4 -pin wr_length_reg[2] Q -pin wr_state[0]_i_5 I3
netloc wr_length_reg__0[2] 1 5 16 1060 2840 NJ 2840 1440 2940 NJ 2940 1860 2960 2160J 2920 2340 3020 NJ 3020 2840 3300 NJ 3300 NJ 3300 NJ 3300 NJ 3300 NJ 3300 NJ 3300 4680J
load net wr_data[7] -attr @rip(#000000) wr_data[7] -port wr_data[7] -pin wr_data_IBUF[7]_inst I
load net p_0_in[1] -pin wr_length[1]_i_1 O -pin wr_length_reg[1] D
netloc p_0_in[1] 1 4 1 840
load net cur_dest_port[1] -attr @rip(#000000) 1 -port cur_dest_port[1] -pin cur_dest_port_OBUF[1]_inst O
load net wr_state[1]_i_1_n_0 -pin wr_state[1]_i_1 O -pin wr_state_reg[1] D
netloc wr_state[1]_i_1_n_0 1 25 1 N
load net new_length[8] -attr @rip(#000000) 8 -port new_length[8] -pin new_length_OBUF[8]_inst O
load net cur_prior[1] -attr @rip(#000000) 1 -port cur_prior[1] -pin cur_prior_OBUF[1]_inst O
load net wr_data_IBUF[14] -attr @rip(#000000) 14 -pin buffer_reg DIADI[14] -pin new_length_reg[7] D -pin wr_data_IBUF[14]_inst O
load net xfer_data[0] -attr @rip(#000000) 0 -port xfer_data[0] -pin xfer_data_OBUF[0]_inst O
load net xfer_data_OBUF[10] -attr @rip(#000000) DOBDO[10] -pin buffer_reg DOBDO[10] -pin xfer_data_OBUF[10]_inst I
load net wr_eop_IBUF -pin wr_eop_IBUF_inst O -pin wr_state[0]_i_1 I2 -pin wr_state[1]_i_1 I0
netloc wr_eop_IBUF 1 22 3 5160 3570 NJ 3570 NJ
load net clk_IBUF -pin clk_IBUF_BUFG_inst I -pin clk_IBUF_inst O
netloc clk_IBUF 1 1 1 NJ
load net wr_ptr_reg__0[0] -attr @rip(#000000) 4 -pin buffer_reg ADDRARDADDR[4] -pin end_ptr_reg[0] D -pin pause_i_2 I0 -pin wr_ptr[0]_i_1 I0 -pin wr_ptr[1]_i_1 I0 -pin wr_ptr[2]_i_1 I0 -pin wr_ptr[3]_i_1 I1 -pin wr_ptr[4]_i_1 I1 -pin wr_ptr[5]_i_1 I2 -pin wr_ptr_reg[0] Q -pin xfer_state[1]_i_3 I1 -pin xfer_state[1]_i_4 I5
load net cur_length[1] -attr @rip(#000000) 1 -port cur_length[1] -pin cur_length_OBUF[1]_inst O
load net cur_length[6] -attr @rip(#000000) 6 -port cur_length[6] -pin cur_length_OBUF[6]_inst O
load net wr_data[15] -attr @rip(#000000) wr_data[15] -port wr_data[15] -pin wr_data_IBUF[15]_inst I
load net cur_length_OBUF[4] -pin cur_length_OBUF[4]_inst I -pin cur_length_reg[4] Q
netloc cur_length_OBUF[4] 1 34 1 8970
load net wr_state[1] -pin end_ptr[5]_i_1 I0 -pin end_ptr[7]_i_1 I0 -pin new_length[8]_i_1 I2 -pin wr_length[8]_i_1 I1 -pin wr_state[0]_i_1 I3 -pin wr_state[1]_i_1 I1 -pin wr_state_reg[1] Q
netloc wr_state[1] 1 1 27 190 3260 NJ 3260 NJ 3260 NJ 3260 NJ 3260 NJ 3260 NJ 3260 NJ 3260 NJ 3260 NJ 3260 NJ 3260 NJ 3260 NJ 3260 NJ 3260 NJ 3260 NJ 3260 NJ 3260 3930 3400 NJ 3400 NJ 3400 NJ 3400 5260 3730 NJ 3730 5820 3690 NJ 3690 6410 3690 6670
load net xfer_data_OBUF[13] -attr @rip(#000000) DOBDO[13] -pin buffer_reg DOBDO[13] -pin xfer_data_OBUF[13]_inst I
load net pause -port pause -pin pause_OBUF_inst O
netloc pause 1 35 1 NJ
load net xfer_state[1]_i_9_n_0 -pin xfer_state[1]_i_3 I3 -pin xfer_state[1]_i_4 I1 -pin xfer_state[1]_i_9 O
netloc xfer_state[1]_i_9_n_0 1 25 1 6040
load net wr_length_reg__0[1] -pin wr_length[1]_i_1 I1 -pin wr_length[2]_i_1 I1 -pin wr_length[3]_i_1 I0 -pin wr_length[4]_i_1 I2 -pin wr_length[5]_i_1 I1 -pin wr_length[8]_i_3 I2 -pin wr_length_reg[1] Q -pin wr_state[0]_i_5 I5
netloc wr_length_reg__0[1] 1 3 18 660 2750 NJ 2750 1040 2720 NJ 2720 1440 2680 NJ 2680 1900 2940 2120J 2900 2380 2980 NJ 2980 2900 3320 NJ 3320 NJ 3320 NJ 3320 NJ 3320 NJ 3320 NJ 3320 4720J
load net end_ptr[0] -pin end_ptr_reg[0] Q -pin xfer_state[1]_i_5 I0
netloc end_ptr[0] 1 28 1 7230
load net new_length_OBUF[6] -pin cur_length_reg[6] D -pin new_length_OBUF[6]_inst I -pin new_length_reg[6] Q -pin wr_state[0]_i_3 I1
netloc new_length_OBUF[6] 1 20 15 4700 2410 NJ 2410 NJ 2410 NJ 2410 NJ 2410 6100J 2390 NJ 2390 NJ 2390 NJ 2390 NJ 2390 NJ 2390 NJ 2390 NJ 2390 8450 2930 8990J
load net end_ptr[5] -pin end_ptr_reg[5] Q -pin xfer_state[1]_i_6 I2
netloc end_ptr[5] 1 28 1 7190
load net wr_data_IBUF[6] -attr @rip(#000000) 6 -pin buffer_reg DIADI[6] -pin new_prior_reg[2] D -pin wr_data_IBUF[6]_inst O
load net wr_data[8] -attr @rip(#000000) wr_data[8] -port wr_data[8] -pin wr_data_IBUF[8]_inst I
load net p_0_in[2] -pin wr_length[2]_i_1 O -pin wr_length_reg[2] D
netloc p_0_in[2] 1 6 1 1240
load net wr_data_IBUF[11] -attr @rip(#000000) 11 -pin buffer_reg DIADI[11] -pin new_length_reg[4] D -pin wr_data_IBUF[11]_inst O
load net new_length[7] -attr @rip(#000000) 7 -port new_length[7] -pin new_length_OBUF[7]_inst O
load net wr_state[1]_i_2_n_0 -pin end_ptr_reg[0] S -pin end_ptr_reg[1] S -pin end_ptr_reg[2] S -pin end_ptr_reg[3] S -pin end_ptr_reg[4] S -pin end_ptr_reg[5] S -pin wr_ptr_reg[0] CLR -pin wr_ptr_reg[1] CLR -pin wr_ptr_reg[2] CLR -pin wr_ptr_reg[3] CLR -pin wr_ptr_reg[4] CLR -pin wr_ptr_reg[5] CLR -pin wr_state[1]_i_2 O -pin wr_state_reg[0] CLR -pin wr_state_reg[1] CLR -pin xfer_data_vld_reg CLR -pin xfer_ptr_reg[0] CLR -pin xfer_ptr_reg[1] CLR -pin xfer_ptr_reg[2] CLR -pin xfer_ptr_reg[3] CLR -pin xfer_ptr_reg[4] CLR -pin xfer_ptr_reg[5] CLR -pin xfer_state_reg[0] CLR -pin xfer_state_reg[1] CLR
netloc wr_state[1]_i_2_n_0 1 22 12 5200 3020 5460 3370 NJ 3370 6140 3310 NJ 3310 6810 3690 7230J 3600 NJ 3600 NJ 3600 7970 3600 NJ 3600 NJ
load net xfer_ptr_reg[4] -attr @rip(#000000) 8 -pin buffer_reg ADDRBWRADDR[8] -pin pause_i_3 I0 -pin xfer_ptr[4]_i_1 I4 -pin xfer_ptr[5]_i_1 I4 -pin xfer_ptr_reg[4] Q -pin xfer_state[1]_i_7 I0 -pin xfer_state[1]_i_9 I2
load net wr_vld_IBUF -pin buffer_reg ENARDEN -pin new_length[8]_i_1 I3 -pin wr_length_reg[0] CE -pin wr_length_reg[1] CE -pin wr_length_reg[2] CE -pin wr_length_reg[3] CE -pin wr_length_reg[4] CE -pin wr_length_reg[5] CE -pin wr_length_reg[6] CE -pin wr_length_reg[7] CE -pin wr_length_reg[8] CE -pin wr_ptr_reg[0] CE -pin wr_ptr_reg[1] CE -pin wr_ptr_reg[2] CE -pin wr_ptr_reg[3] CE -pin wr_ptr_reg[4] CE -pin wr_ptr_reg[5] CE -pin wr_state[0]_i_1 I5 -pin wr_state[1]_i_1 I3 -pin wr_vld_IBUF_inst O
netloc wr_vld_IBUF 1 2 32 460 2930 NJ 2930 860 2930 NJ 2930 1260 3020 NJ 3020 1660 2920 NJ 2920 2140 2940 NJ 2940 2580 3060 2860J 3020 NJ 3020 3260 2960 NJ 2960 3660 3140 3890 3220 4240 3440 NJ 3440 NJ 3440 5300 3310 5560 3770 5840 3710 NJ 3710 NJ 3710 6830J 3510 NJ 3510 7510J 3240 NJ 3240 NJ 3240 NJ 3240 NJ
load net xfer_state[1]_i_10_n_0 -pin xfer_state[1]_i_10 O -pin xfer_state[1]_i_4 I2
netloc xfer_state[1]_i_10_n_0 1 25 1 N
load net cur_length[0] -attr @rip(#000000) 0 -port cur_length[0] -pin cur_length_OBUF[0]_inst O
load net cur_prior_OBUF[0] -pin cur_prior_OBUF[0]_inst I -pin cur_prior_reg[0] Q
netloc cur_prior_OBUF[0] 1 34 1 N
load net wr_ptr_reg__0[4] -attr @rip(#000000) 8 -pin buffer_reg ADDRARDADDR[8] -pin end_ptr_reg[4] D -pin pause_i_3 I2 -pin wr_ptr[4]_i_1 I4 -pin wr_ptr[5]_i_1 I4 -pin wr_ptr_reg[4] Q -pin xfer_state[1]_i_9 I0
load net xfer_state11_out -pin xfer_state[0]_i_1 I1 -pin xfer_state[1]_i_1 I1 -pin xfer_state[1]_i_2 O
netloc xfer_state11_out 1 26 5 6470 2630 6690J 2540 NJ 2540 NJ 2540 7750
load net wr_data[14] -attr @rip(#000000) wr_data[14] -port wr_data[14] -pin wr_data_IBUF[14]_inst I
load net xfer_data[15] -attr @rip(#000000) 15 -port xfer_data[15] -pin xfer_data_OBUF[15]_inst O
load net buffer_reg_i_1_n_0 -pin buffer_reg ENBWREN -pin buffer_reg_i_1 O -pin xfer_data_vld_reg D -pin xfer_ptr_reg[0] CE -pin xfer_ptr_reg[1] CE -pin xfer_ptr_reg[2] CE -pin xfer_ptr_reg[3] CE -pin xfer_ptr_reg[4] CE -pin xfer_ptr_reg[5] CE -pin xfer_state[1]_i_2 I0 -pin xfer_state[1]_i_4 I0
netloc buffer_reg_i_1_n_0 1 22 12 5300 2570 NJ 2570 NJ 2570 6140 2410 NJ 2410 NJ 2410 NJ 2410 7450 3260 NJ 3260 NJ 3260 NJ 3260 8430
load net xfer_state3[5] -pin xfer_ptr[5]_i_1 O -pin xfer_ptr_reg[5] D -pin xfer_state[1]_i_6 I3
netloc xfer_state3[5] 1 22 7 5220 3330 NJ 3330 NJ 3330 NJ 3330 NJ 3330 NJ 3330 7150J
load net xfer_data_OBUF[9] -attr @rip(#000000) DOBDO[9] -pin buffer_reg DOBDO[9] -pin xfer_data_OBUF[9]_inst I
load net wr_ptr_reg__0[1] -attr @rip(#000000) 5 -pin buffer_reg ADDRARDADDR[5] -pin end_ptr_reg[1] D -pin pause_i_1 I5 -pin pause_i_2 I4 -pin pause_i_4 I1 -pin wr_ptr[1]_i_1 I1 -pin wr_ptr[2]_i_1 I1 -pin wr_ptr[3]_i_1 I0 -pin wr_ptr[4]_i_1 I2 -pin wr_ptr[5]_i_1 I1 -pin wr_ptr_reg[1] Q -pin xfer_state[1]_i_8 I0
load net cur_length_OBUF[3] -pin cur_length_OBUF[3]_inst I -pin cur_length_reg[3] Q
netloc cur_length_OBUF[3] 1 34 1 8950
load net new_length_OBUF[5] -pin cur_length_reg[5] D -pin new_length_OBUF[5]_inst I -pin new_length_reg[5] Q -pin wr_state[0]_i_4 I2
netloc new_length_OBUF[5] 1 20 15 4600 2390 NJ 2390 NJ 2390 NJ 2390 NJ 2390 6020J 2370 NJ 2370 NJ 2370 NJ 2370 NJ 2370 NJ 2370 NJ 2370 NJ 2370 8510 2910 8970J
load net end_ptr[4] -pin end_ptr_reg[4] Q -pin xfer_state[1]_i_6 I4
netloc end_ptr[4] 1 28 1 7210
load net new_prior_OBUF[2] -pin cur_prior_reg[2] D -pin new_prior_OBUF[2]_inst I -pin new_prior_reg[2] Q
netloc new_prior_OBUF[2] 1 33 2 8630 1240 N
load net wr_length_reg__0[0] -pin wr_length[0]_i_1 I0 -pin wr_length[1]_i_1 I0 -pin wr_length[2]_i_1 I0 -pin wr_length[3]_i_1 I1 -pin wr_length[4]_i_1 I1 -pin wr_length[5]_i_1 I2 -pin wr_length[8]_i_3 I3 -pin wr_length_reg[0] Q -pin wr_state[0]_i_5 I0
netloc wr_length_reg__0[0] 1 1 20 170 2750 NJ 2750 640 2730 NJ 2730 1020 2700 NJ 2700 1420 2700 NJ 2700 1840 2720 NJ 2720 2320 3000 NJ 3000 2780 3280 NJ 3280 NJ 3280 NJ 3280 NJ 3280 NJ 3280 NJ 3280 4500J
load net new_length[6] -attr @rip(#000000) 6 -port new_length[6] -pin new_length_OBUF[6]_inst O
load net wr_data_IBUF[15] -attr @rip(#000000) 15 -pin buffer_reg DIADI[15] -pin new_length_reg[8] D -pin wr_data_IBUF[15]_inst O
load net wr_data_IBUF[7] -attr @rip(#000000) 7 -pin buffer_reg DIADI[7] -pin new_length_reg[0] D -pin wr_data_IBUF[7]_inst O
load net wr_data[9] -attr @rip(#000000) wr_data[9] -port wr_data[9] -pin wr_data_IBUF[9]_inst I
load net p_0_in[3] -pin wr_length[3]_i_1 O -pin wr_length_reg[3] D
netloc p_0_in[3] 1 8 1 1620
load net wr_data_IBUF[12] -attr @rip(#000000) 12 -pin buffer_reg DIADI[12] -pin new_length_reg[5] D -pin wr_data_IBUF[12]_inst O
load net xfer_ptr_reg[5] -attr @rip(#000000) 9 -pin buffer_reg ADDRBWRADDR[9] -pin pause_i_3 I4 -pin xfer_ptr[5]_i_1 I5 -pin xfer_ptr_reg[5] Q -pin xfer_state[1]_i_2 I3 -pin xfer_state[1]_i_9 I3
load net rst_n_IBUF -pin cur_dest_port[3]_i_1 I0 -pin end_ptr[7]_i_1 I3 -pin new_length[8]_i_1 I0 -pin rst_n_IBUF_inst O -pin wr_state[1]_i_2 I0
netloc rst_n_IBUF 1 18 15 3890 3080 NJ 3080 4500J 3140 4900 2980 NJ 2980 NJ 2980 NJ 2980 NJ 2980 NJ 2980 6750 2780 NJ 2780 NJ 2780 NJ 2780 NJ 2780 8190J
load net xfer_data_OBUF[12] -attr @rip(#000000) DOBDO[12] -pin buffer_reg DOBDO[12] -pin xfer_data_OBUF[12]_inst I
load net xfer_data[14] -attr @rip(#000000) 14 -port xfer_data[14] -pin xfer_data_OBUF[14]_inst O
load net xfer_state3[4] -pin xfer_ptr[4]_i_1 O -pin xfer_ptr_reg[4] D -pin xfer_state[1]_i_6 I5
netloc xfer_state3[4] 1 22 7 5180 3350 NJ 3350 NJ 3350 NJ 3350 NJ 3350 NJ 3350 7110J
load net xfer_data_OBUF[3] -attr @rip(#000000) DOBDO[3] -pin buffer_reg DOBDO[3] -pin xfer_data_OBUF[3]_inst I
load net wr_ptr_reg__0[5] -attr @rip(#000000) 9 -pin buffer_reg ADDRARDADDR[9] -pin end_ptr_reg[5] D -pin pause_i_3 I3 -pin wr_ptr[5]_i_1 I5 -pin wr_ptr_reg[5] Q -pin xfer_state[1]_i_9 I4
load net xfer_data_OBUF[8] -attr @rip(#000000) DOBDO[8] -pin buffer_reg DOBDO[8] -pin xfer_data_OBUF[8]_inst I
load net cur_length_OBUF[2] -pin cur_length_OBUF[2]_inst I -pin cur_length_reg[2] Q
netloc cur_length_OBUF[2] 1 34 1 8950
load net xfer_state[0]_i_1_n_0 -pin xfer_state[0]_i_1 O -pin xfer_state_reg[0] D
netloc xfer_state[0]_i_1_n_0 1 27 1 6650
load net new_length_OBUF[4] -pin cur_length_reg[4] D -pin new_length_OBUF[4]_inst I -pin new_length_reg[4] Q -pin wr_state[0]_i_4 I4
netloc new_length_OBUF[4] 1 20 15 4620 2220 NJ 2220 5240J 2060 NJ 2060 NJ 2060 NJ 2060 NJ 2060 NJ 2060 NJ 2060 NJ 2060 NJ 2060 NJ 2060 NJ 2060 8450 2280 8950J
load net p_0_in[8] -pin wr_length[8]_i_2 O -pin wr_length_reg[8] D
netloc p_0_in[8] 1 19 1 4200
load net end_ptr[3] -pin end_ptr_reg[3] Q -pin xfer_state[1]_i_6 I1
netloc end_ptr[3] 1 28 1 7130
load net new_prior_OBUF[1] -pin cur_prior_reg[1] D -pin new_prior_OBUF[1]_inst I -pin new_prior_reg[1] Q
netloc new_prior_OBUF[1] 1 33 2 8430 910 8970J
load net xfer_data_OBUF[15] -attr @rip(#000000) DOBDO[15] -pin buffer_reg DOBDO[15] -pin xfer_data_OBUF[15]_inst I
load net cur_dest_port[3]_i_1_n_0 -pin cur_dest_port[3]_i_1 O -pin cur_dest_port_reg[0] CE -pin cur_dest_port_reg[1] CE -pin cur_dest_port_reg[2] CE -pin cur_dest_port_reg[3] CE -pin cur_length_reg[0] CE -pin cur_length_reg[1] CE -pin cur_length_reg[2] CE -pin cur_length_reg[3] CE -pin cur_length_reg[4] CE -pin cur_length_reg[5] CE -pin cur_length_reg[6] CE -pin cur_length_reg[7] CE -pin cur_length_reg[8] CE -pin cur_prior_reg[0] CE -pin cur_prior_reg[1] CE -pin cur_prior_reg[2] CE
netloc cur_dest_port[3]_i_1_n_0 1 33 1 8550
load net xfer_ptr_reg[2] -attr @rip(#000000) 6 -pin buffer_reg ADDRBWRADDR[6] -pin pause_i_2 I2 -pin xfer_ptr[2]_i_1 I2 -pin xfer_ptr[3]_i_1 I2 -pin xfer_ptr[4]_i_1 I0 -pin xfer_ptr[5]_i_1 I3 -pin xfer_ptr_reg[2] Q -pin xfer_state[1]_i_10 I2 -pin xfer_state[1]_i_11 I3 -pin xfer_state[1]_i_5 I2 -pin xfer_state[1]_i_7 I1 -pin xfer_state[1]_i_8 I3
load net wr_data_IBUF[8] -attr @rip(#000000) 8 -pin buffer_reg DIADI[8] -pin new_length_reg[1] D -pin wr_data_IBUF[8]_inst O
load net pause_i_2_n_0 -pin pause_i_1 I0 -pin pause_i_2 O
netloc pause_i_2_n_0 1 32 1 8170
load net wr_state[0]_i_3_n_0 -attr @rip(#000000) 2 -pin wr_state[0]_i_3 O -pin wr_state_reg[0]_i_2 S[2]
load net xfer_data_OBUF[11] -attr @rip(#000000) DOBDO[11] -pin buffer_reg DOBDO[11] -pin xfer_data_OBUF[11]_inst I
load net xfer_data[13] -attr @rip(#000000) 13 -port xfer_data[13] -pin xfer_data_OBUF[13]_inst O
load net cur_dest_port_OBUF[3] -pin cur_dest_port_OBUF[3]_inst I -pin cur_dest_port_reg[3] Q
netloc cur_dest_port_OBUF[3] 1 34 1 N
load net xfer_state3[3] -pin xfer_ptr[3]_i_1 O -pin xfer_ptr_reg[3] D -pin xfer_state[1]_i_3 I5 -pin xfer_state[1]_i_6 I0
netloc xfer_state3[3] 1 22 7 5260 2080 NJ 2080 NJ 2080 6060 3000 NJ 3000 NJ 3000 7030J
load net xfer_state[1]_i_11_n_0 -pin xfer_state[1]_i_11 O -pin xfer_state[1]_i_9 I1
netloc xfer_state[1]_i_11_n_0 1 24 1 NJ
load net p_0_in__0[0] -pin wr_ptr[0]_i_1 O -pin wr_ptr_reg[0] D
netloc p_0_in__0[0] 1 23 1 5480
load net xfer_data_OBUF[2] -attr @rip(#000000) DOBDO[2] -pin buffer_reg DOBDO[2] -pin xfer_data_OBUF[2]_inst I
load net cur_length_OBUF[1] -pin cur_length_OBUF[1]_inst I -pin cur_length_reg[1] Q
netloc cur_length_OBUF[1] 1 34 1 N
load net end_ptr[2] -pin end_ptr_reg[2] Q -pin xfer_state[1]_i_5 I1
netloc end_ptr[2] 1 28 1 7050
load net new_length_OBUF[8] -pin cur_length_reg[8] D -pin new_length_OBUF[8]_inst I -pin new_length_reg[8] Q -pin wr_state[0]_i_3 I2
netloc new_length_OBUF[8] 1 20 15 4720 2780 NJ 2780 NJ 2780 NJ 2780 NJ 2780 6020J 2820 NJ 2820 NJ 2820 NJ 2820 NJ 2820 NJ 2820 NJ 2820 NJ 2820 8470 3020 NJ
load net new_length_OBUF[3] -pin cur_length_reg[3] D -pin new_length_OBUF[3]_inst I -pin new_length_reg[3] Q -pin wr_state[0]_i_4 I1
netloc new_length_OBUF[3] 1 20 15 4680 2020 NJ 2020 NJ 2020 NJ 2020 NJ 2020 NJ 2020 NJ 2020 NJ 2020 NJ 2020 NJ 2020 NJ 2020 NJ 2020 NJ 2020 8610 2260 NJ
load netBundle @new_prior 3 new_prior[2] new_prior[1] new_prior[0] -autobundled
netbloc @new_prior 1 35 1 9280
load netBundle @new_length 9 new_length[8] new_length[7] new_length[6] new_length[5] new_length[4] new_length[3] new_length[2] new_length[1] new_length[0] -autobundled
netbloc @new_length 1 35 1 9280
load netBundle @wr_state_reg,wr_state2 3 wr_state2 wr_state_reg[0]_i_2_n_2 wr_state_reg[0]_i_2_n_3 -autobundled
netbloc @wr_state_reg,wr_state2 1 22 1 5200
load netBundle @wr_ptr_reg__0 6 wr_ptr_reg__0[5] wr_ptr_reg__0[4] wr_ptr_reg__0[3] wr_ptr_reg__0[2] wr_ptr_reg__0[1] wr_ptr_reg__0[0] -autobundled
netbloc @wr_ptr_reg__0 1 22 12 5300 4430 NJ 4430 5800 2610 6080 3290 NJ 3290 6850 3310 7070J 3170 NJ 3170 7770 2680 7990 2740 8230 3080 8530J
load netBundle @xfer_data 16 xfer_data[15] xfer_data[14] xfer_data[13] xfer_data[12] xfer_data[11] xfer_data[10] xfer_data[9] xfer_data[8] xfer_data[7] xfer_data[6] xfer_data[5] xfer_data[4] xfer_data[3] xfer_data[2] xfer_data[1] xfer_data[0] -autobundled
netbloc @xfer_data 1 35 1 9260
load netBundle @xfer_data_OBUF 16 xfer_data_OBUF[15] xfer_data_OBUF[14] xfer_data_OBUF[13] xfer_data_OBUF[12] xfer_data_OBUF[11] xfer_data_OBUF[10] xfer_data_OBUF[9] xfer_data_OBUF[8] xfer_data_OBUF[7] xfer_data_OBUF[6] xfer_data_OBUF[5] xfer_data_OBUF[4] xfer_data_OBUF[3] xfer_data_OBUF[2] xfer_data_OBUF[1] xfer_data_OBUF[0] -autobundled
netbloc @xfer_data_OBUF 1 34 1 8990
load netBundle @cur_prior 3 cur_prior[2] cur_prior[1] cur_prior[0] -autobundled
netbloc @cur_prior 1 35 1 9260
load netBundle @xfer_ptr_reg 6 xfer_ptr_reg[5] xfer_ptr_reg[4] xfer_ptr_reg[3] xfer_ptr_reg[2] xfer_ptr_reg[1] xfer_ptr_reg[0] -autobundled
netbloc @xfer_ptr_reg 1 21 13 4880 2040 NJ 2040 5460 2370 5840 2590 6160 2800 NJ 2800 NJ 2800 7170 3350 7430 3150 NJ 3150 8010 2720 8210 3100 8510J
load netBundle @cur_dest_port 4 cur_dest_port[3] cur_dest_port[2] cur_dest_port[1] cur_dest_port[0] -autobundled
netbloc @cur_dest_port 1 35 1 9280
load netBundle @wr_state 3 wr_state[0]_i_3_n_0 wr_state[0]_i_4_n_0 wr_state[0]_i_5_n_0 -autobundled
netbloc @wr_state 1 21 1 4880
load netBundle @wr_data 16 wr_data[15] wr_data[14] wr_data[13] wr_data[12] wr_data[11] wr_data[10] wr_data[9] wr_data[8] wr_data[7] wr_data[6] wr_data[5] wr_data[4] wr_data[3] wr_data[2] wr_data[1] wr_data[0] -autobundled
netbloc @wr_data 1 0 19 NJ 1230 NJ 1230 NJ 1230 NJ 1230 NJ 1230 NJ 1230 NJ 1230 NJ 1230 NJ 1230 NJ 1230 NJ 1230 NJ 1230 NJ 1230 NJ 1230 NJ 1230 NJ 1230 NJ 1230 NJ 1230 3950
load netBundle @new_dest_port 4 new_dest_port[3] new_dest_port[2] new_dest_port[1] new_dest_port[0] -autobundled
netbloc @new_dest_port 1 35 1 9260
load netBundle @cur_length 9 cur_length[8] cur_length[7] cur_length[6] cur_length[5] cur_length[4] cur_length[3] cur_length[2] cur_length[1] cur_length[0] -autobundled
netbloc @cur_length 1 35 1 9260
load netBundle @wr_data_IBUF 16 wr_data_IBUF[15] wr_data_IBUF[14] wr_data_IBUF[13] wr_data_IBUF[12] wr_data_IBUF[11] wr_data_IBUF[10] wr_data_IBUF[9] wr_data_IBUF[8] wr_data_IBUF[7] wr_data_IBUF[6] wr_data_IBUF[5] wr_data_IBUF[4] wr_data_IBUF[3] wr_data_IBUF[2] wr_data_IBUF[1] wr_data_IBUF[0] -autobundled
netbloc @wr_data_IBUF 1 19 15 4200 1230 NJ 1230 NJ 1230 NJ 1230 NJ 1230 NJ 1230 NJ 1230 NJ 1230 NJ 1230 NJ 1230 NJ 1230 NJ 1230 NJ 1230 8210 1660 8430
levelinfo -pg 1 0 40 240 530 710 910 1110 1310 1510 1730 1990 2210 2450 2670 2970 3150 3330 3530 3730 4010 4380 4770 4990 5350 5640 5900 6210 6540 6920 7300 7560 7820 8060 8300 8720 9030 9300 -top 0 -bot 4440
show
fullfit
#
# initialize ictrl to current module port_wr_frontend work:port_wr_frontend:NOFILE
ictrl init topinfo |
