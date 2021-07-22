#Copy and Rename .sof file by hardware version 
file copy -force -- output_files/LimeSDR-QPCIe-lms7_trx.sof output_files/LimeSDR-QPCIe-lms7_trx_HW_1.2.sof
qexec "quartus_cpf -c output_files/jic_rbf_file_setup.cof"
post_message "*******************************************************************"
post_message "Generated programming file: LimeSDR-QPCIe-lms7_trx_HW_1.2.jic" -submsgs [list "Output file saved in /output_files directory"]
post_message "*******************************************************************"
#qexec "quartus_cpf -c output_files/rbf_file_setup.cof"
#.rpd file is generated automaticaly
post_message "*******************************************************************"
post_message "Generated programming file: LimeSDR-QPCIe-lms7_trx_HW_1.1_auto.rpd" -submsgs [list "Output file saved in /output_files directory"]
post_message "*******************************************************************"