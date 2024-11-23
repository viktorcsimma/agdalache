cmake_minimum_required (VERSION 3.16)

project(SkeletonGUI)
set(PROJECT_VERSION 0.1)
set(PROJECT_VERSION_MAJOR 0)
set(PROJECT-NAME_VERSION_MINOR 1)

include(GNUInstallDirs)

find_package(Catch2 3 REQUIRED)

# the name of the backend project
set(BACKEND_NAME Skeleton)

# if this is compiled from the common parent project,
# we can simply add a dependency (see later)
# otherwise:
if(NOT DEFINED NOT_TOP_LEVEL)
    find_package(${BACKEND_NAME} 0.1 REQUIRED)
endif()

# for Qt

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Widgets LinguistTools)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Widgets LinguistTools)


set(TS_FILES src/View/lang_en_GB.ts)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(${PROJECT_NAME}
        MANUAL_FINALIZATION
    )
# Define target properties for Android with Qt 6 as:
#    set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
#                 ${CMAKE_CURRENT_SOURCE_DIR}/android)
# For more information, see https://doc.qt.io/qt-6/qt-add-executable.html#target-creation

    qt_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TS_FILES})
else()
    if(ANDROID)
        add_library(${PROJECT_NAME} SHARED
            ""
        )
# Define properties for Android with Qt 5 after find_package() calls as:
#    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
    else()
        add_executable(${PROJECT_NAME}
            ""
        )
    endif()

    qt5_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TS_FILES})
endif()

# this is a simple terminal program
add_executable(${PROJECT_NAME}Test "")

# afterwards:

# see https://crascit.com/2016/01/31/enhanced-source-file-handling-with-target_sources/ for the technique
add_subdirectory(src)
add_subdirectory(include)
# should we also add headers later? it helps IDEs

target_link_libraries(${PROJECT_NAME} PRIVATE Qt${QT_VERSION_MAJOR}::Widgets)

target_link_libraries(${PROJECT_NAME}Test PRIVATE Catch2::Catch2)

if(DEFINED NOT_TOP_LEVEL)
    add_dependencies(${PROJECT_NAME} ${BACKEND_NAME})
    add_dependencies(${PROJECT_NAME}Test ${BACKEND_NAME})
    target_link_libraries(${PROJECT_NAME} PRIVATE ${BACKEND_NAME})
    target_link_libraries(${PROJECT_NAME}Test PRIVATE ${BACKEND_NAME})
else()
    target_link_libraries(${PROJECT_NAME} PRIVATE ${BACKEND_NAME}::${BACKEND_NAME})
    target_link_libraries(${PROJECT_NAME}Test PRIVATE ${BACKEND_NAME}::${BACKEND_NAME})
endif()

# For some reason, on Windows, Interaction.o gets corrupted when copied into the library;
# so it has to be included separately.
# See my own question at
# https://stackoverflow.com/questions/78260754/ghc-libraries-with-ffi-on-windows-have-foreign-export-symbols-missing.
if("Windows" STREQUAL ${CMAKE_SYSTEM_NAME})
  target_link_libraries(${PROJECT_NAME} PRIVATE "${CMAKE_INSTALL_PREFIX}/../${BACKEND_NAME}/lib/Interaction.o")
  target_link_libraries(${PROJECT_NAME}Test PRIVATE "${CMAKE_INSTALL_PREFIX}/../${BACKEND_NAME}/lib/Interaction.o")
endif()

# Adding include headers

target_include_directories(${PROJECT_NAME}
                           PUBLIC
                           "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
                           "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)

target_include_directories(${PROJECT_NAME}Test
                           PUBLIC
                           "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
                           "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)

# I don't know why, but with these options, it does not link some system libraries by itself;
# so they need to be named explicitly.
if("Linux" STREQUAL ${CMAKE_SYSTEM_NAME} OR "Darwin" STREQUAL ${CMAKE_SYSTEM_NAME})
  target_link_options(${PROJECT_NAME} PRIVATE -no-pie)
  target_link_options(${PROJECT_NAME}Test PRIVATE -no-pie)
  target_link_libraries(${PROJECT_NAME} PRIVATE dl pthread gmp)
  target_link_libraries(${PROJECT_NAME}Test PRIVATE dl pthread gmp)
  if(CMAKE_BUILD_TYPE MATCHES RELEASE)
      # we tell the dynamic linker to search for shared libraries in the folder of the executable itself
      # this way, we can bundle the remaining libraries with the application
      target_link_options(${PROJECT_NAME} PRIVATE -rpath=.)
  endif()
elseif("Windows" STREQUAL ${CMAKE_SYSTEM_NAME})
  target_link_options(${PROJECT_NAME} PRIVATE -pthread -fno-PIC)
  target_link_options(${PROJECT_NAME}Test PRIVATE -pthread -fno-PIC)
  # as flags, they would be added to the beginning of the command, where they get optimised out
  # see the documentation of ld
  target_link_libraries(${PROJECT_NAME} PRIVATE ws2_32 winmm ntdll rpcrt4 dbghelp ucrt msvcrt)
  target_link_libraries(${PROJECT_NAME}Test PRIVATE ws2_32 winmm ntdll rpcrt4 dbghelp ucrt)
else()
  message( FATAL_ERROR "Unsupported operating system: ${CMAKE_SYSTEM_NAME}" )
endif()


# if we have assets under an "assets" directory:
# file(COPY assets DESTINATION ${CMAKE_BINARY_DIR})
# and installing them, if it is about an installation
# install(DIRECTORY assets DESTINATION ${CMAKE_BINARY_DIR})

install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)


if(QT_VERSION_MAJOR EQUAL 6)
    qt_finalize_executable(${PROJECT_NAME})
endif()
