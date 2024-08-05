# 
# Synthesis run script generated by Vivado
# 

namespace eval rt {
    variable rc
}
set rt::rc [catch {
  uplevel #0 {
    set ::env(BUILTIN_SYNTH) true
    source $::env(HRT_TCL_PATH)/rtSynthPrep.tcl
    rt::HARTNDb_resetJobStats
    rt::HARTNDb_resetSystemStats
    rt::HARTNDb_startSystemStats
    rt::HARTNDb_startJobStats
    set rt::cmdEcho 0
    rt::set_parameter writeXmsg true
    rt::set_parameter enableParallelHelperSpawn true
    set ::env(RT_TMP) "C:/Users/diego/TFG/pid/.Xil/Vivado-18196-LAPTOP-VRI1VQ46/realtime/tmp"
    if { [ info exists ::env(RT_TMP) ] } {
      file delete -force $::env(RT_TMP)
      file mkdir $::env(RT_TMP)
    }

    rt::delete_design

    rt::set_parameter datapathDensePacking false
    set rt::partid xc7a100tcsg324-1
     file delete -force synth_hints.os

    set rt::multiChipSynthesisFlow false
    source $::env(SYNTH_COMMON)/common.tcl
    set rt::defaultWorkLibName xil_defaultlib

    set rt::useElabCache false
    if {$rt::useElabCache == false} {
      rt::read_vhdl -lib neorv32 {
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_package.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/rtl/core/neorv32_application_image.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_boot_rom.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_bootloader_image.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_intercon.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_cache.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_cfs.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_clockgate.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_fifo.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_cpu_decompressor.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_cpu_control.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_cpu_regfile.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_cpu_cp_shifter.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_cpu_cp_muldiv.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_cpu_cp_bitmanip.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_cpu_cp_fpu.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_cpu_cp_cfu.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_cpu_cp_cond.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_cpu_alu.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_cpu_lsu.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_cpu_pmp.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_cpu.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_crc.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_debug_dm.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_debug_dtm.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_dma.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_dmem.entity.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/mem/neorv32_dmem.default.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_gpio.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_gptmr.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_imem.entity.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/mem/neorv32_imem.default.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_mtime.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_neoled.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_onewire.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_pwm.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_sdi.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_slink.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_spi.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_sysinfo.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_xip.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_xbus.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_wdt.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_uart.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_twi.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_trng.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_xirq.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/core/neorv32_top.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/new/Filter_HALL.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/new/PID_HALLFSM.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/new/PID_TOPSENSOR.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/new/SYNCHRNZR.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/new/cambio_digsel.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/new/decoder.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/new/gen_frec.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/new/pid_gen.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/new/pid_top.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/new/pulse_counter.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/new/pwm_decod.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/new/pwm_gen.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/new/pwm_top.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/new/ralent.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/new/separator.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/imports/new/top_display.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/new/control_top.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/new/top_gpio.vhd
      C:/Users/diego/TFG/pid/pid.srcs/sources_1/imports/sources_1/new/neorv32_test_setup_diego.vhd
    }
      rt::filesetChecksum
    }
    rt::set_parameter usePostFindUniquification false
    set rt::top neorv32_test_setup_diego
    rt::set_parameter enableIncremental true
    rt::set_parameter markDebugPreservationLevel "enable"
    set rt::reportTiming false
    rt::set_parameter elaborateOnly true
    rt::set_parameter elaborateRtl true
    rt::set_parameter eliminateRedundantBitOperator false
    rt::set_parameter dataflowBusHighlighting false
    rt::set_parameter generateDataflowBusNetlist false
    rt::set_parameter dataFlowViewInElab false
    rt::set_parameter busViewFixBrokenConnections false
    rt::set_parameter elaborateRtlOnlyFlow true
    rt::set_parameter writeBlackboxInterface true
    rt::set_parameter merge_flipflops true
    rt::set_parameter srlDepthThreshold 3
    rt::set_parameter rstSrlDepthThreshold 4
# MODE: 
    rt::set_parameter webTalkPath {}
    rt::set_parameter synthDebugLog false
    rt::set_parameter printModuleName false
    rt::set_parameter enableSplitFlowPath "C:/Users/diego/TFG/pid/.Xil/Vivado-18196-LAPTOP-VRI1VQ46/"
    set ok_to_delete_rt_tmp true 
    if { [rt::get_parameter parallelDebug] } { 
       set ok_to_delete_rt_tmp false 
    } 
    if {$rt::useElabCache == false} {
        set oldMIITMVal [rt::get_parameter maxInputIncreaseToMerge]; rt::set_parameter maxInputIncreaseToMerge 1000
        set oldCDPCRL [rt::get_parameter createDfgPartConstrRecurLimit]; rt::set_parameter createDfgPartConstrRecurLimit 1
        $rt::db readXRFFile
      rt::run_rtlelab -module $rt::top
        rt::set_parameter maxInputIncreaseToMerge $oldMIITMVal
        rt::set_parameter createDfgPartConstrRecurLimit $oldCDPCRL
    }

    set rt::flowresult [ source $::env(SYNTH_COMMON)/flow.tcl ]
    rt::HARTNDb_stopJobStats
    if { $rt::flowresult == 1 } { return -code error }


  set hsKey [rt::get_parameter helper_shm_key] 
  if { $hsKey != "" && [info exists ::env(BUILTIN_SYNTH)] && [rt::get_parameter enableParallelHelperSpawn] } { 
     $rt::db killSynthHelper $hsKey
  } 
  rt::set_parameter helper_shm_key "" 
    if { [ info exists ::env(RT_TMP) ] } {
      if { [info exists ok_to_delete_rt_tmp] && $ok_to_delete_rt_tmp } { 
        file delete -force $::env(RT_TMP)
      }
    }

    source $::env(HRT_TCL_PATH)/rtSynthCleanup.tcl
  } ; #end uplevel
} rt::result]

if { $rt::rc } {
  $rt::db resetHdlParse
  set hsKey [rt::get_parameter helper_shm_key] 
  if { $hsKey != "" && [info exists ::env(BUILTIN_SYNTH)] && [rt::get_parameter enableParallelHelperSpawn] } { 
     $rt::db killSynthHelper $hsKey
  } 
  source $::env(HRT_TCL_PATH)/rtSynthCleanup.tcl
  return -code "error" $rt::result
}
