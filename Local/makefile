HEAD	= header.v
VLOG	= iverilog
SRC		= VIP.v \
		  VIP_tb.v \
		  ALU.v
SRC_syn	= VIP_syn.v \
		  VIP_tb.v \
		  -v /theda21_2/CBDK_IC_Contest/cur/Verilog/tsmc13.v
SDF		= +define+SDF
TMPFILE	= *.log \
		  INCA_libs
RM		= -rm -rf
VLOGARG	= +access+r
RUN		= vvp
OUT		= vip.out

all :: sim
sim :
	$(VLOG) -o $(OUT) $(HEAD) $(SRC)
	$(RUN) $(OUT)
syn :
	$(VLOG) $(HEAD) $(SRC_syn) $(SDF) $(VLOGARG)
check :
	$(VLOG) -c $(SRC)
clean :
	$(RM) $(TMPFILE)