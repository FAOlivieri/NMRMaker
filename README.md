# NMRMaker
VMD plugin to create AMBER restraint files

# Installation

To install, add the "nmrmaker.tcl" file inside /usr/local/lib/vmd/plugins/noarch/tcl/

and then add the following line to the .vmdrc file

>vmd_install_extension nmrmaker ::restraintmaker::mkwindow NMRMaker.


# Usage

With the RMNMaker window open, use the bond, angle or dihedral tools in VMD to create labels. Every time a bond, angle or dihedral label is created, a new restraint is added to the restraints file.

If the "use pdb values" option is selected, all 4 restraint values will be exactly the value in the pdb file

If the "use custom values" option is selected, the restraint values will be thos specified on the text fields on the left of the RMNMaker window

After creating all restraints, copy the information on the right of the RMNMaker window to your restraints file

DO NOTS:

- Do not use the atom label tool with the RMNMaker window open, as it interferes with normal operation of the plugin
- Do not create any atom, bond, angle or dihedral labels before opening the RMNMaker window

