#----------------------------------------------------------------------------------------------------------------------
#
#  kamaji.00.common_functions.bash
#
#  Copyright 2019 Brian G. Holmes
#
#	This program is part of the Holmespun Makefile Method.
#
#	The Holmespun Makefile Method is free software: you can redistribute it and/or modify it under the terms of the
#	GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#
#	The Holmespun Makefile Method is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
#	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
#	Public License for more details.
#
#	You should have received a copy of the GNU General Public License along with this program.  If not, see
#	<https://www.gnu.org/licenses/>.
#
#  See the COPYING.text file for further information.
#
#  20190818 BGH; created.
#
#----------------------------------------------------------------------------------------------------------------------

set -u

source $(whereHolmespunLibraryBashing)/Library/spit_spite_spitn_and_spew.bash

#----------------------------------------------------------------------------------------------------------------------

function create_exercise_compilable_alpha() {
  #
  local ScriptFSpec=${1}
  #
  spit ${ScriptFSpec} "//"
  spit ${ScriptFSpec} "//  ${ScriptFSpec} created by ${FUNCNAME}."
  spit ${ScriptFSpec} "//"
  spit ${ScriptFSpec} "//  This is a unit test exercise program that represents a series of test cases."
  spit ${ScriptFSpec} "//"
  spit ${ScriptFSpec} ""
  spit ${ScriptFSpec} "# include <iostream> 	//  std::cout"
  spit ${ScriptFSpec} ""
  spit ${ScriptFSpec} "int main() {"
  spit ${ScriptFSpec} ""
  spit ${ScriptFSpec} "    std::cout << \"TC1: I dunno. Fry?\" << std::endl;"
  spit ${ScriptFSpec} "    std::cout << \"TC2: Now I gotta whatchacallit instead of a kajigger,"	\
		      "you stupid whatchacallit!\" << std::endl;"
  spit ${ScriptFSpec} ""
  spit ${ScriptFSpec} "    return( 0 );"
  spit ${ScriptFSpec} ""
  spit ${ScriptFSpec} "}"
  spit ${ScriptFSpec} ""
  spit ${ScriptFSpec} "//"
  #
  chmod 755 ${ScriptFSpec}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function create_exercise_script_alpha() {
  #
  local ScriptFSpec=${1}
  #
  spit ${ScriptFSpec} "#!/bin/bash"
  spit ${ScriptFSpec} "#"
  spit ${ScriptFSpec} "#  ${ScriptFSpec} created by ${FUNCNAME}."
  spit ${ScriptFSpec} "#"
  spit ${ScriptFSpec} "#  This is a unit test exercise script that represents a series of test cases."
  spit ${ScriptFSpec} "#"
  spit ${ScriptFSpec} "echo \"TC1: Good news, everyone!\""
  spit ${ScriptFSpec} "echo \"TC2: I miss Morbo.\""
  spit ${ScriptFSpec} "#"
  #
  chmod 755 ${ScriptFSpec}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function create_production_script_alpha() {
  #
  local ScriptFSpec=${1}
  #
  spit ${ScriptFSpec} "#!/bin/bash"
  spit ${ScriptFSpec} "#"
  spit ${ScriptFSpec} "#  ${ScriptFSpec} created by ${FUNCNAME}."
  spit ${ScriptFSpec} "#"
  spit ${ScriptFSpec} "#  This is a production script to be tested using a CLUT."
  spit ${ScriptFSpec} "#"
  spit ${ScriptFSpec} "echo \"I am the greetest! Now I am leaving Earth for no raisin!\""
  spit ${ScriptFSpec} "#"
  #
  chmod 755 ${ScriptFSpec}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function create_production_script_alpha_clut() {
  #
  local ClutFSpec=${1}
  #
  spit ${ClutFSpec} "#!/bin/bash"
  spit ${ClutFSpec} "#"
  spit ${ClutFSpec} "#  ${ClutFSpec} created by ${FUNCNAME}."
  spit ${ClutFSpec} "#"
  spit ${ClutFSpec} "function testCollection() {"
  spit ${ClutFSpec} "  #"
  spit ${ClutFSpec} "  clut_case_name		NoArguments"
  spit ${ClutFSpec} "  clut_case_comment	\"This is the most trivial test case.\""
  spit ${ClutFSpec} "  clut_case_end"
  spit ${ClutFSpec} "  #"
  spit ${ClutFSpec} "}"
  spit ${ClutFSpec} "#"
  spit ${ClutFSpec} "clut_definition_set	testCollection"
  spit ${ClutFSpec} "#"
  #
}

#----------------------------------------------------------------------------------------------------------------------

function dump_an_elf_file() {
  #
  echo "This is an Executable and Linkable Format (ELF) file; a textual dump would contain non-deterministic data."
  #
}

#----------------------------------------------------------------------------------------------------------------------
