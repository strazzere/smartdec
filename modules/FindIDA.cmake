set(IDA_FOUND FALSE)
set(IDA_SDK_FOUND FALSE)

#
# Find IDA.
#
if(WIN32)
    find_path(IDA_PATH
        NAME "idag.exe" "idaq.exe"
        HINTS $ENV{IDA_DIR} $ENV{IDADIR}
        PATHS "C:/Program Files/IDA" "C:/Program Files (x86)/IDA"
        DOC "IDA Pro installation directory.")
endif()

if(APPLE)
    find_path(IDA_PATH
        NAME "idaq" "idaq64"
	HINTS $ENV{IDA_DIR}
	PATHS "/Applications/IDA\ Pro\ 6.8/idaq.app/Contents/MacOS/" "/Applications/IDA\ Pro\ 6.7/idaq.app/Contents/MacOS/" "/Applications/IDA\ Pro\ 6.6/idaq.app/Contents/MacOS/"
	DOC "IDA Pro installation directory.")
endif()

if(IDA_PATH)
    set(IDA_FOUND TRUE)
    message(STATUS "Looking for IDA Pro - found @ ${IDA_PATH}")
else()
    message(STATUS "Looking for IDA Pro - not found")
endif()

#
# Make up the name of the SDK library subdirectory.
#

# Detect the platform.
set(platform "unknown")
if(WIN32)
    set(platform "win")
endif()
if(UNIX)
    set(platform "linux")
endif()
if(APPLE)
    set(platform "mac")
endif()

# Detect the compiler.
set(compiler "unknown")
if(BORLAND)
    set(compiler "bcc")
endif()
# APPLE should only ever have GCC / Clang, though there is not a variable for clang
if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX OR APPLE)
    set(compiler "gcc")
endif()
if(MSVC)
    set(compiler "vc")
endif()

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(library_dir "lib/x64_${platform}_${compiler}_64")
else()
    set(library_dir "lib/x86_${platform}_${compiler}_32")
endif()

#
# Find IDA Pro SDK.
#
find_path(IDA_SDK_PATH
    NAME ${library_dir}
    HINTS $ENV{IDA_SDK_DIR}
    PATHS "${IDA_SDK_DIR}"
    DOC "IDA Pro SDK directory.")

if(IDA_SDK_PATH)
    set(IDA_SDK_FOUND TRUE)
    set(IDA_INCLUDE_DIR ${IDA_SDK_PATH}/include)
    set(IDA_LIBRARY_DIR ${IDA_SDK_PATH}/${library_dir})

    if(MSVC)
        file(GLOB IDA_LIBRARIES "${IDA_LIBRARY_DIR}/*.lib")
    else()
        file(GLOB IDA_LIBRARIES "${IDA_LIBRARY_DIR}/*.a")
    endif()

    set(IDA_DEFINITIONS -D__IDP__)
    if(WIN32)
        set(IDA_DEFINITIONS ${IDA_DEFINITIONS} -D__NT__)
    endif()
    if(UNIX)
        set(IDA_DEFINITIONS ${IDA_DEFINITIONS} -D__LINUX__)
    endif()
    if(APPLE)
        set(IDA_DEFINITIONS ${IDA_DEFINITIONS} -D__MAC__)
    endif()
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(IDA_DEFINITIONS ${IDA_DEFINITIONS} -D__EA64__ -D__X64__)
    endif()

    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(IDA_PLUGIN_EXT ".p64")
    else()
        set(IDA_PLUGIN_EXT ".plw")
    endif()

    message(STATUS "Looking for IDA Pro SDK - found @ ${IDA_SDK_PATH}")
    message(STATUS "Looking for IDA Pro SDK includes - using ${IDA_INCLUDE_DIR}")
    message(STATUS "Looking for IDA Pro SDK libraries - using ${IDA_LIBRARY_DIR}")
else()
    message(STATUS "Looking for IDA Pro SDK - not found")
endif()

unset(platform)
unset(compiler)
unset(library_dir)

# vim:set et sts=4 sw=4 nospell:
