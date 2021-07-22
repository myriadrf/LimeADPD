# ----------------------------------------------------------------------------
# FILE         : 	wfm_player_x2_top.sdc
# DESCRIPTION  :	Constrains file for wfm_player_x2_top.vhd file
# DATE         :	9:24 AM Tuesday, November 7, 2017
# AUTHOR(s)    :	Lime Microsystems
# REVISIONS    :
# ----------------------------------------------------------------------------
# NOTES:
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
# Exceptions
# ----------------------------------------------------------------------------

# to avoid recovery failures for fifo asynchronous clear. There should be more 
# than one cycle from aclr to wrreq so it safe to ignore this path
set_false_path -from [get_registers *wfm_player_x2_top*edge_pulse*sig_in_risign*]
set_false_path -from [get_registers *wfm_player_x2_top*sync_reg[1]*]