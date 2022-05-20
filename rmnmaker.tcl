#!/usr/bin/wish
# 
#
#  
# 
#
# author: Federico Olivieri
# last modified: May 2018
# website: www.sbg.qb.fcen.uba.ar
# mail: federicoaolivieri@gmail.com
########################################################################
#To install
#vmd_install_extension textview textview_tk "Data/Text Viewer"

namespace eval ::restraintmaker:: {
	namespace export mkwindow
	global w use
	variable version 1.0

}

package provide rmnmaker 1.0 

	proc ::restraintmaker::mkwindow {} {
		global vmd_pick_atom vmd_pick_value
		global w use
		if { [winfo exists .textview] } {
			wm deiconify $w
			return
		}
		set w [toplevel ".restraintmaker"]
		wm title $w "Restraint maker"
		wm resizable $w 0 0
	
		#INTERFACE
		
		menu $w.m
		$w.m add command -command ::restraintmaker::showabout -label "about"
		$w configure -menu $w.m
                $w.m add command -command ::restraintmaker::showhelp -label "help"
		

		label $w.lblats -text "Atoms"
		label $w.lblr1 -text "R1"
		label $w.lblr2 -text "R2"
		label $w.lblr3 -text "R3"
		label $w.lblr4 -text "R4"
		label $w.lblk -text "Const"
		label $w.lblcomment -text "Comment"
	
		grid $w.lblats -column 0 -row 1
		grid $w.lblr1  -column 0 -row 2
		grid $w.lblr2  -column 0 -row 3
		grid $w.lblr3  -column 0 -row 4
		grid $w.lblr4  -column 0 -row 5
		grid $w.lblk   -column 0 -row 6
		grid $w.lblcomment   -column 0 -row 7
	
		entry $w.txtats -textvar ats
		entry $w.txtr1  -textvar r1
		entry $w.txtr2 -textvar r2
		entry $w.txtr3 -textvar r3
		entry $w.txtr4 -textvar r4
		entry $w.txtk -textvar k
		entry $w.txtcomment -textvar comment

		
		$w.txtk insert 0 "20"
	
		grid $w.txtats -column 1 -row 1
		grid $w.txtr1  -column 1 -row 2
		grid $w.txtr2  -column 1 -row 3
		grid $w.txtr3  -column 1 -row 4
		grid $w.txtr4  -column 1 -row 5
		grid $w.txtk   -column 1 -row 6
		grid $w.txtcomment   -column 1 -row 7
	
		button $w.add -text "Add restraint" -command ::restraintmaker::add_rst
		button $w.clr -text "Clear entry" -command restraintmaker::cleartxts
		#button .del -text "Delete last restraint" -command del_rst
		#button .copy -text "Copy output to paperclip" -command copy
	
		grid $w.add -column 0 -row 8
		grid $w.clr -column 1 -row 8
		#grid .del -column 1 -row 7
		#grid .copy -column 2 -row 7
	
		text $w.output
	
		grid $w.output -column 2 -row 1 -rowspan 7

		radiobutton $w.use -text "Use pdb values" -variable use -value 1  -command ::restraintmaker::useValues
		radiobutton $w.notuse -text "Use custom values " -variable use -value 0 -command ::restraintmaker::notuseValues

		grid $w.use -row 9 -column 0
		grid $w.notuse -row 9 -column 1
		
		$w.use select
	
		trace variable vmd_pick_atom w ::restraintmaker::get_atom
		trace variable vmd_pick_value w ::restraintmaker::get_label
		puts "Listening for labels"
	}

#Procedures
	proc ::restraintmaker::add_rst {} {
		global w
		set atomos	[$w.txtats get]
		set indexats [split [string range $atomos 0 end-1] ,]
		set serialtext ""
		foreach item $indexats {
				set serial $item
				incr serial
				set serialtext "$serialtext $serial , "
		}
		set fulltext "iat=$serialtext r1=[$w.txtr1 get], r2=[$w.txtr2 get] , r3=[$w.txtr3 get], r4=[$w.txtr4 get], rk2=[$w.txtk get] , rk3=[$w.txtk get], \n"
		set cmnt [$w.txtcomment get]
		$w.output insert end "# $cmnt \n"
		$w.output insert end "&rst\n"
		$w.output insert end $fulltext
		$w.output insert end "&end\n"
	}

	proc ::restraintmaker::del_rst {} {
		set outputtext [$w.output get 0.0 end]
	
		set outputlist [split $outputtext "\n"]
		$w.output delete 0.0 end
		#tk_messageBox -message $outputlist
	
		for {set i 0} {$i < [llength $outputlist]-5} {incr i} {
			$w.output insert end "[lindex $outputlist $i] \n" 
		}
	}

	proc ::restraintmaker::cleartxts {} {
		global w use
		$w.txtats delete 0 end
		$w.txtcomment delete 0 end

		if {$use == 1} {
			$w.txtr1 delete 0 end
			$w.txtr2 delete 0 end
			$w.txtr3 delete 0 end
			$w.txtr4 delete 0 end
		}
	}
	#Connection to VMD

	proc ::restraintmaker::get_atom {args} {
		puts "picked atom"
		global w
		global vmd_pick_atom vmd_pick_mol
		puts $vmd_pick_atom
		#set atoms [$w.txtats get]
		#$w.txtats delete 0 end
		$w.txtats insert end "$vmd_pick_atom,"
	
		set sel [atomselect $vmd_pick_mol "same residue as index $vmd_pick_atom"]
		set atom [atomselect $vmd_pick_mol "index $vmd_pick_atom"]
		lassign [$atom get {resname resid}] resname resid
		set atomname [$atom get name]
		$w.txtcomment insert end "$resname $resid $atomname-"
	}

	proc ::restraintmaker::get_label {args} {
		puts "picked label"
		global w use
		global vmd_pick_value
		puts $vmd_pick_value
		set a [expr {$vmd_pick_value * 100}]
		puts $a
		set b [expr {floor($a)}]
		puts $b
		set rounded [expr {$b/100}]
		puts $rounded
		
		if {$use == 1} {
			$w.txtr1 delete 0 end
			$w.txtr2 delete 0 end
			$w.txtr3 delete 0 end
			$w.txtr4 delete 0 end
			
			$w.txtr1 insert 0 $rounded
			$w.txtr2 insert 0 $rounded
			$w.txtr3 insert 0 $rounded
			$w.txtr4 insert 0 $rounded
		}

		::restraintmaker::add_rst
		::restraintmaker::cleartxts
		
	}	

	proc ::restraintmaker::useValues {} {
		global w use
		set use 1
	}

	proc ::restraintmaker::notuseValues {} {
                global w use
		set use 0
	}

	proc ::restraintmaker::showabout {} {
		tk_messageBox -message "Made by Federico Olivieri \n federicoaolivieri@gmail.com"
	}

        proc ::restraintmaker::showhelp {} {
                tk_messageBox -message "Create a bond, angle or dihedral with the plugin window open to create a restraint. \n\n You can choose to use the value of the created label or to use your own custom value."
        }



