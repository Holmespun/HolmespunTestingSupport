#----------------------------------------------------------------------------------------------------------------------
#
#  Testing/clutc_exercise.bash
#
#  20180211 BGH; created.
#  20180921 BGH; naming the unnamed test case.
#  20191028 BGH; moved to the Holmespun Testing Support repository.
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

source ${BashLibraryDSpec}/spit_spite_spitn_and_spew.bash

#----------------------------------------------------------------------------------------------------------------------

declare SedExpressionList=

SedExpressionList="${SedExpressionList} --expression='s,^,   |,'"

#----------------------------------------------------------------------------------------------------------------------

function showFile() {
  #
  local -r TargetName=${1}
  #
  echo "----------------------"
  #
  echo "${TargetName}..."
  #
  cat ${TargetName} 2>&1	| eval "sed ${SedExpressionList}"
  #
}

#----------------------------------------------------------------------------------------------------------------------

function createClutBasic() {
  #
  local -r FSpec=${1}
  #
  spit ${FSpec} "#"
  spit ${FSpec} "#  ${FUNCNAME} ${FSpec}"
  spit ${FSpec} "#"
  spit ${FSpec} ""
  spit ${FSpec} "function echoFinalMessage() {"
  spit ${FSpec} "  #"
  spit ${FSpec} "  echo 'This is after the CLU call.'"
  spit ${FSpec} "  echo 'So   is               this.'"
  spit ${FSpec} "  #"
  spit ${FSpec} "}"
  spit ${FSpec} ""
  spit ${FSpec} "function createTextFile() {"
  spit ${FSpec} "  #"
  spit ${FSpec} "  local -r File=\${1}"
  spit ${FSpec} "  shift 1"
  spit ${FSpec} "  local -r Data=\${*}"
  spit ${FSpec} "  #"
  spit ${FSpec} "  echo \$(date '+%H:%M:%S') \${Data} > \${File}"
  spit ${FSpec} "  #"
  spit ${FSpec} "}"
  spit ${FSpec} ""
  spit ${FSpec} "declare -i __CallCount=0"
  spit ${FSpec} ""
  spit ${FSpec} "function noisyEveryFifthCall() {"
  spit ${FSpec} "  #"
  spit ${FSpec} "  __CallCount+=1"
  spit ${FSpec} "  #"
  spit ${FSpec} "  [ \$((\${__CallCount} % 5)) -eq 0 ] && echo \"The user's counter value is \${__CallCount}.\" 1>&2"
  spit ${FSpec} "  #"
  spit ${FSpec} "  true"
  spit ${FSpec} "  #"
  spit ${FSpec} "}"
  spit ${FSpec} ""
  spit ${FSpec} "function dumpForFuzzy2() {"
  spit ${FSpec} "  #"
  spit ${FSpec} "  local -r TargetFSpec=\"\${1}\""
  spit ${FSpec} "  #"
  spit ${FSpec} "  cat \"\${TargetFSpec}\" | sed --expression='s,^,<fuzzy2> ,'"
  spit ${FSpec} "  #"
  spit ${FSpec} "}"
  spit ${FSpec} ""
  spit ${FSpec} "function testCaseRequirementStatements() {"
  spit ${FSpec} "  #"
  spit ${FSpec} "  clut_global_requirement    ABCD-0010							  \\"
  spit ${FSpec} "                               \"When the program is invoked,\"				  \\"
  spit ${FSpec} "                             \"\\nThen it will allow the user to specify an output file;\"   \\"
  spit ${FSpec} "                             \"\\nSo that the user can dictate where the result is stored.\""
  spit ${FSpec} "  #"
  spit ${FSpec} "  clut_global_requirement    ABCD-0020							  \\"
  spit ${FSpec} "                               \"When the program attempts to calculate a median value,\"	  \\"
  spit ${FSpec} "                             \"\\nThen it will ignore all NA values within the sample set;\" \\"
  spit ${FSpec} "                             \"\\nSo that invalid data will not impact the calculation.\""
  spit ${FSpec} "  #"
  spit ${FSpec} "  clut_global_requirement    ABCD-0030							  \\"
  spit ${FSpec} "                               \"When the program is invoked,\"				  \\"
  spit ${FSpec} "                             \"\\nThen it will draw seven red lines,\"			  \\"
  spit ${FSpec} "                             \"\\nAnd all of them will be strictly perpendicular,\"	  \\"
  spit ${FSpec} "                             \"\\nAnd some of them will be drawn with green ink,\"		  \\"
  spit ${FSpec} "                             \"\\nAnd some of them will be drawn with transparent ink.\""
  spit ${FSpec} "  #"
  spit ${FSpec} "}"
  spit ${FSpec} ""
  spit ${FSpec} "function testCasesFirst() {"
  spit ${FSpec} "  #"
  spit ${FSpec} "  clut_shared_initialize      echo 'Shared initializer!'"
  spit ${FSpec} "  #"
  spit ${FSpec} "  clut_case_name              NoParameters"
  spit ${FSpec} "  clut_case_end"
  spit ${FSpec} "  #"
  spit ${FSpec} "  clut_shared_finalize        echo 'Shared finalizer!'"
  spit ${FSpec} "  #"
  spit ${FSpec} "  clut_case_start             Nominal"
  spit ${FSpec} "  clut_case_initialize        echo 'This is before the CLU call.'"
  spit ${FSpec} "  clut_case_initialize        echo \"So   is                this.\""
  spit ${FSpec} "  clut_case_parameter         --parameter=123"
  spit ${FSpec} "  clut_case_finalize          echoFinalMessage"
  spit ${FSpec} "  clut_case_ended"
  spit ${FSpec} "  #"
  spit ${FSpec} "}"
  spit ${FSpec} ""
  spit ${FSpec} "function testCasesMore() {"
  spit ${FSpec} "  #"
  spit ${FSpec} "  clut_global_initialize      noisyEveryFifthCall"
  spit ${FSpec} "  #"
  spit ${FSpec} "  clut_case_begin             Ping"
  spit ${FSpec} "  clut_case_purpose           'This test case has a name... and it's a boy's name.'"
  spit ${FSpec} "  clut_case_requirement       ABCD-0010 Rainy-Day"
  spit ${FSpec} "  clut_case_initialize        createTextFile INPUT.text Some input text"
  spit ${FSpec} "  clut_case_stdin_source      INPUT.text"
  spit ${FSpec} "  clut_case_end"
  spit ${FSpec} "  #"
  spit ${FSpec} "  clut_case_begin             CreateOutputFile"
  spit ${FSpec} "  clut_case_comment           'These comments should wrap in the CLUT output report.'"
  spit ${FSpec} "  clut_case_requirement       ABCD-0010 Sunny-Day"
  spit ${FSpec} "  clut_case_purpose           'All work and no play makes Jack a dull boy once.'"
  spit ${FSpec} "  clut_case_comment           'All work and no play makes Jack a dull boy twice.'"
  spit ${FSpec} "  clut_case_comment           'All work and no play makes Jack a dull boy thrice.'"
  spit ${FSpec} "  clut_case_comment           'All work and no play makes Jack a dull boy a fourth time.'"
  spit ${FSpec} "  clut_case_parameter         Create output.text"
  spit ${FSpec} "  clut_case_end"
  spit ${FSpec} "  #"
  spit ${FSpec} "  clut_case_begin             ModifyInputFile"
  spit ${FSpec} "  clut_case_requirement       ABCD-0010 Sunny-Day"
  spit ${FSpec} "  clut_case_requirement       ABCD-0020 Sunny-Day"
  spit ${FSpec} "  clut_case_initialize        mkdir empty data"
  spit ${FSpec} "  clut_case_initialize        createTextFile data/configuration.text TMPDIR=/remote/tmp"
  spit ${FSpec} "  clut_case_initialize        createTextFile data/delta.text The only constant is change."
  spit ${FSpec} "  clut_case_parameter         Augment"
  spit ${FSpec} "  clut_case_parameter         data/delta.text"
  spit ${FSpec} "  clut_case_end"
  spit ${FSpec} "  #"
  spit ${FSpec} "  clut_global_dump_format     fuzzy2 dumpForFuzzy2"
  spit ${FSpec} "  #"
  spit ${FSpec} "  clut_case_begin             CreateOutputFileOfUnknownType"
  spit ${FSpec} "  clut_case_parameter         Create output.fuzzy1"
  spit ${FSpec} "  clut_case_end"
  spit ${FSpec} "  #"
  spit ${FSpec} "  clut_global_comparison_mask 's,[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\},DATE,g'"
  spit ${FSpec} "  clut_global_comparison_mask 's,[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\},TIME,g'"
  spit ${FSpec} "  #"
  spit ${FSpec} "  clut_case_begin             CreateOutputFileWithSpecialDumpHandler"
  spit ${FSpec} "  clut_case_parameter         Create \$(date '+%Y-%m-%d')_output.fuzzy2"
  spit ${FSpec} "  clut_case_end"
  spit ${FSpec} "  #"
  spit ${FSpec} "  clut_global_finalize        noisyEveryFifthCall"
  spit ${FSpec} "  #"
  spit ${FSpec} "}"
  spit ${FSpec} ""
  spit ${FSpec} "clut_definition_set testCaseRequirementStatements"
  spit ${FSpec} ""
  spit ${FSpec} "clut_definition_set testCasesFirst"
  spit ${FSpec} "clut_definition_set testCasesMore"
  spit ${FSpec} ""
  spit ${FSpec} "#  (eof)"
  #
}

#----------------------------------------------------------------------------------------------------------------------

function createProgram() {
  #
  local -r FSpec=${1}
  #
  spit ${FSpec} "#!/bin/bash"
  spit ${FSpec} "#----------------------------------------------------------------------------------------------------"
  spit ${FSpec} "#"
  spit ${FSpec} "#  ${FSpec}"
  spit ${FSpec} "#"
  spit ${FSpec} "#----------------------------------------------------------------------------------------------------"
  spit ${FSpec} ""
  spit ${FSpec} "set -u"
  spit ${FSpec} ""
  spit ${FSpec} "#----------------------------------------------------------------------------------------------------"
  spit ${FSpec} ""
  spit ${FSpec} "function programMain() {"
  spit ${FSpec} "  #"
  spit ${FSpec} "  local -r Instruction=\"\${1-}\""
  spit ${FSpec} "  local -r FileName=\"\${2-}\""
  spit ${FSpec} "  #"
  spit ${FSpec} "  local    ExitStatus=0"
  spit ${FSpec} "  #"
  spit ${FSpec} "  case \${Instruction} in"
  spit ${FSpec} "       ##"
  spit ${FSpec} "       Create)    echo -e 'This is a line of data\nLine 2\nLine three\n\nLast line.' > \${FileName}"
  spit ${FSpec} "       ;;"
  spit ${FSpec} "       ##"
  spit ${FSpec} "       Augment)   echo -e 'This is an extra data line.' >> \${FileName}"
  spit ${FSpec} "       ;;"
  spit ${FSpec} "       ##"
  spit ${FSpec} "       *)         echo    \"Error: Unknown instruction '\${Instruction}' encountered.\" 1>&2"
  spit ${FSpec} "                  ExitStatus=1"
  spit ${FSpec} "       ;;"
  spit ${FSpec} "       ##"
  spit ${FSpec} "  esac"
  spit ${FSpec} "  #"
  spit ${FSpec} "  return \${ExitStatus}"
  spit ${FSpec} "  #"
  spit ${FSpec} "}"
  spit ${FSpec} ""
  spit ${FSpec} "#----------------------------------------------------------------------------------------------------"
  spit ${FSpec} ""
  spit ${FSpec} "programMain \${*}"
  spit ${FSpec} ""
  spit ${FSpec} "#----------------------------------------------------------------------------------------------------"
  #
  chmod 755 ${FSpec}
  #
}

#======================================================================================================================

declare -r ProgramFName=myAwesomeProgram

declare -r ClutFSpec=${ProgramFName}.clut
declare -r BashFSpec=${ProgramFName}.clut.bash
declare -r OutputFSpec=${ProgramFName}.clut.output

echo "clutc_exercise.bash..."
echo "======================"

echo "Call without parameters."

clutc

echo "======================"
echo "Call with nonexistent file."

clutc bobo

echo "======================"
echo "Call with empty file."

rm --force		${ClutFSpec} ${BashFSpec}

touch			${ClutFSpec}

clutc			${ClutFSpec}

echo "======================"
echo "Call with basic CLUT file, but without an executable file."

rm --force		${ClutFSpec} ${BashFSpec}

createClutBasic		${ClutFSpec}

showFile		${ClutFSpec}

clutc			${ClutFSpec}

echo "======================"
echo "Create a program."

createProgram		${ProgramFName}

showFile		${ProgramFName}

echo "======================"
echo "Call with basic CLUT file to exercise the program."

clutc			${ClutFSpec} ${ProgramFName} ${BashFSpec}

showFile		${BashFSpec}

echo "======================"
echo "Run the CLUT..."

./${BashFSpec} >	${OutputFSpec} 2>&1

showFile		${OutputFSpec}

echo "======================"

#----------------------------------------------------------------------------------------------------------------------

for FName in ${ClutFSpec} ${BashFSpec} ${OutputFSpec} ${ProgramFName}
do
  #
  chmod 644 ${FName}
  #
  mv ${FName} ${FName}.was
  #
done

exit 0

#----------------------------------------------------------------------------------------------------------------------
