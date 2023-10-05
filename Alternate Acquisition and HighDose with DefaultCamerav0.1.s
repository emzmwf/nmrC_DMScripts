/*
Acquire Series with increased beam intensity in between acquisitions

Two microscope conditions will be used, Acquisition and Dose

User should record the raw values for these setups using the GetBrightMagFocus.s script first

Script will adjust BRIGHTNESS (CL3), SPOT and MAG between dose and acquisition conditions
(MAG can be used to ensure camera would not be affected, e.g. to use a condition where the 
dose can be safely recorded on camera viewing vacuum, but may cause a shift if 
going out of a MAG range (e.g. beyond 800k, or below 6k)

Where dose is beyond safe value for camera, this dose should be extrapolated from a 
brightness calibration - IntensityChecker script, see Mike Fay for details 

NOTE raw SPOT value is one less than displayed on JEOL or GMS

17 May 2023 MWF - intial script, to be tested thoroughly
22 May 2023 MWF - tested on FEGTEM

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

string help = "Acquisition and Dose:\n"
help += "Ensure the you have the raw Brightness,\n"
help += "Mag and Spot Size values\n"
help += "for both Acquisition and Dose.\n"
help += "Use the script BrightMagFocus if you do not have these. \n"
help += "Note, Raw SPOT is one less than displayed SPOT. \n"
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

string CamName = CameraGetName(camID)

// Instrument settings
// would be good to be able to look these up
// but for now it seems they need to be hard coded here

//FEGTEM suggested values
number B1 = 55403
number M1 = 20000
number F1 = 154252
number S1 = 4	//Spot 5 on display

number B2 = 50000
number M2 = 15000
number F2 = 154252
number S2 = 1	//spot 2 on display


//Camera names
string K3 = "K3"
string OneView = "OneView"
string Orius = "Orius"

 
if (CamName == K3){
	B1 = 55403
	M1 = 20000
	F1 = 154252
	S1 = 4

	B2 = 50000
	M2 = 15000
	F2 = 154252
	S2 = 1
	}
else if (CamName == "OneView"){
	}	
else if (CamName == "Orius"){
		beep()
		okdialog("Camera "+CamName+" is not yet calibrated")
		exit(0)
	}	
	else{
		beep()
		okdialog("Camera "+CamName+" is not listed in this script")
		exit(0)
		
	}


//Dialog to ask conditions

TagGroup DLG, DLGItems
DLG = DLGCreateDialog( "Please enter Acquisition values", DLGItems )

TagGroup val1tg, val2tg, val3tg, val4tg
DLGitems.DLGAddElement( DLGCreateRealField( "Brightness :", val1tg, B1, 8, 2 ) )        
DLGitems.DLGAddElement( DLGCreateRealField( "Magnification :", val2tg, M1, 8, 2 ) )        
DLGitems.DLGAddElement( DLGCreateRealField( "Focus  :", val3tg, F1, 8, 2 ) )        
DLGitems.DLGAddElement( DLGCreateIntegerField( "Spot:", val4tg, S1, 2 ) )        


if ( !Alloc( UIframe ).Init( DLG ).Pose() )
 Throw( "User abort." )
 
number B = val1tg.DLGGetValue()
number Mag = val2tg.DLGGetValue()
number Focus = val3tg.DLGGetValue()
number Spot = val4tg.DLGGetValue()


TagGroup DLG2, DLGItems2
DLG2 = DLGCreateDialog( "Now please enter Exposure values", DLGItems2 )

TagGroup val5tg, val6tg, val7tg, val8tg
DLGitems2.DLGAddElement( DLGCreateRealField( "Brightness :", val5tg, B2, 8, 3 ) )        
DLGitems2.DLGAddElement( DLGCreateRealField( "Magnification :", val6tg, M2, 8, 2 ) )        
DLGitems2.DLGAddElement( DLGCreateRealField( "Focus  :", val7tg, F2, 8, 1 ) )        
DLGitems2.DLGAddElement( DLGCreateIntegerField( "Spot:", val8tg, S2, 2 ) )        


if ( !Alloc( UIframe ).Init( DLG2 ).Pose() )
 Throw( "User abort." )
 
number EB = val5tg.DLGGetValue()
number EMag = val6tg.DLGGetValue()
number EFocus = val7tg.DLGGetValue()
number ESpot = val8tg.DLGGetValue()


number DoseWait = 10
GetNumber("Select Wait Time in Dose Mode, in seconds", DoseWait, DoseWait )

if ( DoseWait < 0.5)
{
Throw( "Dose time is too short" )
}


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


//Display window sizes 
//Window sizes - default for K3 at x 576 y 409, for OneView at 384 384
number HSz
number VSz

if (CamName == K3){
	HSz = 576
	VSz = 409
}
if (CamName == OneView){
	HSz = 384
	VSz = 384
}
if (CamName == "Orius"){
	HSz = 200*1.5
	VSz = 132*1.5
}


string tstring = ""

//Check if they've changed their mind yet
if ( ShiftDown() ) exit(0)

////new workspace for display
number wsID_src = WorkSpaceGetActive()
number wsID_montage = WorkSpaceAdd( WorkSpaceGetIndex(wsID_src) + 1 )
WorkSpaceSetActive( wsID_montage )
WorkspaceSetName( wsID_montage , "Acquire and Dose Autoseries" )
////Sets the tab-name of the workspace 'wsID' to 'Acquire and Dose Autoseries'.

number s = 0
number NoFr = 3
GetNumber("Total number of exposed frames to acquire", NoFr, NoFr )

number tps = GetHighResTicksPerSecond()

//unblank the beam
EMSetBeamBlanked(OFF)

/////////////////////
// for loop here once testing is done
/////////////////////////
for (s = 0 ; s<=NoFr ; s++)
	{
	
	//Set to acquire mode
	EMSetMagnification(Mag)
	EMSetBrightness(B)
	EMSetSpotSize(Spot)
	delay(50)

	tstring = "Frame "+s+" "
	string imname = ""+tstring
	image IMG
	CameraPrepareForAcquire( camID )
	IMG := CameraAcquire( camID, exposure, xBin, yBin, processing )
	setName (IMG, imname)
	ShowImage(IMG) 		
		
	SetWindowSize(IMG, HSz, VSz) //resize this window depending on the system
	SetWindowPosition(IMG, 10+50*s, 50+50*s)	//non overlap as acquiring
	//Now set to dose mode
	EMSetMagnification(EMag)
	EMSetBrightness(EB)
	EMSetSpotSize(ESpot)
	
	if (s<NoFr){
	//Now wait for determined amount of time
	number start_tick = GetHighResTickCount()
	//while loop - wait until current tick is > start_tick + tps*seconds waiting
	Number Now = GetOSTickCount()
	Number OldTimes = Now
	number EndTimes = Now+(1000*DoseWait)
	number Sp
	Result("\n starting dose exposure RAW spot "+(ESpot)+" Brightness "+EB)
	while (Now<EndTimes){
		Now = GetOSTickCount()
		sleep( 0.1) 
		Sp = Sp+SpaceDown()
		if ( ShiftDown() )
			{
				Sp = Sp+1
			}   //end if shiftdown                           
		if (Sp >4)
			{
			result("\n user abort!")
			result((Now-OldTimes)/1000)
			Exit(0)           
			} // end if aborted
	}// end while
	Result("\n ending dose exposure \n")
	
	}
}	//end s

//Done. Go beep now
beep()	//Not that this will do anything, the sound is off on the monitors
// Blank the beam
EMSetBeamBlanked(ON)

// Ensure we are at acquisition mode
EMSetMagnification(Mag)
EMSetBrightness(B)
EMSetSpotSize(Spot)
delay(50)

EMSetBeamBlanked(ON)

// Autoarrange the workspace
//Number WorkspaceArrange( Number wsID, Number sorted, Number keepSize )

WorkSpaceArrange( wsID_montage, 1,0 )