// Copyright 2017 Makerbot Industries

#include "host_model.h"

#include <iostream>

#include <QMetaProperty>
#include <QVariant>

// Fill the metaInfo property of this model and all submodels
//
// TODO: Add property type information here
void scanProperties(BaseModel * model) {
    const QMetaObject *metaobject = model->metaObject();
    int count = metaobject->propertyCount();
    QVariantList properties;
    for (int i = metaobject->propertyOffset(); i < count; ++i) {
        auto prop = metaobject->property(i);

        // First explicitly check for a submodel
        if (prop.type() == QVariant::UserType) {
            auto val = prop.read(model);
            BaseModel * submodel = val.value<BaseModel *>();
            if (submodel) {
                scanProperties(submodel);
                continue;
            }
        }

        properties.append(QVariantMap({{"prop", prop.name()}}));
    }
    model->setProperty("metaInfo", properties);
}

BotModel * makeHostBotModel() {
    QScopedPointer<BotModel> model(makeBotModel());
    scanProperties(dynamic_cast<BaseModel *>(model.data()));
    return model.take();
}

