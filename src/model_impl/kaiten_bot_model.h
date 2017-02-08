// Copyright 2017 Makerbot Industries

#ifndef _SRC_KAITEN_BOT_MODEL_H
#define _SRC_KAITEN_BOT_MODEL_H

#include "../model/bot_model.h"

// Rather than do a PIMPL setup for this class we just make the
// entire class private and expose only a factory function.
BotModel * makeKaitenBotModel(const char * socketpath);

#endif  // _SRC_KAITEN_BOT_MODEL_H
