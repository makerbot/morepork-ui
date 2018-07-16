// Copyright MakerBot, Inc. 2017
#ifndef SRC_LOGGING_HH_
#define SRC_LOGGING_HH_

// A macro to use like BOOST_LOG_TRIVIAL that also does file and line info. In
// conjunction
// with a commandline -D__FILENAME__ (for a short name) this will give more
// informative logging. Also, a fallback just in case
#ifndef __FILENAME__
#define __FILENAME__ __FILE__
#endif

// (dump everything into qtcreator console if qtcreator build)
#ifdef MOREPORK_UI_QT_CREATOR_BUILD
#define LOG(level) \
    qInfo() << "[" << __FILENAME__ << ":" << __LINE__ << ":" << __func__ << "] "
#define TELEM(level) \
    qInfo() << "[" << __FILENAME__ << ":" << __LINE__ << ":" << __func__ << "] "\
            << "[TELEM] "
#else

#include <boost/log/sources/severity_channel_logger.hpp>
#include <boost/log/trivial.hpp>

#include <string>

#define LOG(level) \
    BOOST_LOG_SEV(Logging::GeneralLog(), boost::log::trivial::level) << "["\
    << __FILENAME__ << ":" << __LINE__ << ":" << __func__ << "] "
#define TELEM(level) \
    BOOST_LOG_SEV(Logging::TelemetryLog(), boost::log::trivial::level)

namespace Logging {
    typedef boost::log::sources
            ::severity_channel_logger<boost::log::trivial::severity_level,
                                      std::string> general_log;
    typedef boost::log::sources
            ::severity_channel_logger<boost::log::trivial::severity_level,
                                      std::string> telem_log;
    void Initialize(const std::string& folder_name,
                    const std::string& general_file_name,
                    const std::string& telemetry_file_name);
    // The sev_name here is a string that should be one of (non-case-sensitive)
    // "debug", "info", "warning", "error", "off".
    void ChangeGeneralLevel(const std::string& sev_name);
    void ChangeTelemetryLevel(const std::string& sev_name);
    general_log& GeneralLog();
    telem_log& TelemetryLog();
    void Flush();
};
#endif
#endif  // SRC_LOGGING_HH_
