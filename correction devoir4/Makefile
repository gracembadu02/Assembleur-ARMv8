AS = as
LD = ld


normal:	tp4.o
	@echo
	@echo ------------------
	@echo Edition des liens
	@echo ------------------
	@echo

	$(LD) -e Main tp4.o -o tp4 -lc



tp4.o: tp4.as
	@echo
	@echo ---------------------------------------------
	@echo Compilation programme principal, tp4.as
	@echo ---------------------------------------------
	@echo

	$(AS) -gstabs tp4.as -o tp4.o



trap:	tp4trap.o
	@echo
	@echo ------------------
	@echo Edition des liens
	@echo ------------------
	@echo

	$(LD) -e Main tp4trap.o -o tp4trap 



tp4trap.o: tp4trap.as
	@echo
	@echo ---------------------------------------------
	@echo Compilation programme principal, tp4trap.as
	@echo ---------------------------------------------
	@echo

	$(AS) -gstabs tp4trap.as -o tp4trap.o
