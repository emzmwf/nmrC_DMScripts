// Script to read in EMSA files from Oxford Instruments AZtect

// Modified from script by 
// D. R. G. Mitchell, version:20150217, v1.0, Feb 2015, www.dmscripting.com

// EMSA files are text files with header information. This script extracts the 
// number of points, dispersion and energy units from the header, then reads the
// intensity into a spectrum

// Main script starts here 

//variables

string pathname, filename, testtext, outputtext, lineid, directory, newname, extension
number i, inputfileno, outputfileno, j


// Locate the file to convert and source some info on it

//if (!OpenDialog(pathname)) exit(0)
if (!OpenDialog(NULL, "Select file to open", pathname, pathname)) exit(0)

filename=pathextractbasename(pathname,0)
directory=pathextractdirectory(pathname, 2)
extension=pathextractextension(pathname,2)


// Open the selected file for reading and create a new file to write to

inputfileno=openfileforreading(pathname)


// Trap for non-EMSA format files -  Noran System Seven files have the header in the first line as
// #FORMAT      : EMSA/MAS Spectral Data File

readfileline(inputfileno, testtext)

number linelength=len(testtext)
number numberpoints
number dispersion
number energyoffset
string xunits, yunits

string trimmedfirstline=left(testtext,linelength-2) // remove two characters (comma and CR) at end of line

if(trimmedfirstline!="#FORMAT      : EMSA/MAS Spectral Data File" )
	{
		if(!twobuttondialog("This file does not appear to be an EMSA/MAS format file!","Proceed","Cancel"))
			{
				closefile(inputfileno)
				showalert("Import Cancelled by User!",1)
				exit(0)
			}
	}



// Do the main processing within a try loop. In the event of an error the catch will close all the relevant files
// and so avoid the 'this file is in use by another process' error - which can only be stopped by restarting DM.

try
{

// Loop through the file reading it line by line and ignoring all lines which begin
// with a # - these are header lines

while(3>2)
	{
		readfileline(inputfileno, testtext)


		// Extract the number of points  in the spectrum
		
		number linelength=len(testtext)
		if(linelength==0) break 
		number len=len(testtext)
		if(left(testtext,14)=="#NPOINTS     :")
			{
				numberpoints=val(mid(testtext, 15, len-15))
			}
			
		
		// Extract the dispersion keV/ch
		
		if(left(testtext,14)=="#XPERCHAN    :")
			{
				dispersion=val(mid(testtext, 15, len-15))
			}


		// Extract the unit string
		
		if(left(testtext,14)=="#XUNITS      :")
			{
				xunits=mid(testtext, 15, len-15)
			}
				
		// Extract the unit string
		
		if(left(testtext,14)=="#YUNITS      :")
			{
				yunits=mid(testtext, 15, len-15)
			}
			
		// Extract the offset voltage
		
		if(left(testtext,14)=="#OFFSET      :")
			{
				energyoffset=val(mid(testtext, 15, len-15))
			}


		// Add in getting the element labels here

		// a trap to avoid infinite loops - eventually the script comes to the end of the file and encounters empty lines

		lineid=left(testtext,1)
		if(lineid!="#") break 
	}


// Break out of the loop when a line is encountered which does not start with a #
// this is the first line of data - convert it to tab delimited and then write this to the outputfile

lineid=""


// Create a spectrum for writing data to

image spectrum=realimage("",4,numberpoints)


// Loop through the remaining lines of the file, reading the data, converting it and writing it to
// the output file

while(3>2)
	{
		j=j+1
		readfileline(inputfileno, testtext)


		// A trap for end of file condition in non-emsa files

		number linelen=len(testtext)
		if(linelen==0) break
		number i
		
		
		// Read through the line looking for a comma which seperates channel number from intensity
		// Use this point to extract the intensity and store it in a spectrum
		
		for(i=0; i<linelen; i++)
			{
				string thischar=mid(testtext, i, 1)
				if(asc(thischar)==44)
					{
						number intensity=val(mid(testtext, i+1, linelen-(i+1)))
						setpixel(spectrum, j-1, 0, intensity)
						break
					}
			}


		// The end of the data in emsa files is signified with #EndOfData
		
		lineid=left(testtext,1)
		if(lineid=="#") break
}


// Close the input and output files

closefile(inputfileno)


// Finish up

showimage(spectrum)
setname(spectrum, filename)
spectrum.imagesetdimensionscale(0, dispersion)
spectrum.imagesetdimensionorigin(0, energyoffset)
spectrum.imagesetdimensionunitstring(0, xunits)
spectrum.imagesetintensityunitstring(yunits)
ImageDisplay disp = spectrum.ImageGetImageDisplay(0)

//disp.LinePlotImageDisplaySetSliceLineThickness( 0, 10 )
disp.LinePlotImageDisplaySetGridOn( 0 )
disp.LinePlotImageDisplaySetFontSize( 24 ) 

//LinePlotImageDisplaySetGridOn( LinePlotImageDisplay lpid, Boolean on )
//Adjust display range - if range is above 20keV, set it to 20
//disp.LinePlotImageDisplaySetDisplayedChannels( 0, round(numberpoints))
disp.LinePlotImageDisplaySetDisplayedChannels( 0, round(numberpoints/2))


//Adjust display height - find highest counts above 0.5 keV
number maxsig = max( spectrum)
maxsig = max( spectrum[0,100,1,numberpoints])
disp.LinePlotImageDisplaySetContrastLimits( 0, maxsig )


// Add peak labels
// e.g. ##OXINSTLABEL: 6, 0.277, C - calculate posX from 0.277keV, get counts at that position for posY
// TODO - automated parsing of this data. Get labels and kV, identify heights, check is above background, is local maxima
/*
number labkV = 0.277
number label_posX = ((labkV-energyoffset)/dispersion)
number label_posY = 2000
string lbl = "C"
//LinePlotImageDisplayAddPeakLabel( disp, Number label_posX, Number label_posY, String lbl )
LinePlotImageDisplayAddPeakLabel( disp, label_posX, label_posY, lbl )
//##OXINSTLABEL: 29, 8.048, Cu
labkV = 8.048
label_posX = ((labkV-energyoffset)/dispersion)
label_posY = 500// unit is counts
lbl = "Cu"
LinePlotImageDisplayAddPeakLabel( disp, label_posX, label_posY, lbl )
*/
}

// If an error occurs due to an inappropriate file format, the files opend for reading and outputting
// are closed to avoid errors

catch 


{
	closefile(inputfileno)
	openandsetprogresswindow("","","")
	showalert("Sorry an error occurred. Make sure you are converted EMSA/MAS Spectra files (.emsa)",2)
}