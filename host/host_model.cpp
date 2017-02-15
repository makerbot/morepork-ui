// Copyright 2017 Makerbot Industries

#include "host_model.h"

#include <iostream>

#include <QMetaProperty>
#include <QVariant>
#include <QMetaEnum>

// Note that this assumes that we are not explicitly assigning values
// to any of our enums, so that the index always equals the value.
QVariantList getEnumList(const QMetaEnum & e) {
    QVariantList names;
    for (int i = 0; i < e.keyCount(); ++i) {
        if (e.value(i) != i) {
            std::cerr << e.scope() << "::" << e.name() << "::" << e.key(i)
                      << " has index " << i << " but value " << e.value(i)
                      << std::endl;
        }
        names.append(e.key(i));
    }
    return std::move(names);
}

// Fill the metaInfo property of this model and all submodels with
// all that PropsView.qml expects to know about each leaf property:
//  - The property name (prop)
//  - Which widget to use to set the value (chooser)
//  - Additional type info specific to the chooser.
void scanProperties(BaseModel * model) {
    const QMetaObject *metaobject = model->metaObject();
    int count = metaobject->propertyCount();
    QVariantList properties;
    for (int i = metaobject->propertyOffset(); i < count; ++i) {
        auto prop = metaobject->property(i);
        QVariantMap prop_info({{"prop", prop.name()}});

        switch (prop.type()) {
          case QVariant::Int:
          case QVariant::UInt:
          case QVariant::Double:
            if (prop.isEnumType()) {
                prop_info["chooser"] = "combo";
                prop_info["combo"] = getEnumList(prop.enumerator());
            } else {
                prop_info["chooser"] = "text";
                prop_info["text_fn"] = "Number";
            }
            break;
          case QVariant::String:
            prop_info["chooser"] = "text";
            prop_info["text_fn"] = "String";
            break;
          case QVariant::Bool:
            prop_info["chooser"] = "check";
            break;
          case QVariant::UserType: {
            // Explicitly check for a submodel
            auto val = prop.read(model);
            BaseModel * submodel = val.value<BaseModel *>();
            if (submodel) {
                scanProperties(submodel);
                continue;
            }
            break;
          }
          default:
            break;
        }

        properties.append(prop_info);
    }
    model->setProperty("metaInfo", properties);
}

BotModel * makeHostBotModel() {
    QScopedPointer<BotModel> model(makeBotModel());
    scanProperties(dynamic_cast<BaseModel *>(model.data()));
    return model.take();
}

