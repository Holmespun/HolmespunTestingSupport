#----------------------------------------------------------------------------------------------------------------------
#
#  Testing/CLUT_Framework_quickstart_guide_exercise.bash
#
#	Generate the CLUT Framework Quick-Start Guide in markdown format.
#
#----------------------------------------------------------------------------------------------------------------------
#
#  20180221 BGH; created.
#  20180222 BGH; modified to output Quick Start Guide content.
#  20191028 BGH; moved to Holmespun Testing Support repository, and modified to work using the kamaji script.
#
#----------------------------------------------------------------------------------------------------------------------
#
#  Copyright (c) 2018-2019 Brian G. Holmes
#
#	This program is part of the Holmespun Testing Support repository.
#
#	The Holmespun Testing Support repository only contains free software: you can redistribute it and/or modify it
#	under the terms of the GNU General Public License as published by the Free Software Foundation, either version
#	three (3) of the License, or (at your option) any later version.
#
#	The Holmespun Testing Support repository is distributed in the hope that it will be useful, but WITHOUT ANY
#	WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
#	General Public License for more details.
#
#	You should have received a copy of the GNU General Public License along with this file. If not, see
#       <https://www.gnu.org/licenses/>.
#
#  See the COPYING.text file for further information.
#
#----------------------------------------------------------------------------------------------------------------------

set -u

export BashLibraryDSpec=$(whereHolmespunLibraryBashing)/Library

source ${BashLibraryDSpec}/echoDatStampedFSpec.bash
source ${BashLibraryDSpec}/spit_spite_spitn_and_spew.bash

#----------------------------------------------------------------------------------------------------------------------
#
#  Text colors do not translate into markdown files, so display all messages in monochrome.
#
#----------------------------------------------------------------------------------------------------------------------

export HOLMESPUN_MONOCHROMATIC=BleakAndWet

#----------------------------------------------------------------------------------------------------------------------
#
#  Sub-make commands inherit some MAKEFLAGS.  As such, we must clear MAKEFLAGS here so that parallel use requests
#  to "make output" are the same whether or not the "--jobs" parameter was used.
#
#----------------------------------------------------------------------------------------------------------------------

MAKEFLAGS=

#----------------------------------------------------------------------------------------------------------------------

declare SedExpressionList=

SedExpressionList+=" --expression='s,^,\t,'"

#----------------------------------------------------------------------------------------------------------------------

function showFile() {
  #
  local -r TargetName=${1}
  #
  echo "	~~~~"
  #
  cat ${TargetName} 2>&1 | eval sed ${SedExpressionList}
  #
  echo "	~~~~"
}

#----------------------------------------------------------------------------------------------------------------------

function echoAndExecute() {
  #
  local TemporaryFSpec=$(mktemp --dry-run -t .temporary_XXXXXX.text)
  #
  echo "	$ ${*}"
  #
  ${*} > ${TemporaryFSpec} 2>&1
  #
  grep -v '^make\[' ${TemporaryFSpec} | eval sed ${SedExpressionList}
  #
  rm ${TemporaryFSpec}
  #
}

#======================================================================================================================

declare -r ProgramFName=printf

declare -r ProjectDSpec=$(echoDatStampedFSpec ClutQuickStart.)_$$

mkdir ${ProjectDSpec}

cd    ${ProjectDSpec}

echo "[](CLUT_Framework_quickstart_guide_exercise.bash...)"
echo "[](================================================)"
echo ""
echo "# CLUT Framework Quick-Start Guide"
echo ""
echo "This markdown file was generated automatically using the"
echo -n "[Testing/CLUT_Framework_Quickstart_Guide_exercise.bash]"
echo "(Testing/CLUT_Framework_Quickstart_Guide_exercise.bash)"
echo "unit test."
echo ""
echo "1. Clone the Holmespun Testing Support repository; it can go anywhere that is convenient to you."
echo "1. Add the fully-qualified path of the [bin](bin) directory to your PATH variable."
echo ""
echo "	If you cloned the repository into your home directory, then the"
echo "	\"export PATH=\${HOME}/Holmespun/HolmespunTestingSupport/bin:\${PATH}\" command will work for you."
echo "	The modified PATH variable allows you to store the repository anywhere you like\;"
echo "	it need not be collocated with your source code."
echo ""
echo "1. Create a project directory to play around in and a Testing subdirectory."
echo ""
echo "	~~~~bash"
echo "	$ cd"

echoAndExecute	mkdir ClutQuickStart

echoAndExecute	cd ClutQuickStart
echoAndExecute	mkdir Testing

echo "	$"
echo "	~~~~"
echo ""
echo "1. Display the kamaji general usage statement."
echo ""
echo "	~~~~"

echoAndExecute 	kamaji usage

echo "	$"
echo "	~~~~"
echo ""
echo "1. Request help on the kamaji grade command."
echo ""
echo "	~~~~"

echoAndExecute	kamaji help grade

echo "	$"
echo "	~~~~"
echo ""
echo "1. Create a simple Testing/printf.clut script that contains a single basic test case:"
echo ""

spit Testing/${ProgramFName}.clut "#"
spit Testing/${ProgramFName}.clut "#  Testing/${ProgramFName}.clut (version 1)"
spit Testing/${ProgramFName}.clut "#"
spit Testing/${ProgramFName}.clut ""
spit Testing/${ProgramFName}.clut "set -u"
spit Testing/${ProgramFName}.clut ""
spit Testing/${ProgramFName}.clut "function defineTestCases() {"
spit Testing/${ProgramFName}.clut "  #"
spit Testing/${ProgramFName}.clut "  clut_case_start      BasicButBeautiful"
spit Testing/${ProgramFName}.clut "  clut_case_comment    Capture output when no parameters given."
spit Testing/${ProgramFName}.clut "  clut_case_end"
spit Testing/${ProgramFName}.clut "  #"
spit Testing/${ProgramFName}.clut "}"
spit Testing/${ProgramFName}.clut ""
spit Testing/${ProgramFName}.clut "clut_definition_set    defineTestCases"
spit Testing/${ProgramFName}.clut ""
spit Testing/${ProgramFName}.clut "#  (eof)"

showFile	Testing/${ProgramFName}.clut

echo ""
echo "	Now we will ask Kamaji to manage our testing efforts."
echo "	Kamaji can be asked to provide three different levels of diagnostic output;"
echo "	these are requested using the silent and verbose modifiers."
echo "	We will use the verbose modifier below to request that Kamaji show you what he is doing."
echo ""
echo "1. Request that the CLUT be compiled and invoked; all tests acted upon when you do not name one."
echo ""
echo "	~~~~"

echoAndExecute	kamaji verbose verbose invoke ${ProgramFName}.clut

echo "	$"
echo "	~~~~"
echo ""
echo "	Kamaji displayed system commands that he invoked on your behalf"
echo "	and added some comments to explain why he did these things:"
echo "	- He builds a ruleset based on the content sof the baseline-folder."
echo "	- He uses symbolic linked in the working-folder to represent baseline and other source files."
echo "	- He remembers the last target file you requested he generate so that you can use the *last* shortcut."
echo "	- He created a Bash script using the *clutc* program because it was needed but did not exist."
echo "	- He created a CLUT output file using that Bash script because it was needed but did not exist."
echo "	- He modified the output file to mask system information, like your user name and home folder name."
echo "	- He used a *partial* output file so the output file itself would not be overwritten with incomplete"
echo "	information if the program that generates it is interrupted."
echo ""
echo "1. Grade the output file; this test will fail because we have not defined a baseline output file."
echo "Review the output file."
echo ""
echo "	~~~~bash"

echoAndExecute	kamaji grade
echoAndExecute	kamaji review

echo "	$"
echo "	~~~~"
echo ""
echo "The BasicButBeautiful test case is a useful one for most programs."
echo "It shows us what the program does with no input and no specific direction."
echo "In this case, the printf command produces an exit status of two (2)"
echo "after writing a usage statement to standard error,"
echo ""
echo "Let's look at the files created by this process:"
echo ""
echo "	~~~~bash"

echoAndExecute	find . | sort

echo "	$"
echo "	~~~~"
echo ""
echo "	The printf.clutc directories are used by the clutc command."
echo "	CLUT compilation creates a Bash script called printf.clut.bash from the printf.clut definitions."
echo "	Kamaji runs that Bash script within a printf.clutr directory to produce the printf.clut.output file."
echo ""
echo "	At this point, it is up to the user to inspect the CLUT output to determine whether or not it is correct."
echo "	Correct output should be used to set the baseline."
echo ""
echo "1. Make the current output file the new baseline, and grade the CLUT based on that new baseline."
echo ""
echo "	~~~~bash"

echoAndExecute	kamaji bless
echoAndExecute	kamaji grade

echo "	$"
echo "	~~~~"
echo ""
echo "1. Modify the CLUT file to include two new test cases:"
echo ""

sed --expression='/clut_case_end/,$d'	Testing/${ProgramFName}.clut > Testing/${ProgramFName}.clut.modified

spit Testing/${ProgramFName}.clut.modified "  clut_case_end"
spit Testing/${ProgramFName}.clut.modified "  #"
spit Testing/${ProgramFName}.clut.modified "  clut_case_start      IntegerRepresentations"
spit Testing/${ProgramFName}.clut.modified "  clut_case_comment    Decimal, hex, text, and floating point 17."
spit Testing/${ProgramFName}.clut.modified '  clut_case_parameter  \\\"%03d %04X %04s %04f\\\\n\\\"'
spit Testing/${ProgramFName}.clut.modified "  clut_case_parameter  17"
spit Testing/${ProgramFName}.clut.modified "  clut_case_parameter  17"
spit Testing/${ProgramFName}.clut.modified "  clut_case_parameter  17"
spit Testing/${ProgramFName}.clut.modified "  clut_case_parameter  17"
spit Testing/${ProgramFName}.clut.modified "  clut_case_end"
spit Testing/${ProgramFName}.clut.modified "  #"
spit Testing/${ProgramFName}.clut.modified "  clut_case_start      FloatRepresentations"
spit Testing/${ProgramFName}.clut.modified "  clut_case_comment    Decimal, hex, text, and floating point 18.19."
spit Testing/${ProgramFName}.clut.modified '  clut_case_parameter  \\\"%03d %04X %04s %04f\\\\n\\\"'
spit Testing/${ProgramFName}.clut.modified "  clut_case_parameter  18.19"
spit Testing/${ProgramFName}.clut.modified "  clut_case_parameter  18.19"
spit Testing/${ProgramFName}.clut.modified "  clut_case_parameter  18.19"
spit Testing/${ProgramFName}.clut.modified "  clut_case_parameter  18.19"
spit Testing/${ProgramFName}.clut.modified "  clut_case_end"

sed --expression='1,/clut_case_end/d'	Testing/${ProgramFName}.clut >> Testing/${ProgramFName}.clut.modified

mv Testing/${ProgramFName}.clut.modified Testing/${ProgramFName}.clut

showFile	Testing/${ProgramFName}.clut

echo ""
echo "1. Generate a new output file and check to see if it matches the baseline."
echo ""
echo "	~~~~bash"

echoAndExecute	kamaji grade

echo "	~~~~"
echo ""
echo "	Now you have a simple sunny-day test case that shows"
echo "	different ways that the printf command formats an integer,"
echo "	as well as one that shows that one that shows that the command will report format incompatibility errors,"
echo "	but still produce output."
echo ""
echo "1. Inspect the differences and"
echo "make the current output file the new baseline."
echo ""
echo "	~~~~bash"

echoAndExecute	kamaji review
echoAndExecute  kamaji bless

echo "	~~~~"
echo ""
echo "1. Build up your test cases by repeating the last few steps."
echo ""
echo "Refer to the [CLUT_Framework.md](CLUT_Framework.md)) for further details,"
echo "including a list of best practices."

#----------------------------------------------------------------------------------------------------------------------

echo ""
echo "## Copyright 2018-2019 Brian G. Holmes"
echo ""
echo "This program is part of the Holmespun Testing Support repository."
echo ""
echo "The Holmespun Testing Support repository contains free software: you can redistribute it and/or modify it under"
echo "the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of"
echo "the License, or (at your option) any later version."
echo ""
echo "The Holmespun Testing Support repository is distributed in the hope that it will be useful, but WITHOUT ANY"
echo "WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU"
echo "General Public License for more details."
echo ""
echo "You should have received a copy of the GNU General Public License along with this file. If not, see"
echo "<https://www.gnu.org/licenses/>."
echo ""
echo "See the [COPYING.text](COPYING.text) file for further licensing information."
echo ""
echo "**(eof)**"
echo ""
echo "[](================================================)"

#----------------------------------------------------------------------------------------------------------------------

exit

#----------------------------------------------------------------------------------------------------------------------
