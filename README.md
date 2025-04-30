# **dh_Toolkit**

dh_Toolkit started as a couple of utility scripts I developed for the Reaper DAW. They were built using [Lokasenna-GUI v2] (https://github.com/jalovatt/Lokasenna_GUI). I decided to make some enhancements to the Lokasenna GUI by adding app scaling and theming. I accomplished this by designing dh_Toolkit to be used in conjunction with Lokasenna GUI without altering the Lokasenna GUI. I also added some slightly modified Lokasenna widget classes (stored in dhToolkit/classes directory).

## **Main Scripts:** (in dhToolkit or /scripts directory)

-dh_ArrangeViews.lua : To quickly navigate to areas of the arrange view window, or to regions. Views are saved per project to project ext state when closing script window or when changing tabs. Updates with current project saved views (if any) when changing project tabs.
-dh_Snapshots.lua : Save and restore snapshots of the Mixer Control Panel including visible tracks, solo, pan, mute, volume, etc. Snapshots are saved per project to project ext state when closing script window or when changing project tabs. Updates with current project saved snapshots (if any) when changing project tabs.

## **Auxillary scripts:** (in dhToolkit or / scripts directory)

-dh_ThemeDesigner.lua : Use to design user themes for your scripts. Themes can be used with any scripts that utilize both Lokasenna GUI and dh_Toolkit.
-dh_Template.lua : A highly commented basic script to be used as a starting point for your scripts. It uses a single (user defined) window size.
-dh_Template-mult.lua : Same as previous but allows for multiple window heights (minimized, expanded, and Preferences). 

## **dh_Toolkit scripts:** (in common directory)

-dh_Toolkit_core.lua : A module containing the code that provides app scaling, theming, and saving and loading of window settings and preferences. It provides a "Preferences" window for choosing your options.
-dh_Toolkit_themes.lua : A module providing several predefined themes and font sets used for scaling app. It also defines additional GUI colors and font sizes.
--dh_Toolkit_shared.lua : A module providing functions used by dh_Toolkit and some which may be useful for your scripts.

## **Custom or modified Lokasenna classes:** (in classes directory)

-dh_Frame.lua :  Provides a frame with with an optional inner rectangle. It is based on the " Button" class therefore it has mouse events.

-dh_Menubox.lua : Calling GUI.Val("menubox_name") returns the number of the selected option. Calling GUI.Val("dh_Menubox_name") returns the number AND the name of the selected option.

-dh_Options.lua : Adds the fields "opt_frame" and "opt_fill" so that they can be defined independently of Lokasenna's theming. I did it so that I can enhance contrast, hence, viewability. Also, checklist mouseup exposes the index number of the clicked option so that it can be used in mouseup override.

-dh_Slider.lua : Adds ability to change track thickness and handle size.

## **Installation:**

As of 04-17-2025 installation consists of placing the dh_Toolkit directory, files, and subdirectories into the Reaper/Scripts directory. User scripts will need to be placed in dh_Toolkit directory. Of course, Lokasenna GUI v2 must be installed using its installation method. 

04-24-2025. The dh_Toolkit directory can be placed anywhere under the Reaper/Scripts directory. The script "Set dh_Toolkit v1 library path.lua" is in the dh_Toolkit directory. In Reaper "Action list" browse for and run that file. That will save the dh_Toolkit library path in Reaper Ext State. This way user scripts can be placed anywhere.
