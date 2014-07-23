//ImageJ macro to split the confocal movie in 8bit files
//for each time point to batch load them to the deconvolution
//software Huygens;

//author: Davide Heller
//email: davide.heller@imls.uzh.ch
//copyright: Basler Lab 2013-

//ATTENTION:
//before running be sure to unselect the scaling option for
//the conversion in Edit>Options>Conversion!!!

//Parameters: save file with sample suffix AFTER running!
//notice that Bioformats enumeration starts with 1
//i.e. first t,z,c = 1

//time points per movie
time_point_x_file = 3;

//selective Z
z_start = 1;
z_stop = 115;

//threshold after which to cut (max. 256 for 8bit files)
intensity_thr = 230;

//Channel to extract
channel = 1;

//****************************************************

//Check conversion option
Dialog.create("Check point")
Dialog.addMessage("Did you unselect the scaling option?\n"+
		"If not cancel and go to Edit>Options>Conversion")
Dialog.show() 

//t counter
t = 0;

file_name = File.openDialog("Please open the movie to be split");

myDir = File.directory();
pmDir = File.directory() + "SingleTp_conv8bit_outlierThr" + intensity_thr + File.separator;
	
//print(myDir);
if(!File.exists(pmDir)){
	//print("A previous pm directory has been found! Pm directory"+
	//"will be: "+pmDir);
	File.makeDirectory(pmDir);
}

setBatchMode(true);

// get all files
list = getFileList(File.directory());
for (i=0; i<list.length; i++){

   //check if image
   if (endsWith(list[i], '.tif')){

	file_name = myDir + list[i];

	print("Start extracting from:"+file_name);

	run("Bio-Formats Macro Extensions");
	Ext.setId(file_name);
	Ext.getCurrentFile(file);
	Ext.getSizeX(sizeX);
	Ext.getSizeY(sizeY);
	Ext.getSizeZ(sizeZ);
	Ext.getSizeT(sizeT);

	//path = File.directory();

	//loop time points per movie file
	for(j=1; j<=time_point_x_file; j++, t++){

		//generate proper indices
		if(t < 10)
			new_name = "frame_00" + t + ".tif";
		else if(t < 100)
			new_name = "frame_0" + t + ".tif";
		else
			new_name = "frame_" + t + ".tif";
		
		//new_folder = "separated_time_points/";
		run("Bio-Formats", 
		"open=["+file_name+"] color_mode=Default "+
		"specify_range view=Hyperstack stack_order=XYCZT "+
		"c_begin="+channel+" c_end="+channel+" c_step=1 "+
		"z_begin="+z_start+" z_end="+z_stop+" z_step=1 +"+
		"t_begin="+j+" t_end="+j+" t_step=1");

		rename(new_name);

		//substitute artifacts (bright spots)
		slices=nSlices; 

		for (s_i=1; s_i<=slices; s_i++) {
			showProgress(s_i, slices);
 			setSlice(s_i); 
			changeValues(intensity_thr, 65536, 100);
		}

		//possibly further removing outliers if desired
		//run("Remove Outliers...", "radius=2 threshold=100 which=Bright stack");

		run("8-bit");

		saveAs("Tiff", pmDir+new_name);

		print("\t saved "+new_name);

		close();

	}
    }
}

setBatchMode(false);