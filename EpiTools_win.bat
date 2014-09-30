@echo off

SET scriptpath=%~dp0
SET matlabpath="C:\Program Files\MATLAB\R2014a\bin\matlab.exe"

%matlabpath% -nodesktop -nosplash -r "cd('%scriptpath%\src');EpiTools;"
