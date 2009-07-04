_pwd := $(pwd)

include $(make-common.dir)/tool/cc.mk
include $(make-common.dir)/tool/cp.mk
include $(make-common.dir)/tool/lua.mk
include $(make-common.dir)/layout.mk

######################################################################

_lib  := $(lib.dir)/liblua.so
_objs := $(call cc.c.to.o,$(addprefix $(_pwd)/src/, \
	lapi.c lcode.c ldebug.c ldo.c ldump.c lfunc.c lgc.c llex.c lmem.c \
	lobject.c lopcodes.c lparser.c lstate.c lstring.c ltable.c ltm.c  \
	lundump.c lvm.c lzio.c \
	lauxlib.c lbaselib.c ldblib.c liolib.c lmathlib.c loslib.c ltablib.c \
	lstrlib.c loadlib.c linit.c \
))

all: | $(_lib)
$(_lib): cc.objs := $(_objs)
$(_lib): cc.macro.flags += -DLUA_USE_LINUX
$(_lib): $(_objs)
	$(cc.so.rule)

######################################################################

_app  := $(bin.dir)/lua
_objs := $(call cc.c.to.o,$(addprefix $(_pwd)/src/, \
	lua.c \
))

all: | $(_app)
$(_app): cc.libs += lua
$(_app): cc.objs := $(_objs)
$(_app): $(_objs)
	$(cc.exe.rule)

######################################################################

_app  := $(bin.dir)/luac
_objs := $(call cc.c.to.o,$(addprefix $(_pwd)/src/, \
	luac.c print.c \
))

all: | $(_app)
$(_app): cc.libs += lua
$(_app): cc.objs := $(_objs)
$(_app): $(_objs)
	$(cc.exe.rule)

######################################################################
# Export headers:
$(include.dir)/%.h: $(_pwd)/src/%.h
	$(cp.rule)

all: $(addprefix $(include.dir)/,lua.h luaconf.h lualib.h lauxlib.h)

######################################################################
# How to run the tests:
.PHONY: lua.test
test: | lua.test

lua ?= lua
lua.test: | $(bin.dir)/lua
#lua.test: lua.path += $(_pwd)
lua.test: $(wildcard $(_pwd)/test/*.lua)
	@mkdir -p $(tmp.dir)
	cd $(tmp.dir); exit=0; for t in $^; do \
		echo "TESTING: $$t"; \
		env -i $(lua.run) $(lua) $$t || exit=$$?; \
	done; exit $$exit
