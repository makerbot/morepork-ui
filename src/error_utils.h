#ifndef __ERROR_UTILS_H__
#define __ERROR_UTILS_H__

#include <cstdio>
#include <cstring>
#include <cerrno>
#include <iostream>
#include <stdexcept>
#if __cplusplus > 199711L
#include <system_error>
#endif
#include <sstream>
#include <cassert>
#include <string>

#if defined __GNUC__
#define CURRENT_FUNC __PRETTY_FUNCTION__ //__func__
#elif defined _MSC_VER
#define CURRENT_FUNC __FUNCTION__
#else
#define CURRENT_FUNC ""
#endif


//std::system_error exception macro
#define EXP_CHK_SYSERR(exp)                                                                                         \
if( !!(exp) ) ; else{                                                                                               \
  std::ostringstream stream;                                                                                        \
  stream << __FILE__ << ":" << CURRENT_FUNC << ":" << __LINE__ << ": (" << #exp << ") is false. System message";    \
  throw std::system_error( errno, std::system_category(), stream.str() );                                           \
}

#define EXP_CHK_SYSERR_M(exp, opt_msg)                                         \
if( !!(exp) ) ; else{                                                          \
  std::ostringstream stream;                                                   \
  stream << __FILE__ << ":" << CURRENT_FUNC << ":" << __LINE__ <<              \
            ": (" << #exp << ") is false. " << opt_msg << ". System message";  \
  throw std::system_error( errno, std::system_category(), stream.str() );      \
}


//Put this macro in a c++ stream to print the current function name and line number
//eg. std::cout << FL_STRM << "there was an error\n";
#define FL_STRM CURRENT_FUNC << ":" << __LINE__ << ": "

//Put this macro in a c++ stream to print the current file name, function name, and line number
#define FFL_STRM __FILE__ << ":" << CURRENT_FUNC << ":" << __LINE__ << ": "

#define ERRNO_STRM "errno message: " << std::strerror(errno)


/*
Use to check boolean expression that should normally evaluate as true.
Prints a formatted message that includes file name, function name, line number, and the expression.
Exit function can be any code you want to execute if the expression evaluates as false.
For example:
EXP_CHK(value > 0, return(false))
The above line will print the formatted message and call return if value is <= 0
*/
#define EXP_CHK(exp, exit_function)                                    \
if( !!(exp) ) ; else{                                                  \
  std::cout << __FILE__ << ":" << CURRENT_FUNC << ":" << __LINE__ <<   \
               ": (" << #exp << ") is false.\n";                       \
  exit_function;                                                       \
}

/*
Same as EXP_CHK, but includes a user message
For example:
EXP_CHK(value > 0, return(false), "you entered an incorrect value")
*/
#define EXP_CHK_M(exp, exit_function, opt_msg)                         \
if( !!(exp) ) ; else{                                                  \
  std::cout << __FILE__ << ":" << CURRENT_FUNC << ":" << __LINE__ <<   \
               ": (" << #exp << ") is false. " << opt_msg << "\n";     \
  exit_function;                                                       \
}

//Expression checking macros with errno evaluation
#define EXP_CHK_ERRNO(exp, exit_function)                                                       \
if( !!(exp) ) ; else{                                                                           \
  std::cout << __FILE__ << ":" << CURRENT_FUNC << ":" << __LINE__ <<                            \
               ": (" << #exp << ") is false. errno message: " << std::strerror(errno) << "\n";  \
  exit_function;                                                                                \
}

#define EXP_CHK_ERRNO_M(exp, exit_function, opt_msg)                                                       \
if( !!(exp) ) ; else{                                                                                      \
  std::cout << __FILE__ << ":" << CURRENT_FUNC << ":" << __LINE__ << " - (" << #exp << ") is false. " <<   \
               opt_msg << ": errno message: " << std::strerror(errno) << "\n";                             \
  exit_function;                                                                                           \
}

#endif // __ERROR_UTILS_H__
