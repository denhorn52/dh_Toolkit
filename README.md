# **dh_Toolkit**

dh_Toolkit started as a couple of utility scripts I developed for the Reaper DAW. They were built using [Lokasenna-GUI v2](https://github.com/jalovatt/Lokasenna_GUI). I decided to make some enhancements to the Lokasenna GUI by adding app scaling and theming. I accomplished this by designing dh_Toolkit to be used in conjunction with Lokasenna GUI without altering the Lokasenna GUI. I also added some slightly modified Lokasenna widget classes (stored in dhToolkit/classes directory).

For greater details see the [project documentation](https://denhorn52.github.io/dh_Toolkit/)

## **Main Scripts:** (in /scripts directory)

**dh_ArrangeViews.lua:** To quickly navigate to areas of the arrange view window, or to regions. Views are saved per project to project ext state when closing script window or when changing tabs. Updates with current project saved views (if any) when changing project tabs.

**dh_Snapshots.lua:** Save and restore snapshots of the Mixer Control Panel including visible tracks, solo, pan, mute, volume, etc. Snapshots are saved per project to project ext state when closing script window or when changing project tabs. Updates with current project saved snapshots (if any) when changing project tabs.

## **Auxillary scripts:** (in /scripts directory)

**dh_ThemeDesigner.lua:** Use to design user themes for your scripts. Themes can be used with any scripts that utilize both Lokasenna GUI and dh_Toolkit.

**dh_Template.lua:** A highly commented basic script to be used as a starting point for your scripts. It uses a single (user defined) window size.

**dh_Template-mult.lua:** Same as previous but allows for multiple window heights (minimized, expanded, and Preferences). 

## **dh_Toolkit scripts:** (in /common directory)

**dh_Toolkit_core.lua:** A module containing the code that provides app scaling, theming, and saving and loading of window settings and preferences. It provides a "Preferences" window for choosing your options.

**dh_Toolkit_themes.lua:** A module providing several predefined themes and font sets used for scaling app. It also defines additional GUI colors and font sizes.

**dh_Toolkit_shared.lua:** A module providing functions used by dh_Toolkit and some which may be useful for your scripts.

## **Custom or modified Lokasenna classes:** (in /classes directory)

Some classes have minimal differences, some more extensive.

## **Installation:**

As of 04-17-2025 installation consists of placing the dh_Toolkit directory, files, and subdirectories into the Reaper/Scripts directory. User scripts will need to be placed in dh_Toolkit directory. Of course, Lokasenna GUI v2 must be installed using its installation method. 

04-24-2025. The dh_Toolkit directory can be placed anywhere under the Reaper/Scripts directory. The script "Set dh_Toolkit v1 library path.lua" is in the dh_Toolkit directory. In Reaper "Action list" browse for and run that file. That will save the dh_Toolkit library path in Reaper Ext State. This way user scripts can be placed anywhere.
