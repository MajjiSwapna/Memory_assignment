# ==================================================
# Simple Makefile for Memory TB
# ==================================================

TOP      = tb_m_bank
RTL_DIR  = para_m_bank.sv
TB_DIR   = tb_m_bank.sv

COV_DIR  = coverage
MERGED   = $(COV_DIR)/merged.ucdb
HTMLDIR  = $(COV_DIR)/html_report

SEED ?= 1

.PHONY: compile run clean merge report

# --------------------------------------------------
# Compile RTL + TB
# --------------------------------------------------
compile:
	vlib work
	vlog -cover bcefst $(RTL_DIR)
	vlog -sv -cover bcefst $(TB_DIR)

# --------------------------------------------------
# make run TEST
# --------------------------------------------------

run:
	mkdir -p coverage
	vsim -c -coverage work.$(TOP) -sv_seed $(SEED)  \
	-onfinish stop \
	-do "run -all; coverage save $(COV_DIR)/seed_$(SEED).ucdb; quit -f"

#sim -c -coverage -assertdebug -voptargs=+acc \
-onfinish stop $(TOP) \
+$(TEST) \
+SEED=$(SEED) \
-do "run -all; \
coverage save -assert -directive -cvg -codeAll coverage/$(TEST).ucdb; \
quit"##
# --------------------------------------------------
# Merge all UCDB files
# --------------------------------------------------

merge:
	vcover merge $(MERGED) $(filter-out $(MERGED),$(wildcard $(COV_DIR)/*.ucdb))

# --------------------------------------------------
# Generate HTML report
# --------------------------------------------------

report:
	mkdir -p $(HTMLDIR)
	vcover report \
	-html \
	-output $(HTMLDIR) \
	-details \
	-assert \
	-directive \
	-cvg \
	-code bcefst \
	-threshL 50 \
	-threshH 90 \
	$(MERGED)

# --------------------------------------------------
# Run full regression (manual loop)
# --------------------------------------------------

##regress:
#	for t in $(TEST); do \
		$(MAKE) run TEST=$$t; \
	done
#	$(MAKE) merge
#	$(MAKE) report
# --------------------------------------------------
# Clean
# --------------------------------------------------

clean:
	rm -rf work transcript vsim.wlf coverage modelsim.ini coverage
