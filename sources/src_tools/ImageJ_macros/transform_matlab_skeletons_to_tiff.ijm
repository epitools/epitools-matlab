//Script to transform skeleton Images from Matlab to 8bit tiff skeleton files.

//author: Davide Heller
//email : davide.heller@imls.uzh.ch

//source:
//http://fiji.sc/wiki/index.php/How_to_apply_a_common_operation_to_a_complete_directory

function skeletonize_and_convert(input,output, filename) {
	open(input + filename);
        run("8-bit");
	run("Invert");
	setOption("BlackBackground", false);
	run("Skeletonize");
	run("Invert");
        saveAs("Tiff", output + filename);
}

input = getDirectory("Please open the skeleton folder to convert");
output = getDirectory("Please open the output folder");

setBatchMode(true); 
list = getFileList(input);
for (i = 0; i < list.length; i++)
        skeletonize_and_convert(input, output, list[i]);
setBatchMode(false);


