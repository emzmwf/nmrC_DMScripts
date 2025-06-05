# Find the location of ColorTables used for Gatan Microscopy Suite

import os
path = os.getenv('LOCALAPPDATA')
CTpath = path+"\Gatan\ColorTables"
print(CTpath)
