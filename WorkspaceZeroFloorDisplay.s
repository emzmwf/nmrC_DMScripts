// Script to set minimum displayed contrast to zero 
// for every image in workspace


void PerformBatchAction( image img )
{
ImageDisplay imageDisp = img.ImageGetImageDisplay( 0 )
number low, high, bright, contrast
ImageDisp.ImageDisplayGetContrastLimits( low, high )
ImageDisplaySetContrastLimits(imageDisp, 0, high) 
}

number nImg = CountImageDocuments()
for ( number i = 0 ; i < nImg ; i ++ )
{
 imageDocument doc = GetImageDocument( i )
 image img := doc.ImageDocumentGetImage(0)
 PerformBatchAction( img )
 
 }




