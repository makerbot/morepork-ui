// Copyright 2017 Makerbot Industries

#include <QMetaProperty>
#include <QVariant>
#include <QMetaEnum>
#include <QDebug>

#include "process_model.h"
#include "../error_utils.h"

ProcessModel::ProcessModel() {
    reset();
}

void ProcessModel::enumToQVariantMap(){
    qDebug() << FL_STRM << "called";
    const QMetaObject *kThisMetaObj = this->metaObject();
    int kPropCount = kThisMetaObj->propertyCount();
    for (int i = kThisMetaObj->propertyOffset(); i < kPropCount; ++i) {
        QMetaProperty meta_prop = kThisMetaObj->property(i);
        if (meta_prop.type() == QVariant::Int && meta_prop.isEnumType()) {
            qDebug() << FL_STRM << "prop: name =" << meta_prop.name()
                                << ", type =" << meta_prop.typeName();
            if(!enum_map_.contains(meta_prop.typeName())){
                QVariantMap enum_var_map;
                const QMetaEnum & kMetaEnum = meta_prop.enumerator();
                for (int i = 0; i < kMetaEnum.keyCount(); ++i){
                    qDebug() << FL_STRM << kMetaEnum.key(i) << "=" << kMetaEnum.value(i);
                    enum_var_map.value(kMetaEnum.key(i), QVariant(kMetaEnum.value(i)));
                }
                enum_map_.insert(meta_prop.typeName(), enum_var_map);
            }
        }
    }
    if(enum_map_.size() > 0)
        enumMapSet(enum_map_);
}

