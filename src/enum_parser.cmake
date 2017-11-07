# You cannot pass a semicolon separated list from from another cmake script
# to another. The semicolons are always replaced by spaces.
# separate_arguments() replaces the spaces with semicolons.
separate_arguments(HEADER_FILE_LIST)
set(QML_ENUMS "")
foreach(HEADER_FILE ${HEADER_FILE_LIST})
    if(EXISTS ${HEADER_FILE})
        message("${HEADER_FILE} exists")
    else()
        message("${HEADER_FILE} does not exist")
    endif()
    file (READ ${HEADER_FILE} ENTIRE_FILE_STR)
    string(REGEX MATCHALL "MOREPORK_QML_ENUM[\r\n ]+enum[ a-zA-Z0-9]+{[\r\n a-zA-Z,]+}" ENUM_MATCHES_DIRTY ${ENTIRE_FILE_STR})
    foreach(ENUM_MATCH_DIRTY ${ENUM_MATCHES_DIRTY})
        string(REGEX REPLACE "MOREPORK_QML_ENUM[\r\n ]+" "" ENUM_MATCH ${ENUM_MATCH_DIRTY})
        list(APPEND QML_ENUMS ${ENUM_MATCH})
    endforeach()
endforeach()
file(WRITE parsed_qml_enums.h "// Copyright 2017 Makerbot Industries\n\
// This file was automatically generated using the enum_parser executable\n\n\
#ifndef __PARSED_ENUM_FILE__\n\
#define __PARSED_ENUM_FILE__\n\n\
#include <QObject>\n\
#include <QtQml>\n\n")
set(QML_ENUM_NAMES "")
foreach(ENUM ${QML_ENUMS})
    string(REGEX MATCH "enum[ a-zA-Z0-9]+{" ENUM_NAME_DIRTY ${ENUM})
    string(REGEX REPLACE "enum[ ]+" "" ENUM_NAME_DIRTY ${ENUM_NAME_DIRTY})
    string(REGEX REPLACE "[ ]*{" "" ENUM_NAME ${ENUM_NAME_DIRTY})
    list(APPEND QML_ENUM_NAMES ${ENUM_NAME})
    #message("<${ENUM}>")
    #message("<${ENUM_NAME}>")
    file(APPEND parsed_qml_enums.h "class ${ENUM_NAME}Class : public QObject {\n\
  Q_OBJECT\n\
  public:\n\
    ${ENUM};\n\
    Q_ENUM(${ENUM_NAME})\n\
    ${ENUM_NAME}Class() {\n\
      qmlRegisterType<${ENUM_NAME}Class>(\"${ENUM_NAME}Enum\", 1, 0, \"${ENUM_NAME}\");\n\
    }\n\
};\n\n")
endforeach()
list(LENGTH QML_ENUM_NAMES QML_ENUM_NAMES_LENGTH)
list(GET QML_ENUM_NAMES QML_ENUM_NAMES_LENGTH-1 LAST_ENUM_NAME)
list(REMOVE_AT QML_ENUM_NAMES QML_ENUM_NAMES_LENGTH-1)
file(APPEND parsed_qml_enums.h "#define QML_ENUM_OBJECTS \\\n")
foreach(ENUM_NAME ${QML_ENUM_NAMES})
    file(APPEND parsed_qml_enums.h "${ENUM_NAME}Class ${ENUM_NAME}Obj; \\\n")
endforeach()
file(APPEND parsed_qml_enums.h "${LAST_ENUM_NAME}Class ${LAST_ENUM_NAME}Obj; \n\n#endif //__PARSED_ENUM_FILE__")

