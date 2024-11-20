#*******************************************************************************
#  Copyright (c) 2017 BSH Hausgeraete GmbH,
#  Carl-Wery-Str. 34, 81739 Munich, Germany, www.bsh-group.de
#
#  All rights reserved. This program and the accompanying materials
#  are protected by international copyright laws.
#  Please contact copyright holder for licensing information.
#
#*******************************************************************************
#  PROJECT          PP PED FW
#*******************************************************************************
#  Description      generic eP_DC, please do no change!
#*******************************************************************************

# Not used for standard build, used when lint 
# for specific components is needed

ifeq ($(ped_lint), true)
	lint_ped_app = $(ped_fw_src)
	lint_ped_app += $(app_ped_fw_src)
	override sources = $(lint_ped_app)
endif


# ----------------- MOC lint ----------------- 
ifeq ($(moc_lint), true)
	lint_src_ = $(motor_control_all)
	lint_src_ += $(test_app_src)
#	lint_ped_app += $(app_ped_fw_src)
	override sources = $(lint_src_)
endif


# ----------------- FS Handler lint -----------------
ifeq ($(fs_handler_lint), true)
	lint_src_ = $(fs_handler_all)
	lint_src_ += $(dc_fshandler_src)
#	lint_ped_app += $(app_ped_fw_src)
	override sources = $(lint_src_)
endif


# ----------------- BAL lint -----------------
ifeq ($(bal_lint), true)
	lint_src_ = $(bal_all)
#	lint_ped_app += $(app_ped_fw_src)
	override sources = $(lint_src_)
endif


# ----------------- Driver lint -----------------
ifeq ($(driver_lint), true)
	lint_src_ = $(driver_all)
#	lint_ped_app += $(app_ped_fw_src)
	override sources = $(lint_src_)
endif

common_cert_files = FuncSafe/fsStack.lin
common_cert_files += FuncSafe/fsRom.lin
common_cert_files += FuncSafe/fsReg.lin
common_cert_files += FuncSafe/fsramcon.lin
common_cert_files += FuncSafe/fsramcon.h.lin
common_cert_files += FuncSafe/fs_psm.lin
common_cert_files += FuncSafe/fs_psm.h.lin
common_cert_files += FuncSafe/fsRam.lin
common_cert_files += FuncSafe/fsIsr.lin
common_cert_files += FuncSafe/fsCom.lin
common_cert_files += FuncSafe/fSafe.h.lin
common_cert_files += FuncSafe/fspriv.h.lin
common_cert_files += FuncSafe/armCmx/fs_register_routines.S.lin
common_cert_files += FuncSafe/armCmx/fs_registers_checks_arm_cmx.lin
common_cert_files += FuncSafe/armCmx/fs_Run_Time_Ram.S.lin
common_cert_files += FuncSafe/armCmx/fs_Start_Up_Ram.S.lin
common_cert_files += FuncSafe/armCmx/fs_asm_macros.h.lin

common_files_count = $(words $(common_cert_files))

ifeq ($(approbation), true)
	include $(fs_dc_path)/bal/cert.mak
	include $(fs_dc_path)/driver/cert.mak
	include $(fs_dc_path)/services/fs_handler/cert.mak
	include $(fs_dc_path)/services/params/cert.mak
	ifeq ($(ecu_driver_functional_safety), ENABLED)
		include $(fs_dc_path)/ecu_driver/cert.mak
	endif
	include $(dc_path)/cert.mak
	cert_files += $(common_cert_files)
	cert_files += $(fs_handler_cert_files)
	cert_files += $(fs_params_cert_files)
	cert_files += $(fs_driver_cert_files)
	ifeq ($(ecu_driver_functional_safety), ENABLED)
		cert_files += $(fs_ecu_driver_cert_files)
	endif
	cert_files += $(fs_bal_cert_files)
	cert_files += $(dc_cert_files)
	override lintplus_files = $(call prepost,$(out_prog_path)/,$(cert_files))
	
	ifeq ($(ecu_driver_functional_safety), ENABLED)
		word_count = $(common_files_count)/$(fs_handler_count)/$(fs_params_count)/$(fs_driver_count)/$(fs_ecu_driver_count)/$(fs_bal_count)/$(dc_files_count)
	else
		word_count = $(common_files_count)/$(fs_handler_count)/$(fs_params_count)/$(fs_driver_count)/0/$(fs_bal_count)/$(dc_files_count)
	endif
endif

