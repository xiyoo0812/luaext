#工程名字
PROJECT_NAME = lualib

#目标名字
TARGET_NAME = lua

#系统环境
UNAME_S = $(shell uname -s)

#伪目标
.PHONY: clean all target pre_build post_build
all : pre_build target post_build

#FLAG
MYCFLAGS =

#需要定义的FLAG


#标准库版本
#gnu99/c++11/c++14/c++17/c++20
MYCFLAGS += -std=gnu99

#需要的include目录
MYCFLAGS += -I./lua

#需要定义的选项
LDFLAGS =
ifeq ($(UNAME_S), Linux)
LDFLAGS += -DLUA_USE_LINUX
endif
ifeq ($(UNAME_S), Darwin)
LDFLAGS += -DLUA_USE_MACOSX
endif

#需要附件link库目录

#源文件路径
SRC_DIR = lua

#需要排除的源文件,目录基于$(SRC_DIR)
EXCLUDE =

#需要连接的库文件
LIBS =
#是否启用mimalloc库
LIBS += -lmimalloc -lpthread
MYCFLAGS += -I../../mimalloc/mimalloc/include -include ../../mimalloc-ex.h
#系统库
LIBS += -lm -ldl -lstdc++
#自定义库

#定义基础的编译选项
CC = gcc
CX = c++
CFLAGS = -g -O2 -Wall -Wno-deprecated -Wextra -Wno-unknown-pragmas $(MYCFLAGS)
CXXFLAGS = -g -O2 -Wall -Wno-deprecated -Wextra -Wno-unknown-pragmas $(MYCFLAGS)

#项目目录
ifndef SOLUTION_DIR
SOLUTION_DIR=./
endif

#临时文件目录
INT_DIR = $(SOLUTION_DIR)temp/$(PROJECT_NAME)

#目标文件前缀，定义则.so和.a加lib前缀，否则不加
PROJECT_PREFIX = lib

#目标定义
MYCFLAGS += -fPIC
TARGET_DIR = $(SOLUTION_DIR)bin
TARGET_DYNAMIC =  $(TARGET_DIR)/$(PROJECT_PREFIX)$(TARGET_NAME).so
#macos系统so链接问题
ifeq ($(UNAME_S), Darwin)
LDFLAGS += -install_name $(PROJECT_PREFIX)$(TARGET_NAME).so
endif

#link添加.so目录
LDFLAGS += -L$(TARGET_DIR)

#自动生成目标
OBJS =
COBJS = $(patsubst %.c, $(INT_DIR)/%.o, onelua.c)
MOBJS = $(patsubst %.m, $(INT_DIR)/%.o, $(COBJS))
CCOBJS = $(patsubst %.cc, $(INT_DIR)/%.o, $(MOBJS))
OBJS = $(patsubst %.cpp, $(INT_DIR)/%.o, $(CCOBJS))

$(TARGET_STATIC) : $(OBJS)
	ar rcs $@ $(OBJS)
	ranlib $@

$(TARGET_DYNAMIC) : $(OBJS)
	$(CC) -o $@ -shared $(OBJS) $(LDFLAGS) $(LIBS) 

$(TARGET_EXECUTE) : $(OBJS)
	$(CC) -o $@  $(OBJS) $(LDFLAGS) $(LIBS) 

# 编译所有源文件
$(INT_DIR)/%.o : $(SRC_DIR)/%.cpp
	$(CX) $(CXXFLAGS) -c $< -o $@
$(INT_DIR)/%.o : $(SRC_DIR)/%.cc
	$(CX) $(CXXFLAGS) -c $< -o $@
$(INT_DIR)/%.o : $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@
$(INT_DIR)/%.o : $(SRC_DIR)/%.m
	$(CC) $(CFLAGS) -c $< -o $@

#target伪目标
target : $(TARGET_DYNAMIC)

#clean伪目标
clean : 
	rm -rf $(INT_DIR)

#预编译
pre_build:
	mkdir -p $(INT_DIR)
	mkdir -p $(TARGET_DIR)

#后编译
post_build:
