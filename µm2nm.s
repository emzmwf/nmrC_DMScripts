// Get front image
image in
if ( !GetFrontImage( in ) )
 Throw( "No image loaded." )

// Get format of units
string Unit = ImageGetDimensionUnitString(in, 0)
Result(Unit)

//string micron = "um"
string micron = "µm"

// If unit is microns, do adjustment routine
if (Unit == micron)
	{
	number sx, sy
	GetScale( in, sx, sy )
	number soutx = sx*1000
	number souty = sy*1000
	in.ImageSetDimensionOrigin( 0, 0 ) 
	in.ImageSetDimensionScale( 0, soutx ) 
	in.ImageSetDimensionUnitString(0, "nm" )
	in.ImageSetDimensionScale( 1, souty ) 
	in.ImageSetDimensionUnitString(1, "nm" )
 	}
// end if

ShowImage( in )