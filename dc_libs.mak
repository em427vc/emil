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

# ----------- LIBS ----------- #
ifeq ($(multi_file), true)
	dc_lib_gen += driver_bal_itcm
	dc_lib_gen += driver_bal
	ifeq ($(approbated_lib), true)
		lib += app/$(project)/libs/driver_bal_fs_itcm.lib
		lib += app/$(project)/libs/driver_bal_fs.lib
	else
		ifeq ($(drives_control_functional_safety), ENABLED)
			dc_lib_gen += driver_bal_fs_itcm
			dc_lib_gen += driver_bal_fs
		endif
	endif
else 
	dc_lib_gen += driver
	dc_lib_gen += bal
	ifeq ($(approbated_lib), true)
		lib += app/$(project)/libs/driver_fs.lib
		lib += app/$(project)/libs/bal_fs.lib
	else
		ifeq ($(drives_control_functional_safety), ENABLED)
			dc_lib_gen += driver_fs
			dc_lib_gen += bal_fs
		endif
	endif
endif

dc_lib_gen += dc_scheduler
dc_lib_gen += params
dc_lib_gen += dc_fshandler
ifeq ($(approbated_lib), true)
	lib += app/$(project)/libs/fs_handler.lib
	lib += app/$(project)/libs/param_fs.lib
else
	ifeq ($(drives_control_functional_safety), ENABLED)
		dc_lib_gen += fs_handler
		dc_lib_gen += params_fs
	endif
endif

ifeq ($(drives_control_diagnostic_component_enabled), ENABLED)
    dc_lib_gen += diag_services
endif

dc_lib_gen += error_mng
dc_lib_gen += motor_control
dc_lib_gen += ecu_driver
dc_lib_gen += version_info

### ------ Optim Level ------ ###
# Use name of library and add "_optlevel"
# Specify optim level wiht -Ox, where 
# x is any number from 0 to 3, or write
# x is "space", "time"
# eg. driver_optlevel = -O3
# eg. driver_optlevel = -Otime
# If left blank, default optim level
# is used (general for all files) 

driver_optlevel =
bal_optlevel =
driver_fs_optlevel =
bal_fs_optlevel =

driver_bal_itcm =
driver_bal =
driver_bal_fs_itcm =
driver_bal_fs =

dc_scheduler_optlevel =
params_optlevel =
fs_handler_optlevel =
params_fs_optlevel =
diag_services_optlevel =
error_mng_optlevel =
motor_control_optlevel =
ecu_driver_optlevel =
version_info_optlevel =

### ------------------------- ###

# ----------- Driver + DC BAL ----------- #
ifeq ($(multi_file), true)
	driver_bal_itcm_files = $(addprefix $(path_to_dc)/, $(driver_all_itcm))
	driver_bal_itcm_files += $(addprefix $(path_to_dc)/, $(bal_all_itcm))
	driver_bal_itcm_src = $(addsuffix .c, $(addprefix drives_control/driver/,driver_bal_itcm.o))
	
	driver_bal_fs_itcm_files = $(addprefix $(path_to_dc)/, $(driver_fs_all_itcm))
	driver_bal_fs_itcm_files += $(addprefix $(path_to_dc)/, $(bal_fs_all_itcm))
	driver_bal_fs_itcm_src = $(addsuffix .c, $(addprefix drives_control/driver/,driver_bal_fs_itcm.o))
	
	driver_bal_files = $(addprefix $(path_to_dc)/, $(driver_all))
	driver_bal_files += $(addprefix $(path_to_dc)/, $(bal_all))
	driver_bal_src = $(addsuffix .c, $(addprefix drives_control/driver/,driver_bal.o))
	
	driver_bal_fs_files = $(addprefix $(path_to_dc)/, $(driver_fs_all))
	driver_bal_fs_files += $(addprefix $(path_to_dc)/, $(bal_fs_all))
	driver_bal_fs_src = $(addsuffix .c, $(addprefix drives_control/driver/,driver_bal_fs.o))
else
	bal_src = $(bal_all)
	bal_fs_src = $(bal_fs_all)
	driver_src = $(driver_all)
	driver_fs_src = $(driver_fs_all)
endif


# ----------- DC Scheduler ----------- #
ifeq ($(multi_file), true)
	dc_scheduler_files = $(addprefix $(path_to_dc)/, $(dc_scheduler_all))
	dc_scheduler_src = $(addsuffix .c, $(addprefix drives_control/services/dc_scheduler/,dc_scheduler.o))
else
	dc_scheduler_src = $(dc_scheduler_all) 
endif


# ----------- Params ----------- #
ifeq ($(multi_file), true)
	params_files = $(addprefix $(path_to_dc)/, $(params_all))
	params_src = $(addsuffix .c, $(addprefix drives_control/services/params/,params.o))
	
	params_fs_files = $(addprefix $(path_to_dc)/, $(params_fs_all))
	params_fs_src = $(addsuffix .c, $(addprefix drives_control/services/params/,params_fs.o))	
else
	params_src = $(params_all)
	params_fs_src = $(params_fs_all)
endif


# ----------- FS Handler ----------- #
ifeq ($(multi_file), true)
	fs_handler_files = $(addprefix $(path_to_dc)/, $(fs_handler_all))
	fs_handler_src = $(addsuffix .c, $(addprefix drives_control/services/fs_handler/,fs_handler.o))
else
	fs_handler_src = $(fs_handler_all)
endif

ifeq ($(multi_file), true)
	dc_fshandler_files = $(addprefix $(path_to_dc)/, $(dc_fshandler_all))
	dc_fshandler_src = $(dc_fshandler_all)
else
	dc_fshandler_src = $(dc_fshandler_all)
endif


# ----------- Diag ----------- #
ifeq ($(drives_control_diagnostic_component_enabled), ENABLED)
    ifeq ($(multi_file), true)
        diag_services_files = $(addprefix $(path_to_dc)/, $(diag_services_all))
        diag_services_src = $(addsuffix .c, $(addprefix drives_control/services/diag_services/,diag_services.o))
    else
        diag_services_src = $(diag_services_all) 
    endif
endif

# ----------- Error Mng ----------- #
ifeq ($(multi_file), true)
	error_mng_files = $(addprefix $(path_to_dc)/, $(error_mng_all))
	error_mng_src = $(addsuffix .c, $(addprefix drives_control/services/error_mng/,error_mng.o))
else
	error_mng_src = $(error_mng_all) 
endif


# ----------- Motor Control ----------- #
motor_control_src = $(motor_control_all) 


# ----------- Ecu Driver ----------- #
ecu_driver_src = $(ecu_driver_all)
ifeq ($(feature_ecu_driver_extended), ENABLED)
    ifeq ($(ecu_driver_functional_safety), ENABLED)
        ifeq ($(approbated_lib), true)
            lib += app/$(project)/libs/ecu_driver_fs.lib
        else
            ifeq ($(drives_control_functional_safety), ENABLED)
                dc_lib_gen += ecu_driver_fs
            endif
        endif
    endif
endif
ecu_driver_fs_src = $(ecu_driver_fs_all)

# When dc_lib_develop_default is set to true, Linplus takes all files into the process.
dc_lib_develop_default ?= true
$(foreach _lib,$(dc_lib_gen),$(eval $(_lib)_develop=$(dc_lib_develop_default)))

# ----------- Version Info ----------- #
version_info_src = $(version_info_all)

ifeq ($(multi_file), true)
	ifneq ($(approbated_lib), true)
		all_multi_files += $(bal_fs_all)
		all_multi_files += $(bal_fs_all_itcm)
		all_multi_files += $(driver_fs_all)
		all_multi_files += $(driver_fs_all_itcm)
		all_multi_files += $(fs_handler_all)
		all_multi_files += $(params_fs_all)
		all_multi_files += $(ecu_driver_fs_all)
	endif
	all_multi_files += $(bal_all)
	all_multi_files += $(bal_all_itcm)
	all_multi_files += $(driver_all)
	all_multi_files += $(driver_all_itcm)
	all_multi_files += $(dc_scheduler_all)
	all_multi_files += $(motor_control_all)
	ifeq ($(drives_control_diagnostic_component_enabled), ENABLED)
	    all_multi_files += $(diag_services_all)
	endif
	all_multi_files += $(error_mng_all)
	all_multi_files += $(ecu_driver_all)
	all_multi_files += $(params_all)

	sources_no_multi = $(filter-out %.o.c, $(sources))
	
	lintplus_src = $(call filter-out,$(addsuffix /%,$(final_no_code_filter)),$(sources_no_multi))
	lintplus_src += $(all_multi_files)
	
	ifeq (,$(filter $(MAKECMDGOALS) $(MFLAGS),$(no_dep_targets)))
    	# do not include dependency in case of some targets like e.g. clean
    	# so in case of defect dependency file at least clean is a solution
    	dep_files = $(call prepost,$(out_prog_path)/,$(basename $(filter %.c %.cpp, $(sources_no_multi))),.ddd)
		override dep_files += $(call prepost,$(out_prog_path)/,$(basename $(filter %.c %.cpp, $(all_multi_files))),.ddd)
	endif
endif
