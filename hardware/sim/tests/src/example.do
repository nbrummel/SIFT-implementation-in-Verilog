set MODULE ExampleTest
start $MODULE
add wave $MODULE/*
add wave $MODULE/dut/*
run 100us
