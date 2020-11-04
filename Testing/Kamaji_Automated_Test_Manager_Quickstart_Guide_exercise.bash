#----------------------------------------------------------------------------------------------------------------------
#
#  Testing/Kamaji_Automated_Test_Manager_quickstart_guide_exercise.bash
#
#	Generate the Kamaji Automated Test Manager Quick-Start Guide in markdown format.
#
#----------------------------------------------------------------------------------------------------------------------
#
#  20191123 BGH; created based on the CLUT_Framework_Quickstart_Guide_exercise.bash script.
#
#----------------------------------------------------------------------------------------------------------------------
#
#  Copyright (c) 2019 Brian G. Holmes
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

export KAMAJI_CONFIG_LIST=./.kamaji.conf

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
  local -r TargetType=${2-}
  #
  echo "    ${TargetName}:"
  echo ""
  echo "	~~~~${TargetType}"
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
  eval ${*} > ${TemporaryFSpec} 2>&1
  #
  grep -v '^make\[' ${TemporaryFSpec} | eval sed ${SedExpressionList}
  #
  rm ${TemporaryFSpec}
  #
}

#======================================================================================================================

declare -r PrototypeName=prototype
declare -r UtilityFName=utility
declare -r ProductFName=product
declare -r ClassName=DateTimeStamp

declare -r ProjectDName=KamajiQuickStart

declare -r ProjectDSpec=$(echoDatStampedFSpec ${ProjectDName}.)_$$

mkdir ${ProjectDSpec}

cd    ${ProjectDSpec}

echo "[](Kamaji_Automated_Test_Manager_quickstart_guide_exercise.bash...)"
echo "[](===============================================================)"
echo ""
echo "# Kamaji Automated Test Manager Quick-Start Guide"
echo ""
echo "This briefly illustrates how the Kamaji Automated Test Manager is used."
echo "The following documentation may also be useful:"
echo ""
echo "* [Kamaji Automated Test Manager](Documen/Kamaji_Automated_Test_Manager.md)"
echo "Detailed documentation for the Kamaji program."
echo ""
echo -n "* [Testing/Kamaji_Automated_Test_Manager_Quickstart_Guide_exercise.bash]"
echo "(Testing/Kamaji_Automated_Test_Manager_Quickstart_Guide_exercise.bash)"
echo "This document is the output file from a test script; it was generated by Kamaji itself."
echo ""
echo "1. Clone the repositories."
echo ""
echo "    ~~~~bash"
echo "    $ git clone https://github.com/Holmespun/HolmespunLibraryBashing.git"
echo "    $ git clone https://github.com/Holmespun/HolmespunTestingSupport.git"
echo "    ~~~~"
echo ""
echo "1. Give yourself temporary access to the utilities in each of these repositories."
echo "You do not want this addition to the PATH variable to be active after the repository is installed."
echo ""
echo "    ~~~~bash"
echo "    $ export PATH=\${PWD}/HolmespunLibraryBashing/bin:\${PATH}"
echo "    $ export PATH=\${PWD}/HolmespunTestingSupport/bin:\${PATH}"
echo "    ~~~~"
echo ""
echo "1. [Optional] Follow the rest of the installation instructions provided in the"
echo "[Installation](Documen/Kamaji_Automated_Test_Manager.md#installation) section of the"
echo "[Kamaji Automated Test Manager](Documen/Kamaji_Automated_Test_Manager.md) documentation."
echo ""
echo "1. Create a project directory to play around in and a Testing subdirectory."
echo ""
echo "	~~~~bash"
echo "	$ cd"

echoAndExecute	mkdir ${ProjectDName}

echoAndExecute	cd ${ProjectDName}
echoAndExecute	mkdir Testing

echo "	$"
echo "	~~~~"
echo ""
echo "1. Start your development effort by creating a prototype."
echo ""

spit ${PrototypeName}.py "#!/usr/bin/env python"
spit ${PrototypeName}.py "#"
spit ${PrototypeName}.py "#  ${PrototypeName}: Given a numeric date-and-time-stamp,"
spit ${PrototypeName}.py "#  display the date and time in YYYY-MM-DD HH:MM:SS format."
spit ${PrototypeName}.py "#"
spit ${PrototypeName}.py ""
spit ${PrototypeName}.py "from datetime import datetime"
spit ${PrototypeName}.py "import sys"
spit ${PrototypeName}.py ""
spit ${PrototypeName}.py "input_form = sys.argv[1]"
spit ${PrototypeName}.py ""
spit ${PrototypeName}.py "internal_form = datetime.fromtimestamp( float(input_form) )"
spit ${PrototypeName}.py ""
spit ${PrototypeName}.py "output_form = internal_form.strftime(\"%c\")"
spit ${PrototypeName}.py ""
spit ${PrototypeName}.py "print( output_form )"
spit ${PrototypeName}.py ""
spit ${PrototypeName}.py "#  (eof)"

chmod 755 ${PrototypeName}.py

showFile ${PrototypeName}.py python

echo ""
echo "1. Create a test program that can be used to demonstrate the prototype."
echo ""

spit Testing/${PrototypeName}_exercise.bash "#!/bin/bash"
spit Testing/${PrototypeName}_exercise.bash "#"
spit Testing/${PrototypeName}_exercise.bash "#  ${PrototypeName} exercise: Demonstration of ${PrototypeName}.py."
spit Testing/${PrototypeName}_exercise.bash "#"
spit Testing/${PrototypeName}_exercise.bash ""
spit Testing/${PrototypeName}_exercise.bash "echo -n \"Test \$(basename \${0}); \""
spit Testing/${PrototypeName}_exercise.bash "echo -n \"User \${USER}; \""
spit Testing/${PrototypeName}_exercise.bash "echo    \"Date \$(date '+%Y-%m-%d %H:%M:%S').\""
spit Testing/${PrototypeName}_exercise.bash ""
spit Testing/${PrototypeName}_exercise.bash "for Input in 1000000000 1575806789 2000000000"
spit Testing/${PrototypeName}_exercise.bash "do"
spit Testing/${PrototypeName}_exercise.bash "  #"
spit Testing/${PrototypeName}_exercise.bash "  echo -n \"Given input \${Input}, ${PrototypeName}.py produces \""
spit Testing/${PrototypeName}_exercise.bash "  #"
spit Testing/${PrototypeName}_exercise.bash "  ../${PrototypeName}.py \${Input}"
spit Testing/${PrototypeName}_exercise.bash "  #"
spit Testing/${PrototypeName}_exercise.bash "done"
spit Testing/${PrototypeName}_exercise.bash ""
spit Testing/${PrototypeName}_exercise.bash "#  (eof)"

chmod 755 Testing/${PrototypeName}_exercise.bash

showFile Testing/${PrototypeName}_exercise.bash bash

echo ""
echo "1. Take a quick look at the contents of our development directory."
echo ""
echo "	~~~~bash"

echoAndExecute "find . | sort"

echo "	~~~~"
echo ""
echo "1. Ask Kamaji to grade your test."
echo ""
echo "	~~~~"

echoAndExecute kamaji verbose grade ${PrototypeName}_exercise.bash

echo "	~~~~"
echo ""
echo "	Tests that use demonstrative output will only pass if the output they produce matches that of the baseline"
echo "  result; your test failed because there is no baseline defined for it yet."
echo ""
echo "	Kamaji will answer a *grade* request with an evaluation for each test requested."
echo "	The *verbose* modifier causes each Kamaji command to be displayed before it it executed."
echo "  Kamaji invoked the test to create an output file, masked that file for comparison, determined that there"
echo "	was no baseline output file associated with the test, and - as such - failed the test."
echo ""
echo "1. Review the output file."
echo ""
echo "	~~~~"

echoAndExecute kamaji review ${PrototypeName}_exercise.output

echo "	~~~~"
echo ""
echo "	Kamaji evaluates the grade assigned to a test before it presents information for your review."
echo "	Output that cannot be compared to a baseline is presented with line numbers to the left."
echo "	As the output looks appropriate, the next step is to make it the baseline that future runs must match."
echo ""
echo "1.  Bless the output file."
echo ""

echo "	~~~~bash"

echoAndExecute kamaji verbose verbose bless ${PrototypeName}_exercise.output

echo "	~~~~"
echo ""
echo "	The use of multiple *verbose* modifiers for the request above caused Kamaji to display the Linux commands"
echo "	it used to fulfill the request."
echo "	In this mode, Kamaji reveals every critical action that it performs:"
echo "  It generates a ruleset for each test you have defined before fulfilling the request with a *cp* command."
echo "  Along the way, it remembers the last target it was asked to act upon, and"
echo "  cleans up a marker that indicates that that target had been reviewed (and thus could be blessed)."
echo ""
echo "1. Grade the test again."
echo ""
echo "	~~~~"

echoAndExecute kamaji grade ${PrototypeName}_exercise.bash

echo "	~~~~"
echo ""
echo "1. Take a quick look at the contents of your development workspace."
echo ""
echo "	~~~~bash"

echoAndExecute "find . | sort"

echo "	~~~~"
echo ""
echo "	Your Testing directory now contains a baseline output file."
echo "	A *Working* folder has also been created in which Kamaji keeps links to your project code,"
echo "	as well as all of the work it derives from them."
echo "	The Working folder is temporary; removing it is similar to issuing a *make clean* command."
echo ""
echo "	Kamaji also created an empty *.kamaji.sed* configuration file for you; it is a *sed* command script file."
echo "  The .kamaji.sed script should be used to define output value masking."
echo ""
echo "1. Remove the Working folder."
echo ""
echo "	~~~~"
echo "	$ moveToGarbage Working"
echo "	mv Working \$HOME/Garbage/YYYYMM/YYYYMMDD_HHMMSS.Account_Specific_Path.Working"
echo "	~~~~"
echo ""
echo "1. Ask Kamaji to generate grades again."
echo ""
echo "	~~~~"

moveToGarbage Working > /dev/null

sleep 1	# So that the new output file does not have the same time-stamp as the baseline.

echoAndExecute kamaji grade

echo "	~~~~"
echo ""
echo "	Your test failed because the output generated by Kamaji now does not match the baseline."
echo ""
echo "1. Review the output file."
echo ""
echo "	~~~~"

echoAndExecute kamaji review

echo "	~~~~"
echo ""
echo "	Date and time values are one of the most common elements that are masked to make output files comparable."
echo ""
echo "1. Define a date- and time-stamp masks in your .kamaji.sed script."
echo ""

spit .kamaji.sed "#  .kamaji.sed"
spit .kamaji.sed ""
spit .kamaji.sed "#  From: Date 2019-12-10 09:34:43"
spit .kamaji.sed "#  To:   Date YYYY-MM-DD HH:MM:SS"
spit .kamaji.sed ""
spit .kamaji.sed "s,[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\},YYYY-MM-DD,g"
spit .kamaji.sed "s,[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\},HH:MM:SS,g"
spit .kamaji.sed ""
spit .kamaji.sed "#  (eof)"

showFile .kamaji.sed sed

echo "1. Ask Kamaji to generate grades again."
echo ""
echo "	~~~~"

echoAndExecute kamaji grade

echo ""
echo "## Copyright 2019 Brian G. Holmes"
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
echo "[](===============================================================)"

#----------------------------------------------------------------------------------------------------------------------

exit

#----------------------------------------------------------------------------------------------------------------------