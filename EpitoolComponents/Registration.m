function Registration(DataSpecificsPath, params)
%Registration Registers image sequence in Time to correct for sample movement
%   DataSpecificsPath - Path Data to analyze (See InspectData function)
load(DataSpecificsPath);

load([AnaDirec,'/ProjIm']);

if(params.useStackReg)
    RegIm = stackRegWrapper(ProjIm);
else
    progressbar('Registering images... (please wait)');
    RegIm = RegisterStack(ProjIm,params);
    progressbar(1);
end


% inspect results
if params.InspectResults
    StackView(RegIm);
end

%saving results
save([AnaDirec,'/RegIm'],'RegIm');

end

