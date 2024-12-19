
//////////////////////////////////////////////
// 80kV and 200kV operation
// After the rebuild
// March 2024
//	July2024 - tidy script
//
// Settings based on alignment files:
//	80kV:	2024-04-15 80kV MWF
//  200kV: 2024-07-04_200kV_JEOL
// 
// STD focus 200kV 1.50818e+06
// STD focus 80kV 1.2127e+06
// aDD 100Kv 2024-12-13 mwf
// Prevent 10k mag select at alpha1

void SetImMode(){
	string Edna = EMGetImagingOpticsMode()
	if (Edna !="MAG1"){
		EMSetBeamBlanked(1)
		string help = "Changing mode to MAG1:\n"
		help += "Press SHIFT to abort."

		if ( !OKCancelDialog( help ) )

		exit( 0 )
		
		EMSetImagingOpticsMode("MAG1")
		EMSetBeamBlanked(0)
	}
}

//set mage to 10K
void Set10K()
	{
	//Check voltage of microscope
	number HT
	HT = EMGetHighTension()

	if (HT != 200000){
		if (HT != 80000){
			if (HT != 100000){
				string help = "This plugin for HTs:\n"
				help += " 80kV, 100, and 200kV\n"
				help += "Press SHIFT to abort."
				if ( !OKCancelDialog( help ) )
				exit( 0 )
				}
			}
		}

	//Check imaging mode
	SetImMode()

	//Check we are in alpha mode 2 or 3, not 1 - will be zero in script numbers
	Number F = EMGetIlluminationSubMode( )
	if ( F == 0 ){
		OKDialog( "10k mag not suitable for Alpha 1" )
		exit( 0 )	
		}

	
	//Set up parameters, with default values
	number NMag = 10000
	number Bval = 57441
	number Focus = 1.60656e+06
		//Apply correct parameters for voltage
	if (HT == 200000){
		Bval = 62541
		Focus = 1.50818e+06
		//Focus = 1.6009e+06
		}

	if (HT == 100000){
		result("Applying 100kV settings")
		Bval = 60735
		Focus = 1.26637e+06
	}

	if (HT == 80000){
		result("Applying 80kV settings")
		Bval = 60735 
		//Focus = 1.20995e+06
		//Eucentric is 1.22288e+06
		Focus = 1.22265e+06 //20240903
		result(Bval)
		}
	
result("\n A")	
	result(Bval)

	string help = "SetMag10k:\n"
	help += "Press SHIFT to abort."

	if ( !OKCancelDialog( help ) )
	exit( 0 )

	//Set Brightness
	result("\n B")
	result(Bval)
	EMSetBrightness(Bval)
	//Set Mag
	EMSetMagnification(NMag)
	//Set standard focus
	EMSetFocus(Focus)
		
	}

///////////////////////////////////////////

//set mage to 50K
void Set50K()
	{
	//Check voltage of microscope
	number HT
	HT = EMGetHighTension()

	if (HT != 200000){
		if (HT != 80000){
			if (HT != 100000){
				string help = "This plugin for HTs:\n"
				help += " 80kV and 200kV\n"
				help += "Press SHIFT to abort."
				if ( !OKCancelDialog( help ) )
				exit( 0 )
				}
			}
		}

	//Check imaging mode
	SetImMode()

	//Set up parameters, with default values
	number NMag = 50000
	number Bval = 46841 
	number Focus = 1.60656e+06
		//Apply correct parameters for voltage
	if (HT == 200000){	
		Bval = 49481
		Focus = 1.50818e+06
		//Focus = 1.6009e+06
	}
	if (HT == 100000){
		result("Applying 100kV settings")
		Bval = 47815
		Focus = 1.26637e+06
	}

	if (HT == 80000){
		result("Applying 80kV settings")
		Bval = 46795
		//Focus = 1.20995e+06
		//Eucentric is 1.22288e+06
		//Focus = 1.22288e+06	
		Focus = 1.22265e+06 //20240903
	}

	string help = "SetMag50k:\n"
	help += "Press SHIFT to abort."

	if ( !OKCancelDialog( help ) )
	exit( 0 )

	//Set Brightness
	EMSetBrightness(Bval)
	//Set Mag
	EMSetMagnification(NMag)
	//Set standard focus
	EMSetFocus(Focus)
		
	}
//////////////////////////////////////////	


//set mage to 250K
void Set250K()
	{
	//Check voltage of microscope
	number HT
	HT = EMGetHighTension()

	if (HT != 200000){
		if (HT != 80000){
			if (HT != 100000){
				string help = "This plugin for HTs:\n"
				help += " 80kV and 200kV\n"
				help += "Press SHIFT to abort."
				if ( !OKCancelDialog( help ) )
				exit( 0 )
				}
			}
		}

	//Check imaging mode
	SetImMode()

	//Set up parameters, with default values
	number NMag = 250000
	number Bval = 44621
	number Focus = 1.60656e+06
	//Apply correct parameters for voltage
	if (HT == 200000){	
		Bval = 46817
		Focus = 1.50818e+06
		//Focus = 1.6009e+06
	}
	if (HT == 100000){
		result("Applying 100kV settings")
		Bval = 46125
		Focus = 1.26637e+06
	}
	if (HT == 80000){
		Bval = 46125
		//Focus = 1.20995e+06
		//Eucentric is 1.22288e+06	
		//Focus = 1.22288e+06
		Focus = 1.22265e+06 //20240903
	}

	string help = "SetMag250k:\n"
	help += "Press SHIFT to abort."

	if ( !OKCancelDialog( help ) )
	exit( 0 )

	//Set Brightness
	EMSetBrightness(Bval)
	//Set Mag
	EMSetMagnification(NMag)
	//Set standard focus
	EMSetFocus(Focus)
		
	}
//////////////////////////////////////////	




    class myDlg:UIframe{
          void OnButtonDo10K(object self) { 
			Set10K()
			result("\n 10K"); 
			}
          void OnButtonDo50K(object self) {
			Set50K()
			}
          void OnButtonDo250K(object self) { 
			Set250K()
			result("\n 250K"); }
          myDlg(object self)
          {
               taggroup dlg = DLGCreateDialog("My Dialog")
               dlg.DLGAddElement(DLGCreateLabel("Dec2024 Select MAG"))
               dlg.DLGAddElement(DLGCreatePushButton("10K", "OnButtonDo10K"))
               dlg.DLGAddElement(DLGCreatePushButton("50k", "OnButtonDo50k"))
               dlg.DLGAddElement(DLGCreatePushButton("250k", "OnButtonDo250k"))
               self.Init( dlg )
          }
    }
    
    clearResults()
    
    Alloc(myDlg).display("Imaging Condition")
    