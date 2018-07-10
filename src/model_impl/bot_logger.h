// Copyright 2017 Makerbot Industries

#ifndef _SRC_BOT_LOGGER_H
#define _SRC_BOT_LOGGER_H

#include "model/logger.h"

// Rather than do a PIMPL setup for this class we just make the
// entire class private and expose only a factory function.
Logger * makeBotLogger();

#endif  // _SRC_BOT_LOGGER_H

