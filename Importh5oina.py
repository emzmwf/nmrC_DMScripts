
# 0.1.1 2025 06 03 - Imports maps and electron image into GMS
# 0.1.2 2025 06 05 - add calibrations to images and maps
# 0.1.3 2025 06 05 - add colour display option
# 0.1.4 2025 07 08 - Check for image called SE or BSE, add catches for error, rename workspace based on site name
# 0.1.5 2025 07 17 - add layered image display as RGB image
# 0.1.6 2025 07 28 - add on the fly generation of a CLUT if we have run out of the defined list
# 0.1.7 2025 08 06 - search for layered image update from 1 to 16 rather than hope its in 1

import numpy as np

def GMSHybridCLUT(img, hue):
    import colorsys
    img_disp = img.GetImageDisplay(0)
    inputColorTable = img_disp.GetInputColorTable()
    
    #Modify CLUT
    # DM Python does not support RGB image creation yet
    # So would need hybrid script
    #Get size of img
    #Set up three arrays of same size
    
    dimx = inputColorTable.GetDimensionSize(0) 
    dimy = inputColorTable.GetDimensionSize(1) 
    
    dsize = dimx*dimy
    
    matrix = np.arange(dsize).reshape(dimx, -1)
    
    rgb = colorsys.hsv_to_rgb(hue, 1, 1)
    
    arr_r = np.round(rgb[0]*matrix.copy())
    arr_g = np.round(rgb[1]*matrix.copy())
    arr_b = np.round(rgb[2]*matrix.copy())
    
    r_ = DM.CreateImage(arr_r.copy())
    g_ = DM.CreateImage(arr_g.copy())
    b_ = DM.CreateImage(arr_b.copy())
    
    dms = 'rgb(' + r_.GetLabel() + ',' + g_.GetLabel() + ',' + b_.GetLabel() + ').ShowImage()'
    DM.ExecuteScriptString(dms)
    imgCLUT = DM.GetFrontImage()
        
    img_disp.SetInputColorTable(imgCLUT)
    #Get image document of imgCLUT
    docCLUT = imgCLUT.GetOrCreateImageDocument()
    docCLUT.Hide()
    del imgCLUT
    print("Hue is "+str(hue))  


def ShowEImage(f):
    #This checks to see if the Electron Image / Data / SE dataset exists in the first site
    #set variable echeck to 0 until we find the dataset
    echeck = 0

    if "1/Electron Image/Data/SE/" in f:
        print("The EDS electron image dataset is in the file")
        echeck = 1
        
    if (echeck == 1):
        print ("OK!")

    if (echeck == 0):
        if "1/Electron Image/Data/BSE/" in f:
            echeck = 2
        else:
            print("No electron image in site 1")
        #raise    
        
    if (echeck == 1):
        print(f['1/Electron Image/Data/SE'])
        ImageName = (list(f['1/Electron Image/Data/SE'].keys())[0])
    if (echeck == 2):
        print(f['1/Electron Image/Data/BSE'])
        ImageName = (list(f['1/Electron Image/Data/BSE'].keys())[0])

    ImageName

    #EImage = f['1/Electron Image/Data/SE/Electron Image 2 (Input 1)']
    if (echeck == 1):
        EImage = f['1/Electron Image/Data/SE/'+ImageName]
    if (echeck == 2):
        EImage = f['1/Electron Image/Data/BSE/'+ImageName]
    #print(EImage)

    arr_1 = EImage[()] 
   
    SX = (f['1/Electron Image/Header/X Cells'][0])
    SY = (f['1/Electron Image/Header/Y Cells'][0])

    IBB = (f['1/Electron Image/Header/Bounding Box Size'])
    print("Electron image Bounding box size")
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
    imgTG.SetTagAsString( 'Analysis Label',str(f['1/Electron Image/Header/Analysis Label'][0].decode('ASCII') ))
    imgTG.SetTagAsString( 'Project File',str(f['1/Electron Image/Header/Project File'][0].decode('ASCII') ))
    imgTG.SetTagAsString( 'Specimen Label',str(f['1/Electron Image/Header/Specimen Label'][0].decode('ASCII') ))
    imgTG.SetTagAsString( 'Site Label',str(f['1/Electron Image/Header/Site Label'][0].decode('ASCII') ))
    imgTG.SetTagAsString( 'Dwell Time', str(f['1/Electron Image/Header/Dwell Time'][0]))
    #imgTG.SetTagAsFloat( 'Stage Position X',  float((f['1/Electron Image/Header/Stage Position/X'][0])))
    #imgTG.SetTagAsFloat( 'Stage Position Y',  float((f['1/Electron Image/Header/Stage Position/Y'][0])))
    

#So from the keys, we can parse over the maps
#Set up a def to do this
def parse_map(name, i, f, EDSpx, bVal, VerifiedMaps, nmRC_ColMaps):
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
    # May also benefit from binning the display for visibility? Add option here if so
    # if using hybrid script, and use the dm command
    # ChooseMenuItem( "Process", "Re-bin by Two")
    colmap = "Greyscale"
    if bVal == True:
        imageDisplay = img.GetImageDisplay(0)
        if (i< len(VerifiedMaps)):
            colmap = VerifiedMaps[i]
            imageDisplay.SetColorTableByName(colmap) 
        else:
            #i=0
            hue = 1/i
            GMSHybridCLUT(img, hue)
        if (len(VerifiedMaps)==0):
            #colmap = "Greyscale"
            #imageDisplay.SetColorTableByName(colmap) 
            hue = 1-(1/(i+0.01))
            GMSHybridCLUT(img, hue)

        i = i+1
    


def ShowMaps(f):
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
        nmRC_ColMaps = ["errata", "celery","peach", "eggshell", "canary", "lilac", "seagreen", "teal", "banana"]
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

    #Otherwise using on the fly modification with GMSHybridCLUT
    

    i = 0
    for name in f['1/EDS/Data/Window Integral/'].keys():
        parse_map(name, i, f, EDSpx, bVal, VerifiedMaps, nmRC_ColMaps)
        i = i+1

# Layered Image
def ShowLayered(f):
    #1/Layered Image/EDS Layered Image 1/Data/Color
    #3 column matrix R G B
    lcheck = 0
    lno = 1
    x = range(16)
    for i in x:
        if "1/Layered Image/EDS Layered Image "+str(i)+"/Data/Color" in f:
            lno = i
            print("Layered EDS image found in "+str(i))
            lcheck = 1

    if lcheck == 1:
        print('showing layered image')
        LImage = f['1/Layered Image/EDS Layered Image '+str(lno)+'/Data/Color']
        SX = (f['1/Layered Image/EDS Layered Image '+str(lno)+'/Header/X Cells'][0])
        SY = (f['1/Layered Image/EDS Layered Image '+str(lno)+'/Header/Y Cells'][0])
        EDSpx = (f['1/Layered Image/EDS Layered Image '+str(lno)+'/Header/X Step'][0])*1000
        arr_1 = LImage[()]
        #Get and shape array for each colour
        arr_r = arr_1[:,0].reshape(SX, SX)
        arr_g = arr_1[:,1].reshape(SX, SX)
        arr_b = arr_1[:,2].reshape(SX, SX)
        
        # Create DM images for each color
        r_ = DM.CreateImage(arr_r.copy())
        g_ = DM.CreateImage(arr_g.copy())
        b_ = DM.CreateImage(arr_b.copy())
        # Build one-liner DM-script to show RGB image 
        dms = 'rgb(' + r_.GetLabel() + ',' + g_.GetLabel() + ',' + b_.GetLabel() + ').ShowImage()'
        DM.ExecuteScriptString(dms)
        #Retitle layered image
        imageL = DM.GetFrontImage()
        imageL.SetName('Layered image') 
        # Apply calibration
        imageL.SetDimensionCalibration(0, 0, EDSpx, 'nm', 0)     
        imageL.SetDimensionCalibration(1, 0, EDSpx, 'nm', 0)
        
    else:
        print("Layered image not found in expected place")

# Script main body

def ProcessH5oina():
    import h5py
    import math

    #Note the slash direction for network drive, will only work this way!
    #example
    #file_name = '//nmrc-nas.nottingham.ac.uk/data/Instrument Data/FEGTEM/MW Fay/2024/Site 2 Map Data 2.h5oina'

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
    
    SiteName = (str(f['1/Electron Image/Header/Site Label'][0].decode('ASCII')))

    #id = listener.WorkspaceHandleWorkspaceCreated('EDX Map') 

    # DM create workspace for display
    dmWScript = 'number wsID_src = WorkSpaceGetActive()' + '\n'
    dmWScript += 'number wsID_montage = WorkSpaceAdd( WorkSpaceGetIndex(wsID_src) + 1 )' + '\n'
    dmWScript += 'WorkSpaceSetActive( wsID_montage )' + '\n'
    #dmWScript += 'WorkspaceSetName( wsID_montage , "EDX Map" )' + '\n'
    dmWScript += 'WorkspaceSetName( wsID_montage , "' + SiteName+'" )' + '\n'
    # Execute DM script
    DM.ExecuteScriptString( dmWScript )
    


    try:
        ShowEImage(f)
    except:
        DM.OkDialog( 'No image found' ) 
    try:
        ShowMaps(f)
    except:
        DM.OkDialog( 'Maps not found' ) 
    try:
        ShowLayered(f)
    except:
        DM.OkDialog( 'Layered image not found' ) 
    # Now tidy up the current workspace - am assuming we've been swapped to the EDX map workspace by here
    dmWS_Arr_script = 'WorkspaceArrange( 1, 1 )' + '\n'
    # Execute DM script
    DM.ExecuteScriptString( dmWS_Arr_script )


ProcessH5oina()
