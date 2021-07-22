set from_node_rdptr_list [get_keepers LTE_tx_path:inst38|tx_pct_data_mimo_v3:inst9|fifo_inst:fifo2|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_p1v1:auto_generated|rdptr_g*]
set to_node_rdptr_list [get_keepers LTE_tx_path:inst38|tx_pct_data_mimo_v3:inst9|fifo_inst:fifo2|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_p1v1:auto_generated|*ws_dgrp|dffpipe*|dffe*]

set_max_skew -from -to -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.8
set_net_delay -from -to -max -get_value_from_clock_period dst_clock_period -value_multiplier 0.8
set_max_delay -from -to 100
set_min_delay -from -to -100

set from_node_wrptr_list [get_keepers <user hierarchy>|delayed_wrptr_g*]
set to_node_wrptr_list [get_keepers <user hierarchy>|*rs_dgwp|dffpipe*|dffe*]

set_max_skew -from -to -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.8
set_net_delay -from -to -max -get_value_from_clock_period dst_clock_period -value_multiplier 0.8
set_max_delay -from -to 100
set_min_delay -from -to -100

set from_node_mstable_ws_list [get_keepers <user hierarchy>|*ws_dgrp|dffpipe*|dffe*]
set to_node_mstable_ws_list [get_keepers <user hierarchy>|*ws_dgrp|dffpipe*|dffe*]
set_net_delay -from -to -max -get_value_from_clock_period dst_clock_period -value_multiplier 0.8

set from_node_mstable_rs_list [get_keepers <user hierarchy>|*rs_dgwp|dffpipe*|dffe*]
set to_node_mstable_rs_list [get_keepers <user hierarchy>|*rs_dgwp|dffpipe*|dffe*]
set_net_delay -from -to -max -get_value_from_clock_period dst_clock_period -value_multiplier 0.8