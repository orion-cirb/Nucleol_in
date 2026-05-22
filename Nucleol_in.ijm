/*
 * Description: 
 * 		Detect vessel, substract them to the first channel
 * 		Detect walls and substract them
 * 		Compute the Mean intensity of the vascular leak 
 * 		
 * Developed for: Vianney, Brunet's team
 * Author: Thomas Caille @ ORION-CIRB 
 * Date: February 2026
 * Repository: https://github.com/orion-cirb/Orion_Macros.git
 * Dependencies: None
*/

    /* VARIABLES TO CHECK */
////////////////////////////////
extension = ".czi";          
Nucleus_max_size = 10000 //pixels         
Nucleolin_channel = 1;     			  
Nucleus_channel = 3;    
						
/////////////////////////////

setBatchMode(true);

// Make sure nothing is open
close("*");
run("Clear Results");
roiManager("reset");

// Prompt user to select directory containing input images
inputDir = getDirectory("Please select a directory containing images to analyze");

// Generate results directory with timestamp
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
resultDir = inputDir + "Results of "+ (month+1) + "-" + dayOfMonth + " at " + hour + "H " + minute + File.separator();
if (!File.isDirectory(resultDir)) {
	File.makeDirectory(resultDir);
}

// Retrieve list of all files in input directory
inputFiles = getFileList(inputDir);

// Create a file named "results.csv" and write headers in it
fileResults = File.open(resultDir + "results.csv");
print(fileResults, "Image name, Nucleus ID, Area ,Mean Intensity, Raw int , int norm, circularity, Aspect Ratio, Nucleol Mean Intensity, Nucleol Raw int, Nucleol int norm, nb slices \n");
run("Set Measurements...", "area mean standard redirect=None decimal=1");



// Process each .nd file in the input directory
for (i = 0; i < inputFiles.length; i++) {
    if (endsWith(inputFiles[i], extension)) {
    	print("- Analyzing file " + inputFiles[i] + " -");
	
		//Open image one by one
		run("Bio-Formats Importer", "open=["+inputDir + inputFiles[i]+"] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT ");
		
		img = getTitle();
		img_root = File.nameWithoutExtension;
		run("Duplicate...", "duplicate channels="+Nucleolin_channel+"");
		nucleolin_title = getTitle();
		run("Z Project...", "projection=[Sum Slices]");
		nucleolin_max_title = getTitle();
		run("Median...", "radius=5");
		
		setAutoThreshold("Triangle dark");
		//run("Threshold...");
		setOption("BlackBackground", true);
		run("Convert to Mask");
	
		//run("Set Measurements...", "area mean standard redirect=None decimal=1");
		run("Analyze Particles...", "size="+Nucleus_max_size+"-Infinity pixel show=Masks clear");
		
		
		
		selectImage(img);
		run("Duplicate...", "duplicate channels="+Nucleus_channel+"");
		run("Z Project...", "projection=[Max Intensity]");
		max_proj_nucleus_title = getTitle();

		run("Duplicate...", " ");
		run("Median...", "radius=10");
		setAutoThreshold("Triangle dark");
		//run("Threshold...");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		
		
		//run("Set Measurements...", "area mean standard redirect="+max_proj_nucleus_title+" decimal=0");
		run("Analyze Particles...", "size="+Nucleus_max_size+"-Infinity pixel show=Masks exclude clear");
		mask_nucleus_filter = getTitle();
		
		
		imageCalculator("Multiply create 32-bit",nucleolin_max_title,mask_nucleus_filter);
		setOption("BlackBackground", true);
		run("Convert to Mask");
		
		run("Analyze Particles...", "size="+Nucleus_max_size+"-Infinity pixel show=Masks exclude clear add");
		
		
		
	
		if (roiManager("count") > 0 ) {
			count = roiManager("count");
			
			for (k = 0 ; k <= count-1; k++) {
			
			selectImage(nucleolin_title);
			run("Duplicate...", "duplicate");
			
			
			roiManager("select", 0);
			run("Median 3D...", "x=2 y=2 z=2");
			
			

			run("Find focused slices", "select=10 variance=0.000 select_only");
			getDimensions(width, height, channels, slices, frames);
			focus_slices = getTitle();
			run("Duplicate...", "duplicate");
			if (slices > 1) {
				run("Z Project...", "projection=[Max Intensity]");
			}
			
			raw_avg_focus = getTitle();
			
			run("Duplicate...", " ");
			roiManager("select", 0);
			
			
			run("Median...", "radius=2");
			run("Clear Outside");
			
			setAutoThreshold("MaxEntropy dark");
			//run("Threshold...");
			run("Convert to Mask");
		
			getMinAndMax(min, max);
			if (max == 255 ) {
				run("Create Selection");
				roiManager("select", 0);
				run("Analyze Particles...", "size=0-Infinity pixel show=Masks clear display");
				getPixelSize(unit, pixelWidth, pixelHeight);
				Table.sort("Area");
				max_area = getResult("Area", nResults-1);
				
				run("Analyze Particles...", "size="+(max_area-1)+"-Infinity show=Masks clear");
				run("Invert LUT");
				run("Create Selection");
				roiManager("add");
				
			}
			
			selectImage(raw_avg_focus);
			roiManager("select", newArray(0,(count)));
			
			roiManager("XOR");
			roiManager("add");
			
			
			//run("Set Measurements...", "area mean integrated redirect=None decimal=1");
			selectImage(focus_slices);
			if (slices > 1) {
				run("Z Project...", "projection=[Average Intensity]");
			}
			
			roiManager("select", count+1);
			List.setMeasurements ;
			area = List.getValue("Area");
			mean = List.getValue("Mean");
			int_Den = List.getValue("RawIntDen");
			int_Den_Norm = List.getValue("IntDen");
			
			
			
			selectImage(focus_slices);
			roiManager("select", count);
			List.setMeasurements ;
			print(fileResults,img_root +","+ k+1+","+ area +","+mean+","+int_Den+","+int_Den_Norm+","+List.getValue("Circ.")+","+List.getValue("AR")+","+List.getValue("Mean")+","+List.getValue("RawIntDen")+","+List.getValue("IntDen")+","+slices);
			//File.close(fileResults);
			
			
			roiManager("select", newArray(0,(count)));
			roiManager("delete");
			
			close(focus_slices);
			
			
		}
		roiManager("save", resultDir+"_"+img_root+"_ROI.zip");
		roiManager("reset");
		} else {
			roiManager("reset");
			continue
		}
		
		


		
		
		
    }
    close("*");
}
setBatchMode(false);
