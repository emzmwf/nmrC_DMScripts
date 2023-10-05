// ## Batch processed binned dm4 files to jpg
// v 1b 19th January 2023 - MWF
// now set to process only type 2 or 11 dm4 images
// to avoid error with FFT files
// v1c 31May2023 - hide images and documents after saving
// 12 June 2023 - add type 2 for OneView dm4 images
// still can't hide opened images despite trying in multiple ways...


//Function clones image, bins down to a size between 1024 and 2048, copies calibrations, saves display as jpg
void PerformBatchAction( image img, string fname )

{

 // Modify this method to act on the image 
 // Current action: Output the data type and some statistics

 result( "\t\t Data range [ " + min( img ) + ", " + max( img ) + "] mean = " + mean( img ) + "\n" )
 
	//ShowImage(img)
 
	number xBin, sx, sy
	GetSize( img, sx, sy )
	number tsx = sx
	xBin = 1
	
	/*
	while (tsx>1024){
		xBin = xBin*2
		tsx = tsx/xBin
		//Result("\n")
		//Result(xbin)
	}
	//xBin = round(sx/1000)
	Image out1 := ImageClone( img )
	SetName( out1, GetName( img ) + " binned" )
	ImageResize( out1, 2, sx/xBin, sy/xBin )	//creates blank image the right size
	// Sum over all possible sub-sections
	for ( number j = 0; j < xBin; j++ )
	{
		for ( number i = 0; i < xBin; i++ )
		{
		out1 += Slice2( img, i, j, 0, 0, sx/xBin, xBin, 1, sy/xBin, xBin )
		}
	}
*/
	Image out16 := ImageClone( img )
	//Convert to integer 2 signed
	ConvertToShort( out16 ) 
	
	SetName( out16, GetName( img ) + " int2" )


		
	// Move this out of a subroutine as it was being skipped for unknown reasons
	// probably my error though
	
	
	// Source the calibration data from the original image

	number xorigin, xscale, yorigin, yscale
	string xunitstring, yunitstring
	number calformat=0
	ImageGetDimensionCalibration( img, 0, xorigin, xscale, xunitstring, calformat ) 
	ImageGetDimensionCalibration( img, 1, yorigin, yscale, yunitstring, calformat ) 

	// Rescale the calibration to account for rebinning and copy it to the rebinned image

	xscale=xscale*xBin
	yscale=yscale*xBin
	ImageSetDimensionCalibration(out16, 0, xorigin, xscale, xunitstring, calformat)
	ImageSetDimensionCalibration(out16, 1, yorigin, yscale, yunitstring, calformat)
	
	
	//Add the scale bar
	ShowImage(out16)	//have to show it to use imagedisplay
	imagedisplay disp = out16.ImageGetImageDisplay(0)
	number kSCALEBAR = 31
	component scalebar = NewComponent( kSCALEBAR, (sy/xBin)-100, 30, (sy/xBin)-20, 230 )
	disp.ComponentAddChildAtEnd( scalebar )
	
	//String Outformat = "jpeg"
	
	string DirOnly = PathExtractDirectory( fname, 0 )
	string NameOnly = PathExtractBaseName(fname, 0)
	String file_name = DirOnly+NameOnly+"_int2.tif"

	SaveAsTiff( out16, file_name, 1) 	//savetype1 = save data

	HideImage(img)			//try and hide display
	HideImage(out16)
		
	DeleteImage(img)         // try and hide display
   DeleteImage(out16)         //try and hide display
   
}

 
// Function converts a string to lower-case characters

string ToLowerCase( string in )
{
 string out = ""
 for( number c = 0 ; c < len( in ) ; c++ )
 {
         string letter = mid( in , c , 1 )
         number n = asc( letter )
         if ( ( n > 64 ) && ( n < 91 ) )        letter = chr( n + 32 )
         out += letter
         }        

 return out

}
 
// Function to create a list of file entries with full path
TagGroup CreateFileList( string folder, number inclSubFolder )
{
 TagGroup filesTG = GetFilesInDirectory( folder , 1 )                        // 1 = Get files, 2 = Get folders, 3 = Get both
 TagGroup fileList = NewTagList()

 for (number i = 0; i < filesTG.TagGroupCountTags() ; i++ )
 {
         TagGroup entryTG
         if ( filesTG.TagGroupGetIndexedTagAsTagGroup( i , entryTG ) )
         {
                 string fileName
                 if ( entryTG.TagGroupGetTagAsString( "Name" , fileName ) )
                 {
                         filelist.TagGroupInsertTagAsString( fileList.TagGroupCountTags() , PathConcatenate( folder , fileName ) )
                 }
         }
 }

 

 if ( inclSubFolder )
 {
         TagGroup allFolders = GetFilesInDirectory( folder, 2 )
         number nFolders = allFolders.TagGroupCountTags()
         for ( number i = 0; i < nFolders; i++ )
         {
                 string sfolder
                 TagGroup entry
                 allFolders.TagGroupgetIndexedTagAsTagGroup( i , entry )
                 entry.TagGroupGetTagAsString( "Name" , sfolder )
                 sfolder = StringToLower( sfolder )
                 TagGroup SubList = CreateFileList( PathConcatenate( folder , sfolder ) , inclSubFolder )
                 for ( number j = 0; j < SubList.TagGroupCountTags(); j++ )
                 {
                         string file
                         if ( SubList.tagGroupGetIndexedTagAsString( j , file ) )
                                 fileList.TagGroupInsertTagAsString( Infinity() , file )
                 }
         }
 }
 return fileList

}

 

// Function removes entries not matching in suffix

TagGroup FilterFilesList( TagGroup list, string suffix )
{
 TagGroup outList = NewTagList()
 suffix = ToLowerCase( suffix )
 for ( number i = 0 ; i < list.TagGroupCountTags() ; i++ )
 {
         string origstr
         if ( list.TagGroupGetIndexedTagAsString( i , origstr ) ) 
         {
                 string str = ToLowerCase( origstr )
                 number matches = 1
                 if ( len( str ) >= len( suffix ) )                 // Ensure that the suffix isn't longer than the whole string
                 {
                         if ( suffix == right( str , len( suffix ) ) ) // Compare suffix to end of original string
                         {
                                 outList.TagGroupInsertTagAsString( outList.TagGroupCountTags() , origstr )        // Copy if matching
                         }
                 }
         }
 }
 return outList

}

 

// Open and process all files in a given fileList

void BatchProcessList( TagGroup fileList , string name )
{
 number nEntries = fileList.TagGroupCountTags()
 if ( nEntries > 0 )
         result( "Processing file list <" + name + "> with " + nEntries + " files.\n" )
 else
         result( "File list <" + name + "> does not contain any files.\n" )
 
 for ( number i = 0 ; i < nEntries ; i++ )
 {
         string str 
         if ( fileList.TagGroupGetIndexedTagAsString( i , str ) )
         {
				 Try{
                 result( "\t open: " + str + "\t" )
                 image img := OpenImage( str )
                 if ( img.ImageIsValid() )
                 {						
                         //Check it isn't an FFT
                         number Tp = ImageGetDataType(img)
                         result("\t type "+Tp)
                         
                         if (Tp == 11){
                         
							//If it is type 11, process it
							// Actual batch-action
							result( "\t process... \n" )
							PerformBatchAction( img, str )
							HideImage(img)                                                
							}
						if (Tp == 2){
                         	//If it is type 2, process it
							// Actual batch-action
							result( "\t process... \n" )
							PerformBatchAction( img, str )                                                
							HideImage(img)
							}
						else {
							Result("\n file found of type ")
							Result(Tp)
							result("\t Skipping \n")
							}
                 }
                 else
                         result( "skipped... \n" )
                         }
                 Catch{
                 result("something went wrong")
                 }
         }
 }
}
////////////////////////////////////////////////////////////////////////////////////////
 
// Main routine. Processes all dm3/dm4 files in a directory
void BatchProcessFilesInFolder( number includeSubFolders )
{
 string folder , outputFolder
 if ( !GetDirectoryDialog( "Select folder to batch process" , "" , folder ) ) 
         return
 
 TagGroup fileList = CreateFileList( folder, includeSubFolders ) 
 TagGroup fileListDM3 = FilterFilesList( fileList , ".dm3" )
 BatchProcessList( fileListDM3 , "DM3 list" )
 TagGroup fileListDM4 = FilterFilesList( fileList , ".dm4" )
 BatchProcessList( fileListDM4 , "DM4 list" )
}
 
BatchProcessFilesInFolder( 1 )
