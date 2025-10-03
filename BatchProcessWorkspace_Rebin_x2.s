

void PerformBatchAction( image img )
{
 // Modify this method to act on the image 
 // Current action: Output the data type and some statistics, rebin if not near max intensity
 result( "\t\t Data range [ " + min( img ) + ", " + max( img ) + "] mean = " + mean( img ) + "\n" )
 
 Number xRebin = 2
 Number yRebin = 2
 number maxpixval = max(img)
 //img := Rebin( img, xRebin, yRebin )
 if (maxpixval <= 16382){
	RebinInPlace( img, xRebin, yRebin )
	}
 UpdateImage(img)
 // Save(img)                         // Use this to resave the image
 // DeleteImage(img)         // use this to close the image
}



number nImg = CountImageDocuments()
for ( number i = 0 ; i < nImg ; i ++ )
{
 imageDocument doc = GetImageDocument( i )
 image img := doc.ImageDocumentGetImage(0)
 PerformBatchAction( img )
 
 }
