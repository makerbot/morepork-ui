// Copyright 2017 Makerbot Industries

#include <iostream>
#include <regex>
#include <fstream>
#include <experimental/filesystem>

namespace efs = std::experimental::filesystem;


void FindReplaceSubstring(std::string &str, std::string search_str,
                          std::string replace_str = std::string()){
  std::string::size_type index;
  index = str.find(search_str);
  if(index != std::string::npos)
    str.replace(index, search_str.size(), replace_str);
}


void RemoveNonAlphaNumeric(std::string &str){
  auto func = [](char ch){ return !::isalnum(ch); };
  str.erase(std::remove_if(str.begin(), str.end(), func), str.end());
}


int main(int argc, char *argv[]){
  if(argc != 2)
    return(-1);

  std::string file_dir = argv[1];
  std::fstream parsed_enum_file(file_dir + "/parsed_qml_enums.h",
                                std::fstream::out);
  if(!parsed_enum_file.is_open())
    return(-1);

  parsed_enum_file << "// Copyright 2017 Makerbot Industries\n";
  parsed_enum_file << "// This file was automatically generated using the enum_parser executable\n\n";
  parsed_enum_file << "#ifndef __PARSED_ENUM_FILE__\n#define __PARSED_ENUM_FILE__\n\n";
  parsed_enum_file << "#include <QObject>\n#include <QtQml>\n\n";

  // "experimental" directory iterating code (below) is non mission critical.
  // this file does not run on the bot.
  efs::recursive_directory_iterator rec_dir_iter(file_dir);
  std::vector<std::string> enum_name_vec;
  for(const efs::directory_entry &dir_entry : rec_dir_iter){
    if(dir_entry.path().extension() == ".h"){
      std::fstream in_file_stream(dir_entry.path(), std::fstream::in);
      std::stringstream buffer;
      buffer << in_file_stream.rdbuf();
      std::string entire_file_str = buffer.str();

      std::string enum_tag("MOREPORK_QML_ENUM");
      std::string regex_patter_str = enum_tag +
          "[\r\n ]+enum[ a-zA-Z0-9]+\\{[\r\n a-zA-Z,]+\\};";
      std::regex reg(regex_patter_str);

      std::smatch str_match_results;
      std::vector<std::string> enum_match_vec;
      while(std::regex_search(entire_file_str, str_match_results, reg)){
        enum_match_vec.push_back(str_match_results.str());
        entire_file_str = str_match_results.suffix();
      }
      //std::cout << "Found " << enum_match_vec.size() << " enumerations\n";

      regex_patter_str = "enum[ a-zA-Z0-9]+\\{";
      reg = std::regex(regex_patter_str);
      std::string enum_tag_return = enum_tag + "\n";
      for(std::string &str : enum_match_vec){
        //std::cout << str << std::endl;
        FindReplaceSubstring(str, enum_tag_return);
        FindReplaceSubstring(str, enum_tag);
        if(std::regex_search(str, str_match_results, reg)){
          std::string match_str = str_match_results.str();
          FindReplaceSubstring(match_str, "enum");
          RemoveNonAlphaNumeric(match_str);
          std::string &enum_name = match_str;
          enum_name_vec.push_back(enum_name);
          std::string enum_class =
          std::string("class ") + enum_name + "Class : public QObject {\n" +
          "  Q_OBJECT\n" +
          "  public:\n" +
          str + "\n" +
          "    Q_ENUM(" + enum_name + ")\n" +
          "    " + enum_name + "Class() {\n" +
          "      qmlRegisterType<" + enum_name + "Class>(\"" + enum_name +
                 "Enum\", 1, 0, \"" + enum_name + "\");\n" +
          "    }\n" +
          "};\n\n";
          parsed_enum_file << enum_class;
        }
      }
    }
  }

  parsed_enum_file << "#define QML_ENUM_OBJECTS \\\n";
  const size_t kEnumNameVecSizeLessOne = enum_name_vec.size()-1;
  for(size_t i = 0; i < kEnumNameVecSizeLessOne; ++i)
    parsed_enum_file << enum_name_vec[i] << "Class " <<
                        enum_name_vec[i] << "Obj; \\\n";
  parsed_enum_file << enum_name_vec.back() << "Class " <<
                      enum_name_vec.back() << "Obj;\n\n";

  parsed_enum_file << "#endif //__PARSED_ENUM_FILE__";
  parsed_enum_file.close();

  return 0;
}

