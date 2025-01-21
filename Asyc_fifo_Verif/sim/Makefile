TOP     = top
SEED    = 1
export TOP_LEVEL = $(TOP)
C_PATH	= ./case_001
VCOMP   = vcs -full64 -sverilog -timescale=1ps/1ps -l comp.log +v2k -debug_acc+dmptf -debug_region+cell+encrypt
COPTS   = -cm line+cond+fsm+tgl+branch -cm_dir $(C_PATH)
ELAB    = vcs -full64 $(COPTS) -debug_access+all -l elab.log -sim_res=1ps -sverilog -f file.f -f tb.f -kdb -o $(TOP).simv
RUN     = ./$(TOP).simv	-l run.log ntb_random_seed=$(SEED) $(COPTS) &
RUNG	= ./$(TOP).simv	-gui -l run.log ntb_random_seed=$(SEED) $(COPTS) &
default : comp elab run

comp:
	$(VCOMP) -f file.f -f tb.f
elab:
	$(ELAB) -top $(TOP)
run:
	./$(RUN)
rung:
	./$(RUNG)

verdi:
	verdi -dbdir $(TOP).simv.daidir -ssf $(TOP).fsdb &
cov:
	dve -full64 -cov -dir top.simv.vdb &
report:
	urg -full64 -dir top.simv.vdb -report covReport -format both
merge:
	urg -full64 -dir *.vdb -dbname merge.vdb
clean:
	\rm -rf *.log
	\rm -rf AN.DB
	\rm -rf *simv*
	\rm -rf DVEfiles
	\rm -rf csrc
	\rm -rf *vpd
	\rm -rf ucli.key
	\rm -rf vc_hdrs.h
	\rm -rf 64

all: clean comp elab run