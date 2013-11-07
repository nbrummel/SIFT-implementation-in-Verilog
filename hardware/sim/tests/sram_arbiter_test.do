set MODULE SramArbiterTest
start $MODULE
add wave $MODULE/*
add wave $MODULE/dut/*
run 99999999us
