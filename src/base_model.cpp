// Copyright 2017 Makerbot Industries

#include "base_model.h"

#include <iostream>

#include <QMetaObject>
#include <QMetaProperty>

void BaseModel::reset() {
    const QMetaObject *metaobject = metaObject();
    int count = metaobject->propertyCount();
    for (int i = 0; i < count; ++i) {
        metaobject->property(i).reset(this);
    }
}
