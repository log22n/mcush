/* MCUSH designed by Peng Shulin, all rights reserved. */
#include "mcush.h"
#include "hal.h"


#if USE_CMD_SCPI_IDN
__attribute__((weak)) int cmd_scpi_idn( int argc, char *argv[] )
{
    /* *idn? command ignore all arguments */
    char buf[64];

#ifndef MODEL_STRING
    shell_write_str( shell_str_mcush );
#else
    shell_write_str( MODEL_STRING );
#endif
    shell_write_char( ',' );
#ifndef VERSION_STRING
    shell_write_line( MCUSH_VERSION_STRING );
#else
    shell_write_line( VERSION_STRING );
#endif
    buf[0] = 0;
    if( hal_get_serial_number(buf) && strlen(buf) )
        shell_write_line( buf );

    return 0;
}
#endif


#if USE_CMD_SCPI_RST
__attribute__((weak)) int cmd_scpi_rst( int argc, char *argv[] )
{
    /* *rst command ignore all arguments */
    hal_platform_reset();
    return 0;
}
#endif

