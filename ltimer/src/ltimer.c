#include <string.h>
#include <stdlib.h>
#include <stdint.h>

#include <lua.h>
#include <lauxlib.h>

#define TIME_NEAR_SHIFT 8
#define TIME_NEAR (1 << TIME_NEAR_SHIFT)
#define TIME_LEVEL_SHIFT 6
#define TIME_LEVEL (1 << TIME_LEVEL_SHIFT)
#define TIME_NEAR_MASK (TIME_NEAR-1)
#define TIME_LEVEL_MASK (TIME_LEVEL-1)

struct timer_node {
    struct timer_node* next;
    uint32_t expire;
    uint64_t timer_id;
};

struct link_list {
    struct timer_node head;
    struct timer_node* tail;
};

struct timer {
    uint32_t time;
    struct link_list near[TIME_NEAR];
    struct link_list t[4][TIME_LEVEL];
};

static inline struct timer_node* link_clear(struct link_list* list) {
    struct timer_node* ret = list->head.next;
    list->head.next = 0;
    list->tail = &(list->head);
    return ret;
}

static inline void link(struct link_list* list, struct timer_node* node) {
    list->tail->next = node;
    list->tail = node;
    node->next = 0;
}

static void add_node(struct timer* T, struct timer_node* node) {
    uint32_t time = node->expire;
    uint32_t current_time = T->time;
    if ((time | TIME_NEAR_MASK) == (current_time | TIME_NEAR_MASK)) {
        link(&T->near[time & TIME_NEAR_MASK], node);
    }
    else {
        int i;
        uint32_t mask = TIME_NEAR << TIME_LEVEL_SHIFT;
        for (i = 0; i < 3; i++) {
            if ((time | (mask - 1)) == (current_time | (mask - 1))) {
                break;
            }
            mask <<= TIME_LEVEL_SHIFT;
        }
        link(&T->t[i][((time >> (TIME_NEAR_SHIFT + i * TIME_LEVEL_SHIFT)) & TIME_LEVEL_MASK)], node);
    }
}

static void timer_add(struct timer* T, uint64_t timer_id, int time) {
    struct timer_node* node = (struct timer_node*)malloc(sizeof(*node));
    if (time < 0)
        time = 0;
    node->timer_id = timer_id;
    node->expire = time + T->time;
    add_node(T, node);
}

static void move_list(struct timer* T, int level, int idx) {
    struct timer_node* current = link_clear(&T->t[level][idx]);
    while (current) {
        struct timer_node* temp = current->next;
        add_node(T, current);
        current = temp;
    }
}

static void timer_shift(struct timer* T) {
    int mask = TIME_NEAR;
    uint32_t ct = ++T->time;
    if (ct == 0) {
        move_list(T, 3, 0);
    }
    else {
        int i = 0;
        uint32_t time = ct >> TIME_NEAR_SHIFT;
        while ((ct & (mask - 1)) == 0) {
            int idx = time & TIME_LEVEL_MASK;
            if (idx != 0) {
                move_list(T, i, idx);
                break;
            }
            mask <<= TIME_LEVEL_SHIFT;
            time >>= TIME_LEVEL_SHIFT;
            ++i;
        }
    }
}

static void
timer_init(struct timer* r) {
    int i, j;
    memset(r, 0, sizeof(*r));
    for (i = 0; i < TIME_NEAR; i++) {
        link_clear(&r->near[i]);
    }
    for (i = 0; i < 4; i++) {
        for (j = 0; j < TIME_LEVEL; j++) {
            link_clear(&r->t[i][j]);
        }
    }
}

static inline void link_free(struct link_list* list) {
    struct timer_node* current = link_clear(list);
    while (current) {
        struct timer_node* temp = current;
        current = current->next;
        free(temp);
    }
    link_clear(list);
}

static void timer_destory(struct timer* T) {
    int i, j;
    for (i = 0; i < TIME_NEAR; i++) {
        link_free(&T->near[i]);
    }
    for (i = 0; i < 4; i++) {
        for (j = 0; j < TIME_LEVEL; j++) {
            link_free(&T->t[i][j]);
        }
    }
}

static int lcreate(lua_State* L) {
    struct timer* t = lua_newuserdata(L, sizeof(struct timer));
    timer_init(t);
    return 1;
}

static int lclose(lua_State* L) {
    struct timer* t = lua_touserdata(L, 1);
    timer_destory(t);
    return 0;
}

static int linsert(lua_State* L) {
    struct timer* T = lua_touserdata(L, 1);
    uint64_t timer_id = luaL_checkinteger(L, 2);
    int time = luaL_checkinteger(L, 3);
    timer_add(T, timer_id, time);
    return 0;
}

static inline void dispatch_list(lua_State* L, struct timer_node* current, int* n) {
    do {
        struct timer_node* temp = current;
        current = current->next;
        // todo: if rawseti raise (memory) error, cause memory leak
        ++ *n;
        lua_pushinteger(L, temp->timer_id);
        lua_rawseti(L, -2, *n);

        free(temp);
    } while (current);
}

static void timer_execute(lua_State* L, struct timer* T, int* n) {
    int idx = T->time & TIME_NEAR_MASK;
    while (T->near[idx].head.next) {
        struct timer_node* current = link_clear(&T->near[idx]);
        dispatch_list(L, current, n);
    }
}

static int lupdate(lua_State* L) {
    struct timer* T = lua_touserdata(L, 1);
    int elapse = luaL_checkinteger(L, 2);
    luaL_checktype(L, 3, LUA_TTABLE);
    lua_settop(L, 3);

    // try to dispatch timeout 0 (rare condition)
    int n = 0;
    timer_execute(L, T, &n);
    for (int i = 0; i < elapse; i++) {
        // shift time first, and then dispatch timer message
        timer_shift(T);
        timer_execute(L, T, &n);
    }
    return 0;
}

#ifdef _MSC_VER
#define LTIMER_API _declspec(dllexport)
#else
#define LTIMER_API extern
#endif

LTIMER_API int luaopen_ltimer(lua_State* L) {
    luaL_checkversion(L);
    luaL_Reg l[] = {
        { "create", lcreate },
        { "close", lclose },
        { "insert" , linsert },
        { "update", lupdate },
        { NULL, NULL },
    };
    luaL_newlib(L, l);
    return 1;
}
