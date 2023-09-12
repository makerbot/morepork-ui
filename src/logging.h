// Copyright MakerBot, Inc. 2022
#include <QtDebug>
#ifndef SRC_LOGGING_HH_
#define SRC_LOGGING_HH_

// (dump everything into qtcreator console if qtcreator build)
#ifdef MOREPORK_UI_QT_CREATOR_BUILD
#define LOG(level) \
    qInfo() << "[" << __FILE__ << ":" << __LINE__ << ":" << __func__ << "]\n"
#define TELEM(level) \
    qInfo() << "[" << __FILE__ << ":" << __LINE__ << ":" << __func__ << "]\n"\
            << "[TELEM] "
#else
#define LOGGING_CONTEXT "ui"
#include "mbcoreutils/firmware_logging.h"
#endif

#endif  // SRC_LOGGING_HH_
