//to change focus while record in-situ
//Change defocus, blank before and after
Result("\n === Through Focus Script ===")

number RawCon =0.77

//number of slices
number n = 50
String SlicPrompt = "Number of slices to acquire"
Getnumber( SlicPrompt, 50, n )

number stepraw
number stepnm = 40	//try1.37 for 160 slices for 200kV at pixel resoln better than 0.25nm. 
number totalfoc = stepnm*n

String StepPrompt = "Approx nm per step"
Getnumber( StepPrompt, stepnm, stepnm )

stepraw = stepnm/RawCon //Correction for FEG
// approx - raw 70 is 90nm


/* 
//Need to have a non blocking dialog for this
//string startNote = "Ensure sample is at exact focus\n"
//startNote += "and start in situ record"

//OKCancelDialog( startNote )
*/


number rawfocus = round(EMGetFocus())
number startfocus = rawfocus-(n/2)*stepraw
number measstartf
number measendf


EMSetBeamBlanked(1)
EMSetFocus(startfocus)
delay(50)
measstartf = round(EMGetFocus())

EMSetBeamBlanked(0)	
//Iterate
number i //counter
for(i = 0; i < n; i ++)
	{

	EMSetFocus(startfocus+i*stepraw)
	delay(2)

	}

// Blank beam	
EMSetBeamBlanked(1)	

measendf = round(EMGetFocus())

// Return focus to original value
EMSetFocus(rawfocus)

Result("\n intended Start focus was "+startfocus)
number endfocus = (startfocus+n*stepraw)
Result("\n intended End focus was "+endfocus)
Result("\n Measured Start focus was "+measstartf)
Result("\n Measured End  focus was "+measendf)
Result("\n raw Step was "+((endfocus-startfocus)/n))
Result("\n Estimated nm per step was "+(RawCon*(endfocus-startfocus)/n))
Result("\n Estimated nm total was "+(RawCon*(endfocus-startfocus)))

string EndNote = "Start focus was "+startfocus +"\n"
EndNote+= "End focus was "+endfocus+"\n"
EndNote+= "raw Step was "+((endfocus-startfocus)/n)+"\n"
EndNote+= "Estimated nm per step was "+(RawCon*(endfocus-startfocus)/n)+"\n"
EndNote+= "Estimated total nm "+(RawCon*(endfocus-startfocus))
OKDialog( EndNote )