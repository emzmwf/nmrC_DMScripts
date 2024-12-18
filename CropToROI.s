// Script to cut out the ROI in the foremost image and
// create a new image from it.

// D. R. G. Mitchell, adminnospam@dmscripting.com (remove the nospam to make this email address work)

// v1.3 20241218 - copy tags also, add tag saying name of original file
// TO DO - scale bar is fine when this is run as a separate script, but size is massive when run from menu. Investigate and fix.

// variables

number sizex, sizey, scalex, scaley
number top, left, bottom, right
number roipixwidth, roiunitwidth, roipixheight, roiunitheight
string unitstring, imgname


//copytags
void copytags(image imgsource, image imgtarget){
//try
//gettwoimageswithprompt("0 = Source Image, 1 = Target Image","Copy ALL tags between images", imgsource, imgtarget)
// 
//catch
//exit(0)
 
string targetname, sourcename
targetname=getname(imgtarget)
sourcename=getname(imgsource)
 
TagGroup sourcetags=imagegettaggroup(imgsource)
TagGroup targettags=imagegettaggroup(imgtarget)
taggroupcopytagsfrom(targettags,sourcetags)

//Add tag to say sourcename
String tagPath = "Acquisition:Original"
TagGroupSetTagAsString(targettags, tagPath, sourcename) 

okdialog("All tags copied from '"+sourcename+"' to '"+targetname+"'.")
}



// Get info from foremost image

image front:=getfrontimage()
getsize(front, sizex, sizey)
getscale(front, scalex, scaley)
getunitstring(front, unitstring)
getname(front, imgname)


// Check for presence of ROI - error if absent

imagedisplay imgdisp=front.imagegetimagedisplay(0)
number roinumber=imgdisp.imagedisplaycountrois()

if(roinumber!=1) 
	{
		beep()
		okdialog("A rectangular Region Of Interest (ROI) must be present for this script to work!")
		exit(0)
	}


// Get ROI parameters

roi theroi=imgdisp.imagedisplaygetroi(0)
roigetrectangle(theroi, top, left, bottom, right)

roipixwidth=right-left
roiunitwidth=roipixwidth*scalex
roipixheight=bottom-top
roiunitheight=roipixheight*scaley


// Give info on the ROI being used

okdialog("Region selected for extraction is : \n"+roipixwidth+" pixels wide ("+roiunitwidth+" "+unitstring+")\n"+roipixheight+" pixels high ("+roiunitheight+" "+unitstring+")\nTop left corner is at x = "+left+" y = "+top)


// Copy the selected region and create a new image 

image cropped=front[]
showimage(cropped)


// Calibrate and name the new image
imagecopycalibrationfrom(cropped, front)
imagedisplay cropdisp=cropped.imagegetimagedisplay(0)
cropdisp.applydatabar()
number substringlength=len(imgname)
if(substringlength>9) substringlength=9
string shortname=left(imgname, substringlength)+" Extracted ROI"
setname(cropped, shortname)

//Copy tags
copytags(front, cropped)
