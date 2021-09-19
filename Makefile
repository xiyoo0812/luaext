empty:
	@echo "====No target! Please specify a target to make!"
	@echo "====If you want to compile all targets, use 'make server'"
	@echo "===='make all', which shoule be the default target is unavailable for UNKNOWN reaseon now."

CUR_DIR = $(shell pwd)/

.PHONY: clean all server  lua luaext

all: clean server 

server:  lua luaext

clean:
	rm -rf temp;

lua:
	cd lua; make SOLUTION_DIR=$(CUR_DIR) -f lualib.mak;
	cd lua; make SOLUTION_DIR=$(CUR_DIR) -f lua.mak;
	cd lua; make SOLUTION_DIR=$(CUR_DIR) -f luac.mak;

luaext:
	cd bson; make SOLUTION_DIR=$(CUR_DIR) -f bson.mak;
	cd lbuffer; make SOLUTION_DIR=$(CUR_DIR) -f lbuffer.mak;
	cd lcjson; make SOLUTION_DIR=$(CUR_DIR) -f lcjson.mak;
	cd lcrypt; make SOLUTION_DIR=$(CUR_DIR) -f lcrypt.mak;
	cd lcurl; make SOLUTION_DIR=$(CUR_DIR) -f lcurl.mak;
	cd lhttp; make SOLUTION_DIR=$(CUR_DIR) -f lhttp.mak;
	cd lnet; make SOLUTION_DIR=$(CUR_DIR) -f lnet.mak;
	cd lpeg; make SOLUTION_DIR=$(CUR_DIR) -f lpeg.mak;
	cd lstdfs; make SOLUTION_DIR=$(CUR_DIR) -f lstdfs.mak;
	cd ltimer; make SOLUTION_DIR=$(CUR_DIR) -f ltimer.mak;
	cd lualog; make SOLUTION_DIR=$(CUR_DIR) -f lualog.mak;
	cd luaxlsx; make SOLUTION_DIR=$(CUR_DIR) -f luaxlsx.mak;
	cd mongo; make SOLUTION_DIR=$(CUR_DIR) -f mongo.mak;
	cd pbc; make SOLUTION_DIR=$(CUR_DIR) -f pbc.mak;

