cmake_minimum_required(VERSION 3.10)
project(ExprEvaluator C)

# Find Flex and Bison
find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

# Define the input files
BISON_TARGET(Parser expr.y ${CMAKE_CURRENT_BINARY_DIR}/y.tab.c
             DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/y.tab.h)
FLEX_TARGET(Scanner expr.l ${CMAKE_CURRENT_BINARY_DIR}/lex.yy.c)
ADD_FLEX_BISON_DEPENDENCY(Scanner Parser)

# Include the directory where YACC outputs its header
include_directories(${CMAKE_CURRENT_BINARY_DIR})

# Build the final executable
add_executable(expr
    ${BISON_Parser_OUTPUTS}
    ${FLEX_Scanner_OUTPUTS}
)

# Link math library (for functions like sqrt, pow, etc.)
target_link_libraries(expr m)
