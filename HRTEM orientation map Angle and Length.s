/* 
HRTEM orientation map script for GMS
MWF October 2023

*/ 


//Function to identify the angle of the brightest spot in the FFT
//Note, this has the SmoothFilter applied to reduce noise sensitivity
number GetAng (image in, number cBx, number cBy, number Rs, number Pr, number Imin){
//Extract ROI
image outroi :=  ImageClone( in[ cBx, cBy, cBx+Rs, cBy+Rs ] )
SetName( outroi, GetName( in ) + " cropped #1" )
//ShowImage( out1 )

//Calculate FFT of ROI
image Ft = ReducedFFT(outroi)
DeleteImage(outroi)
//ShowImage( Ft )

//Get log of modulus of FFT
image mod = modulus(Ft)
DeleteImage(Ft)
//ShowImage( mod )

//Blank out central probe 
mod[((Rs/4)-Pr),((Rs/4)-Pr),((Rs/4)+Pr),((Rs/4)+Pr)]=0
//ShowImage( mod )

//apply filter
image modS = SmoothFilter( mod )
DeleteImage(mod)
//ShowImage(modS)

//find position of maximum value
number mpX, mpY
number mpV = max( modS, mpX, mpY )
//Result("\n mpV is "+mpV)
//Result("\n mpX is "+mpX)
//Result("\n mpy is "+mpY)

//Return value depending on position
number ang = atan2(mpX-(Rs/4), mpY-(Rs/4))
number len = sqrt(((mpX-(Rs/4))*(mpX-(Rs/4)))+((mpY-(Rs/4))*(mpY-(Rs/4))))
// Angle is the orientation of the spot
// len is the distance of the spot from the centre


//Result("\n Angle is "+ang)
if (mpV < Imin){
	ang = 0
}
//Put data into the tag group
TagGroup tg = GetPersistentTagGroup( )
tg.TagGroupSetTagAsNumber( "HRTEMOrientAng", ang )
tg.TagGroupSetTagAsNumber( "HRTEMOrientLen", len )


return ang
}

void main (image in){

/*
   =========================
Following three variables will affect quality,
 resolution and time required to map
Suitable FT window size, probe radius can be appraised with a live FFT in GMS
Note that intensity is from the 

   =========================
*/

//Define FT window size
number Rs = 256

//Define probe radius
number Pr = 3

//Define intensity minimum in FT space
number Imin = 60000

//Define size of steps between mapping areas - 1/32th of the image size takes a few seconds on a desktop PC
number Stepval = 64


//Get size details of front image
number sx, sy
GetSize( in, sx, sy )

//Set up variables for a 2D for loop
number nx
number ny
number nxmax = ((sx-Rs)/Stepval)
number nymax = ((sy-Rs)/Stepval)

//Create map image - note, these will ignore an Rs sized window around the image
image outmap := RealImage( "Angle map", 4, nxmax, nymax )
image lenmap := RealImage( "Dist map", 4, nxmax, nymax )
ShowImage(outmap)
ImageDisplay ImgDisp = outmap.ImageGetImageDisplay( 0 )
// Change color display - Rainbow is a GMS default, but not the best colormap for this
// Additional colormaps based on matplotlib cmaps have been installed on nmRC GMS systems
// e.g. we might use twilight_shifted for this map
ImageDisplaySetColorTableByName(ImgDisp, "Rainbow")
ShowImage(lenmap)
ImageDisplay ImgDispL = lenmap.ImageGetImageDisplay( 0 )
// Change color display - Rainbow is a GMS default, but not the best colormap for this
// Additional colormaps based on matplotlib cmaps have been installed on nmRC GMS systems
// e.g. we might use viridas for this map
ImageDisplaySetColorTableByName(ImgDispL, "Rainbow")

Result("\n Starting loop \n ")

TagGroup tg = GetPersistentTagGroup( )
tg.TagGroupSetTagAsNumber( "HRTEMOrientRs", Rs )

for (nx=1; nx<=nxmax; nx++){
	for (ny=1; ny<=nymax; ny++){
		//Check if they've changed their mind yet
		if  (ShiftDown() == 1){
			Result("Shift pressed, ending script")
			exit( 0 )
		}//end if shift down
		number ang, len
		//ang = GetAng(in, ny*Stepval, nx*Stepval, Rs, Pr, Imin)//x and y need to be reversed but not sure why
		GetAng(in, ny*Stepval, nx*Stepval, Rs, Pr, Imin)//x and y need to be reversed but not sure why
		// Get data from tag group
		tg.TagGroupGetTagAsNumber( "HRTEMOrientAng", ang )
		tg.TagGroupGetTagAsNumber( "HRTEMOrientLen", len )
		outmap.SetPixel(nx-1, ny-1, ang)
		lenmap.SetPixel(nx-1, ny-1, len)
		//Result("\n "+ang +" \n")
		//Result(nx*ny)
	}//end y loop
	ShowImage(outmap) //Only show one to avoid flicker
}//end x loop

ShowImage(outmap)


}// end function

// Set up the global tags used to store data
TagGroup tg = GetPersistentTagGroup( )
number Val1 = TagGroupDoesTagExist( tg, "HRTEMOrientAng" )
if (Val1 ==1){
}
else{
tg.TagGroupSetTagAsNumber( "HRTEMOrientAng", 0 )
tg.TagGroupSetTagAsNumber( "HRTEMOrientLen", 0 )
tg.TagGroupSetTagAsNumber( "HRTEMOrientRs", 64 )
}

//Get front image
image in
if ( !GetFrontImage( in ) )
 Throw( "No image loaded." )

//Apply function
main(in)

//Apply ROI to image to indicate area used
number sx, sy, Rs
GetSize( in, sx, sy )
tg.TagGroupGetTagAsNumber( "HRTEMOrientRs", Rs )
ROI orientROI = NewROI()
orientROI.ROISetRectangle( Rs, Rs, sy-Rs, sx-Rs )
imageDisplay disp = in.ImageGetImageDisplay( 0 )
disp.ImageDisplayAddROI( orientROI )
