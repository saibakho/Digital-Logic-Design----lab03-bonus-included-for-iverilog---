HEAD	= header.v
VLOG	= iverilog
SRC		= Cost.v \
		  Cost_tb.v \
		  ALU.v
SRC_syn	= Cost_syn.v \
		  Cost_tb.v \
		  -v /theda21_2/CBDK_IC_Contest/cur/Verilog/tsmc13.v
SDF		= +define+SDF
TMPFILE	= *.log \
		  INCA_libs
RM		= -rm -rf
VLOGARG	= +access+r
RUN		= vvp
OUT		= cost.out

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