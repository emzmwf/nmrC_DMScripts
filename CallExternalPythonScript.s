//Directory for external python scripts
string ExDir = "//nmrc-nas.nottingham.ac.uk/data/Data Processing Area/Scripts/DM scripts"

// Call external python script (does not run within GMS)
String CSA = "python "
String CSB = "/GMSExternalPy.py"
String callString = CSA+ExDir+CSB

Result("\n going to launch this script: \n")
Result(callString)

LaunchExternalProcessAsync( callString )