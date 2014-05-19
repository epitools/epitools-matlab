function Registration(DataSpecificsPath)
%Registration Registers image sequence in Time to correct for sample movement
%   DataSpecificsPath - Path Data to analyze (See InspectData function)
load(DataSpecificsPath);

load([AnaDirec,'/ProjIm']);

progressbar('Registering images...');

RegIm = RegisterStack(ProjIm);

progressbar(1);

% inspect results
StackView(RegIm);

%saving results
save([AnaDirec,'/RegIm'],'RegIm');

end

