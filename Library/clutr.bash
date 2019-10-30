#----------------------------------------------------------------------------------------------------------------------
###
###		HolmespunTestingSupport/Library/clutr.bash
###
###  @file
###  @author	Brian G. Holmes
###  @copyright	GNU General Public License
###  @brief	Command-Line Utility Test (CLUT) run-time support functions.
###  @remark	This file is sourced by the Bash scripted that is created by the clutc.bash script.
###
#----------------------------------------------------------------------------------------------------------------------
#
#  20120608 BGH; created.
#  20121015 BGH; modified to use a 'workin' directory from which 'before' and 'result' directories are created.
#  20121016 BGH; added clut_export_home_variable_as and clut_global_initialize and GlobalAllCaseIntlz.
#  20121123 BGH; creating clut LATEST link.
#  20121206 BGH; added clut_case_finalize function and GlobalClutCaseFinlz array.
#  20121208 BGH; renamed clut_case_stdin to clut_case_stdin_from, and created clut_case_stdout_into function.
#  20130130 BGH; added valgrind support using GlobalInstrumentFSpec variable.
#  20120204 BGH; renamed support functions and associated scripts to use CLUT instead of inaccurate CUT abbreviation.
#  20131104 BGH; only using the GlobalInstrumentFSpec when the command matches the CLUT root name.
#  20131214 BGH; quiet handling of empty purpose, and added clut_case_stdin_data and support for file-free stdin data.
#  20131214 BGH; clut_case_initializesc to escape single quote, less-than, and greater-than characters.
#  20140515 BGH; added clut_case_output_mask so that dumped text files can be masked.
#  20140518 BGH; introduced the use of the clusano utility, and added the clut_get_script_arguments function.
#  20140901 BGH; added clut_global_finalize function and GlobalAllCaseFinlz variable.
#  20180107 BGH; modified clut_case_output_mask to apply to content and names of all files in the result directory.
#  20180213 BGH; created from clut_driver.bash functionality.
#  20180315 BGH; comparable masks must be applied to all messages and section titles of the output report.
#  20180718 BGH; modified to express the number of test cases in the header and footer sections of the output report.
#  20190707 BGH; moved to the HolmespunTestingSupport repository.
#
#----------------------------------------------------------------------------------------------------------------------
#
#  Copyright (c) 2012-2019 Brian G. Holmes
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

export LC_COLLATE=C

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__BashLibraryDSpec
###  @brief	The location of Testing Support library scripts like this one.
###
#----------------------------------------------------------------------------------------------------------------------

declare -r    __BashLibraryDSpec=$(whereHolmespunTestingSupport)/Library

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutCaseSedIndentationExpression
###  @brief	Holds the sed command expression that is used to indent information in subsections of the output
###		report.
###
#----------------------------------------------------------------------------------------------------------------------

declare -r    __ClutCaseSedIndentationExpression="--expression='s,^,    |,'"

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutOutputFormatVersionMajor
###  @brief	An integer that represents the number of times the output format has been
###  		significantly changed in this script.
###
#----------------------------------------------------------------------------------------------------------------------

declare -r -i __ClutOutputFormatVersionMajor=5

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutOutputFormatVersionMinor
###  @brief	An integer that represents the number of times the output format has been
###  		changed in this script since the last time the @ref __ClutOutputFormatVersionMajor was increased.
###
#----------------------------------------------------------------------------------------------------------------------

declare -r -i __ClutOutputFormatVersionMinor=2

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutCaseRunTimeDump
###  @brief	The file name extension to dump function map used to dump the contents of workspace files.
###  @remark	Set in the @ref clutFileRunTimeDumpFormatRegistration function.
###
###  @details	The __ClutCaseRunTimeDump variable is applied by looking up a function name using the file name
###		extension of a file, and then passing the file specification into a call to that function. If no dump
###		file for the extension is defined then the dump function for UNKNOWN content is used.
###
###		The Library/clutr_content_dump_functions.bash file defined the standard HMM dump functions and
###		associates them with many content types. The user can define and register dump functions using the
###		clut_global_dump_format function.
###
#----------------------------------------------------------------------------------------------------------------------

declare -A    __ClutCaseRunTimeDump

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutCaseRunTimeSection
###  @brief	Section number tracking array.
###
###  @details	The __ClutCaseRunTimeSection variable is used to maintain section numbers for the output report; the
###		current non-empty values for the array represent the current section number. The index into the array
###		represents the section nesting level; the top section number has nesting index zero. For example,
###		report section 12.3.7 would be represented as __ClutCaseRunTimeSection[0]=12;
###		__ClutCaseRunTimeSection[1]=3; __ClutCaseRunTimeSection[2]=7.
###
#----------------------------------------------------------------------------------------------------------------------

declare -a -i __ClutCaseRunTimeSection

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clutFileRunTimeDumpFormatRegistration
###  @param	Format	A file name extension.
###  @param	Dumper	The name of a function that will dump a file when given its specification as an argument.
###  @brief	Used to define the Dumper function to be used for files of a specific Format.
###
#----------------------------------------------------------------------------------------------------------------------

function clutFileRunTimeDumpFormatRegistration() {
  #
  local -r Format=${1}
  local -r Dumper=${2}
  #
  __ClutCaseRunTimeDump[${Format^^}]=${Dumper}
  #
}

#----------------------------------------------------------------------------------------------------------------------

source ${__BashLibraryDSpec}/clutr_content_dump_functions.bash

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	__clutCaseRunTimeEchoTemporaryFSpec
###  @param	Specification	[optional] An identifier that should be part of the result.
###  @brief	Displays the name of a temporary directory name.
###  @remark	Uses the mktemp command and TMPDIR variable to create the result.
###
#----------------------------------------------------------------------------------------------------------------------

function __clutCaseRunTimeEchoTemporaryFSpec() {
  #
  local -r Specification=${*-${FUNCNAME}}
  #
  local -r PwdDName=$(basename ${PWD})
  #
  local -r Result=$(mktemp --dry-run -t ${PwdDName}.${Specification}.XXXXXXXXXX)
  #
  echo "${Result}"
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clutCaseRunTimeCompare
###  @param	OriginalDSpec	The specification of the original directory.
###  @param	ModifiedDSpec	The specification of the modified directory.
###  @brief	Compares the content of two directories, and dumps each file that differs.
###
###  @details	The clutCaseRunTimeCompare creates a diff command report based on the OriginalDSpec and ModifiedDSpec,
###		and them dumps that content of their files based on that report. Files that only exist in the
###		ModifiedDSpec are dumped. Files that exist in both directories but differ are dumped.
###
#
#  20190321 BGH; removed "--text" from the diff command because we have not established that the file shouodl be text.
#
#----------------------------------------------------------------------------------------------------------------------

function clutCaseRunTimeCompare() {
  #
  local OriginalDSpec=${1}
  local ModifiedDSpec=${2}
  #
  local -r Command="diff --recursive --no-dereference"
  #
  local -r DiffResultFSpec=$(__clutCaseRunTimeEchoTemporaryFSpec ${FUNCNAME}).diff.text
  #
  local    SedExpressionList="${__ClutCaseSedIndentationExpression}"
  #
# SedExpressionList+=" --expression='s,Only in ${ModifiedDSpec}:,\\# Created,'"
# SedExpressionList+=" --expression='s,Only in ${OriginalDSpec}:,\\# Deleted,'"
# SedExpressionList+=" --expression='s,${Command}.*${ModifiedDSpec}/,\\# Changed ,'"
  #
  clutCaseRunTimeReport 1 "Workspace Impact..."
  #
  ${Command} ${OriginalDSpec} ${ModifiedDSpec} > ${DiffResultFSpec} 2>&1
  #
  if [ -s ${DiffResultFSpec} ]
  then
     #
     cat ${DiffResultFSpec} | eval sed	"${SedExpressionList}"
     #
     local ThreeFourFSpec TargetFSpec
     #
     local      One Two Three Four Five Six More
     #
     while read One Two Three Four Five Six More
     do
       #
       if [ "${One}" = "Only" ]
       then
          #
          #  Only in <dspec>: <fname>
          #
          if [ "${Three:0:${#ModifiedDSpec}}" = "${ModifiedDSpec}" ]
          then
             #
             ThreeFourFSpec=${Three%:*}/${Four}
             #
             TargetFSpec="${ThreeFourFSpec#${ModifiedDSpec}/}"
             #
             __clutCaseRunTimeDump 2 "${ModifiedDSpec}" "${TargetFSpec}" "${TargetFSpec} (created)"
             #
          fi
          #
       elif [ "${One}" = "diff" ]
       then
          #
          #  diff --recursive <dspec1>/<fspec> <dspec2>/<fspec>
          #
          TargetFSpec="${Six#${ModifiedDSpec}/}"
          #
          __clutCaseRunTimeDump 2 "${ModifiedDSpec}" "${TargetFSpec}" "${TargetFSpec} (changed)"
          #
       elif [ "${Six}" = "differ" ]
       then
          #
          #  Binary files <dspec1>/<fspec> and <dspec1>/<fspec> differ
          #
          TargetFSpec="${Five#${ModifiedDSpec}/}"
          #
          __clutCaseRunTimeDump 2 "${ModifiedDSpec}" "${TargetFSpec}" "${TargetFSpec} (changed)"
          #
       fi
       #
     done < ${DiffResultFSpec}
     #
  else
     #
     clutCaseRunTimeReport 2 "The initial and final workspace contents are equivalent."
     #
  fi
  #
  rm ${DiffResultFSpec}
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clutCaseRunTimeDescribeEnd
###  @brief	A function used to signal the end of a test case.
###  @details	The clutCaseRunTimeDescribeEnd function performs no actions at this time, but serves as a placeholder
###		for future functionality.
###
#----------------------------------------------------------------------------------------------------------------------

function clutCaseRunTimeDescribeEnd() { : ; }

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clutCaseRunTimeDescribeStart
###  @brief	A function used to signal the start of a test case; start a new section in the output report.
###
#----------------------------------------------------------------------------------------------------------------------

function clutCaseRunTimeDescribeStart() {
  #
  local -r -i CaseIndx=${1}
  shift 1
  local -r    CaseName=${*}
  #
  __ClutCaseRunTimeSection[0]=${CaseIndx}
  #
  echo ""
  #
  clutCaseRunTimeReport 0 "${CaseName}."
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	__clutCaseRunTimeDumpDirectory
###  @param	NestedLevel	The section level at with the contents should be reported.
###  @param	WorkinDSpec	The specification of the parent of the NestedFSpec.
###  @param	NestedFSpec	The specification within WorkinDSpec of the directory of interest.
###  @param	BetterFName	A better name to display than NestedFSpec itself.
###  @brief	Dumps the contents of a directory hierarchy.
###
#----------------------------------------------------------------------------------------------------------------------

function __clutCaseRunTimeDumpDirectory() {
  #
  local -r -i NestedLevel=${1}
  local -r    WorkinDSpec=${2}
  local -r    NestedFSpec=${3}
  local       BetterFName=${4}
  #
  [ ${#BetterFName} -eq 0 ] && BetterFName="$(basename ${NestedFSpec})"
  #
  local -r FindResultFSpec=$(__clutCaseRunTimeEchoTemporaryFSpec ${FUNCNAME}).find.text
  #
  (cd ${WorkinDSpec}; find ./${NestedFSpec} | sort | sed --expression='1d' --expression='s,^./,,') > ${FindResultFSpec}
  #
  local -r -i ContentCount=$(cat ${FindResultFSpec} | wc --lines)
  #
  if [ ${ContentCount} -eq 0 ]
  then
     #
     clutCaseRunTimeReport ${NestedLevel} "${BetterFName} is empty."
     #
  else
     #
     local DirectoryMessage="${BetterFName} contains "
     #
     if [ ${ContentCount} -eq 1 ]
     then
        #
        DirectoryMessage+="one file."
        #
     else
        #
        DirectoryMessage+="${ContentCount} files."
        #
     fi
     #
     if [ ${#NestedFSpec} -eq 0 ]
     then
        #
        clutCaseRunTimeReport ${NestedLevel} "${DirectoryMessage}.."
        #
        cat ${FindResultFSpec} | eval sed "${__ClutCaseSedIndentationExpression}"
        #
     else
        #
        clutCaseRunTimeReport ${NestedLevel} "${DirectoryMessage}"
        #
     fi
     #
     local DumpableFSpec DumpableDSpec
     #
     local -r -i NestedLevelNext=$((${NestedLevel}+1))
     #
     while read DumpableFSpec
     do
       #
       DumpableDSpec="$(dirname ${DumpableFSpec})"
       #
       if [[ ( ${#NestedFSpec} -eq 0 && "${DumpableDSpec}" == "." ) || ( "${DumpableDSpec}" == "${NestedFSpec}" ) ]]
       then
          #
          __clutCaseRunTimeDump ${NestedLevelNext} ${WorkinDSpec} ${DumpableFSpec} ""
	  #
       fi
       #
     done < ${FindResultFSpec}
     #
  fi
  #
  rm ${FindResultFSpec}
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	__clutCaseRunTimeDumpDataFile
###  @param	NestedLevel	The section level at with the contents should be reported.
###  @param	WorkinDSpec	The specification of the parent of the NestedFSpec.
###  @param	NestedFSpec	The specification within WorkinDSpec of the file of interest.
###  @param	BetterFName	A better name to display than NestedFSpec itself.
###  @param	ContentType	[optional] The content type that should be used to dump NestedFSpec.
###  @brief	Dumps the contents of a regular file.
###
#----------------------------------------------------------------------------------------------------------------------

function __clutCaseRunTimeDumpDataFile() {
  #
  local -r -i NestedLevel=${1}
  local -r    WorkinFName=${2}
  local -r    NestedFSpec=${3}
  local       BetterFName=${4}
  local       ContentType=${5-}
  #
  local -r    DateTimeStampRegex="[0-9]{8}[_-][0-9]{6}"
  #
  local       ContentTypeClarity=" [${ContentType,,}]"
  #
  [ ${#BetterFName} -eq 0 ] && BetterFName="$(basename ${NestedFSpec})"
  #
  if [ -s ${WorkinFName}/${NestedFSpec} ]
  then
     #
     if [ ${#ContentType} -eq 0 ]
     then
	#
	local -r NestedFName=$(basename ${NestedFSpec})
	#
	ContentType=${NestedFName##*.}
	#
	if [ ${#ContentType} -eq 0 ]
	then
	   ContentType=UNKNOWN
	else
	   ContentTypeClarity=
	fi
	#
     fi
     #
     ContentType=${ContentType^^}
     #
     local ContentDump=${__ClutCaseRunTimeDump[UNKNOWN]}
     #
     #  YYYYMMDD_HHMMSS Date and time stamps and "sorted" don't count; use the extension that they hide.
     #
     if [ "${ContentType}" = "SORTED" ] || [[ ${ContentType} =~ ${DateTimeStampRegex} ]]
     then
        #
        ContentType=${NestedFName%.*}
        #
        ContentType=${ContentType##*.}
        #
        ContentType=${ContentType^^}
        #
     fi
     #
     if [ "${ContentType}" != "UNKNOWN" ] && [ "${__ClutCaseRunTimeDump[${ContentType}]+SET}" = "SET" ]
     then
        #
        ContentDump=${__ClutCaseRunTimeDump[${ContentType}]}
        #
     else
        #
	ContentTypeClarity=" [UNKNOWN]"
        #
     fi
     #
     clutCaseRunTimeReport ${NestedLevel} "${BetterFName}${ContentTypeClarity}..."
     #
     ${ContentDump} ${WorkinFName}/${NestedFSpec} ${ContentType} | eval sed "${__ClutCaseSedIndentationExpression}"
     #
  else
     #
     clutCaseRunTimeReport ${NestedLevel} "${BetterFName} is empty."
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	__clutCaseRunTimeDumpSymbolicLink
###  @param	NestedLevel	The section level at with the contents should be reported.
###  @param	WorkinDSpec	The specification of the parent of the NestedFSpec.
###  @param	NestedFSpec	The specification within WorkinDSpec of the file of interest.
###  @param	BetterFName	[optional] A better name to display than NestedFSpec itself.
###  @brief	Dumps the contents of a symbolic link file.
###
#----------------------------------------------------------------------------------------------------------------------

function __clutCaseRunTimeDumpSymbolicLink() {
  #
  local -r -i NestedLevel=${1}
  local -r    WorkinFName=${2}
  local -r    NestedFSpec=${3}
  local       BetterFName=${4-}
  #
  [ ${#BetterFName} -eq 0 ] && BetterFName="$(basename ${NestedFSpec})"
  #
  local -r    TargetFSpec=${WorkinFName}/${NestedFSpec}
  #
  clutCaseRunTimeReport ${NestedLevel} "${BetterFName} is a symbolic link to $(readlink ${TargetFSpec})"
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	__clutCaseRunTimeDump
###  @param	NestedLevel	The section level at with the contents should be reported.
###  @param	WorkinDSpec	The specification of the parent of the NestedFSpec.
###  @param	NestedFSpec	The specification within WorkinDSpec of the file or directory of interest.
###  @param	BetterFName	A better name to display than NestedFSpec itself.
###  @brief	Dumps the contents of a symbolic link file, regular file, or directory hierarchy.
###
###  @remark	The man page for the 'test' command states that, "Except for -h and -L, all FILE-related tests
###		dereference symbolic links." As such, we need to test for symbolic link type before we do for
###		directory type.
###
#----------------------------------------------------------------------------------------------------------------------

function __clutCaseRunTimeDump() {
  #
  local -r -i NestedLevel=${1}
  local -r    WorkinFName=${2}
  local -r    NestedFSpec=${3}
  local       BetterFName=${4}
  #
  if [ -L ${WorkinFName}/${NestedFSpec} ]
  then
     #
     __clutCaseRunTimeDumpSymbolicLink	${NestedLevel} "${WorkinFName}" "${NestedFSpec}" "${BetterFName}"
     #
  elif [ -d ${WorkinFName}/${NestedFSpec} ]
  then
     #
     __clutCaseRunTimeDumpDirectory	${NestedLevel} "${WorkinFName}" "${NestedFSpec}" "${BetterFName}"
     #
  else
     #
     __clutCaseRunTimeDumpDataFile	${NestedLevel} "${WorkinFName}" "${NestedFSpec}" "${BetterFName}"
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clutCaseRunTimeDump
###  @param	NestedLevel	The section level at with the contents should be reported.
###  @param	TargetFSpec	The specification within the current directory of the file or directory of interest.
###  @param	Alternative	[optional] A better name to display than TargetFSpec itself.
###  @brief	Dumps the contents of the specified symbolic link file, regular file, or directory hierarchy.
###
#----------------------------------------------------------------------------------------------------------------------

function clutCaseRunTimeDump() {
  #
  local -r -i NestedLevel=${1}
  local -r    TargetFSpec=${2}
  local -r    Alternative=${3-}
  #
  __clutCaseRunTimeDump ${NestedLevel} "$(basename ${TargetFSpec})" "" "${Alternative}"
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	__clutCaseRunTimeExecuteIsInWorking
###  @param	ErrorMessage	The error message to display.
###  @brief	Displays an error and terminates if it finds that the user's test code has changes the $PWD from the
###		run-time working directory in which it started.
###
#----------------------------------------------------------------------------------------------------------------------

function __clutCaseRunTimeExecuteIsInWorking() {
  #
  local -r ErrorMessage="${*}"
  #
  local -r PwdDSpec=$(dirname  ${PWD})
  local -r PwdDName=$(basename ${PWD})
  #
  if [ "${PwdDSpec}" != "${__ClutWorkingDSpec}" ]
  then
     #
     echo "ERROR: ${ErrorMessage}."
     echo "ERROR: The PWD is not nested inside ${__ClutWorkingDSpec}."
     echo "ERROR: The PWD parent directory is  ${PwdDSpec}."
     echo "ERROR: The PWD directory name is    ${PwdDName}."
     #
     exit 1
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	__clutCaseRunTimeExecute
###  @param	StandardInputFSpec	The file specification that should be used for standard input; null string when
###					standard input need not be supported.
###  @param	CommandToExecute	The command and arguments that should be executed.
###  @brief	Executes a command and captures the standard forms of output that it produces.
###
###  @remark	Symbolic links are created in the test case working directory that point to the files used to capture
###		stdout and stderr output; these links are removed when the case is complete, but they will persist
###		(and thus be available for user inspection) if and when the case is interrupted.
###
#----------------------------------------------------------------------------------------------------------------------

function __clutCaseRunTimeExecute() {
  #
  local StandardInputFSpec="${1}"
  shift 1
  local CommandToExecute="${*}"
  #
  local -r TemporaryPrefix=$(__clutCaseRunTimeEchoTemporaryFSpec ${FUNCNAME})
  #
  local -r StandardOutputFSpec=${TemporaryPrefix}.stdout
  local -r StandardErrorsFSpec=${TemporaryPrefix}.stderr
  #
  ln --symbolic ${StandardOutputFSpec}
  ln --symbolic ${StandardErrorsFSpec}
  #
  local -i ExitStatus
  #
  local StandardFSpec StandardFName
  #
  __clutCaseRunTimeExecuteIsInWorking "Programmatic error in ${FUNCNAME}"
  #
  if [ "${CommandToExecute:0:4}" = "gdb " ]
  then
     #
     #  Interactive, so do not capture STDOUT and STDERR.
     #
     if [ ${#StandardInputFSpec} -gt 0 ]
     then
        #
        clutCaseRunTimeReport 2 "${CommandToExecute} <<< ${StandardInputFSpec}"
        #
        eval ${CommandToExecute} <<< ${StandardInputFSpec}
        #
        ExitStatus=${?}
        #
     else
        #
        clutCaseRunTimeReport 2 "${CommandToExecute}"
        #
        eval ${CommandToExecute}
        #
        ExitStatus=${?}
        #
     fi
     #
  else
     #
     #  Normal, so capture STDOUT and STDERR.
     #
     if [ ${#StandardInputFSpec} -gt 0 ]
     then
        #
        clutCaseRunTimeReport 2 "${CommandToExecute} <<< ${StandardInputFSpec}"
        #
        eval ${CommandToExecute} <<< ${StandardInputFSpec}	> ${StandardOutputFSpec} 2> ${StandardErrorsFSpec}
        #
        ExitStatus=${?}
        #
     else
        #
        clutCaseRunTimeReport 2 "${CommandToExecute}"
        #
        eval ${CommandToExecute} > ${StandardOutputFSpec} 2> ${StandardErrorsFSpec}
        #
        ExitStatus=${?}
        #
     fi
     #
  fi
  #
  [ ${ExitStatus} -ne 0 ] && clutCaseRunTimeReport 3 "Exit Status ${ExitStatus}!"
  #
  local -r TemporaryPrefixDSpec=$(dirname ${TemporaryPrefix})
  #
  if [ -s ${StandardErrorsFSpec} ]
  then
     #
     [ ${ExitStatus} -eq 0 ] && clutCaseRunTimeReport 3 "Exit Status ${ExitStatus}!"
     #
     clutFileRunTimeMaskDataInFile ${StandardErrorsFSpec}
     #
     __clutCaseRunTimeDumpDataFile 3 ${TemporaryPrefixDSpec} $(basename ${StandardErrorsFSpec}) "STDERR" text
     #
  fi
  #
  if [ -s ${StandardOutputFSpec} ]
  then
     #
     clutFileRunTimeMaskDataInFile ${StandardOutputFSpec}
     #
     __clutCaseRunTimeDumpDataFile 3 ${TemporaryPrefixDSpec} $(basename ${StandardOutputFSpec}) "STDOUT" text
     #
  fi
  #
  __clutCaseRunTimeExecuteIsInWorking "The '${CommandToExecute}' command is flawed"
  #
  rm --force ${StandardErrorsFSpec} $(basename ${StandardErrorsFSpec})
  rm --force ${StandardOutputFSpec} $(basename ${StandardOutputFSpec})
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clutCaseRunTimeFinalization
###  @param	CommandToExecute	The command and arguments that should be executed.
###  @brief	Executes a finalization command and captures the standard forms of output that it produces.
###
#----------------------------------------------------------------------------------------------------------------------

function clutCaseRunTimeFinalization() {
  #
  __clutCaseRunTimeExecute "" ${*}
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clutCaseRunTimeInitialization
###  @param	CommandToExecute	The command and arguments that should be executed.
###  @brief	Executes an initialization command and captures the standard forms of output that it produces.
###
#----------------------------------------------------------------------------------------------------------------------

function clutCaseRunTimeInitialization() {
  #
  __clutCaseRunTimeExecute "" ${*}
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clutCaseRunTimeParagraph
###  @param	TokenList	A list of tokens (words).
###  @brief	Formats a TokenList into report output that is at most 119 characters long and vertical-bar indented.
###
#----------------------------------------------------------------------------------------------------------------------

function clutCaseRunTimeParagraph() {
  #
  local -r    TokenList="${*}"
  #
  local -r    OutputLinePrefix=$(echo "" | eval sed "${__ClutCaseSedIndentationExpression}")
  #
  local -r -i OutputLineLengthMaximum=$((119 - ${#OutputLinePrefix}))
  #
  local       OutputLineTokenList=
  #
  local       OutputLineTokenListLast Token
  #
  for Token in ${TokenList}
  do
    #
    OutputLineTokenListLast="${OutputLineTokenList}"
    #
    OutputLineTokenList+=" ${Token}"
    #
    if [ ${#OutputLineTokenList} -gt ${OutputLineLengthMaximum} ]
    then
       #
       echo "${OutputLinePrefix}${OutputLineTokenListLast:1}"
       #
       OutputLineTokenList=" ${Token}"
       #
    fi
    #
  done
  #
  echo "${OutputLinePrefix}${OutputLineTokenList:1}"
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clutCaseRunTimeReport
###  @param	Level	An output report section level.
###  @param	Message A message to write to the output report.
###  @brief	Creates an output report section header at the given Level with the given Message.
###  @remark	Comparable masks are applied to the given message.
###
#----------------------------------------------------------------------------------------------------------------------

function clutCaseRunTimeReport() {
  #
  local -r -i Level=${1}
  shift 1
  local -r    Message="${*}"
  #
  [ ${Level} -gt 0 ] && __ClutCaseRunTimeSection[${Level}]+=1
  #
  __ClutCaseRunTimeSection[$((${Level}+1))]=0
  #
  local    SectionNumber=
  #
  local -i Index=0
  #
  while [ ${Index} -le ${Level} ]
  do
    #
    SectionNumber+="${__ClutCaseRunTimeSection[${Index}]}."
    #
    Index+=1
    #
  done
  #
  clutFileRunTimeMask Text "${SectionNumber} ${Message}"
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clutCaseRunTimeUtilityExecute
###  @param	StdinSource	The file specification that should be used for standard input; null string when
###  				standard input need not be supported.
###  @param	Command2Run	The command and arguments that should be executed.
###  @brief	Executes the CLU and captures the standard forms of output that it produces.
###
#----------------------------------------------------------------------------------------------------------------------

function clutCaseRunTimeUtilityExecute() {
  #
  local -r StdinSource=${1}
  shift 1
  local -r Command2Run=${*}
  #
  __clutCaseRunTimeExecute "${StdinSource}" "${Command2Run}"
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clutFileRunTimeDescribeEnded
###  @param	ClutFName	The name of the CLUT definition file.
###  @param	ClutMinor	The minor format version for the output report.
###  @brief	Create a report output footer.
###
#----------------------------------------------------------------------------------------------------------------------

function clutFileRunTimeDescribeEnded() {
  #
  local -r    ClutFName="${1}"
  local -r -i ClutMinor=$((${__ClutOutputFormatVersionMinor} + ${2}))
  local -r -i CaseCount=${3}
  #
  echo ""
  echo "CLUT Source File: ${ClutFName} (${CaseCount} cases)"
  echo "CLUT Output Format Version: ${__ClutOutputFormatVersionMajor}.${ClutMinor}"
  echo "CLUT Output Complete."
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clutFileRunTimeDescribeStart
###  @param	ClutFName	The name of the CLUT definition file.
###  @param	ClutMinor	The minor format version for the output report to be produced.
###  @brief	Create a report output header.
###
#----------------------------------------------------------------------------------------------------------------------

function clutFileRunTimeDescribeStart() {
  #
  local -r    ClutFName="${1}"
  local -r -i ClutMinor=$((${__ClutOutputFormatVersionMinor} + ${2}))
  local -r -i CaseCount=${3}
  #
  echo "CLUT Output Begins..."
  echo "CLUT Output Format Version: ${__ClutOutputFormatVersionMajor}.${ClutMinor}"
  echo "CLUT Source File: ${ClutFName} (${CaseCount} cases)"
  #
  __ClutCaseRunTimeSection[0]=0
  #
}

#----------------------------------------------------------------------------------------------------------------------
