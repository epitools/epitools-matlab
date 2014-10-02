@echo off
SET scriptpath=%~dp0
matlab -nodesktop -nosplash -r "cd('%scriptpath%\src');EpiTools;"