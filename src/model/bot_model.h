// Copyright 2017 Makerbot Industries

#ifndef _SRC_BOT_MODEL_H
#define _SRC_BOT_MODEL_H

#include <QObject>
#include <QDebug>

#include "base_model.h"
#include "net_model.h"
#include "process_model.h"

// The top level API for our bot model.  We don't allow direct instantiation
// because this doesn't initialize submodels.
class BotModel : public BaseModel {
  public:
    enum ConnectionState {
        Connecting,
        Connected,
        Disconnected,
        TimedOut
    };
    enum FilamentColor{
        Unknown,
        Red,
        Green,
        Blue,
        Yellow,
        Orange,
        Violet
    };
    Q_ENUM(ConnectionState)
    Q_ENUM(FilamentColor)
    Q_INVOKABLE virtual void cancel();
    Q_INVOKABLE virtual void pausePrint();
    Q_INVOKABLE virtual void print(QString file_name);
    Q_INVOKABLE virtual void updateInternalStorageFileList();
    Q_INVOKABLE virtual void deletePrintFile(QString file_name);
    Q_INVOKABLE virtual void loadFilament(const int kToolIndex);
    Q_INVOKABLE virtual void unloadFilament(const int kToolIndex);
  private:
    Q_OBJECT
    SUBMODEL(NetModel, net)
    SUBMODEL(ProcessModel, process)
    MODEL_PROP(QString, name, "Unknown")
    MODEL_PROP(QString, version, "Unknown")
    MODEL_PROP(ConnectionState, state, Connecting)
    MODEL_PROP(FilamentColor, filament1Color, Unknown)
    MODEL_PROP(FilamentColor, filament2Color, Unknown)
    MODEL_PROP(int, filament1Percent, 0)
    MODEL_PROP(int, filament2Percent, 0)
    MODEL_PROP(QStringList, internalStorageFileList, {"No Internal Files Found"})
    MODEL_PROP(int, extruderACurrentTemp, -999)
    MODEL_PROP(int, extruderATargetTemp, -999)
    MODEL_PROP(int, extruderBCurrentTemp, -999)
    MODEL_PROP(int, extruderBTargetTemp, -999)
    MODEL_PROP(int, chamberCurrentTemp, -999)
    MODEL_PROP(int, chamberTargetTemp, -999)
  protected:
    BotModel();
};

// Make a dummy implementation of the API with all submodels filled in.
BotModel * makeBotModel();

#endif  // _SRC_BOT_MODEL_H
