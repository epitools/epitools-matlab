function runAllMyTests

import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;
import matlab.unittest.plugins.TAPPlugin;
import matlab.unittest.plugins.ToFile;
try
    % Create the suite and runner
    suite = TestSuite.fromFolder('./tests_*', 'IncludingSubfolders', true);
    runner = TestRunner.withTextOutput;

    % Add the TAPPlugin directed to a file in the Jenkins workspace
    tapFile = fullfile(getenv('WORKSPACE'), 'test-reports/','testResults.tap');
    runner.addPlugin(TAPPlugin.producingOriginalFormat(ToFile(tapFile)));

    runner.run(suite); 
catch e;
    disp(e.getReport);
    exit(1);
end;
exit force;
