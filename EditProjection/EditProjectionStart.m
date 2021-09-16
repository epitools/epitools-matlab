% EditProjection startup script

  %filename='1A_fast.tif';
  %frames=60;
  %zslices=21;

  [filename, pathname]=uigetfile('*.tif','Load Image Stack');
  
  if (filename==0)
      disp('no file selected');
  end
  
% number of z-slices per stack
answer = inputdlg('Enter number of z slices per stack','Sample', [1 100]);
zslices=str2num( answer{1});
  
disp(sprintf ('Loading.. %s ...', fullfile(pathname,filename)));

Imstack=imread3(fullfile(pathname,filename));

s=size(Imstack);
frames=s(3)/zslices;


EditProjectionGUI(Imstack,zslices,frames);
