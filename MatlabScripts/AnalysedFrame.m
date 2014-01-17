classdef AnalysedFrame
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        As
        Orient 
        ERs 
        D
        DD 
        Centers  
        RDists 
    end
    
    methods
        function obj = appendFrame(obj,P)
            obj.As = [obj.As P.As];
            obj.Orient = [obj.Orient P.Orient];
            obj.ERs = [obj.ERs P.ERs];
            obj.D = [obj.D P.D];
            obj.DD = [obj.DD P.DD];
            obj.Centers = [obj.Centers P.Centers];
            obj.RDists = [obj.RDists P.RDists];
        end
    end
    
end

