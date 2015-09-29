# eda
Exploratory Wiki sidebar (aka infobox) data analysis. See: http://en.memory-alpha.wikia.com/wiki/Forum:Exploratory_Data_Analysis

The initial versions of these scripts (in R) were created by a user named DataScientist (orignally residing on IP 58.178.109.242).

There are two scripts (which are intended to be run in numerical order). The initial draft was to capture data from four Memory Alpha sidebars in terms of what kind of data was contained in "species", "planets", "individuals", and "starships".

There are two scripts herein:
  10-check-tag-variables.R
  20-extract-sidebars.R
  
These scripts require two R packages, "stringi" and "XML", to be run.

Current issues:
* The regular expression looks for "{{sidebar" up to "\n}}". If the link end is only "}}" then it would get either until the whole end of the text, or cut short by some links inside the sidebar itself. The consequence is that sidebar templates that do NOT use the indicated formatting and do NOT end with a closing line with the "}}", will be missed.
* Currently wipes out all formatting/etc inside each variable when recording it (partly due to the difficulty of parsing mediawiki templates/etc.
