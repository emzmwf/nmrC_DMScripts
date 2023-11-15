void FocusToTag(){
// Based on example code by DRG Mitchell
 
// version:20231114
// version 0.1: 20231115

// Based on StageToTag script
// Adds raw focus and brightness metadata to front image
// based on current microscope values

// Create a new taggroup which will hold all the information
taggroup lenstags=newtaggroup()
string packagename="FocusToTag"
 
image front:=getfrontimage()
component imgdisp=imagegetimagedisplay(front, 0)
number i

//Check we are on a real microscope - voltage won't be zero
TagGroup tgm = GetPersistentTagGroup( ) 
number voltage
TagGroup infoTGm
tgm.TagGroupGetTagAsTagGroup( "Microscope Info", infoTGm )
infoTGm.TagGroupGetTagAsNumber( "Voltage", voltage )

number startFocus, Bval

startFocus = EMGetFocus( )
Bval = EMGetBrightness()
result("\ngetting values from microscope\n")
//Result("\n Raw focus is "+startFocus+"\n")

number index

TagGroup imgTags = front.ImageGetTagGroup()

//imgTags.TagGroupSetTagAsString( "My Tags:Sub-branch:SubSub-Branch:My String", str )
imgTags.TagGroupSetTagAsNumber( "LensVal:Focus raw", startFocus )
imgTags.TagGroupSetTagAsNumber( "LensVal:Brightness", Bval )

//Check for microscope info stage tag
taggroup etags=front.ImageGetTagGroup()

string Tstring = "Microscope Info:Stage Position:Focus raw"
number Create = TagGroupDoesTagExist(etags, Tstring)
//result("Create is:")
//result(Create)
//Create is 1 if it exists, 0 if it doesnt
if (Create == 0){
	//adding to existing tag group
	string Ts6 = "Microscope Info:Stage Position:Focus raw"
	string Ts7 = "Microscope Info:Stage Position:Brightness"
	
	etags.TagGroupSetTagAsNumber( Ts6, startFocus )
	etags.TagGroupSetTagAsNumber( Ts7, Bval )
	result("\n Added Focus and Brightness Tags")
}
else{
	result("\n Focus and Brightness tags already exist for this image")	
	TagGroup DLG, DLGItems
	DLG = DLGCreateDialog( "Tags already exist", DLGItems )
	TagGroup opt1tg = DLGCreateCheckBox( "Overwrite?", 0)

	//However you add text to a dialog, do it here
	DLGitems.DLGAddElement( DLGCreateLabel( "Confirm you wish to overwrite tags" ) )   

	//Radio select box
	DLGitems.DLGAddElement( opt1tg )
	if ( !Alloc( UIframe ).Init( DLG ).Pose() )
	Throw( "User abort." )
	Result( "User confirmation: " + opt1tg.DLGGetValue() + "\n" )
	}

}

// Dialog	
    class myDlg:UIframe{
          void OnButtonDoA(object self) {
			FocusToTag() 
			result("\n Option selected"); 
			}
          myDlg(object self)
          {
               taggroup dlg = DLGCreateDialog("My Dialog")
               dlg.DLGAddElement(DLGCreateLabel("Run Script"))
               dlg.DLGAddElement(DLGCreatePushButton("Add Focus to Tags", "OnButtonDoA"))
               self.Init( dlg )
          }
    }
    
    Alloc(myDlg).display("Imaging Condition")
