//LM stage mapping

//Function to run the stage montage
void GetMontage(){
Result("Montage runs here")

//Set up camera 
//Camera variables
number camID = CameraGetActiveCameraID( )
number exposure
number xBin, yBin
number processing
number areaT, areaL, areaB, areaR
//Get the camera parameters
CameraGetDefaultParameters( camID, exposure, xBin, yBin, processing, areaT, areaL, areaB, areaR )
Result( "\n\n" )
Result( "Default parameters for '" + CameraGetName(camID) + "' in the 'Record' setting: \n" )
Result( "Exposure time (sec) : " + exposure + "\n" )
Result( "CCD Read-out area   : [" + areaT + "/" + areaL + "/" + areaB + "/" + areaR + "] \n" )
Result( "CCD binning (pixels): " + xBin + "x" + yBin +"\n" )
Result( "processing          : " + processing)

object camera = CM_GetCurrentCamera()
object acq_params = camera.CM_GetCameraAcquisitionParameterSet("Imaging", "Acquire", "Record", 1)
cm_Validate_AcquisitionParameters(camera, acq_params);

CameraPrepareForAcquire(camID) 


//Calibrated stage movements for LMAG x50 for  Tecnai (somewhat approximate)
number smod = 2
number UPX = -33.89*smod	//-297 to -254
number UPY = 157.67*smod	//-50 to -165
number LEFX = -204.45*smod	// -272 to -100
number LEFY = -47.68*smod	//-53 to 6.41

number SX
number SY

//Amount of images +_
number ir = 2
number jr = 2

//
number i
number j

// Now to do some moving
result("\n===LMAG MONTAGE===\n")
result("Moving the stage")
EMSetStageX(-ir*UPX-jr*LEFX)
Delay(400)	
EMSetStageY(-ir*UPY-jr*LEFY)
Delay(400)	


////new workspace for display
number wsID_src = WorkSpaceGetActive()
number wsID_montage = WorkSpaceAdd( WorkSpaceGetIndex(wsID_src) + 1 )
WorkSpaceSetActive( wsID_montage )
WorkspaceSetName( wsID_montage , "LMMontage" )
////Sets the tab-name of the workspace 'wsID' to 'ISMontage'.

//Set window sizes
number HSz = round((501*0.75)/ir)
number VSz = round((334*0.75)/jr)

CameraPrepareForAcquire(camID) 
result("\n checkpoint 1")
for (i = -ir; i<=ir; i++){
	for (j = -jr; j<=jr; j++){
		result("\n checkpoint 2")
		SX = i*UPX+j*LEFX
		SY = i*UPY+j*LEFY
		
//		\\\move and wait\\\
		EMSetStageX(SX)
		
		number ScX = nearest(EMGetStageX())
		while(abs(ScX-nearest(SX))>5)
		{
		Delay(100)
		result ("\n waiting for stage"+ScX)
//		EMSetStageX(SX)
		ScX = nearest(EMGetStageX())
		}
		EMSetStageY(SY)
		number ScY = nearest(EMGetStageY())
		while(abs(ScY-nearest(SY))>5)
		{
		Delay(100)
		result ("\n waiting for stage" +ScY)
		ScY = nearest(EMGetStageY())
//		EMSetStageY(SY)
		}
		result("\n checkpoint 3")
			
//		'''acquire'''
		CameraPrepareForAcquire( camID )
		result("\n checkpoint 3b")
		//IMG := cm_AcquireImage(camera, acq_params)
		image IMG
		IMG := CameraAcquire( camID, exposure, xBin, yBin, processing )
		result("\n checkpoint 3c")
		string nameImg = "i"+i+" j"+j
		result("\n checkpoint 4")		
		setName (IMG, nameImg)
		showImage (IMG)
		SetWindowSize(IMG, HSz, VSz)
		SetWindowPosition(IMG, 555+HSz*-j, 364+VSz*-i)
		result("\n checkpoint 5")				
		beep()

		result ("i is "+i+": ")
		result ("j is "+j+"\n")
		result ("SX is "+SX+": ")
		result ("SY is "+SY+"\n")
		
		

		}
	}




}//end of GetMontage function





string help = "Low mag montage:\n"
help += "Script will lower screen, :\n"
help += "and set mag, spotsize and intensity. :\n"
help += "Please manually remove the objective aperture."

if ( !OKCancelDialog( help ) )
	exit( 0 )


//Set screen down
EMSetScreenPosition(0)
EMSetBeamBlanked(0)

//Set Mag to LM 44x
EMSetMagnification(50)
//Set spot size to 6
EMSetSpotSize(6)
//Set beam spread to be beyond camera size
EMSetBrightness(1.1825e+06)

string help2 = "Low mag montage:\n"
help2 += "Check beam is centred, :\n"
help2 += "then raise screen  :\n"
help2 += "and press OK to proceed."

if ( !OKCancelDialog( help2 ) )
	exit( 0 )

if ( ShiftDown() ){
	exit(0)
	}
//raise screen
EMSetScreenPosition(2)
//Tecnai won't let us raise it, but can tell it is raised
Number screen 
Delay(100)
screen = EMGetScreenPosition( )
Result("\n screen up ")
Result(screen)
/*
if (screen != 0){
GetMontage()
Result("blahblahblah")
}
*/

GetMontage()
//beep()
//Wait and then lower screen
Delay(200)
EMSetScreenPosition(0)
EMSetBeamBlanked(1)
EMSetStageX(0)
EMSetStageY(0)

string help3 = "Low mag montage:\n"
help3 += "Montage finished :\n"
help3 += "Press OK to unblank beam."

if ( !OKCancelDialog( help3 ) )
	exit( 0 )

EMSetBeamBlanked(0)