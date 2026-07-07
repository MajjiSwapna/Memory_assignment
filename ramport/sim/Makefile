# ==================================================
# Simple Makefile for Single port RAM TB
# ==================================================

TOP      = tb_ramport
RTL_DIR  = ../RTL
TB_DIR   = ../TB

COV_DIR  = coverage
MERGED   = $(COV_DIR)/merged.ucdb
HTMLDIR  = $(COV_DIR)/html_report

TEST ?= TC7
SEED ?= 1

TESTS = TC1 TC2 TC3 TC4 TC5 TC6 TC7

.PHONY: all compile run clean merge report regress

#---------------------------------------------------
# COMPLETE FLOW
#---------------------------------------------------

all: clean compile run merge report regress

# --------------------------------------------------
# Compile RTL + TB
# --------------------------------------------------
compile:
	vlib work
	vmap work work
	vlog -sv -cover bcst $(RTL_DIR)/ramport.sv $(TB_DIR)/sampleram.sv  # make run TEST
# --------------------------------------------------
run:
	mkdir -p coverage
	vsim -c -coverage -assertdebug -voptargs=+acc \
	-onfinish stop $(TOP) \
	+TEST=$(TEST) \
	-do "run -all; \
	coverage save -assert -directive -cvg -codeAll coverage/$(TEST).ucdb; \
	quit"

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

	@if command -v microsoft-edge >/dev/null 2>&1; then \
		microsoft-edge $(HTMLDIR)/index.html >/dev/null 2>&1 & \
	elif command -v microsoft-edge-stable >/dev/null 2>&1; then \
		microsoft-edge-stable $(HTMLDIR)/index.html >/dev/null 2>&1 & \
	elif command -v firefox >/dev/null 2>&1; then \
		firefox $(HTMLDIR)/index.html >/dev/null 2>&1 & \
	else \
		echo "Coverage report generated at $(HTMLDIR)/index.html"; \
         fi

# --------------------------------------------------
# Run full regression (manual loop)
# --------------------------------------------------
regress:
	for t in $(TESTS); do \
		$(MAKE) run TEST=$$t; \
	done
	$(MAKE) merge
	$(MAKE) report
# --------------------------------------------------
# Clean
# --------------------------------------------------
clean:
	rm -rf work transcript vsim.wlf coverage modelsim.ini coverage

