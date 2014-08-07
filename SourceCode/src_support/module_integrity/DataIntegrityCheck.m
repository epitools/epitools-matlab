function argout = DataIntegrityCheck(hObject, handles, varargin)
% Global_IntegrityCheck is intended to check for the integrity of all the
% directory specified in the analysis file. This operation is required when
% the user is sharing files between different machines.
%
% Check if the Machine MAC ID saved in the file is identic to the current
% machine MAC ID * if not, thrown an exception and run a discovery in the
% current folder where the analysis file has been loaded.

hMainGui = getappdata(0, 'hMainGui');

argout = true;

if(isappdata(hMainGui,'settings_objectname'))
    if(isa(getappdata(hMainGui,'settings_objectname'),'settings'))
        
        stgObj = getappdata(hMainGui,'settings_objectname');
        
        
        % The analysis file has been generated on the same machine
        % where it is has been loaded.
        
        % Get the mac address of the machine running the analysis and
        % format it in the right way [00:00:00:00:00:00]
        ni = java.net.NetworkInterface.getNetworkInterfaces;
        addr = abs(ni.nextElement.getHardwareAddress);
        addr_allOneString = sprintf('%.0f:' , addr);
        addr_allOneString = addr_allOneString(1:end-1);% strip final comma
        

        if (strcmp(stgObj.platform_id, addr_allOneString))
         
            % Check for integrity of those folders specified in the setting
            % object
            
            lstDirExistance = StartDiscovery();  
            
            % Ask for user manual intervention in case directory integrity 
            % is lost.
            
            ManualFetching();
            
     
        else
            
            % When the analysis file was generated on a different machine
            % (sharing files between users/computers) the probability that
            % the user has moved the analysis file together with the
            % analysis folder is higher. Hence, run a discovery around the
            % analysis file path.
            
            
            %AutoFetching(varargin{1});
            
            
            % However, in case the search is unsuccesful, ask for user
            % manual intervention in case directory integrity is lost.
            
            lstDirExistance = StartDiscovery();
            
            % Ask for user manual intervention in case directory integrity is lost
            ManualFetching();
            
                     
            
        end
    end
    
end

    
%     function idx = substrmatch(word,cellarray)    
%         idx = ~cellfun(@isempty,strfind(word,cellarray));
%     end
% 
% 
%     function newcell = findmatching(word,oldcell)    
%         newcell = oldcell(substrmatch(word,oldcell));
%     end
%     
%     function  argout = AutoFetching(strCurrentDirectory)
%         argout = true;
%         
%         substrmatch =@(x,y) ~cellfun(@isempty,strfind(y,x));
%         findmatching =@(x,y) y(substrmatch(x,y));
%         
%         
%         lstImplementedDirNames = {'Analysis', 'Benchmark', 'Images', 'Data' };  
%         
%         lstItemsCurDir = dir(strCurrentDirectory);
%         idx = find([lstItemsCurDir.isdir] == true);
%         
%         for o=1:numel(lstDirExistance{cell2mat(lstDirExistance(:,3))==0,1})  
%             
%             
%             intIndexFound = find(strcmp(lstItemsCurDir(4).name, lstImplementedDirNames));
%             
%             switch intIndexFound
%                 case 1
%                 case 2
%                 case 3
%                 case 4
%                 otherwise
%             end
%             
%         end
%                     
%         
%         
%     end

    function argout = ManualFetching()
    % Ask for user manual intervention in case directory integrity is lost
        
        argout = true;
        
        if (sum(cell2mat(lstDirExistance(:,3))) < size(lstDirExistance,1))
            for i=1:size(lstDirExistance,1)
                if (cell2mat(lstDirExistance(i,3)) == 0)
                    
                    IntegrityPathRequestGUI(lstDirExistance(i,:));
                    
                end
            end
        end
    end

    function  lstDirExistance = StartDiscovery()
        % Supported directory variables
        regexDIR = {'(path|dir)'};
        arrayFields = fields(stgObj);
        intDIRidx = find(~cellfun(@isempty,regexp(arrayFields,regexDIR)));
        
        % Initialising integrity check list
        lstDirExistance = {};
        
        for i=1:numel(intDIRidx)
            
            if(stgObj.(char(arrayFields(intDIRidx(i)))))
                
                switch exist(stgObj.(char(arrayFields(intDIRidx(i)))),'dir')
                    
                    case 0 % it does not exist
                        
                        % Filling the list
                        lstDirExistance(i,:) = {char(arrayFields(intDIRidx(i))),stgObj.(char(arrayFields(intDIRidx(i)))),0};
                        
                    case 7 % it exists and it is a folder
                        
                        % Filling the list
                        lstDirExistance(i,:) = {char(arrayFields(intDIRidx(i))),stgObj.(char(arrayFields(intDIRidx(i)))),1};
                        
                    otherwise
                        
                        warning('MATLAB:ambiguousSyntax','Something went wrong here. I could not determine the existance of the following path: %s', stgObj.(char(arrayFields(intDIRidx(i)))) )
                end
                
            end
            
            
        end
        
    end
end