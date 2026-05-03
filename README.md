# **dh_Toolkit**

dh_Toolkit started as a couple of utility scripts I developed for the Reaper DAW. They were built using [Lokasenna-GUI v2](https://github.com/jalovatt/Lokasenna_GUI). I decided to make some enhancements to the Lokasenna GUI by adding app scaling and theming. I accomplished this by designing dh_Toolkit to be used in conjunction with Lokasenna GUI without altering the Lokasenna GUI. I also added some modified Lokasenna widget classes (stored in dhToolkit/classes directory). Most of the modifications are changed some property names and default colors, although some functionality is changed in some classes.

For greater details see the [project documentation](https://denhorn52.github.io/dh_Toolkit/)

## **Main Scripts:** (in /scripts directory)

**dh_ArrangeViews.lua:** To quickly navigate to areas of the arrange view window, or to regions. Views are saved per project to project ext state. When changing project tabs the script updates with the new tab's project saved views.

**dh_Snapshots.lua:** Save and restore snapshots of the Mixer Control Panel including visible tracks, solo, pan, mute, volume, etc. Snapshots are saved per project to project ext state. When changing project tabs the script updates with the new tab's project saved snapshots.

## **Auxillary scripts:** (in /scripts directory)

**dh_ThemeDesigner.lua:** Use to design user themes for your scripts. Themes can be used with any scripts that utilize both Lokasenna GUI and dh_Toolkit.

**dh_Template.lua:** A highly commented basic script to be used as a starting point for your scripts. It uses a single (user defined) window size; as used in dh_Snapshots.

**dh_Template-mult.lua:** Same as previous but allows for multiple window heights (minimized, expanded, and Preferences); as used in dh_ArrangeViews. 

## **dh_Toolkit scripts:** (in /common directory)

**dh_Toolkit_core.lua:** A module containing the code that provides app scaling, theming, and saving and loading of window settings and preferences. It provides a "Preferences" window for choosing your options.

**dh_Toolkit_themes.lua:** A module providing several predefined themes and font sets used for scaling app. It also defines additional GUI colors and font sizes.

**dh_Toolkit_shared.lua:** A module providing functions used by dh_Toolkit and some which may be useful for your scripts.

## **Custom or modified Lokasenna classes:** (in /classes directory)

Most dh_Toolkit classes have minimal differences from the Lokasenna classes; mainly some changed property names and default colors. Some classes enhance functionality, such as ability to change slider thickness.

## **Installation:**

The dh_Toolkit_v1 directory (and all its files and subdirectories) can be placed anywhere under the Reaper/Scripts directory. The dh_Toolkit_v1/library directory contains the file "Set dh_Toolkit v1 library path.lua". In Reaper "Action list" browse for and run that file. That will save the dh_Toolkit library path in Reaper Ext State. dh_Toolkit scripts there to load its core files. This way user scripts can be placed anywhere. Of course, Lokasenna GUI v2 must also be installed (using its installation method). 

