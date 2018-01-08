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


#define UPDATE_STRING_ARRAY_PROP(PROP, JSON_VAL) \
    { \
        QStringList qt_dns_list; \
        if(JSON_VAL.isArray()){ \
            const Json::Value dns_list = JSON_VAL; \
            for(Json::Value::const_iterator it = dns_list.begin() ; it != dns_list.end(); ++it) { \
                /* '*it' has the type 'const Json::Value' */ \
                if((*it).isString()) { \
                    qt_dns_list.push_back((*it).asString().c_str()); \
                } \
            } \
        } \
        if(qt_dns_list.size() > 0) { \
            PROP ## Set(qt_dns_list); \
        } \
        else { \
            PROP ## Reset(); \
        } \
    }

#define UPDATE_INT_PROP(PROP, JSON_VAL) \
    { \
        const Json::Value & json_val = JSON_VAL; \
        if(json_val.isInt()) \
            PROP ## Set(json_val.asInt()); \
        else \
            PROP ## Reset(); \
    }

#define UPDATE_FLOAT_PROP(PROP, JSON_VAL) \
    { \
        const Json::Value & json_val = JSON_VAL; \
        if(json_val.isDouble()) \
            PROP ## Set(json_val.asDouble()); \
        else \
            PROP ## Reset(); \
    }

#endif  // _SRC_IMPL_UTIL_H

