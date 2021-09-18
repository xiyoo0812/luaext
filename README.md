# luaext
若干lua扩展库集合。

# 依赖
- [lua](https://github.com/xiyoo0812/lua.git)5.2以上

# 编译
- msvc : 准备好lua依赖库并放到指定位置，将proj文件加到sln后编译。
- linux：准备好lua依赖库并放到指定位置，执行make -f lualog.mak

# 工程
- 本项目使用[lmake](https://github.com/xiyoo0812/lmake.git)管理
- 根目录配置lmake
```lua
--lmake
--工程名
SOLUTION = "luaext"
--lmake目录
LMAKE_DIR = "../lmake"
--mimalloc
USE_MIMALLOC = false
```shell
- 子项目配置*.lmake
- 执行以下指令自动生成项目文件(makefile/vcxproj)
```
# lmake_dir: lmake项目路径
# solution_dir: 工程根目录
./lua lmake_dir/lmake.lua solution_dir
```

# 扩展库
- lua
- pbc
- lpeg
- bson
- lnet
- mongo
- lhttp
- lcurl
- lstdfs
- lcjson
- lshare
- lcrypt
- lualog
- lbuffer
- lusxlsx
