// DM scrip Dialog for Imaging Conditions for K3 camera on FEGTEM\
// 
// update 8 Nov 2022 
// Set the beam blank on as default
//	- MWF 
// update 23 May 2023
// This version for beam sensitive materials

// Update Dec 2024 - disable 10k selection if alpha mode is 1


void Set10K()
	{
number HT
HT = EMGetHighTension()

if (HT != 200000)
	{
	if (HT !=100000){
		if (HT != 80000){
			string help = "This plugin for HTs:\n"
			help += " 200kV, 100kV, and 80kV\n"
			help += "Press SHIFT to abort."
			if ( !OKCancelDialog( help ) )
			exit( 0 )
			}
		}
	}
	

	//Check we are in alpha mode 2 or 3, not 1 - will be zero in script numbers
	Number F = EMGetIlluminationSubMode( )
	if ( F == 0 ){
		OKDialog( "10k mag not suitable for Alpha 1" )
		exit( 0 )	
		}


//Check imaging mode
string Edna = EMGetImagingOpticsMode()
if (Edna !="MAG1"){
	string help = "Change mode to MAG1:\n"
	help += "Before proceeding:\n"
	help += "Press SHIFT to abort."

	if ( !OKCancelDialog( help ) )
	exit( 0 )

	try{
	EMSetImagingOpticsMode("MAG1")	//can't do this on old GMS on FEG
	}
	catch{
	string help = "Mode not MAG1:\n"
	help += "Cannot proceed:\n"
	( OKDialog( help ) )
	exit( 0 )
	}
}

number Bval
number NMag
number Focus
number SpS

//200kV
if (HT == 200000){
Bval = 65535 
NMag = 10000
Focus = 1.54252e+06
SpS = 2	// note, spot size in code is one less than on display
}

//100kV
if (HT == 100000){
Bval = 65535 
NMag = 10000
Focus = 1.28171e+06
SpS = 2 // note, spot size in code is one less than on display
}

//80kV
if (HT == 80000){
Bval = 65535 
NMag = 10000
Focus = 1.28171e+06
SpS = 2 // note, spot size in code is one less than on display
}


string Mode = EMGetImagingOpticsMode()
if (Mode != "MAG1")
	{
	result("\n Optics mode is not MAG1 ")
	exit( 0 )
	}


string help = "SetMag10k:\n"
help += "Press SHIFT to abort."

if ( !OKCancelDialog( help ) )

 exit( 0 )

//possibly going down in mag, so blank the beam, change brightness first, then Mag
EMSetBeamBlanked(1)

//Set Brightness
EMSetBrightness(Bval)

//Set Mag
EMSetMagnification(NMag)

//Set standard focus
EMSetFocus(Focus)

//Set Spot Size
EMSetSpotSize(SpS) 	//Note, spot sizes are 0 to 4 in code, 1-5 on user interface
//EMSetBeamBlanked(OFF)	
	}
	
// Set 50k
void Set50k(){
//v0.2 Jan 2022
//Script by MW Fay for University of Nottingham JEOL 2100F operation


//Set beam mode 50k at 200kV or 80kV


//Check microscope name
//string Nom = EMGetMicroscopeName()
//FEGTEM returns as JEOL COM

//Check voltage of microscope
number HT
HT = EMGetHighTension()

if (HT != 200000)
	{
	if (HT != 100000){
		if (HT != 80000){
		string help = "This plugin for HTs:\n"
		help += " 200kV, 100kV, and 80kV\n"
		help += "Press SHIFT to abort."

		if ( !OKCancelDialog( help ) )

		exit( 0 )
		}
	}
}



//Check imaging mode
string Edna = EMGetImagingOpticsMode()
if (Edna !="MAG1"){
	string help = "Change mode to MAG1:\n"
	help += "Before proceeding:\n"
	help += "Press SHIFT to abort."

	if ( !OKCancelDialog( help ) )
	exit( 0 )
}

Edna = EMGetImagingOpticsMode()
if (Edna !="MAG1"){

	try{
	EMSetImagingOpticsMode("MAG1")	//can't do this on old GMS on FEG
	}
	catch{
	string help = "Mode not MAG1:\n"
	help += "Cannot proceed:\n"
	( OKDialog( help ) )
	exit( 0 )
	}
}
number Bval
number NMag
number Focus
number SpS

//200kV
if (HT == 200000){
Bval = 44703
NMag = 50000
Focus = 1.54252e+06
//SpS = 0	// note, spot size in code is one less than on display
}

//100kV
if (HT == 100000){
Bval = 46911
NMag = 50000
Focus = 1.28248e+06
//SpS = 0	// note, spot size in code is one less than on display
}

//80kV
if (HT == 80000){
Bval = 46911 
NMag = 50000
Focus = 1.28171e+06
//SpS = 0	// note, spot size in code is one less than on display
}


string Mode = EMGetImagingOpticsMode()
if (Mode != "MAG1")
	{
	result("\n Optics mode is not MAG1 ")
	exit( 0 )
	}

string help = "SetMag50k:\n"

help += "This will also blank the beam\n"

help += "Press SHIFT to abort."

if ( !OKCancelDialog( help ) )

 exit( 0 )


//Blank beam
//CAN't do this on 1.8
EMSetBeamBlanked(1)

//possibly going down in mag, so change brightness first, then Mag


//Set Brightness
EMSetBrightness(Bval)

//Set Mag
EMSetMagnification(NMag)

//Set standard focus
EMSetFocus(Focus)

//Set Spot Size
EMSetSpotSize(SpS) 	//Note, spot sizes are 0 to 4 in code, 1-5 on user interface


//unblank beam
//CAN't do this on 1.8!!!
//EMSetBeamBlanked(OFF)
}

//Set 250k	
void Set250k()
	{
//v0.2 Jan 2022
//Script by MW Fay for University of Nottingham JEOL 2100F operation

//Set beam mode 250k at 200kV or 80kV

//Check microscope name
//string Nom = EMGetMicroscopeName()
//FEGTEM returns as JEOL COM

//Check voltage of microscope
number HT
HT = EMGetHighTension()

if (HT != 200000)
	{
	if (HT != 100000){
		if (HT != 80000){
		string help = "This plugin for HTs:\n"
		help += " 200kV, 100kV, and 80kV\n"
		help += "Press SHIFT to abort."

		if ( !OKCancelDialog( help ) )

		exit( 0 )
		}
	}
}



//Check imaging mode
string Edna = EMGetImagingOpticsMode()
if (Edna !="MAG1"){
	string help = "Change mode to MAG1:\n"
	help += "Before proceeding:\n"
	help += "Press SHIFT to abort."

	if ( !OKCancelDialog( help ) )
	exit( 0 )
}


Edna = EMGetImagingOpticsMode()
if (Edna !="MAG1"){

	try{
	EMSetImagingOpticsMode("MAG1")	//can't do this on old GMS on FEG
	}
	catch{
	string help = "Mode not MAG1:\n"
	help += "Cannot proceed:\n"
	( OKDialog( help ) )
	exit( 0 )
	}
}

number Bval
number NMag
number Focus
number SpS

//200kV
if (HT == 200000){
Bval = 38051
NMag = 250000
Focus = 1.54303e+06
SpS = 0	// note, spot size in code is one less than on display
}

//100kV
if (HT == 100000){
Bval = 40851
NMag = 250000
Focus = 1.28177e+06
SpS = 0	// note, spot size in code is one less than on display
}

//80kV
if (HT == 80000){
Bval = 40851
NMag = 250000
Focus = 1.28171e+06
SpS = 0	// note, spot size in code is one less than on display
}


string help = "SetMag250k:\n"
help += "note this script will\n"
help += "blank the beam\n"

help += "Press SHIFT to abort."

if ( !OKCancelDialog( help ) )

 exit( 0 )


//possibly going down in mag, so change brightness first, then Mag
//Blank beam
//CAN't do this on 1.8!!!
EMSetBeamBlanked(1)

//Set Brightness
EMSetBrightness(Bval)

//Set Mag
EMSetMagnification(NMag)

//Set standard focus
EMSetFocus(Focus)

//Set Spot Size
EMSetSpotSize(SpS) 	//Note, spot sizes are 0 to 4 in code, 1-5 on user interface

//unblank beam
//CAN't do this on 1.8!!!
//EMSetBeamBlanked(OFF)	
	}


// Dialog	


    class myDlg:UIframe{
          void OnButtonDoA(object self) { 
			Set10k()
			result("\n 10K mag selected"); 
			}
          void OnButtonDoB(object self) {
          	Set50k()
			result("\n 50k mag selected"); }
          void OnButtonDoC(object self) { 
          	Set250k()
			result("\n 250k mag selected"); }
          myDlg(object self)
          {
               taggroup dlg = DLGCreateDialog("My Dialog")
               dlg.DLGAddElement(DLGCreateLabel("For low dose Samples")).DLGWidth( 22 )
               dlg.DLGAddElement(DLGCreateLabel("Select Option"))
               dlg.DLGAddElement(DLGCreatePushButton("10Kx", "OnButtonDoA"))
               dlg.DLGAddElement(DLGCreatePushButton("50Kx", "OnButtonDoB"))
               dlg.DLGAddElement(DLGCreatePushButton("250Kx", "OnButtonDoC"))
               self.Init( dlg )
          }
    }
    
    //clearResults()
    //Result("I do stuff \n")
    Alloc(myDlg).display("Imaging Condition")
    //Result("I continue to do stuff.")