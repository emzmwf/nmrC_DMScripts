number GetAng (image in, number cBx, number cBy, number Rs, number Pr, number Imin){
//Extract ROI
image outroi :=  ImageClone( in[ cBx, cBy, cBx+Rs, cBy+Rs ] )
SetName( outroi, GetName( in ) + " cropped #1" )
//ShowImage( out1 )

//Calculate FFT of ROI
image Ft = ReducedFFT(outroi)
//ShowImage( Ft )

//Get log of modulus of FFT
image mod = modulus(Ft)
//ShowImage( mod )

//Blank out central probe 
mod[((Rs/4)-Pr),((Rs/4)-Pr),((Rs/4)+Pr),((Rs/4)+Pr)]=0
//ShowImage( mod )

//apply filter
image modS = SmoothFilter( mod )
//ShowImage(modS)

//find position of maximum value
number mpX, mpY
number mpV = max( modS, mpX, mpY )
//Result("\n mpV is "+mpV)
//Result("\n mpX is "+mpX)
//Result("\n mpy is "+mpY)

//Return value depending on position
number ang = atan2(mpX-(Rs/4), mpY-(Rs/4))
//Result("\n Angle is "+ang)
if (mpV < Imin){
	ang = 0
}
return ang
}

void main (image in){

//Define FT window size
number Rs = 256

//Define probe radius
number Pr = 5

//Define intensity minimum in FT space
number Imin = 70000

//Get size details of front image
number sx, sy
GetSize( in, sx, sy )
//Create map image
//image outmap := RealImage( "map", 4, sx, sy )


number cBx
number cBy

number Stepval = 32

number nx
number ny
number nxmax = ((sx-Rs)/Stepval)
number nymax = ((sy-Rs)/Stepval)

//image outmap := RealImage( "map", 4, nxmax*2, nymax*2 )
image outmap := RealImage( "map", 4, nxmax, nymax )
ShowImage(outmap)
Result("\n Starting loop \n ")



for (nx=1; nx<=nxmax; nx++){
	for (ny=1; ny<=nymax; ny++){
		//Check if they've changed their mind yet
		if  (ShiftDown() == 1){
			Result("Shift pressed, ending script")
			exit( 0 )
		}//end if shift down
		number ang = GetAng(in, ny*Stepval, nx*Stepval, Rs, Pr, Imin)//x and y need to be reversed but not sure why
		outmap.SetPixel(nx-1, ny-1, ang)
		//Result("\n "+ang +" \n")
		//Result(nx*ny)
	}//end y loop
}//end x loop

ShowImage(outmap)
ImageDisplay ImgDisp = outmap.ImageGetImageDisplay( 0 )
ImageDisplaySetColorTableByName(ImgDisp, "Rainbow")

}// end function

//Get front image
image in
if ( !GetFrontImage( in ) )
 Throw( "No image loaded." )

//Apply function
main(in)