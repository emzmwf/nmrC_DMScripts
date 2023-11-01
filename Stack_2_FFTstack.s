// Take front image, check it's a stack, make an FFT stack of this image
// April 17 2023	MWF


void main(){

// Find out what size the original images are
// Get the stack
image stackin:=GetFrontImage()
if (3 != stackin.ImageGetNumDimensions() ) Throw( "Invalid input. Not 3D stack." )
imageDisplay dispin = stackin.ImageGetImageDisplay(0)

string name = stackin.GetName()

number stackx, stacky, nproj

stackx=stackin.ImageGetDimensionSize(0)
stacky=stackin.ImageGetDimensionSize(1)
nproj=stackin.ImageGetDimensionSize(2)

// Make a new stack ready for this data

//image out2 := ComplexImage( Name+"_FFTstack", 8, stackx, stacky,nproj )
image out2 := ComplexImage( Name+"_FFTstack", 8, stacky, stacky,nproj )
out2.ShowImage()
imageDisplay dispout2 = out2.ImageGetImageDisplay(0)

// Iterate through

number i = 5
for(i=0;i<nproj;i++)
{
//get one slice
Result("\n Slice "+i)
//image img = slice2(stackin, 0,0,i,0,stackx, 1,1,stacky,1)
//Assume stacky is the shorter axis
number xydiff = stackx-stacky
//image img = slice2(stackin, xydiff/2,0,i,0,stacky-xydiff/2, 1,1,stacky,1)
image img = slice2(stackin, (xydiff/2),0,i,0,stacky, 1,1,stacky,1)
//img.ShowImage()
//This should be the central 

// Transform
compleximage img_FFT := RealFFT(img)
img_FFT.UpdateImage()

//Put the FFT slice in the output stack
out2.slice2(0,0,i, 0,stacky,1, 1,stacky,1) = img_FFT	//
if(i==0){
number VAL = 1
VAL = ImageGetDimensionScale( img_FFT, 0 )
string UNIT
//UNIT = ImageGetDimensionUnitString(img_FFT,0)
//That bit doesn't seem to work, so just assume
UNIT="1/nm"

out2.ImageSetDimensionOrigin( 0, 0 ) 
out2.ImageSetDimensionScale( 0, VAL ) 
out2.ImageSetDimensionUnitString(0, UNIT ) 

out2.ImageSetDimensionOrigin(1, 0 ) 
out2.ImageSetDimensionScale( 1, VAL ) 
out2.ImageSetDimensionUnitString(1, UNIT ) 
}
}

//Copy calibrations





// show the stack
}

main()