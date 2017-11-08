// Copyright 2017 Makerbot Industries

#ifndef _SRC_BASE_MODEL_H
#define _SRC_BASE_MODEL_H

#include <QObject>
#include <QVariant>


// A Model Property is a Qt property that should only be modified from within
// the bot model and which notifies on change.  Should be declared in a private
// section to avoid silently privatizing whatever follows it.
#define MODEL_PROP(TYPE, NAME, DEFAULT) \
  private:\
    Q_PROPERTY(TYPE NAME READ NAME WRITE NAME ## Set RESET NAME ## Reset \
               NOTIFY NAME ## Changed) \
    TYPE m_ ## NAME; \
  public: \
    inline const TYPE & NAME() const { return m_ ## NAME; } \
    Q_SIGNAL void NAME ## Changed(); \
  protected: \
    void NAME ## Set(const TYPE & NAME) { \
        if (m_ ## NAME != NAME) { \
            m_ ## NAME = NAME; \
            emit NAME ## Changed(); \
        } \
    } \
  public: \
    inline void NAME ## Reset() { NAME ## Set(DEFAULT); } \
  private:


// A sub model is just a constant property that is itself a pointer to a model
#define SUBMODEL(TYPE, NAME) \
  private: \
    Q_PROPERTY(TYPE* NAME READ NAME CONSTANT) \
  protected: \
    QScopedPointer<TYPE, QScopedPointerDeleteLater> m_ ## NAME; \
  public: \
    inline TYPE * NAME() { return m_ ## NAME.data(); } \
  private:


// Base class for all models -- all models should use this base class
// and call reset() in their constructor.
class BaseModel : public QObject {
    Q_OBJECT
    /// Placeholder property to deal with QML's inability to access
    /// dynamic object properties.
    Q_PROPERTY(QVariant metaInfo MEMBER m_metaInfo NOTIFY notifySignal)
    QVariant m_metaInfo;
  protected:
    /// Reset all properties to their default value
    void reset();
  signals:
    void notifySignal(); // Dummy signal to suppress missing NOTIFY warning
};

#endif  // _SRC_BASE_MODEL_H

