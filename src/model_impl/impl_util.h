// Copyright 2017 Makerbot Industries

// General helpers for converting the json types we get from jsonrpc to the
// types required by our model.

#ifndef _SRC_IMPL_UTIL_H
#define _SRC_IMPL_UTIL_H

#include <mbcoreutils/jsoncpp_wrappers.h>

// Helper macros to update model properties based on json values.
// If the json value is of the right type we update otherwise we
// reset to default.
#define UPDATE_STRING_PROP(PROP, JSON_VAL) \
    do { \
        auto v = (JSON_VAL); \
        if (v.isString()) { \
            PROP ## Set(v.asString().c_str()); \
        } else { \
            PROP ## Reset(); \
        } \
    } while (0)

#endif  // _SRC_IMPL_UTIL_H

