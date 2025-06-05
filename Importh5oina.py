# 0.1.1 2025 06 03 - Imports maps and electron image into GMS
# 0.1.2 2025 06 05 - add calibrations to images and maps


import h5py
import math

#Note the slash direction for network drive, will only work this way!
#example
#file_name = '//nmrc-nas.nottingham.ac.uk/data/Instrument Data/FEGTEM/MW Fay/2024/20240717 Salvatore Lagana/B2 272192 J8_A741 EDS/h5oina/B2 272192 B2 272192 Site 2 Map Data 2.h5oina'

#DM import file
dmScript = 'string path = GetApplicationDirectory( "open_save" , 0 )' + '\n'
dmScript += 'if ( !OpenDialog( NULL, "Select h5oina file to open" , path , path ) ) exit( 0 )' + '\n'
dmScript += 'TagGroup tg = GetPersistentTagGroup( ) ' + '\n'
dmScript += 'tg.TagGroupSetTagAsString( "DM2Python String", path )' + '\n'
# Execute DM script
DM.ExecuteScriptString( dmScript )

#Get the selection data into python
TGp = DM.GetPersistentTagGroup()
returnval, file_name = TGp.GetTagAsText('DM2Python String')

f = h5py.File(file_name, "r")

f.visit(print) 

#id = listener.WorkspaceHandleWorkspaceCreated('EDX Map') 

# DM create workspace for display
dmWScript = 'number wsID_src = WorkSpaceGetActive()' + '\n'
dmWScript += 'number wsID_montage = WorkSpaceAdd( WorkSpaceGetIndex(wsID_src) + 1 )' + '\n'
dmWScript += 'WorkSpaceSetActive( wsID_montage )' + '\n'
dmWScript += 'WorkspaceSetName( wsID_montage , "EDX Map" )' + '\n'
# Execute DM script
DM.ExecuteScriptString( dmWScript )


def ShowEImage():
    #This checks to see if the Electron Image / Data / SE dataset exists in the first site
    #set variable echeck to 0 until we find the dataset
    echeck = 0

    if "1/Electron Image/Data/SE/" in f:
        print("The EDS electron image dataset is in the file")
        echeck = 1
        
    if (echeck == 1):
        print ("OK!")

    if (echeck == 0):
        print("No electron image in site 1")
        f.close()
        raise    
        
    print(f['1/Electron Image/Data/SE'])

    ImageName = (list(f['1/Electron Image/Data/SE'].keys())[0])
    ImageName

    #EImage = f['1/Electron Image/Data/SE/Electron Image 2 (Input 1)']
    EImage = f['1/Electron Image/Data/SE/'+ImageName]

    print(EImage)

    arr_1 = EImage[()] 
   
    SX = (f['1/Electron Image/Header/X Cells'][0])
    SY = (f['1/Electron Image/Header/Y Cells'][0])

    IBB = (f['1/Electron Image/Header/Bounding Box Size'])
    print(IBB[0])
    print(IBB[1])

    arr_2d = arr_1.reshape(SX, SX)
    print( 'Shape of Numpy array:',arr_2d.shape )
    
    # Pixel size of the electron image in microns
    print("\n x step ")
    EIpx = (f['1/Electron Image/Header/X Step'][0])   

    img = DM.CreateImage(arr_2d.copy())
    img.SetName(ImageName)
    img.ShowImage()

    img.SetDimensionCalibration(0, 0, EIpx*1000, 'nm', 0)     
    img.SetDimensionCalibration(1, 0, EIpx*1000, 'nm', 0)  
    img_disp = img.GetImageDisplay(0)
    img_disp.AddNewComponent(31, SX*0.8, SX*0.1, SX*0.9, SX*0.9 )# scale bar from top, left, 
    #Get the image tags
    imgTG = img.GetTagGroup()
    #print(f['1/Electron Image/Header/Analysis Label'][0].decode('ASCII'))
    #print(f['1/Electron Image/Header/Analysis Unique Identifier'][0].decode('ASCII'))
    #print(f['1/Electron Image/Header/Dwell Time'][0])
    #print(f['1/Electron Image/Header/Project File'][0].decode('ASCII'))
    #print(f['1/Electron Image/Header/Site Label'][0].decode('ASCII'))
    #print(f['1/Electron Image/Header/Stage Position/X'][0])
    #print(f['1/Electron Image/Header/Stage Position/X'][0])
    imgTG.SetTagAsString( 'Analysis Label',str(f['1/Electron Image/Header/Analysis Label'][0].decode('ASCII') ))
    imgTG.SetTagAsString( 'Project File',str(f['1/Electron Image/Header/Project File'][0].decode('ASCII') ))
    imgTG.SetTagAsString( 'Specimen Label',str(f['1/Electron Image/Header/Specimen Label'][0].decode('ASCII') ))
    imgTG.SetTagAsString( 'Site Label',str(f['1/Electron Image/Header/Site Label'][0].decode('ASCII') ))
    imgTG.SetTagAsString( 'Dwell Time', str(f['1/Electron Image/Header/Dwell Time'][0]))
    #imgTG.SetTagAsFloat( 'Stage Position X',  float((f['1/Electron Image/Header/Stage Position/X'][0])))
    #imgTG.SetTagAsFloat( 'Stage Position Y',  float((f['1/Electron Image/Header/Stage Position/Y'][0])))
    

ShowEImage()
###
#now for the maps
#So how many maps in total then
try:
    print(f['1/EDS/Data/Window Integral/'])
except:
    DM.OkDialog( 'No maps found' ) 

mapnames = (f['1/EDS/Data/Window Integral/'].keys())
print(mapnames)

# Get EDS pixel size in nm
EDSpx = (f['1/EDS/Header/X Step'][0])*1000

bVal = 0
bVal = DM.OkCancelDialog( 'OK to colour, cancel for greyscale' )

import os
def MapVerify(name):
    path = os.getenv('LOCALAPPDATA')
    CTpath = path+"\Gatan\ColorTables"
    CTname = (CTpath+"\\"+name+".dm3")
    print(CTname)
    if (os.path.isfile(CTname)):
        VerifiedMaps.append(name)
#

if bVal == True:
    nmRC_ColMaps = ["red", "errata", "celery","peach", "eggshell", "canary", "lilac", "seagreen", "teal", "banana"]
#If we want to color the maps in display, need a list of suitable colormaps by name to use
#Would need to have a list of named suitable colormaps, check if they exist, and put them in a list to use if they do
#For a GMS installation on a camera system, the color tables are saved in 
# C:\Users\VALUEDGATANCUSTOMER\AppData\Local\Gatan\ColorTables
# Get current AppData\Local with 
#import os
#path = os.getenv('LOCALAPPDATA')
#CTpath = path+"\Gatan\ColorTables"
# so now check for each filename in the list
# os.path.isfile(CTpath+"\lilac.dm3"))

    VerifiedMaps = []
    for name in nmRC_ColMaps:
        MapVerify(name)
#

#or have on the fly get, modify, display colortable in a suitable visibility range



#So from the keys, we can parse over the maps
#Set up a def to do this
def parse_map(name, i):
    print(name)
    Map = (f['1/EDS/Data/Window Integral/'+name]) 
    SZ = Map.shape[0]
    SY = (f['1/EDS/Header/X Cells'][0])
    SX = (f['1/EDS/Header/Y Cells'][0])
    arr = Map[()] 
    arr_2d = arr.reshape(SX, SY)
    img = DM.CreateImage(arr_2d.copy())
    img.SetName(name)
    img.ShowImage()
    img.SetDimensionCalibration(0, 0, EDSpx, 'nm', 0)     
    img.SetDimensionCalibration(1, 0, EDSpx, 'nm', 0)  
    #Size the maps so they will display better on a typical GMS window if they are 256 or less
    if SX <=256:
        ImageDocGetOrCreate = img.GetOrCreateImageDocument()  
        WindowB = ImageDocGetOrCreate.GetWindow()
        x, y = WindowB.GetFrameSize()  
        WindowB.SetFrameSize(x*2, y*2) 
    if bVal == True:
        imageDisplay = img.GetImageDisplay(0)
        if (i<= len(VerifiedMaps)):
            colmap = VerifiedMaps[i]
        else:
            i=0
        if (len(VerifiedMaps)==0):
            colmap = "Greyscale"
        imageDisplay.SetColorTableByName(colmap) 
        i = i+1
    
#Then lets see all of them, plus a resized version in case they're noisy

i = 0
for name in f['1/EDS/Data/Window Integral/'].keys():
    parse_map(name, i)
    i = i+1


# Now tidy up the current workspace - am assuming we've been swapped to the EDX map workspace by here
dmWS_Arr_script = 'WorkspaceArrange( 1, 1 )' + '\n'
# Execute DM script
DM.ExecuteScriptString( dmWS_Arr_script )


# 1/Layered Image/EDS Layered Image 3/Data/Color
# coloured image, GMS python not yet handling colour images? 
# so would have to create as R G and B and then DMscript to combine
#CImage = f['1/Layered Image/EDS Layered Image 3/Data/Color']
#arr_C = CImage[()] 

#print("\n bounding box size ")
#print(f['1/EDS/Header/Bounding Box Size'])
#print(f['1/EDS/Header/Bounding Box Size'][0])
#print(f['1/EDS/Header/Bounding Box Size'][1])

#print("\n \n electron image bounding box size ")
#print(f['1/Electron Image/Header/Bounding Box Size'][0])
#print(f['1/Electron Image/Header/Bounding Box Size'][1])

#print(f['1/Electron Image/Header/Analysis Label'][0].decode('ASCII'))
#print(f['1/Electron Image/Header/Analysis Unique Identifier'][0].decode('ASCII'))
#print(f['1/Electron Image/Header/Dwell Time'][0])
#print(f['1/Electron Image/Header/Project File'][0].decode('ASCII'))
#print(f['1/Electron Image/Header/Site Label'][0].decode('ASCII'))
#print(f['1/Electron Image/Header/Stage Position/X'][0])
#print(f['1/Electron Image/Header/Stage Position/Y'][0])
