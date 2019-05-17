###| CMAKE Kiibohd Controller |###
#
# Jacob Alexander 2011-2019
# Due to this file's usefulness:
#
# Released into the Public Domain
#
# ARM CMake Build Configuration
#
###


###
# Compiler Check
#

#|
#| In CMake 3.6 a new feature to configure try_compile to work with cross-compilers
#| https://cmake.org/cmake/help/v3.6/variable/CMAKE_TRY_COMPILE_TARGET_TYPE.html#variable:CMAKE_TRY_COMPILE_TARGET_TYPE
#| If we detect CMake 3.6 or higher, use the new method
#|
if ( NOT CMAKE_VERSION VERSION_LESS "3.6" )
	# Prepare for cross-compilation
	set( CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY" )
	set( CMAKE_SYSTEM_NAME "Generic" )

	message( STATUS "Compiler Selected:" )
	if ( "${COMPILER}" MATCHES "gcc" )
		set( CMAKE_C_COMPILER   arm-none-eabi-gcc )
		set( _CMAKE_TOOLCHAIN_PREFIX arm-none-eabi- )
		message( "gcc" )
	elseif ( "${COMPILER}" MATCHES "clang" )
		set( CMAKE_C_COMPILER    clang )
		set( CMAKE_C_COMPILER_ID ARMCCompiler )
		set( _CMAKE_TOOLCHAIN_PREFIX llvm- )
		message( "clang" )
	else ()
		message( AUTHOR_WARNING "COMPILER: ${COMPILER} - Unknown compiler selection" )
	endif ()

#|
#| Before CMake 3.6 the cmake_force_c_compiler command was necessary to select cross-compilers
#| and other problemmatic compilers.
#|
else ()
	# Set the Compilers (must be set first)
	include( CMakeForceCompiler )
	message( STATUS "Compiler Selected:" )
	if ( "${COMPILER}" MATCHES "gcc" )
		cmake_force_c_compiler( arm-none-eabi-gcc ARMCCompiler )
		set( _CMAKE_TOOLCHAIN_PREFIX arm-none-eabi- )
		message( "gcc" )
	elseif ( "${COMPILER}" MATCHES "clang" )
		cmake_force_c_compiler( clang ARMCCompiler )
		set( _CMAKE_TOOLCHAIN_PREFIX llvm- )
		message( "clang" )
	else ()
		message( AUTHOR_WARNING "COMPILER: ${COMPILER} - Unknown compiler selection" )
	endif ()
endif ()



###
# ARM Defines and Linker Options
#

#| Chip Name (Linker)
message( STATUS "Chip Selected:" )
message( "${CHIP}" )
set( MCU "${CHIP}" ) # For loading script compatibility

#| Kinetis
if ( "${CHIP}" MATCHES "^mk.*$" )
	include( kinetis )

#| SAM
elseif ( "${CHIP}" MATCHES "^sam.*$" )
	include( sam )

#| nRF
elseif ( "${CHIP}" MATCHES "^nrf5.*$" )
	include( nrf5 )

#| Unknown
else ()
	message( FATAL_ERROR "CHIP: ${CHIP} - Unknown ARM microcontroller" )
endif ()

#| Chip Base Type
message( STATUS "Chip Family:" )
message( "${CHIP_FAMILY}" )

#| CPU Type
message( STATUS "CPU Selected:" )
message( "${CPU}" )


#| Extra Compiler Sources
#| Mostly for convenience functions like interrupt handlers
set( COMPILER_SRCS
	Lib/${CHIP_SUPPORT}.c
	Lib/delay.c
	Lib/entropy.c
	Lib/gpio.c
	Lib/periodic.c
	Lib/storage.c
	Lib/time.c
	Lib/utf8.c
)
if ( "${CPU}" MATCHES "cortex-m4" )
	list( APPEND COMPILER_SRCS
		Lib/arm_cortex.c
	)

	# KLL Options
	set( Device_KLL "${CMAKE_CURRENT_SOURCE_DIR}/Lib/arm_cortex.kll" )
endif ()

#| SAM Sources
if ( "${CHIP_SUPPORT}" MATCHES "sam" )
	list( APPEND COMPILER_SRCS
		Lib/ASF/common/services/clock/sam4s/sysclk.c
		Lib/ASF/common/utils/interrupt/interrupt_sam_nvic.c
		Lib/ASF/sam/drivers/efc/efc.c
		Lib/ASF/sam/drivers/pio/pio.c
		Lib/ASF/sam/drivers/pmc/pmc.c
		Lib/ASF/sam/utils/cmsis/sam4s/source/templates/system_sam4s.c
		Lib/ASF/sam/services/flash_efc/flash_efc.c
	)

	# KLL Options
	set( Device_KLL ${Device_KLL} "${CMAKE_CURRENT_SOURCE_DIR}/Lib/sam.kll" )
endif ()

#| NRF5 Sources
if ( "${CHIP_SUPPORT}" MATCHES "nrf5" )
	list( APPEND COMPILER_SRCS
		Lib/nRF5_SDK/components/boards/boards.c
		Lib/nRF5_SDK/components/libraries/atomic/nrf_atomic.c
		Lib/nRF5_SDK/components/libraries/balloc/nrf_balloc.c
		Lib/nRF5_SDK/components/libraries/experimental_section_vars/nrf_section_iter.c
		Lib/nRF5_SDK/components/libraries/log/src/nrf_log_backend_rtt.c
		Lib/nRF5_SDK/components/libraries/log/src/nrf_log_backend_serial.c
		Lib/nRF5_SDK/components/libraries/log/src/nrf_log_backend_uart.c
		Lib/nRF5_SDK/components/libraries/log/src/nrf_log_default_backends.c
		Lib/nRF5_SDK/components/libraries/log/src/nrf_log_frontend.c
		Lib/nRF5_SDK/components/libraries/log/src/nrf_log_str_formatter.c
		Lib/nRF5_SDK/components/libraries/memobj/nrf_memobj.c
		Lib/nRF5_SDK/components/libraries/pwr_mgmt/nrf_pwr_mgmt.c
		Lib/nRF5_SDK/components/libraries/ringbuf/nrf_ringbuf.c
		Lib/nRF5_SDK/components/libraries/strerror/nrf_strerror.c
		Lib/nRF5_SDK/components/libraries/util/app_error.c
		Lib/nRF5_SDK/components/libraries/util/app_error_handler_gcc.c
		Lib/nRF5_SDK/components/libraries/util/app_error_weak.c
		Lib/nRF5_SDK/components/libraries/util/app_util_platform.c
		Lib/nRF5_SDK/components/libraries/util/nrf_assert.c
		Lib/nRF5_SDK/external/fprintf/nrf_fprintf.c
		Lib/nRF5_SDK/external/fprintf/nrf_fprintf_format.c
		Lib/nRF5_SDK/external/segger_rtt/SEGGER_RTT.c
		Lib/nRF5_SDK/external/segger_rtt/SEGGER_RTT_Syscalls_GCC.c
		Lib/nRF5_SDK/external/segger_rtt/SEGGER_RTT_printf.c
		Lib/nRF5_SDK/integration/nrfx/legacy/nrf_drv_ppi.c
		Lib/nRF5_SDK/integration/nrfx/legacy/nrf_drv_uart.c
		Lib/nRF5_SDK/modules/nrfx/drivers/src/nrfx_ppi.c
		Lib/nRF5_SDK/modules/nrfx/drivers/src/nrfx_saadc.c
		Lib/nRF5_SDK/modules/nrfx/drivers/src/nrfx_timer.c
		Lib/nRF5_SDK/modules/nrfx/drivers/src/nrfx_uart.c
		Lib/nRF5_SDK/modules/nrfx/drivers/src/nrfx_uarte.c
		Lib/nRF5_SDK/modules/nrfx/drivers/src/prs/nrfx_prs.c
		Lib/nRF5_SDK/modules/nrfx/mdk/gcc_startup_nrf52.S
		Lib/nRF5_SDK/modules/nrfx/mdk/system_nrf52.c
		Lib/nRF5_SDK/modules/nrfx/soc/nrfx_atomic.c
		Lib/nRF5_SDK/components/drivers_nrf/nrf_soc_nosd/nrf_nvic.c
		Lib/nRF5_SDK/components/drivers_nrf/nrf_soc_nosd/nrf_soc.c
		Lib/nRF5_SDK/components/libraries/bsp/bsp.c
		Lib/nRF5_SDK/components/libraries/button/app_button.c
		Lib/nRF5_SDK/components/libraries/gfx/nrf_gfx.c
		Lib/nRF5_SDK/components/libraries/queue/nrf_queue.c
		Lib/nRF5_SDK/components/libraries/scheduler/app_scheduler.c
		Lib/nRF5_SDK/components/libraries/spi_mngr/nrf_spi_mngr.c
		Lib/nRF5_SDK/components/libraries/timer/app_timer.c
		Lib/nRF5_SDK/components/libraries/util/nrf_assert.c
		Lib/nRF5_SDK/external/fprintf/nrf_fprintf.c
		Lib/nRF5_SDK/external/fprintf/nrf_fprintf_format.c
		Lib/nRF5_SDK/external/segger_rtt/SEGGER_RTT.c
		Lib/nRF5_SDK/external/segger_rtt/SEGGER_RTT_Syscalls_GCC.c
		Lib/nRF5_SDK/external/segger_rtt/SEGGER_RTT_printf.c
		Lib/nRF5_SDK/external/thedotfactory_fonts/orkney24pts.c
		Lib/nRF5_SDK/external/thedotfactory_fonts/orkney8pts.c
		Lib/nRF5_SDK/integration/nrfx/legacy/nrf_drv_clock.c
		Lib/nRF5_SDK/integration/nrfx/legacy/nrf_drv_spi.c
		Lib/nRF5_SDK/modules/nrfx/drivers/src/nrfx_clock.c
		Lib/nRF5_SDK/modules/nrfx/drivers/src/nrfx_gpiote.c
		Lib/nRF5_SDK/modules/nrfx/drivers/src/nrfx_spi.c
		Lib/nRF5_SDK/modules/nrfx/drivers/src/nrfx_spim.c
	)

	set_property(SOURCE Lib/nRF5_SDK/modules/nrfx/mdk/gcc_startup_nrf52.S PROPERTY LANGUAGE C)

	# KLL Options
	set( Device_KLL ${Device_KLL} "${CMAKE_CURRENT_SOURCE_DIR}/Lib/nrf5.kll" )
endif ()

#| Kinetis Sources
if ( "${CHIP_SUPPORT}" MATCHES "kinetis" )
	# KLL Options
	set( Device_KLL ${Device_KLL} "${CMAKE_CURRENT_SOURCE_DIR}/Lib/kinetis.kll" )
endif ()

#| Clang needs a few more functions for linking
if ( "${COMPILER}" MATCHES "clang" )
	set( COMPILER_SRCS ${COMPILER_SRCS}
		Lib/clang.c
	)
endif ()

message( STATUS "Compiler Source Files:" )
message( "${COMPILER_SRCS}" )


#| USB Defines, this is how the loader programs detect which type of chip base is used
message( STATUS "Bootloader Type:" )
if ( DFU )
	# XXX (HaaTa) These VID's are deprecated, but are kept as the default for unspecified keyboards
	set( VENDOR_ID       "0x1C11" CACHE STRING "USB Firmware VID" )
	set( PRODUCT_ID      "0xB04D" CACHE STRING "USB Firmware PID" )
	set( BOOT_VENDOR_ID  "0x1C11" CACHE STRING "USB Bootloader VID" )
	set( BOOT_PRODUCT_ID "0xB007" CACHE STRING "USB Bootloader PID" )

	# The | symbol is replaced by a space if in secure mode, or a \0 if not (at runtime)
	set( BOOT_DFU_ALTNAME "Kiibohd DFU|Secure" )

	message( "dfu" )
elseif ( TEENSY )
	set( VENDOR_ID       "0x1C11" CACHE STRING "USB Firmware VID" )
	set( PRODUCT_ID      "0xB04D" CACHE STRING "USB Firmware PID" )
	set( BOOT_VENDOR_ID  "0x16c0" CACHE STRING "USB Bootloader VID" )# TODO Double check, this is likely incorrect
	set( BOOT_PRODUCT_ID "0x0487" CACHE STRING "USB Bootloader PID" )
	message( "Teensy" )
endif ()


#| Compiler flag to set the C Standard level.
#|     c89   = "ANSI" C
#|     gnu89 = c89 plus GCC extensions
#|     c99   = ISO C99 standard
#|     gnu99 = c99 plus GCC extensions
#|     gnu11 = c11 plus GCC extensions
set( CSTANDARD "-std=gnu11" )


#| Warning Options
#|  -Wall...:     warning level
set( WARN "-Wall -ggdb3" )


#| Tuning Options
#|  -f...:        tuning, see GCC manual
#| NOTE: -fshort-wchar is specified to allow USB strings be passed conveniently
#| Bootloader Compiler Flags
if ( BOOTLOADER )

	## Clang Compiler
	if ( "${COMPILER}" MATCHES "clang" )
		# TODO Not currently working, clang doesn't support all the neccessary extensions
		message ( AUTHOR_WARNING "clang doesn't support all the needed extensions, code may need rework to use clang" )
		set ( TUNING "-D_bootloader_ -Wno-main -msoft-float -target arm-none-eabi -mtbm -fdata-sections -ffunction-sections -fshort-wchar -fno-builtin -fplan9-extensions -fstrict-volatile-bitfields -flto -fno-use-linker-plugin -nostdlib" )

	## GCC Compiler
	else ()
		set ( TUNING "-D_bootloader_ -Wno-main -msoft-float -mthumb -fplan9-extensions -ffunction-sections -fdata-sections -fno-builtin -fstrict-volatile-bitfields -fno-use-linker-plugin -nostdlib" )
		#set( TUNING "-mthumb -fdata-sections -ffunction-sections -fno-builtin -msoft-float -fstrict-volatile-bitfields -flto -fno-use-linker-plugin -fwhole-program -Wno-main -nostartfiles -fplan9-extensions -D_bootloader_" )
	endif ()

#| Firmware Compiler Flags
else ()
	## Clang Compiler
	if ( "${COMPILER}" MATCHES "clang" )
		set ( TUNING "-target arm-none-eabi -nostdlib -fdata-sections -ffunction-sections -fshort-wchar -fno-builtin ${FLOAT}" )

	## GCC Compiler
	else ()
		set( TUNING "-mthumb -nostdlib -fdata-sections -ffunction-sections -fshort-wchar -fno-builtin -nostartfiles -fstack-protector-all ${FLOAT}" )
	endif ()
endif ()


#| Optimization level, can be [0, 1, 2, 3, s].
#|     0 = turn off optimization. s = optimize for size.
#|     (Note: 3 is not always the best optimization level.)
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
set( OPT "0" )
add_definitions("-DDEBUG")
else ()
set( OPT "s" )
endif ()

#| JLink support
#| Used to drop to a breakpoint hardfault handler
#| This isn't something most people would want
if ( JLINK )
add_definitions("-DJLINK")
endif ()


#| Compiler Flags
add_definitions( "-mcpu=${CPU} -DF_CPU=${F_CPU} -D_${CHIP}_=1 -O${OPT} ${TUNING} ${WARN} ${CSTANDARD}" )


#| Linker Flags
if ( BOOTLOADER )
	# Bootloader linker flags
	set( LINKER_FLAGS "${TUNING} -Wl,--gc-sections -fwhole-program -L${CMAKE_CURRENT_SOURCE_DIR}/../Lib/ld -T${CHIP}.bootloader.ld -nostartfiles -Wl,-Map=link.map" )
else ()
	## Clang Compiler
	if ( "${COMPILER}" MATCHES "clang" )
		set( LINKER_FLAGS "-mcpu=${CPU} ${TUNING} -Wl,-Map=link.map,--cref -Wl,--gc-sections -Wl,--no-wchar-size-warning -L${CMAKE_CURRENT_SOURCE_DIR}/Lib/ld -T${CHIP}.ld" )
	else ()
		# Normal linker flags
		set( LINKER_FLAGS "-mcpu=${CPU} ${TUNING} -Wl,-Map=link.map,--cref -Wl,--gc-sections -Wl,--no-wchar-size-warning -L${CMAKE_CURRENT_SOURCE_DIR}/Lib/ld -T${CHIP}.ld" )
	endif ()
endif ()


#| Enable color output with Ninja
if( CMAKE_GENERATOR STREQUAL "Ninja" )
	## Clang Compiler
	if ( "${COMPILER}" MATCHES "clang" )
		add_definitions( "-fcolor-diagnostics" )
	## GCC Compiler
	else ()
		add_definitions( "-fdiagnostics-color=always" )
	endif ()

	# We always use the gcc linker for arm-none-eabi
	set( LINKER_FLAGS "${LINKER_FLAGS} -fdiagnostics-color=always" )
endif ()


#| Hex Flags (XXX, CMake seems to have issues if you quote the arguments for the custom commands...)
set( HEX_FLAGS -O ihex -R .eeprom )


#| Binary Flags
set( BIN_FLAGS -O binary )


#| Lss Flags
if ( "${COMPILER}" MATCHES "clang" )
	set( LSS_FLAGS -section-headers -triple=arm-none-eabi )
else ()
	set( LSS_FLAGS -h -S -z )
endif ()
