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


sym_var = -SIGNVER
sym_var += 2016


# Build Firmware update SW for selected project
# Quick build, no lint and dependencies
FWU:
ifeq ($(FW_update_type),FWU3)
	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) variant=BootManager clean -s -j
	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) variant=BootManager -s -j auto_dep=false default_targets=link
	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) variant=lromLoader clean -s -j
	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) variant=lromLoader -s -j auto_dep=false default_targets=link
	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) variant=programmer clean -s -j
	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) variant=programmer -s -j auto_dep=false default_targets=link
	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) variant=ramLoader clean -s -j
	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) variant=ramLoader -s -j auto_dep=false default_targets=link
else
	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) variant=romLoader clean -s -j
	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) variant=romLoader -s -j auto_dep=false default_targets=link
	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) variant=ramLoader clean -s -j
	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) variant=ramLoader -s -j auto_dep=false default_targets=link
endif

APP_DATA:
#	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) clean -s -j
#	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) -s -j
	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) variant=NSR_DATA -s -j clean
	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) variant=NSR_DATA -s -j
	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) variant=SR_DATA -s -j clean
	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) variant=SR_DATA -s -j
	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) variant=PT_DATA -s -j clean
	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) variant=PT_DATA -s -j
	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) variant=PT2_DATA -s -j clean
	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) variant=PT2_DATA -s -j
	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) variant=PT3_DATA -s -j clean
	-$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(MFLAGS) variant=PT3_DATA -s -j

wf: flash_only

#copy to debug target (if not build already it will build it)
postlink: patchbin
ifneq ($(dc_postlink), false)
	@$(maksym) -TENG=Register $(dwarf_file) $(sym_var) > $(sym_base).sy2
ifeq ($(smoke_test_on), true)
	@$(maksym) -TENG=Register $(dwarf_file) $(sym_var) -CF $(dc_path)/cfg_app/_test_app/ControlFile$(MOC).cfg > $(sym_base)_SmokeTest.sy2
endif
ifeq ($(DC_SCHEDULER_STATS), TRUE)
	@$(maksym) -TENG=Register $(dwarf_file) $(sym_var) -CF $(dc_path)/cfg_app/_test_app/ControlFileDcStats.cfg > $(sym_base)_DcStats.sy2
endif
ifeq ($(variant), $(filter $(variant), $(built_in_variants)))
	$(call copy, $(patchbin_out_mot), $(debug_path)/)
	@$(call prntGr,"--------Copying $(variant) motorola file done-------------\n\n")
else
ifeq ($(split_app), true)
	@$(patchbin) -silent1 -i(0x$(app2_store_crc),0x$(app2_end_crc))$(patchbin_out_mot) $(app2_data_bin_out_opt)
#ifneq ($(strip $(build_type)),RELEASE)
#	$(sec_MotSigner) -bin $(patchbin_out_bin_2) -binout $(patchbin_out_bin_2)
#endif
endif
ifeq ($(data_sections_bin), true)
	@echo --- Generating data_sections .bin files ---
	@$(patchbin) -silent1 -i(0x$(pt_store_crc),0x$(pt_end_crc))$(patchbin_out_mot) $(pt_data_bin_out_opt)
	@$(patchbin) -silent1 -i(0x$(pt2_store_crc),0x$(pt2_end_crc))$(patchbin_out_mot) $(pt2_data_bin_out_opt)
	@$(patchbin) -silent1 -i(0x$(pt3_store_crc),0x$(pt3_end_crc))$(patchbin_out_mot) $(pt3_data_bin_out_opt)
	@$(patchbin) -silent1 -i(0x$(nsr_store_crc),0x$(vc_end_crc))$(patchbin_out_mot) $(nsr_data_bin_out_opt)
	@$(patchbin) -silent1 -i(0x$(sr_store_crc),0x$(fs_end_crc))$(patchbin_out_mot) $(sr_data_bin_out_opt)
	@$(call prntGr,"-----Generating .bin file done-----\n\n")
endif
	@echo --- Copying required Debug files ---

	$(call copy, $(dwarf_file), $(debug_path)/CompTest.elf)
	$(call copy, $(sym_file), $(debug_path)/CompTest.sym)
	$(call copy, $(patchbin_out_mot), $(debug_path)/CompTest.mot)
	$(call copy, $(patchbin_out_hex), $(debug_path)/CompTest.hex)
	$(call copy, $(patchbin_out_bin), $(debug_path)/CompTest.bin)
	$(call copy, $(map_file), $(debug_path)/CompTest.map)
	$(call copy, $(sym_base).syc, $(debug_path)/CompTest.syc)
	$(call copy, $(sym_base).sy2, $(debug_path)/CompTest.sy2)
ifeq ($(smoke_test_on), true)
	$(call copy, $(sym_base)_SmokeTest.sy2, $(debug_path)/CompTest_SmokeTest.sy2)
endif
ifeq ($(DC_SCHEDULER_STATS), TRUE)
	$(call copy, $(sym_base)_DcStats.sy2, $(debug_path)/CompTest_DcStats.sy2)
endif
	
ifeq ($(platform), stm32g4)
	$(call copy, $(option_byte_sb).hex, $(debug_path)/opt_byte_sb.hex)
	$(call copy, $(option_byte_sb).mot, $(debug_path)/opt_byte_sb.mot)
	$(call copy, $(flash_ob_code_bat), $(debug_path)/)
	$(call copy, $(flash_code_bat), $(debug_path)/)
	$(call copy, $(flash_ob_bat), $(debug_path)/)
	$(call dircopy, $(st_tool), $(debug_path)/stflash/)
endif
	$(call copy, $(linkerScript), $(debug_path)/)
	$(call copy, $(ramloader_file), $(debug_path)/)
	$(call copy, $(lromloader_file), $(debug_path)/)
	$(call copy, $(bootmanger_file), $(debug_path)/)
	$(call copy, $(programmer_file), $(debug_path)/)
	$(call copy, $(winflash_cfg_file), $(debug_path)/)
		
#	$(call copy, C://Temp/ePactDC-BuildLog.txt, $(debug_path)/)
	@echo $(C_options) > $(debug_path)/ccopt.txt
	@echo $(linkopt) > $(debug_path)/linkopt.txt
	
	@$(call prntGr,"--------Copying done-------------\n\n")
ifeq ($(copy_dc_libs), true)
	@echo --- Copying delivery libraries ---
	$(call mkdir, app/$(project)/lib)
	$(foreach lib, $(lib_gen), $(call copy, $(out_prog_path)/$(lib).lib, app/$(project)/lib/$(lib).lib))
	@$(call prntGr,"--------All done-------------\n\n")
endif
endif
endif

postlink_data: patchbin
	@$(patchbin) -silent1 -i(0x$(data_start),0x$(data_end_crc))$(patchbin_out_mot) $(patchbin_binary_out_opt)
#	@$(sec_MotSigner) -bin $(patchbin_out_bin) -binout $(patchbin_out_bin)
	$(call copy, $(patchbin_out_mot), $(debug_path)/$(variant).mot)
	$(call copy, $(patchbin_out_hex), $(debug_path)/$(variant).hex)
	$(call copy, $(patchbin_out_bin), $(debug_path)/$(variant).bin)
	@$(call prntGr,"--------Copying done-------------\n\n")



version:
	@echo ## drives_control (v$(EPDC_VERSION)), MCU_FW(v$(MCU_FW_VERSION))
	@echo -- No change --
	@$(call prntGr,"\n")
	@echo ### al (v$(AL_VERSION)) - fs_al (v$(FS_AL_VERSION))
	@echo -- No change --
	@$(call prntGr,"\n")
	@echo ### driver (v$(DRVR_VERSION)) - fs_driver (v$(FS_DRVR_VERSION))
	@echo -- No change --
	@$(call prntGr,"\n")
	@echo ### ecu_driver (v$(ECU_VERSION)) - fs_ecu_driver (v$(FS_ECU_DRVR_VERSION))
	@echo -- No change --
	@$(call prntGr,"\n")
	@echo ### scheduler (v$(SCH_VERSION))
	@echo -- No change --
	@$(call prntGr,"\n")
	@echo ### diag_services (v$(DIAG_VERSION))
	@echo -- No change --
	@$(call prntGr,"\n")
	@echo ### error_mng (v$(ERRMNG_VERSION))
	@echo -- No change --
	@$(call prntGr,"\n")
	@echo ### fs_handler (v$(FS_HDL_VERSION))
	@echo -- No change --
	@$(call prntGr,"\n")
	@echo ### motor_control
	@echo #### MIS (v$(MIS_MOC_VERSION)):
	@echo -- No change --
	@$(call prntGr,"\n")
	@echo #### NIS (v$(NIS_MOC_VERSION)): 
	@echo -- No change --
	@$(call prntGr,"\n")
	@echo #### BIS (v$(BIS_MOC_VERSION)):
	@echo -- No change --
	@$(call prntGr,"\n")
	@echo #### EDL (v$(EDL_MOC_VERSION)):
	@echo -- No change --
	@$(call prntGr,"\n")
	@echo #### LIN (v$(LIN_MOC_VERSION)):
	@echo -- No change --
	@$(call prntGr,"\n")
	@echo #### GIS (v$(GIS_MOC_VERSION)):
	@echo -- No change --
	@$(call prntGr,"\n")
	@echo ### params (v$(PARM_VERSION)) - fs_params (v$(FS_PARM_VERSION))

	@echo -- No change --
	@$(call prntGr,"\n")
	@echo ### version_info (v$(VERINFO_VERSION))
	@echo -- No change --
	
sprint_release:
	@echo Sprint$(sprint)
	@echo NON SAFETY RELEVANT
	@echo drives_control (v$(EPDC_VERSION)), MCU_FW(v$(MCU_FW_VERSION))
	@echo al (v$(AL_VERSION))
	@echo driver (v$(DRVR_VERSION))
	@echo ecu_driver (v$(ECU_VERSION))
	@echo scheduler (v$(SCH_VERSION))
	@echo diag_services (v$(DIAG_VERSION))
	@echo error_mng (v$(ERRMNG_VERSION))
	@echo motor_control
	@echo MIS (v$(MIS_MOC_VERSION)):
	@echo NIS (v$(NIS_MOC_VERSION)): 
	@echo BIS (v$(BIS_MOC_VERSION)):
	@echo EDL (v$(EDL_MOC_VERSION)):
	@echo LIN (v$(LIN_MOC_VERSION)):
	@echo GIS (v$(GIS_MOC_VERSION)):
	@echo params (v$(PARM_VERSION))
	@echo version_info (v$(VERINFO_VERSION))
	@echo whitespace
	@echo SAFETY RELEVANT
	@echo fs_al (v$(FS_AL_VERSION))
	@echo fs_driver (v$(FS_DRVR_VERSION))
	@echo fs_ecu_driver (v$(FS_ECU_DRVR_VERSION))
	@echo fs_handler (v$(FS_HDL_VERSION))
	@echo fs_param (v$(FS_PARM_VERSION))
	@echo line
	@echo EPIC_GENERIC $(EPIC_GENERIC)
	@echo EPIC_ADMDU_Gen2 $(EPIC_ADMDU_Gen2)
	@echo EPIC_GV_660 $(EPIC_GV_660)
	@echo EPIC_CADOC $(EPIC_CADOC)
	@echo EPIC_GV_650_AX $(EPIC_GV_650_AX)
	@echo EPIC_MUD1 $(EPIC_MUD1)
	@echo EPIC_MUD2 $(EPIC_MUD2)
	@echo EPIC_NALA $(EPIC_NALA)
	@echo EPIC_PUMU_Light_1G5 $(EPIC_PUMU_Light_1G5)
	@echo EPIC_PUMU_Ventilation $(EPIC_PUMU_Ventilation)
	@echo EPIC_PUMU_1G5_U $(EPIC_PUMU_1G5_U)
	@echo EPIC_PUMU_1G5 $(EPIC_PUMU_1G5)
	@echo EPIC_PUMUDU_1G5 $(EPIC_PUMUDU_1G5)
	@echo EPIC_ADM_MPFU $(EPIC_ADM_MPFU)
	@echo EPIC_DUHP $(EPIC_DUHP)
	@echo EPIC_GV_660_Zeolith $(EPIC_GV_660_Zeolith)
	@echo EPIC_REFRIGERATOR $(EPIC_REFRIGERATOR)
	@echo EPIC_PUMU_BEA $(EPIC_PUMU_BEA)
	@echo EPIC_LULIUS $(EPIC_LULIUS)

hash:
	@$(python) $(fs_hash) -Dgethash -V$(fs_file) -A$(approbated_file) -ETag_v$(EPDC_VERSION) -FFS_DC -P$(project)

appr:
	@$(python) $(fs_hash) -Dapprobate -V$(fs_file) -A$(approbated_file) -E$(EPDC_VERSION) -F$(FS_DC_VESRION)  -P$(project)
	
excel:
ifeq ($(approbation), true)
	@if exist $(out_prog_path)/lint_hash.txt ($(python) $(dc_mixed_path)\python_scripts\excel.py XLSX $(out_prog_path)/lint_hash.txt $(word_count) $(EPDC_VERSION) $(sprint)) else (echo Run Lint first)
else
	@echo This mode is available only when approbation set to true!!!
endif

varHeader = $(app_path)/prog/$(variant).h

$(out_prog_path)/%.o.o : $($(*F)_files) $(varHeader)
	@echo compiling $(basename $@)
	$(call mkdir, $(dir $@))  
	@$(cc) $(copt) $(ccopt) $(time_opt) $($(*F)_optlevel) --multifile $($(*F)_files) -o $@
	@if exist $(subst /,\,$(basename $@)).lst del $(subst /,\,$(basename $@)).lst
	@if exist $(subst /,\,$(basename $@)).txt  ren $(subst /,\,$(basename $@)).txt $(*F).o.lst


data_test:
	@echo pt_start_	= $(pt_start)
	@echo pt2_start_	= $(pt2_start)
	@echo pt3_start_	= $(pt3_start)
	@echo nsr_start_	= $(nsr_start)
	@echo sr_start_	= $(sr_start)
ifeq ($(reuse_spare_space), true)
	@echo app2_start_	= $(app2_start)
	@echo app2_size_	= $(app2_size)
endif
	@echo end_ 		= $(next_start5)
	@echo fwu_end_  	= $(FWU_APP1_END_ADDRESS)
	@echo size_ 		= $(data_total_size)

	
data_test2:
	@echo ecu_id_no		= $(ecu_id_no)
	@echo programmer_id_no	= $(programmer_id_no)
	@echo app_id_no		= $(app_id_no)
ifeq ($(pt_data_include), true)
	@echo pt_id_no		= $(pt_id_no)
endif
ifeq ($(pt2_data_include), true)
	@echo pt2_id_no		= $(pt2_id_no)
endif
ifeq ($(pt3_data_include), true)
	@echo pt3_id_no 		= $(pt3_id_no)
endif
ifeq ($(nsr_data_include), true)
	@echo nsr_id_no  		= $(nsr_id_no)
endif
ifeq ($(sr_data_include), true)
	@echo sr_id_no 		= $(sr_id_no)
endif
ifeq ($(reuse_spare_space), true)
	@echo app2_id_no 		= $(app2_id_no)
endif

