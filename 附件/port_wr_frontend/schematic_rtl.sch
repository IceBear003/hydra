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
load symbol RTL_RAM work GEN pin WCLK input.clk.left pin WE2 input.left pinBus RA1 input.left [5:0] pinBus RO1 output.right [15:0] pinBus WA2 input.left [5:0] pinBus WD2 input.left [15:0] fillcolor 1
load symbol RTL_MUX7 work MUX pin I0 input.left pin I1 input.left pin O output.right pin S input.bot fillcolor 1
load symbol RTL_ROM4 work GEN pin O output.right pinBus A input.left [2:0] fillcolor 1
load symbol RTL_ROM3 work GEN pinBus A input.left [2:0] pinBus O output.right [7:0] fillcolor 1
load symbol RTL_EQ1 work RTL(=) pin O output.right pinBus I0 input.left [5:0] pinBus I1 input.left [5:0] fillcolor 1
load symbol RTL_ADD1 work RTL(+) pinBus I0 input.left [5:0] pinBus I1 input.left [1:0] pinBus O output.right [5:0] fillcolor 1
load symbol RTL_REG__BREG_8 work GEN pin C input.clk.left pin D input.left pin Q output.right fillcolor 1
load symbol RTL_ADD0 work RTL(+) pin I1 input.left pinBus I0 input.left [8:0] pinBus O output.right [8:0] fillcolor 1
load symbol RTL_ADD work RTL(+) pin I1 input.left pinBus I0 input.left [5:0] pinBus O output.right [5:0] fillcolor 1
load symbol RTL_AND1 work AND pin I0 input pin I1 input pin O output fillcolor 1
load symbol RTL_EQ work RTL(=) pin O output.right pinBus I0 input.left [8:0] pinBus I1 input.left [8:0] fillcolor 1
load symbol RTL_MUX2 work MUX pinBus I0 input.left [3:0] pinBus I1 input.left [3:0] pinBus I2 input.left [3:0] pinBus I3 input.left [3:0] pinBus O output.right [3:0] pinBus S input.bot [2:0] fillcolor 1
load symbol RTL_MUX1 work MUX pin S input.bot pinBus I0 input.left [2:0] pinBus I1 input.left [2:0] pinBus O output.right [2:0] fillcolor 1
load symbol RTL_MUX23 work MUX pin I0 input.left pin I1 input.left pin O output.right pinBus S input.bot [1:0] fillcolor 1
load symbol RTL_REG_ASYNC__BREG_10 workCLR GEN pin C input.clk.left pin CLR input.neg.top pin D input.left pin Q output.right fillcolor 1
load symbol RTL_NEQ work RTL(!=) pin O output.right pinBus I0 input.left [5:0] pinBus I1 input.left [5:0] fillcolor 1
load symbol RTL_EQ2 work RTL(=) pin O output.right pinBus I0 input.left [7:0] pinBus I1 input.left [7:0] fillcolor 1
load symbol RTL_ADD3 work RTL(+) pin I1 input.left pinBus I0 input.left [5:0] pinBus O output.right [6:0] fillcolor 1
load symbol RTL_MUX16 work MUX pinBus I0 input.left [2:0] pinBus I1 input.left [2:0] pinBus I2 input.left [2:0] pinBus O output.right [2:0] pinBus S input.bot [1:0] fillcolor 1
load symbol RTL_MUX15 work MUX pin S input.bot pinBus I0 input.left [1:0] pinBus I1 input.left [1:0] pinBus O output.right [1:0] fillcolor 1
load symbol RTL_REG_ASYNC__BREG_1 workCLR[2:0]sssww GEN pin C input.clk.left pin CE input.left pin CLR input.neg.top pinBus D input.left [2:0] pinBus Q output.right [2:0] fillcolor 1 sandwich 3 prop @bundle 3
load symbol RTL_REG_ASYNC__BREG_3 work[2:0]ssswsw GEN pin C input.clk.left pin CE input.left pin CLR input.top pinBus D input.left [2:0] pin PRE input.bot pinBus Q output.right [2:0] fillcolor 1 sandwich 3 prop @bundle 3
load symbol RTL_REG_ASYNC__BREG_3 work[8:0]ssswsw GEN pin C input.clk.left pin CE input.left pin CLR input.top pinBus D input.left [8:0] pin PRE input.bot pinBus Q output.right [8:0] fillcolor 1 sandwich 3 prop @bundle 9
load symbol RTL_REG_ASYNC__BREG_3 work[3:0]ssswsw GEN pin C input.clk.left pin CE input.left pin CLR input.top pinBus D input.left [3:0] pin PRE input.bot pinBus Q output.right [3:0] fillcolor 1 sandwich 3 prop @bundle 4
load symbol RTL_REG__BREG_9 work[15:0]ssww GEN pin C input.clk.left pin CE input.left pinBus D input.left [15:0] pinBus Q output.right [15:0] fillcolor 1 sandwich 3 prop @bundle 16
load symbol RTL_REG_ASYNC__BREG_1 workCLR[5:0]sssww GEN pin C input.clk.left pin CE input.left pin CLR input.neg.top pinBus D input.left [5:0] pinBus Q output.right [5:0] fillcolor 1 sandwich 3 prop @bundle 6
load symbol RTL_REG_SYNC__BREG_5 work[7:0]sswwws GEN pin C input.clk.left pin CE input.left pinBus D input.left [7:0] pinBus Q output.right [7:0] pinBus RST input.top [7:0] pin SET input.bot fillcolor 1 sandwich 3 prop @bundle 8
load symbol RTL_REG_ASYNC__BREG_1 workCLR[1:0]sssww GEN pin C input.clk.left pin CE input.left pin CLR input.neg.top pinBus D input.left [1:0] pinBus Q output.right [1:0] fillcolor 1 sandwich 3 prop @bundle 2
load symbol RTL_REG_SYNC__BREG_2 work[8:0]sswws GEN pin C input.clk.left pin CE input.left pinBus D input.left [8:0] pinBus Q output.right [8:0] pin RST input.top fillcolor 1 sandwich 3 prop @bundle 9
load port wr_sop input -pg 1 -y 1490
load port xfer_data_vld output -pg 1 -y 650
load port clk input -pg 1 -y 1200
load port wr_eop input -pg 1 -y 1180
load port rst_n input -pg 1 -y 1080
load port match_suc input -pg 1 -y 310
load port pause output -pg 1 -y 760
load port wr_vld input -pg 1 -y 1220
load portBus xfer_data output [15:0] -attr @name xfer_data[15:0] -pg 1 -y 1030
load portBus new_length output [8:0] -attr @name new_length[8:0] -pg 1 -y 260
load portBus new_prior output [2:0] -attr @name new_prior[2:0] -pg 1 -y 1110
load portBus new_dest_port output [3:0] -attr @name new_dest_port[3:0] -pg 1 -y 380
load portBus cur_dest_port output [3:0] -attr @name cur_dest_port[3:0] -pg 1 -y 500
load portBus cur_prior output [2:0] -attr @name cur_prior[2:0] -pg 1 -y 880
load portBus wr_data input [15:0] -attr @name wr_data[15:0] -pg 1 -y 250
load portBus cur_length output [8:0] -attr @name cur_length[8:0] -pg 1 -y 170
load inst new_dest_port_i__0 RTL_MUX7 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=1'b1 -pinAttr I1 @attr S=default -pg 1 -lvl 17 -y 1140
load inst new_dest_port_i__1 RTL_MUX7 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=1'b0 -pinAttr I1 @attr S=default -pg 1 -lvl 18 -y 710
load inst pause_reg RTL_REG__BREG_8 work -attr @cell(#000000) RTL_REG -pg 1 -lvl 20 -y 760
load inst wr_state_reg[2:0] RTL_REG_ASYNC__BREG_1 workCLR[2:0]sssww -attr @cell(#000000) RTL_REG_ASYNC -pg 1 -lvl 8 -y 1160
load inst pause1_i RTL_ADD1 work -attr @cell(#000000) RTL_ADD -pinBusAttr I0 @name I0[5:0] -pinBusAttr I1 @name I1[1:0] -pinBusAttr I1 @attr V=B\"10\" -pinBusAttr O @name O[5:0] -pg 1 -lvl 18 -y 890
load inst xfer_state3_i__0 RTL_ADD3 work -attr @cell(#000000) RTL_ADD -pinBusAttr I0 @name I0[5:0] -pinBusAttr O @name O[6:0] -pg 1 -lvl 10 -y 840
load inst cur_dest_port_reg[3:0] RTL_REG_ASYNC__BREG_3 work[3:0]ssswsw -attr @cell(#000000) RTL_REG_ASYNC -pinAttr CLR @attr n/c -pinAttr PRE @attr n/c -pg 1 -lvl 20 -y 500
load inst new_prior_i__0 RTL_MUX7 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=1'b1 -pinAttr I1 @attr S=default -pg 1 -lvl 17 -y 1260
load inst wr_state0_i RTL_AND1 work -attr @cell(#000000) RTL_AND -pg 1 -lvl 4 -y 1170
load inst new_dest_port_reg[3:0] RTL_REG_ASYNC__BREG_3 work[3:0]ssswsw -attr @cell(#000000) RTL_REG_ASYNC -pinAttr CLR @attr n/c -pinAttr PRE @attr n/c -pg 1 -lvl 19 -y 380
load inst new_prior_i__1 RTL_MUX7 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=1'b0 -pinAttr I1 @attr S=default -pg 1 -lvl 18 -y 1250
load inst cur_prior_i RTL_MUX7 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=1'b0 -pinAttr I1 @attr S=default -pg 1 -lvl 19 -y 780
load inst cur_prior_reg[2:0] RTL_REG_ASYNC__BREG_3 work[2:0]ssswsw -attr @cell(#000000) RTL_REG_ASYNC -pinAttr CLR @attr n/c -pinAttr PRE @attr n/c -pg 1 -lvl 20 -y 880
load inst cur_length_i RTL_MUX7 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=1'b0 -pinAttr I1 @attr S=default -pg 1 -lvl 19 -y 60
load inst wr_ptr0_i RTL_ADD work -attr @cell(#000000) RTL_ADD -pinBusAttr I0 @name I0[5:0] -pinBusAttr O @name O[5:0] -pg 1 -lvl 8 -y 1040
load inst new_length_i RTL_ROM4 work -attr @cell(#000000) RTL_ROM -pinBusAttr A @name A[2:0] -pg 1 -lvl 16 -y 1010
load inst xfer_state_reg[1:0] RTL_REG_ASYNC__BREG_1 workCLR[1:0]sssww -attr @cell(#000000) RTL_REG_ASYNC -pg 1 -lvl 16 -y 680
load inst pause0_i RTL_EQ1 work -attr @cell(#000000) RTL_EQ -pinBusAttr I0 @name I0[5:0] -pinBusAttr I1 @name I1[5:0] -pg 1 -lvl 19 -y 900
load inst xfer_data_i RTL_MUX23 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=2'b01 -pinAttr I1 @attr S=default -pinBusAttr S @name S[1:0] -pg 1 -lvl 19 -y 1010
load inst xfer_state0_i RTL_AND1 work -attr @cell(#000000) RTL_AND -pg 1 -lvl 12 -y 680
load inst new_prior_i RTL_ROM4 work -attr @cell(#000000) RTL_ROM -pinBusAttr A @name A[2:0] -pg 1 -lvl 16 -y 1250
load inst wr_state_i__0 RTL_MUX1 work -attr @cell(#000000) RTL_MUX -pinBusAttr I0 @name I0[2:0] -pinBusAttr I0 @attr V=B\"011\",\ S=1'b1 -pinBusAttr I1 @name I1[2:0] -pinBusAttr I1 @attr S=default -pinBusAttr O @name O[2:0] -pg 1 -lvl 5 -y 990
load inst wr_state1_i__0 RTL_AND1 work -attr @cell(#000000) RTL_AND -pg 1 -lvl 5 -y 1310
load inst wr_state_i__1 RTL_MUX1 work -attr @cell(#000000) RTL_MUX -pinBusAttr I0 @name I0[2:0] -pinBusAttr I0 @attr V=B\"010\",\ S=1'b1 -pinBusAttr I1 @name I1[2:0] -pinBusAttr I1 @attr S=default -pinBusAttr O @name O[2:0] -pg 1 -lvl 6 -y 990
load inst wr_state1_i__1 RTL_AND1 work -attr @cell(#000000) RTL_AND -pg 1 -lvl 6 -y 1310
load inst wr_state_i__2 RTL_MUX1 work -attr @cell(#000000) RTL_MUX -pinBusAttr I0 @name I0[2:0] -pinBusAttr I0 @attr V=B\"001\",\ S=1'b1 -pinBusAttr I1 @name I1[2:0] -pinBusAttr I1 @attr S=default -pinBusAttr O @name O[2:0] -pg 1 -lvl 7 -y 990
load inst cur_dest_port_i RTL_MUX7 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=1'b0 -pinAttr I1 @attr S=default -pg 1 -lvl 19 -y 520
load inst wr_length_i RTL_ROM4 work -attr @cell(#000000) RTL_ROM -pinBusAttr A @name A[2:0] -pg 1 -lvl 1 -y 1270
load inst wr_state_i__3 RTL_MUX7 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=1'b1 -pinAttr I1 @attr S=default -pg 1 -lvl 5 -y 1160
load inst end_ptr_reg[7:0] RTL_REG_SYNC__BREG_5 work[7:0]sswwws -attr @cell(#000000) RTL_REG_SYNC -pg 1 -lvl 10 -y 680
load inst wr_state_i__4 RTL_MUX7 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=1'b1 -pinAttr I1 @attr S=default -pg 1 -lvl 6 -y 1160
load inst xfer_ptr_i RTL_MUX23 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=2'b01 -pinAttr I1 @attr S=default -pinBusAttr S @name S[1:0] -pg 1 -lvl 8 -y 390
load inst wr_state_i__5 RTL_MUX7 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=1'b1 -pinAttr I1 @attr S=default -pg 1 -lvl 7 -y 1160
load inst cur_length_reg[8:0] RTL_REG_ASYNC__BREG_3 work[8:0]ssswsw -attr @cell(#000000) RTL_REG_ASYNC -pinAttr CLR @attr n/c -pinAttr PRE @attr n/c -pg 1 -lvl 20 -y 170
load inst xfer_state1_i__0 RTL_AND1 work -attr @cell(#000000) RTL_AND -pg 1 -lvl 13 -y 880
load inst xfer_state1_i__1 RTL_AND1 work -attr @cell(#000000) RTL_AND -pg 1 -lvl 18 -y 300
load inst buffer_reg RTL_RAM work -attr @cell(#000000) RTL_RAM -pinBusAttr RA1 @name RA1[5:0] -pinBusAttr RO1 @name RO1[15:0] -pinBusAttr WA2 @name WA2[5:0] -pinBusAttr WD2 @name WD2[15:0] -pg 1 -lvl 19 -y 1170
load inst wr_length_reg[8:0] RTL_REG_SYNC__BREG_2 work[8:0]sswws -attr @cell(#000000) RTL_REG_SYNC -pg 1 -lvl 2 -y 1290
load inst xfer_state1_i__2 RTL_NEQ work -attr @cell(#000000) RTL_NEQ -pinBusAttr I0 @name I0[5:0] -pinBusAttr I1 @name I1[5:0] -pg 1 -lvl 11 -y 830
load inst xfer_data_vld_reg RTL_REG_ASYNC__BREG_10 workCLR -attr @cell(#000000) RTL_REG_ASYNC -pg 1 -lvl 20 -y 650
load inst xfer_state2_i RTL_EQ2 work -attr @cell(#000000) RTL_EQ -pinBusAttr I0 @name I0[7:0] -pinBusAttr I1 @name I1[7:0] -pg 1 -lvl 11 -y 710
load inst wr_state2_i RTL_EQ work -attr @cell(#000000) RTL_EQ -pinBusAttr I0 @name I0[8:0] -pinBusAttr I1 @name I1[8:0] -pg 1 -lvl 3 -y 1440
load inst wr_length0_i RTL_ADD0 work -attr @cell(#000000) RTL_ADD -pinBusAttr I0 @name I0[8:0] -pinBusAttr O @name O[8:0] -pg 1 -lvl 1 -y 1390
load inst xfer_data_reg[15:0] RTL_REG__BREG_9 work[15:0]ssww -attr @cell(#000000) RTL_REG -pg 1 -lvl 20 -y 1030
load inst end_ptr_i__0 RTL_MUX7 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=1'b0 -pinAttr I1 @attr S=default -pg 1 -lvl 9 -y 690
load inst xfer_state_i RTL_MUX16 work -attr @cell(#000000) RTL_MUX -pinBusAttr I0 @name I0[2:0] -pinBusAttr I0 @attr V=B\"001\",\ S=2'b00 -pinBusAttr I1 @name I1[2:0] -pinBusAttr I1 @attr V=B\"010\",\ S=2'b01 -pinBusAttr I2 @name I2[2:0] -pinBusAttr I2 @attr V=B\"100\",\ S=2'b10 -pinBusAttr O @name O[2:0] -pinBusAttr S @name S[1:0] -pg 1 -lvl 17 -y 550
load inst end_ptr_i__1 RTL_ROM3 work -attr @cell(#000000) RTL_ROM -pinBusAttr A @name A[2:0] -pinBusAttr O @name O[7:0] -pg 1 -lvl 9 -y 810
load inst xfer_state_i__0 RTL_MUX15 work -attr @cell(#000000) RTL_MUX -pinBusAttr I0 @name I0[1:0] -pinBusAttr I0 @attr S=1'b1 -pinBusAttr I1 @name I1[1:0] -pinBusAttr I1 @attr V=B\"01\",\ S=default -pinBusAttr O @name O[1:0] -pg 1 -lvl 13 -y 500
load inst xfer_state1_i RTL_AND1 work -attr @cell(#000000) RTL_AND -pg 1 -lvl 12 -y 780
load inst xfer_state_i__1 RTL_MUX15 work -attr @cell(#000000) RTL_MUX -pinBusAttr I0 @name I0[1:0] -pinBusAttr I0 @attr V=B\"10\",\ S=1'b1 -pinBusAttr I1 @name I1[1:0] -pinBusAttr I1 @attr S=default -pinBusAttr O @name O[1:0] -pg 1 -lvl 14 -y 690
load inst wr_state_i RTL_MUX2 work -attr @cell(#000000) RTL_MUX -pinBusAttr I0 @name I0[3:0] -pinBusAttr I0 @attr V=B\"0001\",\ S=3'b000 -pinBusAttr I1 @name I1[3:0] -pinBusAttr I1 @attr V=B\"0010\",\ S=3'b001 -pinBusAttr I2 @name I2[3:0] -pinBusAttr I2 @attr V=B\"0100\",\ S=3'b010 -pinBusAttr I3 @name I3[3:0] -pinBusAttr I3 @attr V=B\"1000\",\ S=3'b011 -pinBusAttr O @name O[3:0] -pinBusAttr S @name S[2:0] -pg 1 -lvl 3 -y 1300
load inst new_prior_reg[2:0] RTL_REG_ASYNC__BREG_3 work[2:0]ssswsw -attr @cell(#000000) RTL_REG_ASYNC -pinAttr CLR @attr n/c -pinAttr PRE @attr n/c -pg 1 -lvl 19 -y 1320
load inst xfer_state_i__2 RTL_MUX15 work -attr @cell(#000000) RTL_MUX -pinBusAttr I0 @name I0[1:0] -pinBusAttr I0 @attr V=B\"01\",\ S=1'b1 -pinBusAttr I1 @name I1[1:0] -pinBusAttr I1 @attr S=default -pinBusAttr O @name O[1:0] -pg 1 -lvl 15 -y 690
load inst xfer_data_vld_i RTL_MUX23 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=2'b01 -pinAttr I1 @attr S=default -pinBusAttr S @name S[1:0] -pg 1 -lvl 19 -y 660
load inst xfer_state2_i__0 RTL_EQ1 work -attr @cell(#000000) RTL_EQ -pinBusAttr I0 @name I0[5:0] -pinBusAttr I1 @name I1[5:0] -pg 1 -lvl 12 -y 890
load inst xfer_state_i__3 RTL_MUX7 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=1'b1 -pinAttr I1 @attr S=default -pg 1 -lvl 13 -y 650
load inst xfer_state_i__4 RTL_MUX7 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=1'b1 -pinAttr I1 @attr S=default -pg 1 -lvl 14 -y 860
load inst wr_ptr_reg[5:0] RTL_REG_ASYNC__BREG_1 workCLR[5:0]sssww -attr @cell(#000000) RTL_REG_ASYNC -pg 1 -lvl 9 -y 1040
load inst xfer_state_i__5 RTL_MUX7 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=1'b1 -pinAttr I1 @attr S=default -pg 1 -lvl 15 -y 860
load inst end_ptr_i RTL_ROM4 work -attr @cell(#000000) RTL_ROM -pinBusAttr A @name A[2:0] -pg 1 -lvl 9 -y 900
load inst new_length_i__0 RTL_MUX7 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=1'b1 -pinAttr I1 @attr S=default -pg 1 -lvl 17 -y 1020
load inst new_dest_port_i RTL_ROM4 work -attr @cell(#000000) RTL_ROM -pinBusAttr A @name A[2:0] -pg 1 -lvl 16 -y 1130
load inst wr_state1_i RTL_AND1 work -attr @cell(#000000) RTL_AND -pg 1 -lvl 4 -y 1310
load inst new_length_i__1 RTL_MUX7 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=1'b0 -pinAttr I1 @attr S=default -pg 1 -lvl 18 -y 400
load inst new_length_reg[8:0] RTL_REG_ASYNC__BREG_3 work[8:0]ssswsw -attr @cell(#000000) RTL_REG_ASYNC -pinAttr CLR @attr n/c -pinAttr PRE @attr n/c -pg 1 -lvl 19 -y 230
load inst xfer_state3_i RTL_ADD work -attr @cell(#000000) RTL_ADD -pinBusAttr I0 @name I0[5:0] -pinBusAttr O @name O[5:0] -pg 1 -lvl 10 -y 520
load inst xfer_ptr_reg[5:0] RTL_REG_ASYNC__BREG_1 workCLR[5:0]sssww -attr @cell(#000000) RTL_REG_ASYNC -pg 1 -lvl 9 -y 510
load net buffer_reg_n_9 -attr @rip(#000000) RO1[6] -pin buffer_reg RO1[6] -pin xfer_data_reg[15:0] D[6]
load net wr_length0[5] -attr @rip(#000000) O[5] -pin wr_length0_i O[5] -pin wr_length_reg[8:0] D[5]
load net xfer_data_vld -port xfer_data_vld -pin xfer_data_vld_reg Q
netloc xfer_data_vld 1 20 1 NJ
load net new_length_i_n_0 -pin new_length_i O -pin new_length_i__0 I0
netloc new_length_i_n_0 1 16 1 NJ
load net xfer_state3[2] -attr @rip(#000000) O[2] -pin xfer_state2_i I0[2] -pin xfer_state3_i__0 O[2]
load net xfer_data[12] -attr @rip(#000000) 12 -port xfer_data[12] -pin xfer_data_reg[15:0] Q[12]
load net new_prior_i__1_n_0 -pin new_prior_i__1 O -pin new_prior_reg[2:0] CE
netloc new_prior_i__1_n_0 1 18 1 5830
load net wr_eop -port wr_eop -pin wr_state0_i I1
netloc wr_eop 1 0 4 NJ 1180 NJ 1180 NJ 1180 NJ
load net wr_ptr[5] -attr @rip(#000000) 5 -pin buffer_reg WA2[5] -pin end_ptr_reg[7:0] D[5] -pin pause1_i I0[5] -pin wr_ptr0_i I0[5] -pin wr_ptr_reg[5:0] Q[5] -pin xfer_state1_i__2 I1[5] -pin xfer_state2_i__0 I1[5]
load net end_ptr[1] -attr @rip(#000000) 1 -pin end_ptr_reg[7:0] Q[1] -pin xfer_state2_i I1[1]
load net wr_length[1] -attr @rip(#000000) 1 -pin wr_length0_i I0[1] -pin wr_length_reg[8:0] Q[1] -pin wr_state2_i I0[1]
load net xfer_state_i__0_n_0 -attr @rip(#000000) O[1] -pin xfer_state_i__0 O[1] -pin xfer_state_i__1 I1[1]
load net wr_length0[4] -attr @rip(#000000) O[4] -pin wr_length0_i O[4] -pin wr_length_reg[8:0] D[4]
load net xfer_state3_i_n_0 -attr @rip(#000000) O[5] -pin xfer_ptr_reg[5:0] D[5] -pin xfer_state1_i__2 I0[5] -pin xfer_state2_i__0 I0[5] -pin xfer_state3_i O[5]
load net xfer_state_i__0_n_1 -attr @rip(#000000) O[0] -pin xfer_state_i__0 O[0] -pin xfer_state_i__1 I1[0]
load net wr_state_i__5_n_0 -pin wr_state_i__5 O -pin wr_state_reg[2:0] CE
netloc wr_state_i__5_n_0 1 7 1 N
load net xfer_state3_i_n_1 -attr @rip(#000000) O[4] -pin xfer_ptr_reg[5:0] D[4] -pin xfer_state1_i__2 I0[4] -pin xfer_state2_i__0 I0[4] -pin xfer_state3_i O[4]
load net cur_length[5] -attr @rip(#000000) 5 -port cur_length[5] -pin cur_length_reg[8:0] Q[5]
load net xfer_state3_i_n_2 -attr @rip(#000000) O[3] -pin xfer_ptr_reg[5:0] D[3] -pin xfer_state1_i__2 I0[3] -pin xfer_state2_i__0 I0[3] -pin xfer_state3_i O[3]
load net xfer_state3_i_n_3 -attr @rip(#000000) O[2] -pin xfer_ptr_reg[5:0] D[2] -pin xfer_state1_i__2 I0[2] -pin xfer_state2_i__0 I0[2] -pin xfer_state3_i O[2]
load net xfer_data[5] -attr @rip(#000000) 5 -port xfer_data[5] -pin xfer_data_reg[15:0] Q[5]
load net xfer_state3_i_n_4 -attr @rip(#000000) O[1] -pin xfer_ptr_reg[5:0] D[1] -pin xfer_state1_i__2 I0[1] -pin xfer_state2_i__0 I0[1] -pin xfer_state3_i O[1]
load net xfer_state3_i_n_5 -attr @rip(#000000) O[0] -pin xfer_ptr_reg[5:0] D[0] -pin xfer_state1_i__2 I0[0] -pin xfer_state2_i__0 I0[0] -pin xfer_state3_i O[0]
load net xfer_state_i__5_n_0 -pin xfer_state_i__5 O -pin xfer_state_reg[1:0] CE
netloc xfer_state_i__5_n_0 1 15 1 4830
load net xfer_state1_i_n_0 -pin xfer_state1_i O -pin xfer_state_i__0 S -pin xfer_state_i__3 S
netloc xfer_state1_i_n_0 1 12 1 3770
load net <const0> -ground -pin cur_dest_port_i I0 -pin cur_length_i I0 -pin cur_prior_i I0 -pin end_ptr_i__0 I1 -pin end_ptr_reg[7:0] D[7] -pin end_ptr_reg[7:0] D[6] -pin new_dest_port_i__0 I1 -pin new_dest_port_i__1 I0 -pin new_length_i__0 I1 -pin new_length_i__1 I0 -pin new_prior_i__0 I1 -pin new_prior_i__1 I0 -pin pause1_i I1[0] -pin wr_state_i I0[3] -pin wr_state_i I0[2] -pin wr_state_i I0[1] -pin wr_state_i I1[3] -pin wr_state_i I1[2] -pin wr_state_i I1[0] -pin wr_state_i I2[3] -pin wr_state_i I2[1] -pin wr_state_i I2[0] -pin wr_state_i I3[2] -pin wr_state_i I3[1] -pin wr_state_i I3[0] -pin wr_state_i__0 I0[2] -pin wr_state_i__0 I1[2] -pin wr_state_i__0 I1[1] -pin wr_state_i__0 I1[0] -pin wr_state_i__1 I0[2] -pin wr_state_i__1 I0[0] -pin wr_state_i__2 I0[2] -pin wr_state_i__2 I0[1] -pin xfer_data_i I1 -pin xfer_data_vld_i I1 -pin xfer_ptr_i I1 -pin xfer_state2_i I0[7] -pin xfer_state_i I0[2] -pin xfer_state_i I0[1] -pin xfer_state_i I1[2] -pin xfer_state_i I1[0] -pin xfer_state_i I2[1] -pin xfer_state_i I2[0] -pin xfer_state_i__0 I0[1] -pin xfer_state_i__0 I0[0] -pin xfer_state_i__0 I1[1] -pin xfer_state_i__1 I0[0] -pin xfer_state_i__2 I0[1]
load net wr_state_i__0_n_0 -attr @rip(#000000) O[2] -pin wr_state_i__0 O[2] -pin wr_state_i__1 I1[2]
load net wr_data[10] -attr @rip(#000000) wr_data[10] -pin buffer_reg WD2[10] -pin new_length_reg[8:0] D[3] -port wr_data[10]
load net xfer_state3[1] -attr @rip(#000000) O[1] -pin xfer_state2_i I0[1] -pin xfer_state3_i__0 O[1]
load net xfer_data[11] -attr @rip(#000000) 11 -port xfer_data[11] -pin xfer_data_reg[15:0] Q[11]
load net wr_state_i__0_n_1 -attr @rip(#000000) O[1] -pin wr_state_i__0 O[1] -pin wr_state_i__1 I1[1]
load net pause1[4] -attr @rip(#000000) O[4] -pin pause0_i I0[4] -pin pause1_i O[4]
load net wr_state_i__0_n_2 -attr @rip(#000000) O[0] -pin wr_state_i__0 O[0] -pin wr_state_i__1 I1[0]
load net wr_state0 -pin wr_state0_i O -pin wr_state_i__3 I1
netloc wr_state0 1 4 1 N
load net wr_state_i__2_n_0 -attr @rip(#000000) O[2] -pin wr_state_i__2 O[2] -pin wr_state_reg[2:0] D[2]
load net wr_ptr[4] -attr @rip(#000000) 4 -pin buffer_reg WA2[4] -pin end_ptr_reg[7:0] D[4] -pin pause1_i I0[4] -pin wr_ptr0_i I0[4] -pin wr_ptr_reg[5:0] Q[4] -pin xfer_state1_i__2 I1[4] -pin xfer_state2_i__0 I1[4]
load net wr_state1 -pin wr_state1_i__1 O -pin wr_state_i__2 S -pin wr_state_i__5 S
netloc wr_state1 1 6 1 1800
load net wr_state_i__2_n_1 -attr @rip(#000000) O[1] -pin wr_state_i__2 O[1] -pin wr_state_reg[2:0] D[1]
load net wr_state2 -pin wr_state1_i I1 -pin wr_state2_i O
netloc wr_state2 1 3 1 900
load net wr_state_i__2_n_2 -attr @rip(#000000) O[0] -pin wr_state_i__2 O[0] -pin wr_state_reg[2:0] D[0]
load net xfer_state2_i_n_0 -pin xfer_state1_i I1 -pin xfer_state2_i O
netloc xfer_state2_i_n_0 1 11 1 3520
load net wr_length0[3] -attr @rip(#000000) O[3] -pin wr_length0_i O[3] -pin wr_length_reg[8:0] D[3]
load net wr_length[2] -attr @rip(#000000) 2 -pin wr_length0_i I0[2] -pin wr_length_reg[8:0] Q[2] -pin wr_state2_i I0[2]
load net cur_length[4] -attr @rip(#000000) 4 -port cur_length[4] -pin cur_length_reg[8:0] Q[4]
load net cur_length_i_n_0 -pin cur_length_i O -pin cur_length_reg[8:0] CE
netloc cur_length_i_n_0 1 19 1 6390
load net clk -pin buffer_reg WCLK -port clk -pin cur_dest_port_reg[3:0] C -pin cur_length_reg[8:0] C -pin cur_prior_reg[2:0] C -pin end_ptr_reg[7:0] C -pin new_dest_port_reg[3:0] C -pin new_length_reg[8:0] C -pin new_prior_reg[2:0] C -pin pause_reg C -pin wr_length_reg[8:0] C -pin wr_ptr_reg[5:0] C -pin wr_state_reg[2:0] C -pin xfer_data_reg[15:0] C -pin xfer_data_vld_reg C -pin xfer_ptr_reg[5:0] C -pin xfer_state_reg[1:0] C
netloc clk 1 0 20 NJ 1200 260 1120 NJ 1120 NJ 1120 1120J 1240 NJ 1240 NJ 1240 2150 970 2470 610 2900 590 NJ 590 NJ 590 NJ 590 NJ 590 NJ 590 4830 590 5120J 650 NJ 650 5930 150 6370
load net xfer_data[6] -attr @rip(#000000) 6 -port xfer_data[6] -pin xfer_data_reg[15:0] Q[6]
load net xfer_state3[0] -attr @rip(#000000) O[0] -pin xfer_state2_i I0[0] -pin xfer_state3_i__0 O[0]
load net xfer_data[10] -attr @rip(#000000) 10 -port xfer_data[10] -pin xfer_data_reg[15:0] Q[10]
load net new_length[5] -attr @rip(#000000) 5 -pin cur_length_reg[8:0] D[5] -port new_length[5] -pin new_length_reg[8:0] Q[5] -pin wr_state2_i I1[5]
load net <const1> -power -pin end_ptr_i__0 I0 -pin pause1_i I1[1] -pin wr_length0_i I1 -pin wr_ptr0_i I1 -pin wr_state_i I0[0] -pin wr_state_i I1[1] -pin wr_state_i I2[2] -pin wr_state_i I3[3] -pin wr_state_i__0 I0[1] -pin wr_state_i__0 I0[0] -pin wr_state_i__1 I0[1] -pin wr_state_i__2 I0[0] -pin wr_state_i__3 I0 -pin wr_state_i__4 I0 -pin wr_state_i__5 I0 -pin xfer_data_i I0 -pin xfer_data_vld_i I0 -pin xfer_ptr_i I0 -pin xfer_state3_i I1 -pin xfer_state3_i__0 I1 -pin xfer_state_i I0[0] -pin xfer_state_i I1[1] -pin xfer_state_i I2[2] -pin xfer_state_i__0 I1[0] -pin xfer_state_i__1 I0[1] -pin xfer_state_i__2 I0[0] -pin xfer_state_i__3 I0 -pin xfer_state_i__4 I0 -pin xfer_state_i__5 I0
load net wr_length[7] -attr @rip(#000000) 7 -pin wr_length0_i I0[7] -pin wr_length_reg[8:0] Q[7] -pin wr_state2_i I0[7]
load net wr_data[11] -attr @rip(#000000) wr_data[11] -pin buffer_reg WD2[11] -pin new_length_reg[8:0] D[4] -port wr_data[11]
load net p_0_in -attr @rip(#000000) O[1] -pin xfer_state1_i I0 -pin xfer_state1_i__0 I0 -pin xfer_state_i O[1]
load net wr_ptr[3] -attr @rip(#000000) 3 -pin buffer_reg WA2[3] -pin end_ptr_reg[7:0] D[3] -pin pause1_i I0[3] -pin wr_ptr0_i I0[3] -pin wr_ptr_reg[5:0] Q[3] -pin xfer_state1_i__2 I1[3] -pin xfer_state2_i__0 I1[3]
load net pause1[5] -attr @rip(#000000) O[5] -pin pause0_i I0[5] -pin pause1_i O[5]
load net wr_length0[2] -attr @rip(#000000) O[2] -pin wr_length0_i O[2] -pin wr_length_reg[8:0] D[2]
load net cur_length[3] -attr @rip(#000000) 3 -port cur_length[3] -pin cur_length_reg[8:0] Q[3]
load net new_length[1] -attr @rip(#000000) 1 -pin cur_length_reg[8:0] D[1] -port new_length[1] -pin new_length_reg[8:0] Q[1] -pin wr_state2_i I1[1]
load net new_dest_port[2] -attr @rip(#000000) 2 -pin cur_dest_port_reg[3:0] D[2] -port new_dest_port[2] -pin new_dest_port_reg[3:0] Q[2]
load net wr_data[2] -attr @rip(#000000) wr_data[2] -pin buffer_reg WD2[2] -pin new_dest_port_reg[3:0] D[2] -port wr_data[2]
load net xfer_data[3] -attr @rip(#000000) 3 -port xfer_data[3] -pin xfer_data_reg[15:0] Q[3]
load net cur_prior_i_n_0 -pin cur_prior_i O -pin cur_prior_reg[2:0] CE
netloc cur_prior_i_n_0 1 19 1 6310
load net wr_data[3] -attr @rip(#000000) wr_data[3] -pin buffer_reg WD2[3] -pin new_dest_port_reg[3:0] D[3] -port wr_data[3]
load net wr_state1_i_n_0 -pin wr_state1_i O -pin wr_state_i__0 S -pin wr_state_i__3 S
netloc wr_state1_i_n_0 1 4 1 1100
load net new_length[4] -attr @rip(#000000) 4 -pin cur_length_reg[8:0] D[4] -port new_length[4] -pin new_length_reg[8:0] Q[4] -pin wr_state2_i I1[4]
load net xfer_state_i__4_n_0 -pin xfer_state_i__4 O -pin xfer_state_i__5 I1
netloc xfer_state_i__4_n_0 1 14 1 4500
load net pause1[2] -attr @rip(#000000) O[2] -pin pause0_i I0[2] -pin pause1_i O[2]
load net wr_length[8] -attr @rip(#000000) 8 -pin wr_length0_i I0[8] -pin wr_length_reg[8:0] Q[8] -pin wr_state2_i I0[8]
load net end_ptr_i__1_n_0 -attr @rip(#000000) O[7] -pin end_ptr_i__1 O[7] -pin end_ptr_reg[7:0] RST[7]
load net end_ptr_i__1_n_1 -attr @rip(#000000) O[6] -pin end_ptr_i__1 O[6] -pin end_ptr_reg[7:0] RST[6]
load net wr_length0[1] -attr @rip(#000000) O[1] -pin wr_length0_i O[1] -pin wr_length_reg[8:0] D[1]
load net end_ptr_i__1_n_2 -attr @rip(#000000) O[5] -pin end_ptr_i__1 O[5]
load net new_length[0] -attr @rip(#000000) 0 -pin cur_length_reg[8:0] D[0] -port new_length[0] -pin new_length_reg[8:0] Q[0] -pin wr_state2_i I1[0]
load net cur_length[2] -attr @rip(#000000) 2 -port cur_length[2] -pin cur_length_reg[8:0] Q[2]
load net end_ptr_i__1_n_3 -attr @rip(#000000) O[4] -pin end_ptr_i__1 O[4]
load net wr_ptr0[1] -attr @rip(#000000) O[1] -pin wr_ptr0_i O[1] -pin wr_ptr_reg[5:0] D[1]
load net end_ptr_i__1_n_4 -attr @rip(#000000) O[3] -pin end_ptr_i__1 O[3]
load net new_dest_port_i__0_n_0 -pin new_dest_port_i__0 O -pin new_dest_port_i__1 I1
netloc new_dest_port_i__0_n_0 1 17 1 5500
load net end_ptr_i__1_n_5 -attr @rip(#000000) O[2] -pin end_ptr_i__1 O[2]
load net wr_data[1] -attr @rip(#000000) wr_data[1] -pin buffer_reg WD2[1] -pin new_dest_port_reg[3:0] D[1] -port wr_data[1]
load net new_dest_port[3] -attr @rip(#000000) 3 -pin cur_dest_port_reg[3:0] D[3] -port new_dest_port[3] -pin new_dest_port_reg[3:0] Q[3]
load net new_prior[2] -attr @rip(#000000) 2 -pin cur_prior_reg[2:0] D[2] -port new_prior[2] -pin new_prior_reg[2:0] Q[2]
load net xfer_data[9] -attr @rip(#000000) 9 -port xfer_data[9] -pin xfer_data_reg[15:0] Q[9]
load net end_ptr_i__1_n_6 -attr @rip(#000000) O[1] -pin end_ptr_i__1 O[1]
load net xfer_data_vld_i_n_0 -pin xfer_data_vld_i O -pin xfer_data_vld_reg D
netloc xfer_data_vld_i_n_0 1 19 1 N
load net xfer_data[4] -attr @rip(#000000) 4 -port xfer_data[4] -pin xfer_data_reg[15:0] Q[4]
load net wr_state_i__1_n_0 -attr @rip(#000000) O[2] -pin wr_state_i__1 O[2] -pin wr_state_i__2 I1[2]
load net end_ptr_i__1_n_7 -attr @rip(#000000) O[0] -pin end_ptr_i__1 O[0]
load net wr_state_i__1_n_1 -attr @rip(#000000) O[1] -pin wr_state_i__1 O[1] -pin wr_state_i__2 I1[1]
load net wr_state_i__1_n_2 -attr @rip(#000000) O[0] -pin wr_state_i__1 O[0] -pin wr_state_i__2 I1[0]
load net xfer_state_i__2_n_0 -attr @rip(#000000) O[1] -pin xfer_state_i__2 O[1] -pin xfer_state_reg[1:0] D[1]
load net wr_data[4] -attr @rip(#000000) wr_data[4] -pin buffer_reg WD2[4] -pin new_prior_reg[2:0] D[0] -port wr_data[4]
load net xfer_state_i__2_n_1 -attr @rip(#000000) O[0] -pin xfer_state_i__2 O[0] -pin xfer_state_reg[1:0] D[0]
load net xfer_state1_i__0_n_0 -pin xfer_state1_i__0 O -pin xfer_state_i__1 S -pin xfer_state_i__4 S
netloc xfer_state1_i__0_n_0 1 13 1 4130
load net new_length[3] -attr @rip(#000000) 3 -pin cur_length_reg[8:0] D[3] -port new_length[3] -pin new_length_reg[8:0] Q[3] -pin wr_state2_i I1[3]
load net new_dest_port_i__1_n_0 -pin new_dest_port_i__1 O -pin new_dest_port_reg[3:0] CE
netloc new_dest_port_i__1_n_0 1 18 1 5890
load net pause1[3] -attr @rip(#000000) O[3] -pin pause0_i I0[3] -pin pause1_i O[3]
load net cur_dest_port[2] -attr @rip(#000000) 2 -port cur_dest_port[2] -pin cur_dest_port_reg[3:0] Q[2]
load net wr_length0[0] -attr @rip(#000000) O[0] -pin wr_length0_i O[0] -pin wr_length_reg[8:0] D[0]
load net cur_prior[2] -attr @rip(#000000) 2 -port cur_prior[2] -pin cur_prior_reg[2:0] Q[2]
load net new_dest_port[0] -attr @rip(#000000) 0 -pin cur_dest_port_reg[3:0] D[0] -port new_dest_port[0] -pin new_dest_port_reg[3:0] Q[0]
load net wr_data[0] -attr @rip(#000000) wr_data[0] -pin buffer_reg WD2[0] -pin new_dest_port_reg[3:0] D[0] -port wr_data[0]
load net xfer_data[1] -attr @rip(#000000) 1 -port xfer_data[1] -pin xfer_data_reg[15:0] Q[1]
load net match_suc -port match_suc -pin xfer_state1_i__1 I1
netloc match_suc 1 0 18 NJ 310 NJ 310 NJ 310 NJ 310 NJ 310 NJ 310 NJ 310 NJ 310 NJ 310 NJ 310 NJ 310 NJ 310 NJ 310 NJ 310 NJ 310 NJ 310 NJ 310 NJ
load net wr_ptr0[2] -attr @rip(#000000) O[2] -pin wr_ptr0_i O[2] -pin wr_ptr_reg[5:0] D[2]
load net xfer_data[8] -attr @rip(#000000) 8 -port xfer_data[8] -pin xfer_data_reg[15:0] Q[8]
load net new_length[2] -attr @rip(#000000) 2 -pin cur_length_reg[8:0] D[2] -port new_length[2] -pin new_length_reg[8:0] Q[2] -pin wr_state2_i I1[2]
load net wr_data[5] -attr @rip(#000000) wr_data[5] -pin buffer_reg WD2[5] -pin new_prior_reg[2:0] D[1] -port wr_data[5]
load net wr_length_i_n_0 -pin wr_length_i O -pin wr_length_reg[8:0] RST
netloc wr_length_i_n_0 1 1 1 300
load net wr_state[2] -attr @rip(#000000) 2 -pin end_ptr_i A[2] -pin end_ptr_i__1 A[2] -pin new_dest_port_i A[2] -pin new_length_i A[2] -pin new_prior_i A[2] -pin wr_length_i A[2] -pin wr_state_i S[2] -pin wr_state_reg[2:0] Q[2]
load net wr_state_i__4_n_0 -pin wr_state_i__4 O -pin wr_state_i__5 I1
netloc wr_state_i__4_n_0 1 6 1 1780
load net cur_dest_port[3] -attr @rip(#000000) 3 -port cur_dest_port[3] -pin cur_dest_port_reg[3:0] Q[3]
load net rst_n -pin cur_dest_port_i S -pin cur_length_i S -pin cur_prior_i S -pin end_ptr_i__0 S -pin new_dest_port_i__1 S -pin new_length_i__1 S -pin new_prior_i__1 S -port rst_n -pin wr_ptr_reg[5:0] CLR -pin wr_state_reg[2:0] CLR -pin xfer_data_vld_reg CLR -pin xfer_ptr_reg[5:0] CLR -pin xfer_state_reg[1:0] CLR
netloc rst_n 1 0 20 NJ 1080 NJ 1080 NJ 1080 NJ 1080 NJ 1080 NJ 1080 NJ 1080 2110J N 2490 N 2800J 890 3210J 780 3500J 730 NJ 730 4170J 610 NJ 610 N N 5080 460 5480 N 5950 N 6310
load net wr_sop -port wr_sop -pin wr_state1_i__1 I1
netloc wr_sop 1 0 6 NJ 1490 NJ 1490 NJ 1490 NJ 1490 NJ 1490 1480J
load net xfer_state[1] -attr @rip(#000000) 1 -pin xfer_data_i S[1] -pin xfer_data_vld_i S[1] -pin xfer_ptr_i S[1] -pin xfer_state_i S[1] -pin xfer_state_reg[1:0] Q[1]
load net new_dest_port[1] -attr @rip(#000000) 1 -pin cur_dest_port_reg[3:0] D[1] -port new_dest_port[1] -pin new_dest_port_reg[3:0] Q[1]
load net new_prior[0] -attr @rip(#000000) 0 -pin cur_prior_reg[2:0] D[0] -port new_prior[0] -pin new_prior_reg[2:0] Q[0]
load net xfer_data[7] -attr @rip(#000000) 7 -port xfer_data[7] -pin xfer_data_reg[15:0] Q[7]
load net xfer_data[2] -attr @rip(#000000) 2 -port xfer_data[2] -pin xfer_data_reg[15:0] Q[2]
load net wr_data[13] -attr @rip(#000000) wr_data[13] -pin buffer_reg WD2[13] -pin new_length_reg[8:0] D[6] -port wr_data[13]
load net wr_state_i_n_0 -attr @rip(#000000) O[3] -pin wr_state0_i I0 -pin wr_state_i O[3]
load net cur_length[8] -attr @rip(#000000) 8 -port cur_length[8] -pin cur_length_reg[8:0] Q[8]
load net xfer_state0 -pin xfer_state0_i O -pin xfer_state_i__3 I1
netloc xfer_state0 1 12 1 3810
load net end_ptr_i__0_n_0 -pin end_ptr_i__0 O -pin end_ptr_reg[7:0] SET
netloc end_ptr_i__0_n_0 1 9 1 2820
load net wr_state_i_n_1 -attr @rip(#000000) O[2] -pin wr_state1_i I0 -pin wr_state_i O[2]
load net xfer_state1 -pin cur_dest_port_i I1 -pin cur_length_i I1 -pin cur_prior_i I1 -pin xfer_state1_i__1 O -pin xfer_state_i__2 S -pin xfer_state_i__5 S
netloc xfer_state1 1 15 4 4810 800 NJ 800 NJ 800 5870
load net wr_length[3] -attr @rip(#000000) 3 -pin wr_length0_i I0[3] -pin wr_length_reg[8:0] Q[3] -pin wr_state2_i I0[3]
load net wr_state_i_n_2 -attr @rip(#000000) O[1] -pin wr_state1_i__0 I0 -pin wr_state_i O[1]
load net xfer_state2 -pin xfer_state1_i__0 I1 -pin xfer_state2_i__0 O
netloc xfer_state2 1 12 1 N
load net wr_vld -pin buffer_reg WE2 -pin new_dest_port_i__0 S -pin new_length_i__0 S -pin new_prior_i__0 S -pin wr_length_reg[8:0] CE -pin wr_ptr_reg[5:0] CE -pin wr_state1_i__0 I1 -port wr_vld
netloc wr_vld 1 0 19 NJ 1220 280 1200 NJ 1200 900J 1220 1080 1360 NJ 1360 NJ 1360 NJ 1360 2530 1320 NJ 1320 NJ 1320 NJ 1320 NJ 1320 NJ 1320 NJ 1320 NJ 1320 5100 N 5520 1150 NJ
load net wr_state_i_n_3 -attr @rip(#000000) O[0] -pin wr_state1_i__1 I0 -pin wr_state_i O[0]
load net wr_data[6] -attr @rip(#000000) wr_data[6] -pin buffer_reg WD2[6] -pin new_prior_reg[2:0] D[2] -port wr_data[6]
load net end_ptr_i_n_0 -pin end_ptr_i O -pin end_ptr_reg[7:0] CE
netloc end_ptr_i_n_0 1 9 1 2840
load net xfer_ptr[3] -attr @rip(#000000) 3 -pin buffer_reg RA1[3] -pin pause0_i I1[3] -pin xfer_ptr_reg[5:0] Q[3] -pin xfer_state3_i I0[3] -pin xfer_state3_i__0 I0[3]
load net wr_state1_i__0_n_0 -pin wr_state1_i__0 O -pin wr_state_i__1 S -pin wr_state_i__4 S
netloc wr_state1_i__0_n_0 1 5 1 1440
load net end_ptr[7] -attr @rip(#000000) 7 -pin end_ptr_reg[7:0] Q[7] -pin xfer_state2_i I1[7]
load net cur_dest_port[0] -attr @rip(#000000) 0 -port cur_dest_port[0] -pin cur_dest_port_reg[3:0] Q[0]
load net cur_prior[0] -attr @rip(#000000) 0 -port cur_prior[0] -pin cur_prior_reg[2:0] Q[0]
load net new_length_i__0_n_0 -pin new_length_i__0 O -pin new_length_i__1 I1
netloc new_length_i__0_n_0 1 17 1 5460
load net xfer_state[0] -attr @rip(#000000) 0 -pin xfer_data_i S[0] -pin xfer_data_vld_i S[0] -pin xfer_ptr_i S[0] -pin xfer_state_i S[0] -pin xfer_state_reg[1:0] Q[0]
load net xfer_state_i_n_0 -attr @rip(#000000) O[2] -pin xfer_state0_i I0 -pin xfer_state_i O[2]
load net wr_ptr0[0] -attr @rip(#000000) O[0] -pin wr_ptr0_i O[0] -pin wr_ptr_reg[5:0] D[0]
load net xfer_state_i__3_n_0 -pin xfer_state_i__3 O -pin xfer_state_i__4 I1
netloc xfer_state_i__3_n_0 1 13 1 4150
load net wr_ptr[2] -attr @rip(#000000) 2 -pin buffer_reg WA2[2] -pin end_ptr_reg[7:0] D[2] -pin pause1_i I0[2] -pin wr_ptr0_i I0[2] -pin wr_ptr_reg[5:0] Q[2] -pin xfer_state1_i__2 I1[2] -pin xfer_state2_i__0 I1[2]
load net xfer_state_i_n_2 -attr @rip(#000000) O[0] -pin xfer_state1_i__1 I0 -pin xfer_state_i O[0]
load net wr_data[12] -attr @rip(#000000) wr_data[12] -pin buffer_reg WD2[12] -pin new_length_reg[8:0] D[5] -port wr_data[12]
load net new_prior[1] -attr @rip(#000000) 1 -pin cur_prior_reg[2:0] D[1] -port new_prior[1] -pin new_prior_reg[2:0] Q[1]
load net pause0 -pin pause0_i O -pin pause_reg D
netloc pause0 1 19 1 6330
load net cur_length[7] -attr @rip(#000000) 7 -port cur_length[7] -pin cur_length_reg[8:0] Q[7]
load net wr_state[0] -attr @rip(#000000) 0 -pin end_ptr_i A[0] -pin end_ptr_i__1 A[0] -pin new_dest_port_i A[0] -pin new_length_i A[0] -pin new_prior_i A[0] -pin wr_length_i A[0] -pin wr_state_i S[0] -pin wr_state_reg[2:0] Q[0]
load net new_length_i__1_n_0 -pin new_length_i__1 O -pin new_length_reg[8:0] CE
netloc new_length_i__1_n_0 1 18 1 5830
load net wr_length[4] -attr @rip(#000000) 4 -pin wr_length0_i I0[4] -pin wr_length_reg[8:0] Q[4] -pin wr_state2_i I0[4]
load net wr_data[7] -attr @rip(#000000) wr_data[7] -pin buffer_reg WD2[7] -pin new_length_reg[8:0] D[0] -port wr_data[7]
load net end_ptr[6] -attr @rip(#000000) 6 -pin end_ptr_reg[7:0] Q[6] -pin xfer_state2_i I1[6]
load net xfer_ptr[4] -attr @rip(#000000) 4 -pin buffer_reg RA1[4] -pin pause0_i I1[4] -pin xfer_ptr_reg[5:0] Q[4] -pin xfer_state3_i I0[4] -pin xfer_state3_i__0 I0[4]
load net cur_dest_port[1] -attr @rip(#000000) 1 -port cur_dest_port[1] -pin cur_dest_port_reg[3:0] Q[1]
load net new_length[8] -attr @rip(#000000) 8 -pin cur_length_reg[8:0] D[8] -port new_length[8] -pin new_length_reg[8:0] Q[8] -pin wr_state2_i I1[8]
load net cur_prior[1] -attr @rip(#000000) 1 -port cur_prior[1] -pin cur_prior_reg[2:0] Q[1]
load net xfer_state1_i__2_n_0 -pin xfer_state0_i I1 -pin xfer_state1_i__2 O
netloc xfer_state1_i__2_n_0 1 11 1 3480
load net wr_ptr[1] -attr @rip(#000000) 1 -pin buffer_reg WA2[1] -pin end_ptr_reg[7:0] D[1] -pin pause1_i I0[1] -pin wr_ptr0_i I0[1] -pin wr_ptr_reg[5:0] Q[1] -pin xfer_state1_i__2 I1[1] -pin xfer_state2_i__0 I1[1]
load net cur_dest_port_i_n_0 -pin cur_dest_port_i O -pin cur_dest_port_reg[3:0] CE
netloc cur_dest_port_i_n_0 1 19 1 6310
load net xfer_data[0] -attr @rip(#000000) 0 -port xfer_data[0] -pin xfer_data_reg[15:0] Q[0]
load net xfer_ptr[0] -attr @rip(#000000) 0 -pin buffer_reg RA1[0] -pin pause0_i I1[0] -pin xfer_ptr_reg[5:0] Q[0] -pin xfer_state3_i I0[0] -pin xfer_state3_i__0 I0[0]
load net cur_length[1] -attr @rip(#000000) 1 -port cur_length[1] -pin cur_length_reg[8:0] Q[1]
load net cur_length[6] -attr @rip(#000000) 6 -port cur_length[6] -pin cur_length_reg[8:0] Q[6]
load net wr_state_i__3_n_0 -pin wr_state_i__3 O -pin wr_state_i__4 I1
netloc wr_state_i__3_n_0 1 5 1 1460
load net wr_ptr0[5] -attr @rip(#000000) O[5] -pin wr_ptr0_i O[5] -pin wr_ptr_reg[5:0] D[5]
load net wr_data[15] -attr @rip(#000000) wr_data[15] -pin buffer_reg WD2[15] -pin new_length_reg[8:0] D[8] -port wr_data[15]
load net xfer_state3[6] -attr @rip(#000000) O[6] -pin xfer_state2_i I0[6] -pin xfer_state3_i__0 O[6]
load net wr_state[1] -attr @rip(#000000) 1 -pin end_ptr_i A[1] -pin end_ptr_i__1 A[1] -pin new_dest_port_i A[1] -pin new_length_i A[1] -pin new_prior_i A[1] -pin wr_length_i A[1] -pin wr_state_i S[1] -pin wr_state_reg[2:0] Q[1]
load net pause -port pause -pin pause_reg Q
netloc pause 1 20 1 NJ
load net end_ptr[0] -attr @rip(#000000) 0 -pin end_ptr_reg[7:0] Q[0] -pin xfer_state2_i I1[0]
load net end_ptr[5] -attr @rip(#000000) 5 -pin end_ptr_reg[7:0] Q[5] -pin xfer_state2_i I1[5]
load net wr_length[5] -attr @rip(#000000) 5 -pin wr_length0_i I0[5] -pin wr_length_reg[8:0] Q[5] -pin wr_state2_i I0[5]
load net wr_data[8] -attr @rip(#000000) wr_data[8] -pin buffer_reg WD2[8] -pin new_length_reg[8:0] D[1] -port wr_data[8]
load net wr_length0[8] -attr @rip(#000000) O[8] -pin wr_length0_i O[8] -pin wr_length_reg[8:0] D[8]
load net new_dest_port_i_n_0 -pin new_dest_port_i O -pin new_dest_port_i__0 I0
netloc new_dest_port_i_n_0 1 16 1 NJ
load net new_length[7] -attr @rip(#000000) 7 -pin cur_length_reg[8:0] D[7] -port new_length[7] -pin new_length_reg[8:0] Q[7] -pin wr_state2_i I1[7]
load net xfer_ptr[5] -attr @rip(#000000) 5 -pin buffer_reg RA1[5] -pin pause0_i I1[5] -pin xfer_ptr_reg[5:0] Q[5] -pin xfer_state3_i I0[5] -pin xfer_state3_i__0 I0[5]
load net pause1[0] -attr @rip(#000000) O[0] -pin pause0_i I0[0] -pin pause1_i O[0]
load net wr_ptr[0] -attr @rip(#000000) 0 -pin buffer_reg WA2[0] -pin end_ptr_reg[7:0] D[0] -pin pause1_i I0[0] -pin wr_ptr0_i I0[0] -pin wr_ptr_reg[5:0] Q[0] -pin xfer_state1_i__2 I1[0] -pin xfer_state2_i__0 I1[0]
load net xfer_state_i__1_n_0 -attr @rip(#000000) O[1] -pin xfer_state_i__1 O[1] -pin xfer_state_i__2 I1[1]
load net xfer_state_i__1_n_1 -attr @rip(#000000) O[0] -pin xfer_state_i__1 O[0] -pin xfer_state_i__2 I1[0]
load net cur_length[0] -attr @rip(#000000) 0 -port cur_length[0] -pin cur_length_reg[8:0] Q[0]
load net buffer_reg_n_10 -attr @rip(#000000) RO1[5] -pin buffer_reg RO1[5] -pin xfer_data_reg[15:0] D[5]
load net xfer_ptr[1] -attr @rip(#000000) 1 -pin buffer_reg RA1[1] -pin pause0_i I1[1] -pin xfer_ptr_reg[5:0] Q[1] -pin xfer_state3_i I0[1] -pin xfer_state3_i__0 I0[1]
load net buffer_reg_n_11 -attr @rip(#000000) RO1[4] -pin buffer_reg RO1[4] -pin xfer_data_reg[15:0] D[4]
load net wr_data[14] -attr @rip(#000000) wr_data[14] -pin buffer_reg WD2[14] -pin new_length_reg[8:0] D[7] -port wr_data[14]
load net xfer_state3[5] -attr @rip(#000000) O[5] -pin xfer_state2_i I0[5] -pin xfer_state3_i__0 O[5]
load net xfer_data[15] -attr @rip(#000000) 15 -port xfer_data[15] -pin xfer_data_reg[15:0] Q[15]
load net buffer_reg_n_12 -attr @rip(#000000) RO1[3] -pin buffer_reg RO1[3] -pin xfer_data_reg[15:0] D[3]
load net new_prior_i__0_n_0 -pin new_prior_i__0 O -pin new_prior_i__1 I1
netloc new_prior_i__0_n_0 1 17 1 N
load net buffer_reg_n_13 -attr @rip(#000000) RO1[2] -pin buffer_reg RO1[2] -pin xfer_data_reg[15:0] D[2]
load net buffer_reg_n_14 -attr @rip(#000000) RO1[1] -pin buffer_reg RO1[1] -pin xfer_data_reg[15:0] D[1]
load net buffer_reg_n_15 -attr @rip(#000000) RO1[0] -pin buffer_reg RO1[0] -pin xfer_data_reg[15:0] D[0]
load net end_ptr[4] -attr @rip(#000000) 4 -pin end_ptr_reg[7:0] Q[4] -pin xfer_state2_i I1[4]
load net wr_length0[7] -attr @rip(#000000) O[7] -pin wr_length0_i O[7] -pin wr_length_reg[8:0] D[7]
load net new_length[6] -attr @rip(#000000) 6 -pin cur_length_reg[8:0] D[6] -port new_length[6] -pin new_length_reg[8:0] Q[6] -pin wr_state2_i I1[6]
load net wr_length[6] -attr @rip(#000000) 6 -pin wr_length0_i I0[6] -pin wr_length_reg[8:0] Q[6] -pin wr_state2_i I0[6]
load net wr_data[9] -attr @rip(#000000) wr_data[9] -pin buffer_reg WD2[9] -pin new_length_reg[8:0] D[2] -port wr_data[9]
load net xfer_data_i_n_0 -pin xfer_data_i O -pin xfer_data_reg[15:0] CE
netloc xfer_data_i_n_0 1 19 1 6310
load net pause1[1] -attr @rip(#000000) O[1] -pin pause0_i I0[1] -pin pause1_i O[1]
load net wr_ptr0[3] -attr @rip(#000000) O[3] -pin wr_ptr0_i O[3] -pin wr_ptr_reg[5:0] D[3]
load net xfer_state3[4] -attr @rip(#000000) O[4] -pin xfer_state2_i I0[4] -pin xfer_state3_i__0 O[4]
load net xfer_data[14] -attr @rip(#000000) 14 -port xfer_data[14] -pin xfer_data_reg[15:0] Q[14]
load net xfer_ptr[2] -attr @rip(#000000) 2 -pin buffer_reg RA1[2] -pin pause0_i I1[2] -pin xfer_ptr_reg[5:0] Q[2] -pin xfer_state3_i I0[2] -pin xfer_state3_i__0 I0[2]
load net end_ptr[3] -attr @rip(#000000) 3 -pin end_ptr_reg[7:0] Q[3] -pin xfer_state2_i I1[3]
load net wr_length0[6] -attr @rip(#000000) O[6] -pin wr_length0_i O[6] -pin wr_length_reg[8:0] D[6]
load net xfer_ptr_i_n_0 -pin xfer_ptr_i O -pin xfer_ptr_reg[5:0] CE
netloc xfer_ptr_i_n_0 1 8 1 2510
load net buffer_reg_n_0 -attr @rip(#000000) RO1[15] -pin buffer_reg RO1[15] -pin xfer_data_reg[15:0] D[15]
load net new_prior_i_n_0 -pin new_prior_i O -pin new_prior_i__0 I0
netloc new_prior_i_n_0 1 16 1 NJ
load net buffer_reg_n_1 -attr @rip(#000000) RO1[14] -pin buffer_reg RO1[14] -pin xfer_data_reg[15:0] D[14]
load net buffer_reg_n_2 -attr @rip(#000000) RO1[13] -pin buffer_reg RO1[13] -pin xfer_data_reg[15:0] D[13]
load net buffer_reg_n_3 -attr @rip(#000000) RO1[12] -pin buffer_reg RO1[12] -pin xfer_data_reg[15:0] D[12]
load net xfer_data[13] -attr @rip(#000000) 13 -port xfer_data[13] -pin xfer_data_reg[15:0] Q[13]
load net buffer_reg_n_4 -attr @rip(#000000) RO1[11] -pin buffer_reg RO1[11] -pin xfer_data_reg[15:0] D[11]
load net xfer_state3[3] -attr @rip(#000000) O[3] -pin xfer_state2_i I0[3] -pin xfer_state3_i__0 O[3]
load net buffer_reg_n_5 -attr @rip(#000000) RO1[10] -pin buffer_reg RO1[10] -pin xfer_data_reg[15:0] D[10]
load net wr_ptr0[4] -attr @rip(#000000) O[4] -pin wr_ptr0_i O[4] -pin wr_ptr_reg[5:0] D[4]
load net buffer_reg_n_6 -attr @rip(#000000) RO1[9] -pin buffer_reg RO1[9] -pin xfer_data_reg[15:0] D[9]
load net wr_length[0] -attr @rip(#000000) 0 -pin wr_length0_i I0[0] -pin wr_length_reg[8:0] Q[0] -pin wr_state2_i I0[0]
load net buffer_reg_n_7 -attr @rip(#000000) RO1[8] -pin buffer_reg RO1[8] -pin xfer_data_reg[15:0] D[8]
load net end_ptr[2] -attr @rip(#000000) 2 -pin end_ptr_reg[7:0] Q[2] -pin xfer_state2_i I1[2]
load net buffer_reg_n_8 -attr @rip(#000000) RO1[7] -pin buffer_reg RO1[7] -pin xfer_data_reg[15:0] D[7]
load netBundle @new_prior 3 new_prior[2] new_prior[1] new_prior[0] -autobundled
netbloc @new_prior 1 19 2 6390 1110 NJ
load netBundle @new_length 9 new_length[8] new_length[7] new_length[6] new_length[5] new_length[4] new_length[3] new_length[2] new_length[1] new_length[0] -autobundled
netbloc @new_length 1 2 19 590 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 6350 260 NJ
load netBundle @wr_length 9 wr_length[8] wr_length[7] wr_length[6] wr_length[5] wr_length[4] wr_length[3] wr_length[2] wr_length[1] wr_length[0] -autobundled
netbloc @wr_length 1 0 3 40 1320 280J 1370 550
load netBundle @end_ptr_i__1_n_0 8 end_ptr_i__1_n_0 end_ptr_i__1_n_1 end_ptr_i__1_n_2 end_ptr_i__1_n_3 end_ptr_i__1_n_4 end_ptr_i__1_n_5 end_ptr_i__1_n_6 end_ptr_i__1_n_7 -autobundled
netbloc @end_ptr_i__1_n_0 1 9 1 2920
load netBundle @wr_ptr0 6 wr_ptr0[5] wr_ptr0[4] wr_ptr0[3] wr_ptr0[2] wr_ptr0[1] wr_ptr0[0] -autobundled
netbloc @wr_ptr0 1 8 1 2470J
load netBundle @pause1 6 pause1[5] pause1[4] pause1[3] pause1[2] pause1[1] pause1[0] -autobundled
netbloc @pause1 1 18 1 NJ
load netBundle @buffer_reg_n_0,buffer_reg_n_1 16 buffer_reg_n_0 buffer_reg_n_1 buffer_reg_n_2 buffer_reg_n_3 buffer_reg_n_4 buffer_reg_n_5 buffer_reg_n_6 buffer_reg_n_7 buffer_reg_n_8 buffer_reg_n_9 buffer_reg_n_10 buffer_reg_n_11 buffer_reg_n_12 buffer_reg_n_13 buffer_reg_n_14 buffer_reg_n_15 -autobundled
netbloc @buffer_reg_n_0,buffer_reg_n_1 1 19 1 6410
load netBundle @xfer_data 16 xfer_data[15] xfer_data[14] xfer_data[13] xfer_data[12] xfer_data[11] xfer_data[10] xfer_data[9] xfer_data[8] xfer_data[7] xfer_data[6] xfer_data[5] xfer_data[4] xfer_data[3] xfer_data[2] xfer_data[1] xfer_data[0] -autobundled
netbloc @xfer_data 1 20 1 NJ
load netBundle @wr_state_i__2_n_0 3 wr_state_i__2_n_0 wr_state_i__2_n_1 wr_state_i__2_n_2 -autobundled
netbloc @wr_state_i__2_n_0 1 7 1 2130
load netBundle @xfer_state_i__2_n_0 2 xfer_state_i__2_n_0 xfer_state_i__2_n_1 -autobundled
netbloc @xfer_state_i__2_n_0 1 15 1 4810
load netBundle @xfer_state 2 xfer_state[1] xfer_state[0] -autobundled
netbloc @xfer_state 1 8 11 2470J 420 NJ 420 NJ 420 NJ 420 NJ 420 NJ 420 NJ 420 NJ 420 5100 N NJ 620 5910
load netBundle @wr_state_i__0_n_0 3 wr_state_i__0_n_0 wr_state_i__0_n_1 wr_state_i__0_n_2 -autobundled
netbloc @wr_state_i__0_n_0 1 5 1 1440
load netBundle @xfer_state_i__1_n_0 2 xfer_state_i__1_n_0 xfer_state_i__1_n_1 -autobundled
netbloc @xfer_state_i__1_n_0 1 14 1 4500
load netBundle @xfer_state_i__0_n_0 2 xfer_state_i__0_n_0 xfer_state_i__0_n_1 -autobundled
netbloc @xfer_state_i__0_n_0 1 13 1 4190
load netBundle @xfer_state3_i_n_0 6 xfer_state3_i_n_0 xfer_state3_i_n_1 xfer_state3_i_n_2 xfer_state3_i_n_3 xfer_state3_i_n_4 xfer_state3_i_n_5 -autobundled
netbloc @xfer_state3_i_n_0 1 8 4 2510 590 2800J 570 3230 880 NJ
load netBundle @wr_ptr 6 wr_ptr[5] wr_ptr[4] wr_ptr[3] wr_ptr[2] wr_ptr[1] wr_ptr[0] -autobundled
netbloc @wr_ptr 1 7 12 2170 950 NJ 950 2860 910 3250 910 3500 940 NJ 940 NJ 940 NJ 940 NJ 940 NJ 940 5540 1190 NJ
load netBundle @cur_prior 3 cur_prior[2] cur_prior[1] cur_prior[0] -autobundled
netbloc @cur_prior 1 20 1 NJ
load netBundle @cur_dest_port 4 cur_dest_port[3] cur_dest_port[2] cur_dest_port[1] cur_dest_port[0] -autobundled
netbloc @cur_dest_port 1 20 1 NJ
load netBundle @wr_data 16 wr_data[15] wr_data[14] wr_data[13] wr_data[12] wr_data[11] wr_data[10] wr_data[9] wr_data[8] wr_data[7] wr_data[6] wr_data[5] wr_data[4] wr_data[3] wr_data[2] wr_data[1] wr_data[0] -autobundled
netbloc @wr_data 1 0 19 NJ 250 NJ 250 NJ 250 NJ 250 NJ 250 NJ 250 NJ 250 NJ 250 NJ 250 NJ 250 NJ 250 NJ 250 NJ 250 NJ 250 NJ 250 NJ 250 NJ 250 NJ 250 5850
load netBundle @wr_state_i_n_0,wr_state_i_n_1 4 wr_state_i_n_0 wr_state_i_n_1 wr_state_i_n_2 wr_state_i_n_3 -autobundled
netbloc @wr_state_i_n_0,wr_state_i_n_1 1 3 3 920 1260 1140 1260 1480
load netBundle @wr_state_i__1_n_0 3 wr_state_i__1_n_0 wr_state_i__1_n_1 wr_state_i__1_n_2 -autobundled
netbloc @wr_state_i__1_n_0 1 6 1 1800
load netBundle @wr_state 3 wr_state[2] wr_state[1] wr_state[0] -autobundled
netbloc @wr_state 1 0 16 20 1440 NJ 1440 570 N NJ 1380 NJ 1380 NJ 1380 NJ 1380 NJ 1380 2510 1250 NJ 1250 NJ 1250 NJ 1250 NJ 1250 NJ 1250 NJ 1250 4810
load netBundle @xfer_ptr 6 xfer_ptr[5] xfer_ptr[4] xfer_ptr[3] xfer_ptr[2] xfer_ptr[1] xfer_ptr[0] -autobundled
netbloc @xfer_ptr 1 9 10 2880 960 NJ 960 NJ 960 NJ 960 NJ 960 NJ 960 NJ 960 NJ 960 NJ 960 5970
load netBundle @xfer_state3 7 xfer_state3[6] xfer_state3[5] xfer_state3[4] xfer_state3[3] xfer_state3[2] xfer_state3[1] xfer_state3[0] -autobundled
netbloc @xfer_state3 1 10 1 3190J
load netBundle @new_dest_port 4 new_dest_port[3] new_dest_port[2] new_dest_port[1] new_dest_port[0] -autobundled
netbloc @new_dest_port 1 19 2 6390 380 NJ
load netBundle @cur_length 9 cur_length[8] cur_length[7] cur_length[6] cur_length[5] cur_length[4] cur_length[3] cur_length[2] cur_length[1] cur_length[0] -autobundled
netbloc @cur_length 1 20 1 NJ
load netBundle @end_ptr 8 end_ptr[7] end_ptr[6] end_ptr[5] end_ptr[4] end_ptr[3] end_ptr[2] end_ptr[1] end_ptr[0] -autobundled
netbloc @end_ptr 1 10 1 3210
load netBundle @xfer_state_i_n_0,p_0_in 3 xfer_state_i_n_0 p_0_in xfer_state_i_n_2 -autobundled
netbloc @xfer_state_i_n_0,p_0_in 1 11 7 3540 830 3810 780 NJ 780 NJ 780 NJ 780 NJ 780 5440
load netBundle @wr_length0 9 wr_length0[8] wr_length0[7] wr_length0[6] wr_length0[5] wr_length0[4] wr_length0[3] wr_length0[2] wr_length0[1] wr_length0[0] -autobundled
netbloc @wr_length0 1 1 1 300
levelinfo -pg 1 0 130 360 770 970 1300 1640 1980 2290 2630 3010 3320 3610 3980 4370 4680 4890 5310 5680 6090 6470 6680 -top 0 -bot 1520
show
zoom 0.258051
scrollpos -211 -349
#
# initialize ictrl to current module port_wr_frontend work:port_wr_frontend:NOFILE
ictrl init topinfo |
