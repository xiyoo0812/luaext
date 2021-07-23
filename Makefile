empty:
	@echo "====No target! Please specify a target to make!"
	@echo "====If you want to compile all targets, use 'make core' && 'make server'"
	@echo "===='make all', which shoule be the default target is unavailable for UNKNOWN reaseon now."
	@echo "====server is composed of dbx,session,gate,name and world. You can only compile the module you need."

CUR_DIR = $(shell pwd)/

.PHONY: clean lua ext proj

all: clean lua ext

proj: lua ext

clean:
	rm -rf temp;

lua:
	cd lua; make SOLUTION_DIR=$(CUR_DIR) -f lualib.mak;
	cd lua; make SOLUTION_DIR=$(CUR_DIR) -f luac.mak;
	cd lua; make SOLUTION_DIR=$(CUR_DIR) -f lua.mak;

ext:
	cd lfs; make SOLUTION_DIR=$(CUR_DIR) -f lfs.mak;
	cd pbc; make SOLUTION_DIR=$(CUR_DIR) -f pbc.mak;
	cd bson; make SOLUTION_DIR=$(CUR_DIR) -f bson.mak;
	cd lpeg; make SOLUTION_DIR=$(CUR_DIR) -f lpeg.mak;
	cd lnet; make SOLUTION_DIR=$(CUR_DIR) -f lnet.mak;
	cd mongo; make SOLUTION_DIR=$(CUR_DIR) -f mongo.mak;
	cd lcrypt; make SOLUTION_DIR=$(CUR_DIR) -f lcrypt.mak;
	cd luacjson; make SOLUTION_DIR=$(CUR_DIR) -f luacjson.mak;
	cd lualog; make SOLUTION_DIR=$(CUR_DIR) -f lualog.mak;
	cd luaxlsx; make SOLUTION_DIR=$(CUR_DIR) -f luaxlsx.mak;
	cd luahttp; make SOLUTION_DIR=$(CUR_DIR) -f luahttp.mak;
