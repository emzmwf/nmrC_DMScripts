/*
Intensity checker
Takes a series of images at increasing brightness spread (decreasing intensity at camera)
to calculate camera intensity

Start with vacuum, intensity that is high but not saturating

//MWF 22 May 2023 initial script

ToDo list - get mean and standard deviation from each image as they are displayed - DONE
			create array of brightness and mean, create plot
			Also get exposure time and calibration gain factor
			and save as two column text format
*/

//Camera variables
number camID = CameraGetActiveCameraID( )
number exposure
number xBin, yBin
number processing
number areaT, areaL, areaB, areaR

//
//Check that the user is ready to acquire camera parameters 
//and then get the images

string help = "Brightness Checker:\n"
help += "Ensure the you have the Brightness,\n"
help += "Set to give a bright but\n"
help += "unsaturated image.\n"
help += "Hold SHIFT to abort."

if ( !OKCancelDialog( help ) )
 exit( 0 )
 
 
//Get the camera parameters
CameraGetDefaultParameters( camID, exposure, xBin, yBin, processing, areaT, areaL, areaB, areaR )
Result( "\n\n" )
Result( "Default parameters for '" + CameraGetName(camID) + "' in the 'Record' setting: \n" )
Result( "Exposure time (sec) : " + exposure + "\n" )
Result( "CCD Read-out area   : [" + areaT + "/" + areaL + "/" + areaB + "/" + areaR + "] \n" )
Result( "CCD binning (pixels): " + xBin + "x" + yBin +"\n" )
Result( "processing          : " + processing)
 

if ( processing == CameraGetUnprocessedEnum( ) )
{
 //Result( " = unprocessed \n" )
}

else if ( processing == CameraGetDarkSubtractedEnum( ) )
{
 //Result(" = dark subtracted \n")
}

else if ( processing == CameraGetGainNormalizedEnum( ) )
{
 //Result(" = gain normalized \n")
}

//// Can we check if the camera view is running and stop the script if it is?
CameraPrepareForAcquire(camID) 	//inserts it, but doesn't stop the view

//Get Mag and camera to calculate modifiers

string CamName = CameraGetName(camID)
 
 
number BVal = EMGetBrightness()
string tstring = ""
number s = 65535	//default value, fully spread

number BrightChange = 5000	//default value, would probably give five or six images at a normal setting for 50k, use 2500 step for 10k
GetNumber("Amount of raw units to change per step", BrightChange, BrightChange )


/////////////////////
// for loop here once testing is done
/////////////////////////
for (s = BVal ; s<=65535 ; s = s+BrightChange)
{
	EMSetBrightness(s)
	//tstring = "Brightness "+s+" "
	tstring = s+" "
	string imname = ""+tstring
	image IMG
	CameraPrepareForAcquire( camID )
	IMG := CameraAcquire( camID, exposure, xBin, yBin, processing )
	setName (IMG, imname)
	ShowImage(IMG)
	number immean = mean(IMG)
	Result("\n"+imname+": "+immean)	
	
	// To do - get mean intensity, save to array
	
}

// Blank the beam
EMSetBeamBlanked(ON)

string end = "Brightness Series:\n"
end += "Acquisiton complete."

//To do - plot brightness vs intensity for images
//To do - get exposure time and calibration gain factor from tags
//To do - save brightness and intensity values to two column text
//To do - with exposure time and calibration gain factor used


if ( !OKCancelDialog( end ) )
 exit( 0 )