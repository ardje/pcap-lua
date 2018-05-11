# Linux
CC = gcc
LDFLAGS = -fPIC -fno-common -shared
LUA = lua5.3
CLUA=$(shell pkg-config --cflags ${LUA})
LLUA=$(shell pkg-config --libs ${LUA})

