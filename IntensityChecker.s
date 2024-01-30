/*
Intensity checker
Takes a series of images at increasing brightness spread (decreasing intensity at camera)
to calculate camera intensity

Start with vacuum, intensity that is high but not saturating

//MWF 22 May 2023 initial script
Script tested on Gatan OneView on JEOL 2100Plus
Gatan K3-IS on JEOL 2100F

Feb2024 - replace linear step with varying, todo - test params on differing TEMs
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

// Put a friendly marker in the results window
Result( "\n ========================== \n" )
Result( "     Intensity Checker     " )
Result( "\n ========================== \n" )

//Get the microscope parameters
number NMag = EMGetMagnification()
number Focus = EMGetFocus()
number SptS = EMGetSpotSize()+1
Result( "\n" )
Result( "Microscope parameters \n" )
Result( "Magnification : " + NMag + "\n" )
Result( "Objective Focus (raw units) : " + Focus + "\n" )
Result( "Spot size (JEOL display): " + SptS + "\n" )

  
//Get the camera parameters
CameraGetDefaultParameters( camID, exposure, xBin, yBin, processing, areaT, areaL, areaB, areaR )
Result( "\n" )
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

number BrightChange = 500	//Suggested values - K3: 500, 
GetNumber("Amount of raw units to change first step", BrightChange, BrightChange )


/////////////////////////
// while loop to run acquisition - varying step for each iteration, e.g. 1.1 of previous step
/////////////////////////

number step = BrightChange
number oldint = 99999999

s = BVal
while (s <=65535)
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
 	//Get mean from image
	number immean = mean(IMG)
	Result("\n"+imname+": "+immean)	
	s = s+step
	step = round(step*1.1)
	if (immean <2)
		break
	if (immean > oldint){
		Result("\n intensity not changing, ending loop")
		break
		}
	if  (ShiftDown() == 1){
		Result("\n Shift pressed, ending loop")
		break
		}//end if shift down		
	oldint = immean
} 

// Blank the beam
EMSetBeamBlanked(1)

string end = "Brightness Series:\n"
end += "Acquisition complete.\n"
end += "Beam has been blanked."

//To do - plot brightness vs intensity for images
//To do - automatically export into file:
//To do - brightness and intensity values as two column text
//To do - with exposure time and calibration gain factor used (will use ## tag format)


if ( !OKCancelDialog( end ) )
 exit( 0 )
