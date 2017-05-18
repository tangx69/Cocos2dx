/*
** Copyright (C) 2012-2014 Arseny Vakhrushev <arseny.vakhrushev at gmail dot com>
** Please read the LICENSE file for license details
*/

#ifndef luacjson_h
#define luacjson_h

#ifndef _WIN32
#ifdef __cplusplus
extern "C" {
#include <lua.h>
#else
#include <lua.h>
#endif
#endif

int luaopen_cjson(lua_State *l);
int luaopen_cjson_safe(lua_State *l);

#ifndef _WIN32
#ifdef __cplusplus
}
#endif
#endif

#endif
