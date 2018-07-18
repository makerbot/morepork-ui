// Copyright MakerBot 2017
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-local-typedefs"
#pragma GCC diagnostic ignored "-Wunused-variable"
#include <boost/log/core.hpp>
#include <boost/log/sinks.hpp>
#include <boost/log/sources/global_logger_storage.hpp>
#include <boost/log/expressions.hpp>
#include <boost/log/sinks/text_file_backend.hpp>
#include <boost/log/utility/setup.hpp>
#include <boost/uuid/uuid.hpp>

#include <locale>
#include <algorithm>
#include <sstream>
#include <string>

#pragma GCC diagnostic pop

#include "logging.h"

BOOST_LOG_INLINE_GLOBAL_LOGGER_INIT(general,
                                    Logging::general_log) {
    Logging::general_log lg(boost::log::keywords::channel = "ui");
    return lg;
}


BOOST_LOG_INLINE_GLOBAL_LOGGER_INIT(telemetry,
                                    Logging::telem_log) {
    Logging::telem_log lg(boost::log::keywords::channel = "telemetry");
    return lg;
}

// ugh
static boost::shared_ptr < boost::log::sinks
                         ::synchronous_sink < boost::log::sinks
                                            ::text_file_backend > >
                         general_file_backend;
static boost::shared_ptr < boost::log::sinks
                         ::synchronous_sink < boost::log::sinks
                                            ::text_file_backend > >
                         telemetry_file_backend;

void Logging::Initialize(const std::string& folder_name,
                         const std::string& general_file_name,
                         const std::string& telemetry_file_name) {
    std::string general_path = std::string("/home/logs/") + folder_name
        + "/" + general_file_name + "_%N.log";
    std::string target = std::string("/home/logs/") + folder_name;
    std::string telemetry_path = std::string("/home/logs/") + folder_name
        + "/" + telemetry_file_name + "_%N.log";
    if (!general_file_backend) {
        general_file_backend
            = boost::log::add_file_log(boost::log::keywords::file_name
                                       = general_path.c_str(),
                                       boost::log::keywords::open_mode
                                       = std::ios::out | std::ios::app,
                                       // rotate files every 1MB
                                       boost::log::keywords::rotation_size
                                       = 1024 * 1024,
                                       // flush logfile to disk after ea write
                                       boost::log::keywords::auto_flush
                                       = true,
                                       boost::log::keywords::target
                                       = target.c_str(),
                                       // 10MB total log space
                                       boost::log::keywords::max_size
                                       = 10 * 1024 *1024,
                                       boost::log::keywords::format
                                      = "[%TimeStamp%]: [%Channel%] %Message%");
        ChangeGeneralLevel("info");
    }
    if (!telemetry_file_backend) {
        telemetry_file_backend
            = boost::log::add_file_log(
                                       boost::log::keywords::file_name
                                       = telemetry_path.c_str(),
                                       boost::log::keywords::open_mode
                                       = std::ios::out | std::ios::app,
                                       // rotate files every 1MB
                                       boost::log::keywords::rotation_size
                                       = 1024 * 1024,
                                       // flush logfile to disk after ea write
                                       boost::log::keywords::auto_flush
                                       = true,
                                       boost::log::keywords::target
                                       = target.c_str(),
                                       // 10MB total log space
                                       boost::log::keywords::max_size
                                       = 10 * 1024 *1024,
                                       boost::log::keywords::format
                                     = "%TimeStamp%,%Message%");
        ChangeTelemetryLevel("info");
    }
    boost::log::add_common_attributes();
}

template <int Level>
void SetGeneralLevel() {
    general_file_backend->set_filter(boost::log::trivial::severity >= Level
                                     &&
                         boost::log::expressions::attr<std::string>("Channel")
                                     != "telemetry");
}

template <int Level>
void SetTelemLevel() {
    telemetry_file_backend->set_filter(boost::log::trivial::severity >= Level
                                       &&
                          boost::log::expressions::attr<std::string>("Channel")
                                       == "telemetry");
}

boost::log::trivial::severity_level
SeverityFromString(const std::string& sev) {
}

void Logging::ChangeGeneralLevel(const std::string& sev) {
    auto sev_enum = SeverityFromString(sev);
    if (general_file_backend) {
        general_file_backend->reset_filter();
        std::string lower(sev.size(), ' ');
        std::transform(sev.cbegin(), sev.cend(), lower.begin(),
                       [](char c) {return std::tolower(c, std::locale());});
        if (lower == "debug") {
            SetGeneralLevel<boost::log::trivial::debug>();
        } else if (lower == "info") {
            SetGeneralLevel<boost::log::trivial::info>();
        } else if (lower == "warning") {
            SetGeneralLevel<boost::log::trivial::warning>();
        } else if (lower == "error") {
            SetGeneralLevel<boost::log::trivial::error>();
        } else if (lower == "off") {
            SetGeneralLevel<boost::log::trivial::fatal>();
        } else {
            LOG(warning) << "Invalid log specifier: " << sev;
            SetGeneralLevel<boost::log::trivial::trace>();
        }
    }
}

void Logging::ChangeTelemetryLevel(const std::string& sev) {
    auto sev_enum = SeverityFromString(sev);
    if (telemetry_file_backend) {
        telemetry_file_backend->reset_filter();
        std::string lower(sev.size(), ' ');
        std::transform(sev.cbegin(), sev.cend(), lower.begin(),
                       [](char c) {return std::tolower(c, std::locale());});
        if (lower == "debug") {
            SetTelemLevel<boost::log::trivial::debug>();
        } else if (lower == "info") {
            SetTelemLevel<boost::log::trivial::info>();
        } else if (lower == "warning") {
            SetTelemLevel<boost::log::trivial::warning>();
        } else if (lower == "error") {
            SetTelemLevel<boost::log::trivial::error>();
        } else if (lower == "off") {
            SetTelemLevel<boost::log::trivial::fatal>();
        } else {
            LOG(warning) << "Invalid log specifier: " << sev;
            SetTelemLevel<boost::log::trivial::trace>();
        }
    }
}

Logging::general_log& Logging::GeneralLog() {
    return general::get();
}

Logging::telem_log& Logging::TelemetryLog() {
    return telemetry::get();
}

void Logging::Flush() {
    boost::log::core::get()->flush();
}
