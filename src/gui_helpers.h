// Copyright 2017 MakerBot Industries

#ifndef __GUI_HELPERS_H__
#define __GUI_HELPERS_H__

#include <QString>
#include <QDateTime>
#include <string>
#include <QFontMetrics>
#include <QFont>

namespace guihelpers {

// changes a duration in seconds to a formatted string (i.e. 1h 23m 0s)
const QString durationString(unsigned int seconds,
                             bool noSecondsIfZero = false);

// returns a formatted string that represents the duration to the nearest
// supplied interval
// ex: 8880s (2hr28m) with an interval of 900s(15m) will be formatted as 2h30m
const QString approxDurationString(unsigned int seconds,
                                   unsigned int approxIntervalSeconds);

// changes a duration in seconds to a numbered display (i.e. 01:23:00)
// if show seconds is true, format is hh:mm:ss else format is hh:mm
const QString duration(unsigned int seconds, bool showSeconds = true);

// changes a time in seconds or prior datetime to a string describing
// when it happened (i.e. 5 days ago)
const QString ago(unsigned int seconds);
const QString ago(const QDateTime priorDatetime);

// Convert an int into a QString with a degree label (C)
const QString temp(int temp, bool celsiusLabel = true);

// take a quantity and a value and pluralize it... i.e. 1 MakerBot, 5 MakerBots
const QString pluralize(unsigned int quantity, QString label,
                        bool capitalize = false);

// adds ellipsis to strings longer than max length
QString truncate(QString string, int maxLength);

// returns the size in pixels that the text must be to fit in maxWidth
int stringResize(QString str, int maxSize, int maxWidth,
                 int fontWeight = QFont::Normal);

}

#endif  // __GUI_HELPERS_H__

