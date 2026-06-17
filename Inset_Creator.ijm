// Initialisation
requires("1.54p");
run("Check Required Update Sites");
close("*");
run("Close All");
if (roiManager("count") > 0) {
roiManager("deselect");
roiManager("delete");
}

// Start 
Dialog.create("Start");
Dialog.addMessage("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
Dialog.addMessage("This macro use BioVoxxel plugin...");
Dialog.addMessage("Cite the newest version of the BioVoxxel Figure Tools using https://doi.org/10.5281/zenodo.7268127");
Dialog.addMessage("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
Dialog.addDirectory("Folder containing the images: ","");
Dialog.addCheckbox("Adjust brightness:", true);
Dialog.addCheckbox("Rotate the image: ", false);
Dialog.addCheckbox("Crop the image:", false);
Dialog.addNumber("Number of insert: ", 1);
Dialog.addCheckbox("Check everytime that ROI was added in ROI Manager", true);
Dialog.show();

inputDir = Dialog.getString();
adjBrightness = Dialog.getCheckbox();
rotate = Dialog.getCheckbox();
crop = Dialog.getCheckbox();
insetNbr = Dialog.getNumber();
checkROI = Dialog.getCheckbox();
imgList = getFileList(inputDir);

if (File.exists(inputDir+File.separator+"settingInsetCreator.csv")) {
	preexistingSetting = true;
	print("Loading setting...");
	Table.open(inputDir+File.separator+"settingInsetCreator.csv");
	scLength = Table.get("scLength", 0);
	print("Length of the scale bar for the main image: " + scLength);
	iscLength = Table.get("iscLength", 0);
	print("Length of the scale bar for the insets: " + iscLength);
	scThickness = Table.get("scThickness", 0);
	print("Thickness of the scale bar: " + scThickness);
	scFond = Table.get("scFond", 0);
	print("Font of the scale bar: " + scFond);
	scColor = Table.getString("scColor", 0);
	print("Color of the scale bar: " + scColor);
	dim = Table.getString("dim", 0);
	print("Dimension set: " + dim);
	size = Table.get("size", 0);
	print("Size of the image (in the dimension you chose): " + size);
	dpi = Table.get("dpi", 0);
	print("Resolution of the image: " + dpi);
	format = Table.getString("format", 0);
	print("Format for saving the image: " + format);
	
	head = Table.headings();
	if (head.contains("colorCh")) {
		colorCh = Table.getColumn("colorCh");
		minBrightCh = Table.getColumn("minBrightCh");
		maxBrightCh = Table.getColumn("maxBrightCh");
		rmBgCh = Table.getColumn("rmBgCh");
	}
	close("settingInsetCreator.csv");
} else {
	preexistingSetting = false;
	print("Setting not found...");
}

firstImage = true;

for (img = 0; img < imgList.length; img++) {
    if (endsWith(imgList[img], ".tif") && !startsWith(imgList[img], "Mod") && !startsWith(imgList[img], "Inset")) {
    	setBatchMode("exit and display");
    	print("Open the image: " + imgList[img]);
		open(inputDir + File.separator + imgList[img]);
		title = correctGetTitle(); //To remove space in the image name if present
		typeImage = checkImageType();
		imgHeight = getHeight();
		
if (firstImage) {
	if (!preexistingSetting) {
	scLength = 500;
	iscLength = 25;
	scThickness = imgHeight*(100/15000);
	scFond = imgHeight*(500/15000);
	scColor = "Black";
	dim = "Height";
	size = 50;
	dpi = 300;
	format = "SVG";
	}
	
whiteblack = newArray("White","Black");

Dialog.create("Setting");
Dialog.addMessage("---------------------------");
Dialog.addMessage("Scale bar setting");
Dialog.addMessage("---------------------------");
Dialog.addNumber("Length of the scale bar for the main image: ", scLength);
Dialog.addNumber("Length of the scale bar for the inset: ", iscLength);
Dialog.addNumber("thickness (in px): ", scThickness);
Dialog.addNumber("font (in px): ", scFond);
Dialog.addChoice("color", whiteblack, scColor);
Dialog.addToSameRow();
Dialog.addCheckbox("Adjust the color for each image? ", true);

Dialog.addMessage("");
Dialog.addMessage("---------------------------");
Dialog.addMessage("Save Setting");
Dialog.addMessage("---------------------------");
Dialog.addChoice("Choose dimension", newArray("Height","Width"), dim);
Dialog.addNumber("Image height in mm", size);
Dialog.addNumber("DPI for image import", dpi);
Dialog.addChoice("Format of the image", newArray("SVG","TIFF"), format);
Dialog.addMessage("");
Dialog.addMessage("Note regarding image saving:");
Dialog.addMessage("Initially, Inkscape uses a resolution of 96 dpi,\nwhile Illustrator uses a resolution of 72 dpi\nwhen importing images.");
Dialog.addMessage("In Inkscape, you can adjust the import resolution to ensure that the specified size is respected\n(Edit > Preferences > Import/Export > Import Resolution)\nIt does not work with Illustrator");
Dialog.addMessage("Moreover, the specified size will only be preserved if the image is saved as\na TIFF (in which case, the scale bars and inset rectangles cannot be\nmodified). If you want to be able to modify the scale bars and inset\nrectangles, you must select SVG as the save format.");
Dialog.show();

scLength = Dialog.getNumber();
iscLength = Dialog.getNumber();
scThickness = Dialog.getNumber();
scFond = Dialog.getNumber();
scColor = Dialog.getChoice();
scAskColor = Dialog.getCheckbox();
dim=Dialog.getChoice();
size = Dialog.getNumber();
dpi = Dialog.getNumber();
format = Dialog.getChoice();

// Define RGBcolor here that will be used for create inset
if (scColor=="Black") {
	scRGBColor = "000, 000, 000";
} else {
	scRGBColor = "255, 255, 255";
}
//

if (typeImage != "RGB" && adjBrightness) {
	getDimensions(width, height, channels, slices, frames);
	getMinAndMax(min, max);
	
	if (!preexistingSetting) {
		colorCh = newArray(channels);
		minBrightCh = newArray(channels);
		maxBrightCh = newArray(channels);
		rmBgCh = newArray(channels);
		for (channel = 0; channel < channels; channel++) {
			colorCh[channel] = "Grays";
			minBrightCh[channel] = min;
			maxBrightCh[channel] = max;
			rmBgCh[channel] = 0;
		}
	
	}
	Dialog.createNonBlocking("Setting for gray scale image: color and brightness");
	Dialog.addMessage("---------------------------");
	Dialog.addMessage("Seeting channel brightness and color");
	Dialog.addMessage("---------------------------");
	Dialog.addCheckbox("Adjust the color and brightness for each image? ", true);
	for (channel = 0; channel < channels; channel++) {
		Dialog.addMessage("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
		Dialog.addMessage("Channel " + channel+1);
		Dialog.addChoice("Color: " , getList("LUTs"), colorCh[channel]);
		Dialog.addSlider("Minimal Brightness (Can be adjusted latter): ", min, max, minBrightCh[channel]);
		Dialog.addSlider("Maximal Brightness (Can be adjusted latter): ", min, max, maxBrightCh[channel]);
		Dialog.addNumber("Remove background - sigma: \nTo disable it, enter 0", rmBgCh[channel]);
	}
	Dialog.show();
	
	adjChannelForEachImg = Dialog.getCheckbox();
	for (channel = 0; channel < channels; channel++) {
		colorCh[channel] = Dialog.getChoice();
		minBrightCh[channel] = Dialog.getNumber();
		maxBrightCh[channel] = Dialog.getNumber();
		rmBgCh[channel] = Dialog.getNumber();
	}
}
}

	if (rotate) {
		Dialog.create("Rotate");
		Dialog.addChoice("Rotation", newArray("none","90° right", "90° left", "180°"),"none");
		Dialog.addChoice("Flip", newArray("none", "horizontally", "vertically"), "none");
		Dialog.show();
		
		rotation = Dialog.getChoice();
		flip = Dialog.getChoice();
		
		if (rotation == "90° right") run("Rotate 90 Degrees Right");
		if (rotation == "90° left") run("Rotate 90 Degrees Left");
		if (rotation == "180°") run("Rotate... ", "angle=180 interpolation=Bilinear");
		if (flip == "horizontally") run("Flip Horizontally");
		if (flip == "vertically") run("Flip Vertically");
	}


	if (adjBrightness) {
		if (typeImage == "RGB") {
		run("Brightness/Contrast...");
		waitForUser("Adjust the brightness...");
	} else if (typeImage != "RGB") {
		run("Split Channels");
		mergingArray = newArray("*None*", "*None*", "*None*", "*None*", "*None*", "*None*", "*None*", "*None*");
		for (channel = 0; channel < channels; channel++) {
			selectImage("C"+channel+1+"-"+title);
			mergingArray[channel] = getTitle(); 
			if (rmBgCh[channel]>0) run("Subtract Background...","rolling="+rmBgCh[channel]);
			run(colorCh[channel]);
			setMinAndMax(minBrightCh[channel], maxBrightCh[channel]);
			run("Brightness/Contrast...");
			waitForUser("Adjust the brightness and color...");
			getMinAndMax(minBrightCh[channel], maxBrightCh[channel]);
			close("B&C");
		}
	}
	}
	
	mergeS = "c1=" +mergingArray[0]+ " c2=" +mergingArray[1]+ "  c3=" +mergingArray[2]+ "  c4=" +mergingArray[3]+ "  c5=" +mergingArray[4]+ "  c6=" +mergingArray[5]+ "  c7=" +mergingArray[6]+ "  c8=" +mergingArray[7];
	run("Merge Channels...", mergeS+" create");
	
	if (crop) {
		setTool(0);
		roiManager("deselect");
		if(roiManager("count")>0) roiManager("delete");
		if(File.exists(inputDir+"crop.zip")) roiManager("open", inputDir+"crop.zip");
		waitForUser("Select ROI for cropping.\nAdd it to the ROI Manager (Ctrl+T), if you want to save it.\nYou can also load 'crop' ROI from a previous processing step");
		if (roiManager("count") > 0) roiManager("save", inputDir+"crop.zip");
		if(checkROI){
			while (roiManager("count") ==0) {
				waitForUser("You forgot to add ROI to ROI manager... Enter Ctrl+T");
			}
		}
		run("Crop");
	}
		setBatchMode("hide");
	
		setTool(0);
		roiManager("deselect");
		if(roiManager("count")>0) roiManager("delete");
		if(File.exists(inputDir+"inset.zip")) roiManager("open", inputDir+"inset.zip");
		setBatchMode("exit and display");
		
	for (inset = 0; inset < insetNbr; inset++) {
		selectImage(title);
		selectWindow("ROI Manager");
		run("Create framed inset zoom");

		Dialog.createNonBlocking("Create Inset");
		Dialog.addMessage("Inset: " + inset + 1);
		Dialog.addMessage("Move the square that appears in the top left to the zone of interest.");
		Dialog.addMessage("For consistency, indicate:");
		Dialog.addMessage("	-"+scThickness+" as Frame width");
		Dialog.addMessage("	-"+scColor+" as Frame color");
		Dialog.addMessage("To modify the size of the square, the color of the inset, and so on, use only the user interface of the Biovoxxel plugin.\nNormally the interface is automatically open");
		Dialog.addMessage("You can also use a previous inset:\n-open the Biovoxxel plugin\n-click on the ROI of interest in the ROI Manager,\n-ROI is rotated, you need to rotate it again using the Biovoxxel plugin interface.");
		Dialog.addMessage("Then click on 'OK'.");
		Dialog.addMessage("WARNING: Unclick 'Add scale Bar'");
		Dialog.show();
		roiManager("add");
		eval("script", "importClass(Packages.inset.creator.InsetProcessor); InsetProcessor.createInset();");
		checkInserDone();
		rename("Inset-" +inset+1+ "-"+title);
		selectImage(title);
	}

	if (roiManager("count") > 0) roiManager("save", inputDir+"inset.zip");
	
	selectImage(title);
	makeRectangle(0, 0, 0, 0);
	rename("Mod-"+title);
	
	//Scale down the image and draw scalebar
	if (scAskColor) {
		Dialog.create("Set Color Scale Bar");
		Dialog.addChoice("Choose color for the scale bar: ", whiteblack);
		Dialog.show();
		scColor = Dialog.getChoice();
	}

	wdArray = getList("image.titles");
	for (wd = 0; wd < wdArray.length; wd++) {
		selectImage(wdArray[wd]);
		pxHeightImg = getHeight();
		pxWidthImg = getWidth();
		if (channel > 1) setSlice(1);
		
		if (wdArray[wd].contains("Mod-")) {
			run("Scale Bar...", "width="+scLength+" height=0 thickness="+scThickness+" font="+scFond+" color="+scColor+" bold overlay");
		} else {
			run("Scale Bar...", "width="+iscLength+" height=0 thickness="+scThickness+" font="+scFond+" color="+scColor+" bold overlay");
		}
		
		if (dim == "Height") ratio = ((size/25.4)*dpi)/pxHeightImg;
		if (dim == "Width") ratio = ((size/25.4)*dpi)/pxWidthImg;

		print("Initial pixel size of the image: " +pxWidthImg+ "x" +pxHeightImg);
		print("For a " +dim+ " of "+size+" mm at " +dpi+ " DPI, the calculated ratio is: "+ ratio);
		print("Resulting pixel size of the image: " +pxWidthImg*ratio+ "x" +pxHeightImg*ratio);
		
		run("Scale...", "x=" +ratio+ " y=" +ratio+ " interpolation=Bicubic average create");
		close(wdArray[wd]);
		rename(wdArray[wd]);
	}

if (format == "SVG") run("Export all images as SVG");
if (format == "TIFF") {
	for (wd = 0; wd < wdArray.length; wd++) {
		selectImage(wdArray[wd]);
		run("Flatten");
		saveAs("tiff", inputDir+File.separator+wdArray[wd]);
	}
}

print("Save setting in " + inputDir);
print("Scale bar length main image: " + scLength);
print("Scale bar length inset: " + iscLength);
print("Scale bar thickness: " + scThickness);
print("Scale bar fond: " + scFond);
print("Scale bar color: " + scColor);
if (typeImage != "RGB" && adjBrightness) {
	for (channel = 0; channel < channels; channel++) {
	print("Channel " +channel+1+ "in color "+colorCh[channel]+ ". Min & max brightness: " +minBrightCh[channel]+ "-" +maxBrightCh[channel]+ ". Sigma rolling ball: " +rmBgCh[channel]);
}
print("Fixed dimension: " + dim);
print("Size dimension: " + size);
print("dpi: " + dpi);
print("format: " + format);

Table.create("Setting InsetMarker");
Table.set("scLength", 0,  scLength);
Table.set("iscLength", 0,  iscLength);
Table.set("scThickness", 0, scThickness);
Table.set("scFond", 0, scFond);
Table.set("scColor", 0, scColor);
Table.set("scAskColor", 0, scAskColor);
Table.set("dim", 0, dim);
Table.set("size", 0, size);
Table.set("dpi", 0, dpi);
Table.set("format", 0, format);
if (typeImage != "RGB" && adjBrightness) {
	Table.set("adjChannelForEachImg", 0, adjChannelForEachImg);
	Table.setColumn("colorCh", colorCh);
	Table.setColumn("minBrightCh", minBrightCh);
	Table.setColumn("maxBrightCh", maxBrightCh);
	Table.setColumn("rmBgCh", rmBgCh);
}
Table.update;
Table.save(inputDir+File.separator+"settingInsetCreator.csv");
close("settingInsetCreator.csv");
run("Close All");
firstImage = false;
}
}
}





function checkInserDone(){
	absent = true;
	while (absent==true) {
		titles = getList("image.titles");
		for (i = 0; i < titles.length; i++) {
			if (indexOf(titles[i], "Inset") != -1) {
				absent = false;
	        	break;
				}
			}
		if (absent==true) waitForUser("You forgot to click on \"Create\" !! ");
			}
}

function checkImageType(){
	t = bitDepth();
if (t == 24)
    return "RGB";
else if (t == 8)
    return "8-bit";
else if (t == 16)
    return "16-bit";
else if (t == 32)
    return "32-bit float";
}

function correctGetTitle() {
	title = getTitle();
	if (title.contains(" ")) {
		title = replace(getTitle(), " ", "_");
		rename(title);
	}
	return title;
}

