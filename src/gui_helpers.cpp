// Copyright 2015 MakerBot Industries

#include "gui_helpers.h"

namespace guihelpers {

const QString durationString(unsigned int seconds, bool noSecondsIfZero) {
    QString ss;
    if (seconds >= 3600)
        ss += QString::number(floor(seconds / 3600)) + QString("hr ");
    seconds %= 3600;
    if (seconds >= 60)
        ss += QString::number(floor(seconds / 60)) + QString("m ");
    seconds %= 60;
    if (!(seconds == 0 && noSecondsIfZero))
        ss += QString::number(seconds) + QString("s");
    return ss;
}

const QString approxDurationString(unsigned int seconds,
    unsigned int approxIntervalSeconds) {
    unsigned int intervals = ceil(static_cast<float>(seconds) /
                                  static_cast<float>(approxIntervalSeconds));
    // If there are 0 intervals in the supplied time, set it to 1, that way the
    // user sees
    // something like "Approximately 5m remaining" rather than "Approximately 0m
    // remaining"
    if (intervals == 0)
        intervals = 1;

    return duration(intervals * approxIntervalSeconds, true);
}

const QString duration(unsigned int seconds, bool showSeconds) {
    QString output;

    // handle hours
    int hours = std::floor(seconds / 3600);
    if (hours < 10)
        output += "0";  // zero pad
    output += QString::number(hours);
    seconds %= 3600;

    // handle minutes
    output += ":";
    int mins = std::floor(seconds / 60);
    if (mins < 10)
        output += "0";  // zero pad
    output += QString::number(mins);
    seconds %= 60;

    if (showSeconds) {
      // handle seconds
      output += ":";
      if (seconds < 10)
          output += "0";  // zero pad
      output += QString::number(seconds);
    }

    return output;
}

const QString ago(unsigned int seconds) {
    QString ss;
    if (seconds >= 86400) {
        ss += pluralize(floor(seconds / 86400), QString("day"));
    }
    else if (seconds >= 3600) {
        ss += pluralize(floor(seconds / 3600), QString("hour"));
    } else if (seconds >= 60) {
        ss += pluralize(floor(seconds / 60), QString("min"));
    } else {
        ss += pluralize(seconds, QString("sec"));
    }
    ss += QString(" ago");
    return ss;
}

const QString ago(const QDateTime priorDatetime) {
    return ago(priorDatetime.secsTo(QDateTime::currentDateTime()));
}

const QString temp(int temp, bool celsiusLabel) {
    QString tempLabel(QString::number(temp));
    QChar ch(0x00B0);  // Degree symbol
    tempLabel.push_back(ch);
    if (celsiusLabel) {
        tempLabel += " C";
    }
    return tempLabel;
}

const QString pluralize(unsigned int quantity, QString label, bool capitalize) {
    if (quantity != 1)
        label += capitalize ? "S" : "s";
    return QString("%1 " + label).arg(quantity);
}

QString truncate(QString string, int maxLength) {
    if (string.length() >= maxLength) {
        string.truncate(maxLength - 3);
        string += "...";
    }
    return string;
}

int stringResize(QString str, int maxSize, int maxWidth, int fontWeight) {
    QFont font;
    font.setPixelSize(maxSize);
    font.setWeight(fontWeight);
    QFontMetrics fontMetrics = QFontMetrics(font);
    while (fontMetrics.width(str) > maxWidth) {
        maxSize--;
        font.setPixelSize(maxSize);
        //font metrics has no way to update font, need to recreate every time.
        fontMetrics = QFontMetrics(font);
    }
    return maxSize;
}

}

