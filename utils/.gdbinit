# arm-none-eabi-gdb debug utility
# designed by PengShulin <trees_peng@163.com>

python 
import os
CHIP=os.getenv("CHIP")
if CHIP is None:
    chip='stm32l152rb'
    chip='stm32f103ze'
    chip='stm32f103rb'
    chip='stm32f407ve'
    chip='lpc4337'
    chip='stm32f429ig'
    chip='stm32f407zg'
else:
    chip = CHIP
print 'set chip as %s'% chip

import glob
import os, os.path
try:
    dbg_file=glob.glob('*_dbg.elf')[0]
    print "found debug file %s..."% dbg_file
except: 
    dbg_file=None
    print "not debug file found."
    
class dump_array(gdb.Command):
    fname = '/dev/shm/float_array'
    def __init__ (self):
        super (dump_array, self).__init__ ("dump_array", gdb.COMMAND_USER)

    def invoke (self, arg, from_tty):
        args = arg.split()
        try:
            var = args[0]
        except:
            print 'error varname parms'
            return
        try:
            size = int(args[1])
        except IndexError:
            size = None  # not assigned
        except:
            print 'error size parms'
            return
        f = open(self.fname, 'w+')
        print 'dump %s...'% var
        v = gdb.parse_and_eval(var)
        #print v 
        if size is None:
            # now check the actual size
            _t, _s = str(v.type).split()
            assert _t == 'float'
            size = int(_s[1:-1])
            assert size > 0
            #print 'size=%d'% size
        for i in range(size):
            f.write( '%s\n'% v[i] )
        f.close()
dump_array()


class sptk_watch(gdb.Command):
    def __init__ (self):
        super (sptk_watch, self).__init__ ("sptk_watch", gdb.COMMAND_USER)

    def invoke (self, arg, from_tty):
        args = arg.split()
        if len(args) < 2:
            print 'error parms'
            return 
        var = args[0]
        location = ' '.join(args[1:])
        print var, '@', location
        existing=False
        bps = gdb.breakpoints()
        if bps:
            for b in bps:
                b.enabled = False
                if b.location == location:
                    existing = True
                    bp = b
        if existing:
            bp.enabled = True
        else:
            gdb.Breakpoint(location) 
        while True:
            gdb.execute( 'c' )
            gdb.execute( 'dump_array %s'% var )
            open('/dev/shm/sptk_dsp.fifo','a').write('update\n')

sptk_watch()

end

######################################################################

define init_regs
python
chip_mem_configs = {

'stm32f030f4': [
[ 0x08000000, 0x08003FFC, 'ro', 32, True,  'Flash 16k' ],
[ 0x20000000, 0x20000FFC, 'rw', 32, False, 'SRAM 4k' ],
[ 0x40000000, 0x4007FFFC, 'rw', 32, False, 'Peripherals', ],
],


'stm32l152rb': [
[ 0x08000000, 0x0801FFFC, 'ro', 32, True,  'Flash 128k' ],
[ 0x20000000, 0x20003FFC, 'rw', 32, False, 'SRAM 16k' ],
[ 0x22000000, 0x23FFFFFC, 'rw', 32, False, '' ],
[ 0x40000000, 0x4007FFFC, 'rw', 32, False, 'Peripherals', ],
[ 0x08080000, 0x08080FFF, 'rw', 8,  False, 'EEPROM 4k' ],
],

'stm32f103rb': [
[ 0x08000000, 0x0801FFFC, 'ro', 32, True,  'Flash 128k' ],
[ 0x20000000, 0x20004FFC, 'rw', 32, False, 'SRAM 20k' ],
[ 0x40000000, 0x4007FFFC, 'rw', 32, False, 'Peripherals', ],
],

'stm32f103ze': [
[ 0x08000000, 0x0807FFFC, 'ro', 32, True,  'Flash 512k' ],
[ 0x20000000, 0x20013FFC, 'rw', 32, False, 'SRAM 80k' ],
[ 0x22000000, 0x23FFFFFC, 'rw', 32, False, '', ],
[ 0x40000000, 0x4007FFFC, 'rw', 32, False, 'Peripherals', ],
[ 0x1FFF0000, 0x1FFF7A10, 'ro', 32, False, 'System Memory', ],
[ 0x1FFF7A10, 0x1FFF7A1C, 'ro', 32, True,  'UID', ],
[ 0x1FFFC000, 0x1FFFC008, 'ro', 32, False, 'Option Bytes', ],
[ 0xE0000000, 0xFFFFFFFF, 'rw', 32, False, 'Cortex-M3 Peripherals', ],
[ 0x60000000, 0x63FFFFFE, 'rw', 16, False, 'FSMC/bank1' ],
[ 0x64000000, 0x67FFFFFE, 'rw', 16, False, 'FSMC/bank2' ],
[ 0x68000000, 0x6BFFFFFE, 'rw', 16, False, 'FSMC/bank3' ],
[ 0x6C000000, 0x6FFFFFFE, 'rw', 16, False, 'FSMC/bank4' ],
],

'stm32f207ve': [
[ 0x08000000, 0x081FFFFC, 'ro', 32, True,  'Flash 1024k' ],
[ 0x20000000, 0x2001FFFC, 'rw', 32, False, 'SRAM 128k' ],
[ 0x40000000, 0x4007FFFC, 'rw', 32, False, 'Peripherals', ],
],

'stm32f407zg': [
[ 0x00000000, 0x000FFFFC, 'ro', 32, True,  'Flash 1M', ],
[ 0x08000000, 0x080FFFFC, 'ro', 32, True,  '', ],
[ 0x20000000, 0x2001FFFC, 'rw', 32, False, 'SRAM 128k', ],
[ 0x10000000, 0x1000FFFC, 'rw', 32, False, 'CCM SRAM 64k', ],
[ 0x40000000, 0x4007FFFC, 'rw', 32, False, 'Peripherals', ],
[ 0x60000000, 0x63FFFFFE, 'rw', 16, False, 'FSMC/bank1', ],
[ 0x64000000, 0x67FFFFFE, 'rw', 16, False, 'FSMC/bank2', ],
[ 0x68000000, 0x6BFFFFFE, 'rw', 16, False, 'FSMC/bank3', ],
[ 0x6C000000, 0x6FFFFFFE, 'rw', 16, False, 'FSMC/bank4', ],
],

'stm32f429ig': [
[ 0x00000000, 0x000FFFFC, 'ro', 32, True,  'Flash 1M', ],
[ 0x08000000, 0x080FFFFC, 'ro', 32, True,  '', ],
[ 0x20000000, 0x2002FFFC, 'rw', 32, False, 'SRAM 192k', ],
[ 0x10000000, 0x1000FFFC, 'rw', 32, False, 'CCM SRAM 64k', ],
[ 0x40000000, 0x4007FFFC, 'rw', 32, False, 'Peripherals', ],
[ 0xD0000000, 0xD07FFFFE, 'rw', 16, False, 'FMS/Bank6 SDRAM 8M', ],
[ 0xA0000000, 0xA0000FFE, 'rw', 16, False, 'FMC control register', ],
],


'lpc4337': [
[ 0x1A000000, 0x1A07FFFC, 'ro', 32, True,   'FLASH A', ],
[ 0x1B000000, 0x1B07FFFC, 'ro', 32, True,   'FLASH B', ],
[ 0x20040000, 0x20043FFC, 'ro', 32, True,   'EEPROM', ],
[ 0x10000000, 0x10007FFC, 'rw', 32, False,  'SRAM', ],
[ 0x10080000, 0x10089FFC, 'rw', 32, False,  '', ],
[ 0x20000000, 0x2000FFFC, 'rw', 32, False,  '', ],
[ 0x28000000, 0x2FFFFFFC, 'rw', 32, False,  'SDRAM', ],
[ 0x10400000, 0x1040FFFC, 'ro', 32, True,   'ROM', ],
],

}

if chip in chip_mem_configs.keys():
    for saddr, eaddr, mode, bits, cached, descr in chip_mem_configs[chip]:
        cmd = 'mem 0x%08X 0x%08X %s %d %s'% (saddr, eaddr, mode, bits, 'cache' if cached else 'nocache')
        #print cmd
        gdb.execute(cmd)
else:
    print 'warning: no chip memory config found'
end
end

define update_sptk_dsp
echo update sptk_dsp_app
python open('/dev/shm/sptk_dsp.fifo','a').write('update\n')
end

define connect
shell killall -q st-util 
shell killall -q openocd
shell sleep 0.5 
# gdbserver port:
#   4242 - st-util
#   3333 - openocd
#target remote localhost:4242  
target remote localhost:3333
#monitor reset halt
#monitor halt
end


define load_file
python
if dbg_file:
    print "load file %s..."% dbg_file
    gdb.execute('file %s'% dbg_file)
end
end


define program
python 
if dbg_file:
    f = os.path.abspath(dbg_file)
    print "program %s..."% f
    gdb.execute('program %s'% f)
    print "program done"
end
end

define halt
monitor halt
end

define reset
monitor halt
monitor reset init
monitor reset halt
end

define run2main
tbreak main 
continue
end

define loopstep
set verbose off
set confirm off
while (1)
    step
end
end


alias sw = sptk_watch

source .gdbextra

######################################################################
#set pagination off

init_regs
load_file
connect
#program
reset

    
run2main



