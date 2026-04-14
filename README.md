# insetCreator

ImageJ macro for adjusting image brightness and generating multiple insets, based on the [Biovoxxel Figure Tools plugin](https://github.com/biovoxxel/BioVoxxel-Figure-Tools).

If you use this macro in your work, please cite the original Biovoxxel plugin:
https://doi.org/10.5281/zenodo.7268127

# Installation

1. Download the ZIP file by clicking **Code > Download ZIP**.
2. Extract the downloaded file.
3. Copy the `insetCreator.ijm` file into the `Fiji.app/plugins` folder.
4. Restart Fiji.
5. Open the plugin from **Plugins > insetCreator**.

# Requirements

To use this macro, you need:
- A recent version of Fiji: [Link to install Fiji](https://imagej.net/software/fiji/)
- The Biovoxxel plugins installed and up to date. [Follow the tutorial to install Biovoxxel plugins](https://imagej.net/update-sites/following)
- Input images in TIFF format with appropriate scaling.

# Features

Through the graphical user interface, you will be asked to choose the folder containing the images. You can then decide whether:
- the image should be cropped,
- brightness and contrast should be adjusted,
- the scale bar length, thickness, and color should be set,
- the output image format, size and resolution should be defined.

Note: output settings work properly only if the file is saved as TIFF.

The ROIs used for cropping and for the different insets are saved as `crop.zip` and `inset.zip`, and the settings are saved as `settingInsetCreator.csv`.
These files are reused to process the next images.
The main image will be saved with "Mod-" + title of the image and the different insets: "Inset-"+title of the image.















