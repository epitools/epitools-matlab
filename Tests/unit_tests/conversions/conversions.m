classdef conversions < matlab.unittest.TestCase
     
    methods (Test)
        
        function testOne(tc)  % Test fails
            tc.verifyEqual(5, 5, 'Testing 5==5');
        end
        
        function testTwo(tc)  % Test passes
            tc.verifyEqual(5, 5, 'Testing 5==5');
        end
        
        function testThree(tc)
            tc.verifyEqual(5, 5, 'Testing 5==5');
        end
    end
     
end