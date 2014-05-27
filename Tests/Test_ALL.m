%% TEST ALL

currentpath = pwd;
run('test_woGUI.m');

run('test_woGUI_singleFrame.m')

cd(currentpath)
run('RepeatTrackingGUI_test.m')

cd(currentpath)
run('RepeatTrackingGUI_test_SingleFrame.m')