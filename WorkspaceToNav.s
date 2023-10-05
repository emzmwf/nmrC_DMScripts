// Get file positions in current workspace and output to a .nav file
// Initial version 25 August 2023 MWF
/*
Format to be output for each image is in the style of
[Item = 1]
Color = 0
StageXYZ = 200.783 -369.024 -5.00157
NumPts = 1
Draw = 0
Regis = 1
Type = 0
SamePosId = 877731955
RawStageXY = 200.783 -369.024
MapID = 359996960
PtsX = 200.783
PtsY = -369.024
*/


//Get active workspace and count documents in it
number wsID = WorkspaceGetActive(  )
string workname = WorkspaceGetName( wsID )
Number nDoc = CountImageDocuments( wsID )
result( "\n Performing action on " + nDoc + " documents on '" + workname + "':\n" )

//Create new text window
documentwindow win
win = NewScriptWindow(nDoc+".nav", 100, 100, 600, 900)
win.EditorWindowAddText( "AdocVersion = 2.00\n\n")


void PerformWorkspaceAction( imageDocument doc, documentwindow win, number i )
{
	number mag, SA, SB, Sx, Sy, Sz
	Result("\n")
	Result("i is "+i)
	Result("\n")
	String idname = ImageDocumentGetName( doc ) 
//	Result(idname)
	image img := doc.ImageDocumentGetImage( 0 ) 
	String ImgName = ImageGetName( img ) 
	number imnum = ImageGetID( img )
//	Result("Image name is "+ImgName)
	TagGroup tgs = img.ImageGetTagGroup()
	tgs.TagGroupGetTagAsNumber( "Microscope Info:Actual Magnification", mag ) 
	tgs.TagGroupGetTagAsNumber( "Microscope Info:Stage Position:Stage Alpha", SA ) 
	tgs.TagGroupGetTagAsNumber( "Microscope Info:Stage Position:Stage Beta", SB ) 
	tgs.TagGroupGetTagAsNumber( "Microscope Info:Stage Position:Stage X", Sx ) 
	tgs.TagGroupGetTagAsNumber( "Microscope Info:Stage Position:Stage Y", Sy ) 
	tgs.TagGroupGetTagAsNumber( "Microscope Info:Stage Position:Stage Z", Sz )
	Result(Sx)
	//Now put info into text
	win.EditorWindowAddText( "[Item = "+i+"]\n" )
	win.EditorWindowAddText( "Color = 0\n" )	
	win.EditorWindowAddText( "StageXYZ = "+Sx+" "+Sy+" "+Sz+"\n" )	
	win.EditorWindowAddText( "NumPts = 1\n")
	win.EditorWindowAddText( "Draw = 0\n")
	win.EditorWindowAddText( "Regis = 1\n")
	win.EditorWindowAddText( "Type = 0\n")
	win.EditorWindowAddText( "Note = "+idname+"\n")
	win.EditorWindowAddText( "SamePosId ="+imnum+"\n")
	win.EditorWindowAddText( "RawStageXY = "+Sx+" "+Sy+"\n" )
	win.EditorWindowAddText( "MapID = "+imnum+"\n")
	win.EditorWindowAddText( "PtsX = "+Sx+"\n")
	win.EditorWindowAddText( "PtsY = "+Sy+"\n\n")

}


for ( number i = 0; i < nDoc; i++ ){
			imageDocument doc = GetImageDocument( i, wsID )
			PerformWorkspaceAction( doc, win, i )
}

