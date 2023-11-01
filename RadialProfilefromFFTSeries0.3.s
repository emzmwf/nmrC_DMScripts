//===============================
//RadialProfilefromFFTSeries 0.2
//===============================

//Radial Intensity Calculation from script by Ming Pan, Paul Thomas, Robin Harmon
image RadialIntensityDistribution(image img, number samples)
{
	// Define neccessary parameters and constants
	number pi = 3.1416
	number xscale, yscale, xsize, ysize
	number centerx, centery, halfMinor
	number scale = img.ImageGetDimensionScale(0)
	string unit = img.ImageGetDimensionUnitString(0)

	// Likewise, declare intermediate images
	image rotational_average, dst, line_projection
	
	// If the source image is complex, take the modulus						
	if ( img.ImageIsDataTypeComplex( ))
		img := modulus(img)

	// Get the dimension sizes, and determine half the smallest dimension 
	img.Get2dSize( xsize, ysize )
	halfMinor = min( xsize, ysize )/2

	// Find the centre of the image
	centerx = xsize / 2
	centery = ysize / 2

	// Convert the image to polar co-ordinates...
	dst := RealImage( "dst", 4, halfMinor, samples )
	dst = warp( img, icol*sin(irow*2*pi/samples) + \
			centerx, icol*cos(irow*2*pi/samples) + centery )

	// and create a line projection using the icol intrinsic variable, 
	// normalising with the sampling density
	line_projection := RealImage( "line projection", 4, halfMinor, 1 )
	line_projection.ImageSetDimensionScale( 0, scale )
	line_projection.ImageSetDimensionUnitString( 0, unit )
	line_projection = 0
	line_projection[icol,0] += dst
	line_projection /= samples
		
	return line_projection
}



//Body of script
image Main(image in){

//Get size of array
number sx, sy, sz
get3dsize(in,sx,sy,sz)
Result("\n sz is "+sz)

number zBin = 1
number r_steps = 128
r_steps = sx/4	//

RealImage Plot2d := RealImage("Profile ", 4, r_steps*2, sz) // name, bytes, x dimension, y dimension
//ShowImage(Plot2d)

//Get each slice in turn and calculate the radial profiles
number k
image slice
image out = RealImage("out", 4, r_steps*2, 1)// name, bytes, x dimension, y dimension
//ShowImage(out)


for (k=1; k<=sz; k++){
	slice = in.slice2(0,0,k-1, 0,sx,1, 1,sy,1)
	number kx, ky, kz
	out = ( RadialIntensityDistribution(slice, r_steps ) )
	GetSize( out, kx, ky )
	//Result("\n Slice number "+k+"\n")
	//Result(kx+"\t"+ky+"\t"+kz+"\n")
	Plot2d[k-1,0,k,r_steps*2] = out
	
}

return Plot2d
}

//Set up timing
number Alice = GetOSTickCount()
image in:=GetFrontImage()

number VAL = 1
VAL = ImageGetDimensionScale( in, 0 )
string UNIT
UNIT = ImageGetDimensionUnitString(in,0)

image out = Main(in)
ImageSetName( out, "Radial Map" ) 
//ShowImage(out)

image out2 = log10(out)     // log base 10
ImageSetName( out2, "Radial Map log 10" )
out2.ImageSetDimensionOrigin( 0, 0 ) 
out2.ImageSetDimensionScale( 0, VAL ) 
out2.ImageSetDimensionUnitString(0, UNIT ) 

 
ShowImage(out2)
ImageDisplay ImgDisp = out2.ImageGetImageDisplay( 0 )
ImageDisplaySetColorTableByName(ImgDisp, "viridis")

number Bob = GetOSTickCount()
number Charlie = CalcOSSecondsBetween(Alice, Bob)
Result("\n Time taken is approximately "+Charlie)