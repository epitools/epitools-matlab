% Execute Client Process - Executed from Server instance 

% Launch new matlab instance

% Launch client process

runtime = java.lang.Runtime.getRuntime();
process = runtime.exec('matlab -nodesktop -nosplash');  % non-blocking
rc = process.exitValue();  % fetch an ended process' return code

