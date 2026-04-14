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
Dialog.addCheckbox("Crop the image:", false);
Dialog.addNumber("Number of insert: ", 1);
Dialog.show();

inputPath = Dialog.getString();
adjBrightness = Dialog.getCheckbox();
crop = Dialog.getCheckbox();
insetNbr = Dialog.getNumber();
imgList = getFileList(inputPath);

whiteblack = newArray("White","Black");

if (File.exists(inputPath+File.separator+"settingInsetCreator.csv")) {
	print("Loading setting...");
	Table.open(inputPath+File.separator+"settingInsetCreator.csv");
	waitForUser
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
	close("settingInsetCreator.csv");
} else {
	print("Setting not found...");
	scLength = 500;
	iscLength = 25;
	scThickness = 1;
	scFond = 11;
	scColor = "Black";
	dim = "Height";
	size = 50;
	dpi = 300;
	format = "SVG";
}

for (img = 0; img < imgList.length; img++) {
    if (endsWith(imgList[img], ".tif") && !startsWith(imgList[img], "Mod") && !startsWith(imgList[img], "Inset")) {
		open(inputPath + File.separator + imgList[img]);
		title = imgList[img];

Dialog.create("Setting");
Dialog.addMessage("---------------------------");
Dialog.addMessage("Scale bar setting");
Dialog.addMessage("---------------------------");
Dialog.addNumber("Length of the scale bar for the main image: ", scLength);
Dialog.addNumber("Length of the scale bar for the inset: ", iscLength);
Dialog.addNumber("thickness: ", scThickness);
Dialog.addNumber("font: ", scFond);
Dialog.addChoice("color", whiteblack, scColor);
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
Dialog.addMessage("In Inkscape, you can adjust the import resolution to ensure that the specified size is respected (Edit > Preferences > Import/Export > Import Resolution)\nIt does not work with Illustrator");
Dialog.addMessage("Moreover, the specified size will only be preserved if the image is saved as\na TIFF (in which case, the scale bars and inset rectangles cannot be\nmodified). If you want to be able to modify the scale bars and inset\nrectangles, you must select SVG as the save format.");
Dialog.show();

scLength = Dialog.getNumber();
iscLength = Dialog.getNumber();
scThickness = Dialog.getNumber();
scFond = Dialog.getNumber();
scColor = Dialog.getChoice();
dim=Dialog.getChoice();
size = Dialog.getNumber();
dpi = Dialog.getNumber();
format = Dialog.getChoice();

Table.create("Setting InsetMarker");
Table.set("scLength", 0,  scLength);
Table.set("iscLength", 0,  iscLength);
Table.set("scThickness", 0, scThickness);
Table.set("scFond", 0, scFond);
Table.set("scColor", 0, scColor);
Table.set("dim", 0, dim);
Table.set("size", 0, size);
Table.set("dpi", 0, dpi);
Table.set("format", 0, format);
Table.update;
Table.save(inputPath+File.separator+"settingInsetCreator.csv");
close("settingInsetCreator.csv");

	if (adjBrightness) {
		run("Brightness/Contrast...");
		waitForUser("Adjust the brightness...");
	}
	
	if (crop) {
		setTool(0);
		roiManager("deselect");
		if(roiManager("count")>0) roiManager("delete");
		if(File.exists(inputPath+"crop.zip")) roiManager("open", inputPath+"crop.zip");
		waitForUser("Select ROI for cropping.\nAdd it to the ROI Manager (Ctrl+T), if you want to save it.\nYou can also load 'crop' ROI from a previous processing step");
		if (roiManager("count") > 0) roiManager("save", inputPath+"crop.zip");
		run("Crop");
	}
	
		setTool(0);
		roiManager("deselect");
		if(roiManager("count")>0) roiManager("delete");
		if(File.exists(inputPath+"inset.zip")) roiManager("open", inputPath+"inset.zip");
	for (inset = 0; inset < insetNbr; inset++) {
		selectWindow("ROI Manager");
		run("Create framed inset zoom");
		Dialog.createNonBlocking("Create Inset");
		Dialog.addMessage("Inset: " + inset + 1);
		Dialog.addMessage("Move the square that appears in the top left to the zone of interest.");
		Dialog.addMessage("To modify the size of the square, the color of the inset, and so on, use only the user interface of the Biovoxxel plugin.\nNormally the interface is automatically open");
		Dialog.addMessage("Add it to the ROI Manager (Ctrl+T) if you want to save it; it will be saved as inset.zip.");
		Dialog.addMessage("You can also use a previous inset. If they don't appear in the ROI Manager, you can load them. Then open the Biovoxxel plugin and click on the ROI of interest in the ROI Manager. Note that if you have rotated the ROI, you need to rotate it again using the Biovoxxel plugin interface.");
		Dialog.addMessage("Then click on 'create', wait for the creation of the inset, close the plugin and click on 'OK'.");
		Dialog.show();
		checkInserDone();
		rename("Inset-" +inset+1+ "-"+title);
		selectImage(title);
	}
	if (roiManager("count") > 0) roiManager("save", inputPath+"inset.zip");
	
	selectImage(title);
	rename("Mod-"+title);
	
	//Scale down the image and draw scalebar
	wdArray = getList("image.titles");
	for (wd = 0; wd < wdArray.length; wd++) {
		selectImage(wdArray[wd]);
		pxHeightImg = getHeight();
		pxWidthImg = getWidth();
		
		if (dim == "Height") ratio = ((size/25.4)*dpi)/pxHeightImg;
		if (dim == "Width") ratio = ((size/25.4)*dpi)/pxWidthImg;

		print("Initial pixel size of the image: " +pxWidthImg+ "x" +pxHeightImg);
		print("For a " +dim+ " of "+size+" mm at " +dpi+ " DPI, the calculated ratio is: "+ ratio);
		print("Resulting pixel size of the image: " +pxWidthImg*ratio+ "x" +pxHeightImg*ratio);
		
		run("Scale...", "x=" +ratio+ " y=" +ratio+ " interpolation=Bicubic average create");
		close(wdArray[wd]);
		rename(wdArray[wd]);
		if (wdArray[wd].contains("Mod-")) {
			run("Scale Bar...", "width="+scLength+" height=0 thickness="+scThickness+" font="+scFond+" color="+scColor+" bold overlay");
		} else {
			run("Scale Bar...", "width="+iscLength+" height=0 thickness="+scThickness+" font="+scFond+" color="+scColor+" bold overlay");
		}
	}

if (format == "SVG") run("Export all images as SVG");
if (format == "TIFF") {
	for (wd = 0; wd < wdArray.length; wd++) {
		selectImage(wdArray[wd]);
		run("Flatten");
		saveAs("tiff", inputPath+File.separator+wdArray[wd]);
	}
}

run("Close All");
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
