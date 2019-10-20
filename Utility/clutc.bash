#!/bin/bash
#----------------------------------------------------------------------------------------------------------------------
###
###	Bash/clutc.bash...
###
###	@file
###	@author		Brian G. Holmes
###	@copyright	GNU General Public License
###	@brief		Command-Line Utility Test (CLUT) compilation script.
###	@todo		https://github.com/Holmespun/HolmespunMakefileMethod/issues
###	@remark		Usage: clutc.bash <clut-specification> [ <clut-compiled-specification> ]
###
###	@details
###
###	## Design and implementation philosophies:
###
###		1. Global variables are named using double underscore character prefixes. We cannot keep the user
###		from referencing them in CLUT definition files.
###
###		2. The user experience can be improved by supporting separate compile- and run-time processing.
###		Run-time processing is defined by a script that is created during compile-time.  As a result, repeat
###		tests that have already been compiled is faster.
###
###		3. Isolating test case definitions in a function not only makes it easy to separate compile- and
###		run-time processing, but it is good practice for users that otherwise ignore modularity in script
###		source code.
###
###	## Requirements Numbers and Test-Type
###
###	One of my best-practices for all testing is to have test cases that exercise a specific requirement.  These
###	test cases have a sunny- (nominal) or rainy-day (error condition) type. As such, the CLUT framework supports
###	requirements traceability, and produces output in it report that can be used to generate a testing traceability
###	matrix.
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
#  20180210 BGH; clut_driver.bash revamp as clutc for use as a CLUT compilation step.
#  20180311 BGH; issue #2 CLUT: Requirements Numbers, Test-Type, and Matrix
#  20180315 BGH; clutFileRunTimeMask, global comparison masking performed by one function.
#  20180419 BGH; added the ability for the user to disable a test case.
#  20180718 BGH; modified to express the number of test cases in the header and footer sections of the output report.
#  20180815 BGH; modified to check to see if critical functions are redefined by the user.
#  20180921 BGH; clut_case_begin now requires a name parameter.
#  20180928 BGH; detecting an incomplete test case definition in clut_case_begin.
#  20181008 BGH; added clut_global_notation and output of notations in the global information section.
#  20190707 BGH; moved to the HolmespunTestingSupport repository.
#
#  Copyright (c) 2012-2019 Brian G. Holmes
#
#	This program is part of the Holmespun Makefile Method.
#
#	The Holmespun Makefile Method is free software: you can redistribute it and/or modify it under the terms of the
#	GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#
#	The Holmespun Makefile Method is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
#	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
#	Public License for more details.
#
#	You should have received a copy of the GNU General Public License along with this program. If not, see
#	<https://www.gnu.org/licenses/>.
#
#  See the COPYING.text file for further information.
#
#----------------------------------------------------------------------------------------------------------------------

set -u

#----------------------------------------------------------------------------------------------------------------------
#
#  We define LC_COLLATE here so that a user-defined sort order does not make the results inconsistent.
#
#----------------------------------------------------------------------------------------------------------------------

export LC_COLLATE=C

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__BashLibraryDSpec
###  @brief	Holds the directory in which Bash library files are stored.
###  @details	Used to include the echoDatStampedFSpec, and
###		spit, spite, spitn, and, spew, utility functions.
###
#----------------------------------------------------------------------------------------------------------------------

declare -r __BashLibraryDSpec=$(whereHolmespunLibraryBashing)/Library

source ${__BashLibraryDSpec}/echoDatStampedFSpec.bash
source ${__BashLibraryDSpec}/echoRelativePath.bash
source ${__BashLibraryDSpec}/spit_spite_spitn_and_spew.bash

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ScriptFName
###  @brief	Holds the name of the script.
###
#----------------------------------------------------------------------------------------------------------------------

declare -r __ScriptFName=$(basename ${0})

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ScriptArgumentList
###  @brief	Holds the argument list that the user passed into the script; a CLUT definition file specification and
###		(optionally) a file specification for the resulting compilation script. 
###
#----------------------------------------------------------------------------------------------------------------------

declare -r __ScriptArgumentList="${*}"

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__WhereWeWereDSpec
###  @brief	Holds the \$PWD from which the script was called.
###
#----------------------------------------------------------------------------------------------------------------------

declare -r __WhereWeWereDSpec="${PWD}"

#----------------------------------------------------------------------------------------------------------------------

function echoErrorAndExit() {
  #
  local -r -i ExitStatus=${1}
  shift 1
  local -r    Message="${*}"
  #
  echo "ERROR: ${Message}" 1>&2
  #
  exit ${ExitStatus}
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	__evaluateScriptArguments
###  @param	ClutSourceFSpecVName	The name of the variable that will hold the name of the CLUT extracted directly
###					as the ClutSourceFSpec (first of the script arguments).
###  @param	ClutTargetFSpecVName	The name of the variable that will hold the specification for the Command Line
###					Utility that the CLUT exercises.
###  @param	ClutResultFSpecVName	The name of the variable that will hold the name of the file to be created by
###					compiling the CLUT cases; fully qualified ClutResultFSpec.
###  @param	ClutSourceFSpec		The first argument to the parent script; the CLUT definition file
###					specification.
###  @param	ClutTargetFSpec		The second argument to the parent script; the specification of the executable
###					file (a.k.a. CLU) that is being tested; not the target build from source, but
###					rather the target of the tests.
###  @param	ClutResultFSpec		[optional] The third argument to the parent script; the file specification
###					into which the parent script should write the compiled CLUT.
###  @brief	Echos a result that should be treated as Bash source code.
###
###  @details	The result will either echo and error or usage message and exit, or it will assign a value to each
###		of the variables named in the first three arguments. This function also handles requests for usage
###		information.
###
###		For example, a call of the form '__evaluateScriptArguments X Y Z' will cause the function to display
###		something like the 'echo "USAGE: clutc <clut-file-spec>"; exit 1' string.  Alternatively, a call of
###		the form '__evaluateScriptArguments X Y Z program.clut' will cause the function to
###		display the 'X=/path/to/program.clut; Y=/path/to/the/program; Z=/path/to/program.clut.bash' string.
###
###		The function may be used to define the variables (named in first three arguments) as follows:
###
###			source <(__evaluateScriptArguments X Y Z ${*})
###
###		Thus using the text displayed by this function part of the current run-time script.
###
#----------------------------------------------------------------------------------------------------------------------

function __evaluateScriptArguments() {
  #
  local -r ClutSourceFSpecVName=${1}
  local -r ClutTargetFSpecVName=${2}
  local -r ClutResultFSpecVName=${3}
  local -r ClutSourceFSpec=${4-USAGE}
  local -r ClutTargetFSpec=${5-}
  local -r ClutResultFSpec=${6-}
  #
  local Result=
  #
  #  Return a script that can be evaluated as an appropriate result.
  #
  if [ "${ClutSourceFSpec}" = "USAGE" ] || [ "${ClutTargetFSpec}" = "USAGE" ] 
  then
     #
     Result="${Result}; echo \"USAGE: ${__ScriptFName} <clut-definition> <clu> [<clut-output>]\"" 1>&2
     #
     Result="${Result}; exit 1"
     #
  elif [ ! -s ${ClutSourceFSpec} ]
  then
     #
     Result="${Result}; echoErrorAndExit 2 \"The '${ClutSourceFSpec}' CLUT definition file is empty or nonexistent.\""
     #
  elif [ ! -x ${ClutTargetFSpec} ]
  then
     #
     local -r WhatItIs="nonexistent or not executable"
     #
     Result="${Result}; echoErrorAndExit 4 \"The '${ClutTargetFSpec}' Command-Line Utility is ${WhatItIs}.\""
     #
  else
     #
     local AbsoluteTargetFSpec
     #
     cd $(dirname ${ClutTargetFSpec})
        #
        AbsoluteTargetFSpec=${PWD}/$(basename ${ClutTargetFSpec})
        #
     cd ${__WhereWeWereDSpec}
     #
     cd $(dirname ${ClutSourceFSpec})
     #
     Result="${Result}; ${ClutSourceFSpecVName}=${PWD}/$(basename ${ClutSourceFSpec})"
     #
     Result="${Result}; ${ClutTargetFSpecVName}=${AbsoluteTargetFSpec}"
     #
     if [ ${#ClutResultFSpec} -gt 0 ]
     then
        #
        Result="${Result}; ${ClutResultFSpecVName}=${ClutResultFSpec}"
        #
     else
        #
        Result="${Result}; ${ClutResultFSpecVName}=${ClutSourceFSpec}.bash"
        #
     fi
     #
  fi
  #
  echo "${Result:1}"
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	__clutCaseCompileTimeListExpansion
###  @param	RunTimeCall	The run-time visitor function to be applied to each item in the list.
###  @param	Indentation	The whitespace that should appear before each call.
###  @param	OutputFSpec	The specification of the output file.
###  @param	TokenVector	[optional] The list of items to be expanded.
###  @brief	Expands a list of items into a series of run-time calls that apply a visitor function to each.
###  @details	The __clutCaseCompileTimeListExpansion function breaks a semicolon-separated TokenVector vector into
###		separate items, passes each item to the RunTimeCall, which is written as a Bash script statement to the
###		OutputFSpec. For example, this function is used to break the __ClutCaseFinalizerList into separate
###		calls to the clutCaseRunTimeFinalization function.
###
#----------------------------------------------------------------------------------------------------------------------

function __clutCaseCompileTimeListExpansion() {
  #
  local -r RunTimeCall="${1}"
  local -r Indentation="${2}"
  local -r OutputFSpec="${3}"
  local -r TokenVector="${4-}"
  #
  if [ ${#TokenVector} -gt 0 ]
  then
     #
     local -r IFSWas="${IFS}"
     #
     IFS=";"
        #
        local Token
        #
        for Token in ${TokenVector}
        do
          #
          if [ ${#Token} -gt 0 ]
	  then
             #
             spit  ${OutputFSpec} "${Indentation}#"
	     #
	     spit  ${OutputFSpec} "${Indentation}${RunTimeCall} ${Token:1}"
	     #
	  fi
	  #
        done
        #
     IFS="${IFSWas}"
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	__clutCaseCompileTimeSpitPrettyPrefix
###  @param	OutputFSpec	The specification of the output file.
###  @param	OutputPrefix	Te prefix that should be applied to the first output line.
###  @param	OutputFollow	The text that should be broken up into multiple output lines to keep all lines to a
###				maximum of 119 characters.
###  @brief	Breaks a very long set of text (i.e. parametric data into a run-time function call) into multiple,
###		back-slash continued lines of a maximum length of 119 characters.
###  @remark	This function is used to pretty-print data in the Bash script that represents a compiled CLUT; no one
###		ever needs to see it, but I prefer to know that it will be legible if and when someone wants to.
###
#----------------------------------------------------------------------------------------------------------------------

function __clutCaseCompileTimeSpitPrettyPrefix() {
  #
  local -r OutputFSpec=${1}
  local -r OutputPrefix="${2}"
  shift 2
  local -r OutputFollow="${*}"
  #
  local -r BlankLine="$(printf ' %.0s' {1..119})"
  #
  local -r SecondaryPrefix="${BlankLine:0:${#OutputPrefix}} "
  #
  local    LineOfText="${OutputPrefix} "
  #
  local    Separator="\""
  #
  local -i SizeOfText=${#LineOfText}
  #
  for Token in ${OutputFollow}
  do
    #
    SizeOfText+=${#Separator}
    SizeOfText+=${#Token}
    #
    if [ ${SizeOfText} -gt 115 ]
    then
       #
       spit ${OutputFSpec} "${LineOfText}\"${BlankLine:0:$((119-${#LineOfText}-2))}\\"	# 2 = double-quote + back-slash
       #
       LineOfText="${SecondaryPrefix}"
       #
       Separator="\""
       #
       SizeOfText=${#LineOfText}
       SizeOfText+=${#Separator}
       SizeOfText+=${#Token}
       #
    fi
    #
    LineOfText+="${Separator}${Token}"
    #
    Separator=" "
    #
  done
  #
  spit ${OutputFSpec} "${LineOfText}\""
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutCaseCommentList
###  @brief	Used to accumulate a set of user comments.
###
#----------------------------------------------------------------------------------------------------------------------

declare       __ClutCaseCommentList

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutCaseDisabledReason
###  @brief	The reason a test case was disabled.
###
#----------------------------------------------------------------------------------------------------------------------

declare	      __ClutCaseDisabledReason

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutCaseDefiner
###  @brief	Tracks the definition function (part of __ClutDefinitionSet) wherein each test case is defined.  The
###		value of __ClutCaseDefiner[N]=F signifies that test case N is the first defined within function F;
###		all other values of __ClutCaseDefiner are blank.
###  @remark	Set by the @ref clut_definition_set function.
###
#----------------------------------------------------------------------------------------------------------------------

declare    -a __ClutCaseDefiner

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutCaseFinalizerList
###  @brief	Accumulates finalization commands that are issued after the call to the CLU
###		program that is to be tested.
###  @remark	Set by the @ref clut_case_finalize function.
###
#----------------------------------------------------------------------------------------------------------------------

declare       __ClutCaseFinalizerList

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutCaseIndex
###  @brief	Used to assign a numerical identifier to each test case; starts at 1. Initially, and
###		after each test case is defined, it represents the next test case to be defined.
###  @remark	Incremented by the @ref clut_case_end function.
###
#----------------------------------------------------------------------------------------------------------------------

declare    -i __ClutCaseIndex=1

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutCaseParameterList
###  @brief	Accumulates parameters for the CLU program/script that is to be tested.
###  @remark	Set by the clut_case_parameter function.
###
#----------------------------------------------------------------------------------------------------------------------

declare       __ClutCaseParameterList

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutCasePriorizerList
###  @brief	Accumulates initialization commands that are issued prior to the call to the CLU program that is to
###		be tested.
###  @remark	Set by the @ref clut_case_initialize function.
###
#----------------------------------------------------------------------------------------------------------------------

declare       __ClutCasePriorizerList

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutCaseIndexOutputFormat
###  @brief	The format used to display test case index numbers.
###
#----------------------------------------------------------------------------------------------------------------------

declare -r    __ClutCaseIndexOutputFormat="printf %02d"

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutCaseName
###  @brief	The name of the current test case.
###  @remark	Set by the @ref clut_case_begin function.
###
#----------------------------------------------------------------------------------------------------------------------

declare       __ClutCaseName

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutCaseRequirementList
###  @brief	A list of requirement number and test type pairs; the format of both are defined by the user.
###  @remark	Set by the @ref clut_case_requirement function.
###
#----------------------------------------------------------------------------------------------------------------------

declare       __ClutCaseRequirementList

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutCaseStdinSourceFName
###  @brief	Holds the name of the file that contains data that the user would like to have used as standard input.
###  @remark	Set by the @ref clut_case_stdin_source function.
###
#----------------------------------------------------------------------------------------------------------------------

declare       __ClutCaseStdinSourceFName

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutDefinitionSet
###  @brief	Accumulates functions that should be called to define test cases.
###  @remark	Set by the @ref clut_definition_set function.
###
#----------------------------------------------------------------------------------------------------------------------

declare       __ClutDefinitionSet=

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutGlobalCompareMaskList
###  @brief	Accumulates comparison masks (sed expressions) that should be applied globally.
###  @remark	Set by the @ref clut_global_comparison_mask function.
###
#----------------------------------------------------------------------------------------------------------------------

declare       __ClutGlobalCompareMaskList=

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutGlobalDumpFormatList
###  @brief	Accumulates dump format handling function registrations.
###  @remark	Set by the @ref clut_global_dump_format function.
###
#----------------------------------------------------------------------------------------------------------------------

declare       __ClutGlobalDumpFormatList=

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutGlobalFinalizerList
###  @brief	Accumulates finalization commands that are issued after calls to the CLU program that is to be tested.
###  @details	Global finalization commands differ from shared finalizations in two ways: (1) The function that they
###		are defined in in immaterial; (2) The set of global finalizations is the same for every test case.
###  @remark	Set by the @ref clut_global_finalize function.
###
#----------------------------------------------------------------------------------------------------------------------

declare       __ClutGlobalFinalizerList=

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutGlobalNotation
###  @brief	An array of titled notations; __ClutGlobalNotation[T]=P where the paragraph P has title T.
###  @remark	Set by the @ref clut_global_notation function.
###
#----------------------------------------------------------------------------------------------------------------------

declare    -A __ClutGlobalNotation

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutGlobalNotationCount
###  @brief	The number of values that are stored in the __ClutGlobalNotation array.
###  @remark	Incremented by the @ref clut_global_notation function.
###
#----------------------------------------------------------------------------------------------------------------------

declare    -i __ClutGlobalNotationCount=0	# Easier than dealing with unbound __ClutGlobalNotation instances.

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutGlobalPriorizerList
###  @brief	Accumulates initialization commands that are issued prior to calls to the CLU program that is to be
###		tested.
###  @details	Global initialization commands differ from shared initializations in two ways: (1) The function that
###		they are defined is in immaterial; (2) The set of global initializations is the same for every test
###		case.
###  @remark	Set by the @ref clut_global_initialize function.
###
#----------------------------------------------------------------------------------------------------------------------

declare       __ClutGlobalPriorizerList=

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutGlobalRequirementCount
###  @brief	Hold the number of values that are stored in the __ClutGlobalRequirementStatement array.
###  @remark	Incremented by the @ref clut_global_requirement function.
###
#----------------------------------------------------------------------------------------------------------------------

declare    -i __ClutGlobalRequirementCount=0	# Easier than dealing with unbound __ClutGlobalRequirementStatement.

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutGlobalRequirementExercised
###  @brief	Describes how the current test case exercises a requirement; __ClutGlobalRequirementExercised[R]=M
###		when the current test case exercises requirement R using test method M.
###  @remark	Set by the @ref clut_case_requirement function.
###
#----------------------------------------------------------------------------------------------------------------------

declare    -A __ClutGlobalRequirementExercised

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutGlobalRequirementSortOrder
###  @brief	Maintains the order in which the user defined requirements so that they can be reported in the same
###		order.
###  @remark	Set by the @ref clut_global_requirement function.
###
#----------------------------------------------------------------------------------------------------------------------

declare    -a __ClutGlobalRequirementSortOrder

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutGlobalRequirementStatement
###  @brief	Accumulates a set of requirements that should be exercised by test cases.
###  @remark	Set by the @ref clut_global_requirement function.
###
#----------------------------------------------------------------------------------------------------------------------

declare    -A __ClutGlobalRequirementStatement

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutOutputFormatVersion
###  @brief	An integer that represents the number of times the output format has been changed in this script since
###		that last time the major format version number was updated in the clutr.bash file. Increasing this
###		number will invalidate baseline output files that were generated prior to the change.
###
#----------------------------------------------------------------------------------------------------------------------

declare -r -i __ClutOutputFormatVersion=3

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutResultFSpec
###  @brief	Holds the specification for the file that this script should produce; the compiled CLUT definitions.
###		The value may be passed in as the second argument to this script.
###  @remark	Set through a call to the __evaluateScriptArguments function.
###
#----------------------------------------------------------------------------------------------------------------------

declare       __ClutResultFSpec

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutSharedFinalizerList
###  @brief	Accumulates finalization commands that are issued after calls to the CLU program that is to be tested.
###  @details	Shared finalization commands differ from global finalizations in two ways: (1) Their scope is limited
###		to the function in which they are defined; (2) The collection grows based on their position within that
###		function.
###  @remark	Set by the @ref clut_shared_finalize function.
###
#----------------------------------------------------------------------------------------------------------------------

declare       __ClutSharedFinalizerList=

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutSharedPriorizerList
###  @brief	Accumulates initialization commands that are issued prior to calls to the CLU program that is to be
###		tested.
###  @details	Shared initialization commands differ from global initializations in two ways: (1) Their scope is
###		limited to the function in which they are defined; (2) The collection grows based on their position
###		within that function.
###  @remark	Set by the @ref clut_shared_initialize function.
###
#----------------------------------------------------------------------------------------------------------------------

declare       __ClutSharedPriorizerList=

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutSourceFSpec
###  @brief	Holds the specification for the file that contains CLUT case definitions. The value is passed in as the
###		first argument to this script.
###  @remark	Set through a call to the __evaluateScriptArguments function.
###
#----------------------------------------------------------------------------------------------------------------------

declare       __ClutSourceFSpec

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutTargetFSpec
###  @brief	Holds the specification for the CLU program/script that is to be tested. The value is based on the name
###		of the __ClutSourceFSpec.
###  @remark	Set through a call to the __evaluateScriptArguments function.
###
#----------------------------------------------------------------------------------------------------------------------

declare       __ClutTargetFSpec

#----------------------------------------------------------------------------------------------------------------------
###
###  @private	This is not for external use.
###  @var	__ClutCaseVariableNameList
###  @brief	Holds a list of variables that must be initialized to the empty string as each new case is defined.
###  @remark	Used by the @ref clut_case_begin and @ref clut_case_disable functions.
###
#----------------------------------------------------------------------------------------------------------------------

declare       __ClutCaseVariableNameList=

__ClutCaseVariableNameList+=" __ClutCaseCommentList"
__ClutCaseVariableNameList+=" __ClutCaseDisabledReason"
__ClutCaseVariableNameList+=" __ClutCaseParameterList"
__ClutCaseVariableNameList+=" __ClutCaseFinalizerList"
__ClutCaseVariableNameList+=" __ClutCasePriorizerList"
__ClutCaseVariableNameList+=" __ClutCaseRequirementList"
__ClutCaseVariableNameList+=" __ClutCaseStdinSourceFName"

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_case_begin
###  @param	Name	The name of the new test case.
###  @brief	Start a new test case definition and name it as specified
###  @details	The clut_case_begin function is used to start and name a test case definition. Terminating errors are
###		raised if the given name describes an existing test case.
###
###  @code
###		clut_case_begin	"No Parameters Given"
###		clut_case_end
###  @endcode
###
#----------------------------------------------------------------------------------------------------------------------

function clut_case_begin() {
  #
  __ClutCaseName=${*}
  #
  if [ ${#__ClutCaseName} -eq 0 ]
  then
     #
     echoErrorAndExit 1 "${FUNCNAME} must be provided a test case name."
     #
  fi
  #
  local -r ClutCaseIndexFormal=$(${__ClutCaseIndexOutputFormat} ${__ClutCaseIndex})
  #
  local -r ClutCaseFSpec=${__ClutWorkinDSpec}/${ClutCaseIndexFormal}.bash
  #
  if [ -s ${ClutCaseFSpec} ]
  then
     #
     echoErrorAndExit 1 "Missing call to clut_case_end detected prior to ${FUNCNAME} ${__ClutCaseName}."
     #
  fi
  #
  spit ${ClutCaseFSpec} "function clutCaseRunTimeForTestCase${ClutCaseIndexFormal}() {"
  spit ${ClutCaseFSpec} "  #"
  spit ${ClutCaseFSpec} "  local -r CluInstrumentation=\"\${*} \""
  spit ${ClutCaseFSpec} "  #"
  spit ${ClutCaseFSpec} "  clutCaseRunTimeDescribeStart ${__ClutCaseIndex} \"${__ClutCaseName}\""
  #
  #  Make sure that the name is unique.
  #
  local -r    ClutCaseNameListFSpec=${__ClutWorkinDSpec}/$(${__ClutCaseIndexOutputFormat} 0).namelist.text
  #
  touch ${ClutCaseNameListFSpec}
  #
  local -r -i NameReuseCount=$(grep --count "^${__ClutCaseName}$" ${ClutCaseNameListFSpec})
  #
  if [ ${NameReuseCount} -gt 0 ]
  then
     #
     local ErrorMessage="The '${__ClutCaseName}' name is used to identify "
     #
     if [ ${NameReuseCount} -eq 1 ]
     then
	#
	ErrorMessage+="another test case.\""
	#
     else
	#
	ErrorMessage+="${NameReuseCount} other test cases.\""
	#
     fi
     #
     echoErrorAndExit 1 "${ErrorMessage}"
     #
  fi
  #
  spit ${ClutCaseNameListFSpec} "${__ClutCaseName}"
  #
  [ ${#} -eq 0 ] && __ClutCaseName=
  #
  #  Initialize the accumulator variables.
  #
  local VariableName
  #
  for VariableName in ${__ClutCaseVariableNameList}
  do
    #
    eval ${VariableName}=
    #
  done
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_case_comment
###  @param	Comment	The textual comment to be added.
###  @brief	Adds a comment to the test case being defined.
###  @details	The user may call the clut_case_comment function to add a comment to the test case being defined.
###		Subsequent comments are appended to those that precede them.  Comments are reported just after the test
###		case name in a CLUT output report.
###
###  @code
###		clut_case_begin		"No Parameters Given"
###		clut_case_comment	"Illustrate what happened with the program is called without any parameters."
###		clut_case_end
###  @endcode
###
#----------------------------------------------------------------------------------------------------------------------

function clut_case_comment() {
  #
  [ ${#__ClutCaseDisabledReason} -gt 0 ] && return
  #
  __ClutCaseCommentList+=" ${*}"
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_case_disable
###  @param	Comment	A comment that describes why the test case has been disabled.
###  @brief	Disables the test case being defined.
###  @details	The user may disable a test case by calling the clut_case_disable function. Test cases are disabled for
###		two main reasons: (1) The test case is already established (the numbering is test) in the baseline
###		output file, but the functionality that it exercises is no longer needed; (2) The test case output is
###		overly verbose, that verbosity does not necessarily prove anything, and/or the output cannot be
###		appropriately masked without a disproportionate amount of effort to reward.
###
###		The clut_case_disable
###		function must be used as soon as the test case is named so that subsequent function calls that define
###		the case can be ignored.
###
###  Given the CLUT case:
###
###  @code
###		clut_case_name        DoItNow_Nominal
###		clut_case_disable     Disabled: The DoItNow function is no longer defined.
###		clut_case_initialize  spit DATA.text This is stuff that will be done now.
###		clut_case_parameter   DATA.text
###		clut_case_end
###  @endcode
###
###  Resulting CLUT report:
###
###  @code
###		5. DoItNow_Nominal.
###		    |Disabled: The DoItNow function is no longer defined.
###		5.1. Requirements.
###		5.2. Initializations.
###		5.3. Target CLU Call.
###		5.4. Finalizations.
###  @endcode
###
###  Disabling a test case has advantages over removing one: The biggest advantage is that the case is still
###  represented in the CLUT report; subsequent cases will retain their previous numbers, and the report remains
###  comparable to past versions.  Another advantage is that the case can remain defined and can be enabled easily.
###
#----------------------------------------------------------------------------------------------------------------------

function clut_case_disable() {
  #
  local -r Comment=${*}
  #
  if [ ${#Comment} -eq 0 ]
  then
     #
     if [ ${#__ClutCaseDisabledReason} -eq 0 ]
     then
        #
        echoErrorAndExit 1 "${FUNCNAME} must be provided a comment that describes why the case was disabled."
        #
     else
        #
        return
        #
     fi
     #
  fi
  #
  local VariableValu=
  #
  local VariableName
  #
  for VariableName in ${__ClutCaseVariableNameList}
  do
    #
    eval VariableValu+="\${${VariableName}}"
    #
  done
  #
  if [ "${VariableValu}" = "${__ClutCaseDisabledReason}" ]
  then
     #
     __ClutCaseDisabledReason+=" ${*}"
     #
  else
     #
     echoErrorAndExit 2 "${FUNCNAME} must be used as soon as the case is named (${VariableValu})."
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_case_end
###  @brief	Complete the current test case definition.
###  @details	The clut_case_end function signals the end of the current test case, allowing the compiler to generate
###		Bash code that represents the case.
###
###  @code
###		clut_case_begin	"No Parameters Given"
###		clut_case_end
###  @endcode
###
#----------------------------------------------------------------------------------------------------------------------

function clut_case_end() {
  #
  local -r ClutCaseIndexFormal=$(${__ClutCaseIndexOutputFormat} ${__ClutCaseIndex})
  #
  local -r ClutCaseFSpec=${__ClutWorkinDSpec}/${ClutCaseIndexFormal}.bash
  #
  local -r AlphaDName=${ClutCaseIndexFormal}.Alpha
  local -r OmegaDName=${ClutCaseIndexFormal}.Omega
  #
  local -r WorkspaceDName=${ClutCaseIndexFormal}.Working
  #
  #  Test cases may be disabled or active...
  #
  if [ ${#__ClutCaseDisabledReason} -gt 0 ]
  then
     #
     #  Handle disabled test cases.
     #
     spit ${ClutCaseFSpec} "  #"
     #
     __clutCaseCompileTimeSpitPrettyPrefix ${ClutCaseFSpec} "  clutCaseRunTimeParagraph" "${__ClutCaseDisabledReason}"
     #
     spit ${ClutCaseFSpec} "  #"
     spit ${ClutCaseFSpec} "  clutCaseRunTimeReport 1 Requirements."
     spit ${ClutCaseFSpec} "  clutCaseRunTimeReport 1 Initializations."
     spit ${ClutCaseFSpec} "  clutCaseRunTimeReport 1 Target CLU Call."
     spit ${ClutCaseFSpec} "  clutCaseRunTimeReport 1 Finalizations."
     spit ${ClutCaseFSpec} "  #"
     spit ${ClutCaseFSpec} "}"
     #
  else
     #
     #  Handle active test cases...
     #
     #
     if [ ${#__ClutCaseCommentList} -gt 0 ]
     then
        #
        spit ${ClutCaseFSpec} "  #"
        #
        __clutCaseCompileTimeSpitPrettyPrefix ${ClutCaseFSpec} "  clutCaseRunTimeParagraph" "${__ClutCaseCommentList}"
        #
     fi
     #
     spit ${ClutCaseFSpec} "  #"
     spit ${ClutCaseFSpec} "  clutCaseRunTimeReport 1 Requirements."
     spit ${ClutCaseFSpec} "  #"
     #
     if [ ${#__ClutCaseRequirementList} -eq 0 ]
     then
        #
        spit ${ClutCaseFSpec} "  clutCaseRunTimeParagraph None."
        #
     else
        #
        __clutCaseCompileTimeSpitPrettyPrefix		\
		   ${ClutCaseFSpec} "  clutCaseRunTimeParagraph" "${__ClutCaseRequirementList:2}"
        #
     fi
     #
     spit ${ClutCaseFSpec} "  #"
     spit ${ClutCaseFSpec} "  mkdir ${WorkspaceDName}"
     spit ${ClutCaseFSpec} "  #"
     spit ${ClutCaseFSpec} "  cd ${WorkspaceDName}"
     spit ${ClutCaseFSpec} "     #"
     spit ${ClutCaseFSpec} "     clutCaseRunTimeReport 1 Initializations."
     spit ${ClutCaseFSpec} "     #"
     spit ${ClutCaseFSpec} "     clutFileRunTimeGlobalInitializations"
     #
     __clutCaseCompileTimeListExpansion "clutCaseRunTimeInitialization" "     "					\
					${ClutCaseFSpec} "${__ClutSharedPriorizerList}"
     #
     __clutCaseCompileTimeListExpansion "clutCaseRunTimeInitialization" "     "					\
					${ClutCaseFSpec} "${__ClutCasePriorizerList}"
     #
     spit ${ClutCaseFSpec} "     #"
     spit ${ClutCaseFSpec} "  cd .."
     spit ${ClutCaseFSpec} "  #"
     spit ${ClutCaseFSpec} "  cp --archive ${WorkspaceDName} ${AlphaDName}"
     spit ${ClutCaseFSpec} "  #"
     spit ${ClutCaseFSpec} "  clutFileRunTimeMaskFilesInDirectory ${AlphaDName}"
     spit ${ClutCaseFSpec} "  #"
     spit ${ClutCaseFSpec} "  clutCaseRunTimeDump 1 ${AlphaDName} 'Initial Workspace'"
     spit ${ClutCaseFSpec} "  #"
     spit ${ClutCaseFSpec} "  cd ${WorkspaceDName}"
     spit ${ClutCaseFSpec} "     #"
     spit ${ClutCaseFSpec} "     clutCaseRunTimeReport 1 Target CLU Call."
     spit ${ClutCaseFSpec} "     #"
     #
     __clutCaseCompileTimeSpitPrettyPrefix ${ClutCaseFSpec}							   \
					   "     clutCaseRunTimeUtilityExecute \"${__ClutCaseStdinSourceFName}\""  \
					   "\${CluInstrumentation}${__ClutTargetFName}${__ClutCaseParameterList}"
     #
     spit ${ClutCaseFSpec} "     #"
     spit ${ClutCaseFSpec} "     clutCaseRunTimeReport 1 Finalizations."
     #
     __clutCaseCompileTimeListExpansion "clutCaseRunTimeFinalization" "     "					\
					${ClutCaseFSpec} "${__ClutCaseFinalizerList}"
     #
     __clutCaseCompileTimeListExpansion "clutCaseRunTimeFinalization" "     "					\
					${ClutCaseFSpec} "${__ClutSharedFinalizerList}"
     #
     spit ${ClutCaseFSpec} "     #"
     spit ${ClutCaseFSpec} "     clutFileRunTimeGlobalFinalizations"
     spit ${ClutCaseFSpec} "     #"
     spit ${ClutCaseFSpec} "  cd .."
     spit ${ClutCaseFSpec} "  #"
     spit ${ClutCaseFSpec} "  mv ${WorkspaceDName} ${OmegaDName}"
     spit ${ClutCaseFSpec} "  #"
     spit ${ClutCaseFSpec} "  clutFileRunTimeMaskFilesInDirectory ${OmegaDName}"
     spit ${ClutCaseFSpec} "  #"
     spit ${ClutCaseFSpec} "  clutCaseRunTimeCompare ${AlphaDName} ${OmegaDName}"
     spit ${ClutCaseFSpec} "  #"
     spit ${ClutCaseFSpec} "  clutCaseRunTimeDescribeEnd ${*}"
     spit ${ClutCaseFSpec} "  #"
     spit ${ClutCaseFSpec} "}"
     #
  fi
  #
  __ClutCaseIndex+=1
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_case_ended
###  @brief	Synonym for @ref clut_case_end.
###
#----------------------------------------------------------------------------------------------------------------------

function clut_case_ended() { clut_case_end ${*}; }

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_case_finalize
###  @param	Command	The command and arguments to be used for finalization.
###  @brief	Use the given command to finalize the test case workspace.
###
###  @details	The clut_case_finalize function is used to request that the given command be applied just after the CLU
###		program is called.  Finalization commands are often calls to a locally defined Bash functions.
###
###  @code
###		function removeSideEffectOutputFiles() {
###		   #
###		   rm --force *.temp *was
###		   #
###		}
###
###		function whatever() {
###		   #
###		   clut_case_begin         "Nominal"
###		   clut_case_finalize	   md5sum OUTPUT.db
###		   clut_case_finalize      removeSideEffectOutputFiles
###		   clut_case_end
###		   #
###		}
###  @endcode
###
#----------------------------------------------------------------------------------------------------------------------

function clut_case_finalize() {
  #
  [ ${#__ClutCaseDisabledReason} -gt 0 ] && return
  #
  __ClutCaseFinalizerList="${__ClutCaseFinalizerList}; ${*}"
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_case_finalizer
###  @param	Command	The command and arguments to be used for finalization of the current test case.
###  @brief	Synonym for @ref clut_case_finalize.
###
#----------------------------------------------------------------------------------------------------------------------

function clut_case_finalizer() { clut_case_finalize ${*}; }
 
#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_case_initialize
###  @param	Command	The command and arguments to be used for initialization of the current test case.
###  @brief	Use the given command to initialize the test case workspace.
###
###  @details	The clut_case_initialize function is used to request that the given command be applied just before the
###		CLU program is called. Initialization commands are often calls to a locally defined Bash functions.
###
###  @code
###		function generateInputData() {
###		   #
###		   local FileSpecification=${1}
###		   #
###		   echo "This is the first line of data."  >  ${FileSpecification}
###		   echo "This is the second line of data." >> ${FileSpecification}
###		   #
###		}
###
###		function whatever() {
###		   #
###		   clut_case_begin         "EasyInput"
###		   clut_case_initialize    generateInputData INPUT.text
###		   clut_case_parameter     --input=INPUT.text
###		   clut_case_end
###		   #
###		}
###  @endcode
###
#----------------------------------------------------------------------------------------------------------------------

function clut_case_initialize() {
  #
  [ ${#__ClutCaseDisabledReason} -gt 0 ] && return
  #
  __ClutCasePriorizerList="${__ClutCasePriorizerList}; ${*}"
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_case_initializer
###  @param	Command	The command and arguments to be used for initialization of the current test case.
###  @brief	Synonym for @ref clut_case_initialize.
###
#----------------------------------------------------------------------------------------------------------------------

function clut_case_initializer() { clut_case_initialize ${*}; }
 
#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_case_name
###  @param	Name	The name of the new test case.
###  @brief	Synonym for @ref clut_case_begin.
###
#----------------------------------------------------------------------------------------------------------------------

function clut_case_name() { clut_case_begin ${*}; }

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_case_parameter
###  @param	Text	Information passed into the CLU as a parameter.
###  @brief	Pass the given text as a parameter to the CLU program.
###
###  @details	The clut_case_parameter function is used to define the parameters that a specific test case pass into
###		the CLU program.
###
###  @code
###		clut_case_begin         "Both Input And Output Specified"
###		clut_case_parameter     --input=INPUT.text
###		clut_case_parameter     --output=OUTPUT.text
###		clut_case_parameter     --verbose
###		clut_case_end
###  @endcode
###
#----------------------------------------------------------------------------------------------------------------------

function clut_case_parameter() {
  #
  [ ${#__ClutCaseDisabledReason} -gt 0 ] && return
  #
  __ClutCaseParameterList="${__ClutCaseParameterList} ${*}"
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_case_purpose
###  @param	Comment	The textual comment to be added to the text case.
###  @brief	Synonym for @ref clut_case_comment.
###
#----------------------------------------------------------------------------------------------------------------------

function clut_case_purpose() { clut_case_comment ${*}; }

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_case_requirement
###  @param	Identifier	The user-defined requirement identifier.
###  @param	Description	A description of how this test case exercises the requirement.
###  @brief	Allows the user to describe how the current test case exercises a specific requirement.
###
###  @details	The clut_case_requirement function allows the user to tag a test case as one that exercises the
###		requirement. The requirement Identifier must match one defined using the @ref clut_global_requirement
###		function.  The Description may be a simple testing type identifier (e.g. Positive, Negative, Sunny Day,
###		Rainy Day) or a more detailed statement.
### 
###  @code
###		clut_global_requirement  ABCD-Input-0010 "The program must require the user to specify an input file."
###		clut_global_requirement  ABCD-Input-0050 "The program must allow the user to specify an output file."
###		clut_global_requirement  ABCD-Input-0050 "All file specifications provided by the user must be unique."
###  @endcode
###  @code
###		clut_case_begin         "InputEqualsOutput"
###		clut_case_requirement	ABCD-Input-0010 Nominal
###		clut_case_requirement	ABCD-Input-0020 Nominal
###		clut_case_requirement	ABCD-Input-0050 Contrary
###		clut_case_parameter     --input=INPUT.text
###		clut_case_parameter     --output=INPUT.text
###		clut_case_parameter     --verbose
###		clut_case_end
###  @endcode
###
###  The calls to @ref clut_global_requirement above result in report section 0.1 below.
###  The calls to @ref clut_case_requirement above result in report section 20.1 and subsections 0.2.1.1, 0.2.2.1, and
###  0.2.3.1 below.
###
###  @code
###		0. Global Information
###		0.1. Notations
###		0.2. Requirement Statements
###		0.2.1. ABCD-Input-0010
###		    |The program must require the user to specify an input file.
###		0.2.2. ABCD-Input-0020
###		    |The program must allow the user to specify an output file.
###		0.2.3. ABCD-Input-0050
###		    |All file specifications provided by the user must be unique.
###		0.2. Requirement Coverage
###		0.2.1. ABCD-Input-0010
###		0.2.1.1. Case 20 InputEqualsOutput: Nominal
###		0.2.2. ABCD-Input-0020
###		0.2.2.1. Case 20 InputEqualsOutput: Nominal
###		0.2.3. ABCD-Input-0050
###		0.2.3.1. Case 20 InputEqualsOutput: Contrary
###		...
###		20. InputEqualsOutput.
###		20.1. Requirements.
###		    |ABCD-Input-0010 Nominal; ABCD-Input-0020 Nominal; ABCD-Input-0050 Contrary
###		20.2. Initializations.
###		...
###  @endcode
###
#----------------------------------------------------------------------------------------------------------------------

function clut_case_requirement() {
  #
  local Identifier=${1}
  shift 1
  local Description="${*}"
  #
  [ ${#__ClutCaseDisabledReason} -gt 0 ] && return
  #
  if [ -z "${__ClutGlobalRequirementStatement[${Identifier}]+IS_SET}" ]
  then
     #
     echoErrorAndExit 1 "${FUNCNAME} given requirement number '${Identifier}' that has not been defined."
     #
  else
     #
     __ClutCaseRequirementList+="; ${Identifier} ${Description}"
     #
#    local Statement="clutCaseRunTimeReport 3 Case ${__ClutCaseIndex}"
     #
     local Statement="clutCaseRunTimeReport 3"
     #
     [ ${#__ClutCaseName} -gt 0 ] && Statement+=" ${__ClutCaseName}"
     #
     Statement+=": ${Description}"
     #
     __ClutGlobalRequirementExercised["${Identifier}"]+="; ${Statement}"
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_case_start
###  @param	Name	The name of the new test case.
###  @brief	Synonym for @ref clut_case_begin.
###
#----------------------------------------------------------------------------------------------------------------------

function clut_case_start() { clut_case_begin ${*}; }

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_case_stdin_source
###  @param	File	The specification for a file that contains input data.
###  @brief	Allows the user to request data in the specified File be passed into the CLU via standard input.
###
###  @details	The clut_case_stdin_source parameter can be used to
###		request the framework to pass the contents of a specific file into the CLU program as standard input.
###
###  @code
###		clut_case_begin         "No Parameters Given But Normative Data on Stdin"
###		clut_case_initialize    createNormativeData TO_BE_STDIN.text
###		clut_case_stdin_source  TO_BE_STDIN.text
###		clut_case_end
###  @endcode
###
#----------------------------------------------------------------------------------------------------------------------

function clut_case_stdin_source() {
  #
  [ ${#__ClutCaseDisabledReason} -gt 0 ] && return
  #
  __ClutCaseStdinSourceFName=$(basename ${*})
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_global_comparison_mask
###  @param	SedExpression	A sed command expression (e.g. s/target/replacement/g).
###  @brief	Adds the SedExpression to the set of comparison masks to be applied to every test workspace.
###
###  @details	The clut_global_comparison_mask function requests that the given *sed* expression be used to modify the
###		contents of every test case workspace. Comparison masks are applied as the final step of workspace
###		initialization and finalization. They are also applied to output written to standard output (stdout)
###		and standard error (stderr).
###
###  @code
###		clut_global_comparison_mask     's,[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\},YYYY-MM-DD,g'
###		clut_global_comparison_mask     's,[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\},HH:MM:SS,g'
###		clut_global_comparison_mask     "s,${HOME},\$HOME,g"
###  @endcode
###
#----------------------------------------------------------------------------------------------------------------------

function clut_global_comparison_mask() {
  #
  __ClutGlobalCompareMaskList+=" --expression='${*}'"
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_global_dump_format
###  @param	Extension	A file name extension.
###  @param	Function	A function that may be used to display information about a file.
###  @brief	Allows the user to define (or re-define) the dump Function associated with files whose names use the
###		given Extension.
###
###  @details	The clut_global_dump_format function is used to register dump function with the framework.
###		The dump function will be used to dump data files that have the specified file name extension.
###		The function registered should take the name of the file to be dumped as it only positional parameter.
###
###  @code
###	function dumpPdfAsText() {
###	
###	   local -r TargetFSpec="${1}"
###	
###	   pdftotext "${TargetFSpec}" - | sed --expression='s,^,    |,'
###	
###	}
###	
###	function whatever() {
###	
###	   clut_global_dump_format PDF dumpPdfAsText
###
###	}
###  @endcode
###
#----------------------------------------------------------------------------------------------------------------------

function clut_global_dump_format() { __ClutGlobalDumpFormatList+="; ${*}"; }

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_global_finalize
###  @param	Command	The command and arguments to be used for finalization.
###  @brief	Use the given command to finalize the workspace of every test case.
###
###  @details	The clut_case_finalize function is used to request that the given command be applied just after the CLU
###		program is called to the workspace of every test case.  Finalization commands are often calls to a
###		locally defined Bash functions.
###
###		Global finalizations are performed after case-specific and shared finalizations, if any.
###
###  @code
###		function reportCountOfFileType() {
###		  #
###		  local -r FileType=${1}
###		  #
###		  local -r -i Count=$(find . -name "*.${FileType}" | wc --lines)
###		  #
###		  echo "The workspace contains ${Count} ${FileType} files."
###		  #
###		}
###
###		function whatever() {
###		  #
###		  clut_global_finalize  reportCountOfFileType gif
###		  clut_global_finalize  reportCountOfFileType jpeg
###		  #
###		}
###  @endcode
###
#----------------------------------------------------------------------------------------------------------------------

function clut_global_finalize() {
  #
  __ClutGlobalFinalizerList="${__ClutGlobalFinalizerList}; ${*}"
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_global_finalizer
###  @param	Command	The command and arguments to be used for finalization.
###  @brief	Synonym for @ref clut_global_finalize.
###
#----------------------------------------------------------------------------------------------------------------------

function clut_global_finalizer() { clut_global_finalize ${*}; }
 
#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_global_initialize
###  @param	Command	The command and arguments to be used for initialization.
###  @brief	Use the given command to initialize the workspace of every test case.
###
###  @details	The clut_case_initialize function is used to request that the given command be applied before the CLU
###		program is called to the workspace of every test case.  Initialization commands are often calls to a
###		locally defined Bash functions.
###
###		Global initializations are performed before shared and case-specific initializations, if any.
###
###  @code
###		function createConfigurationFile() {
###		  #
###		  local -r FileSpecification=${1}
###		  #
###		  echo "VERBOSE = FALSE"	>  ${FileSpecification}
###		  echo "LANG=en_US.UTF-8"	>> ${FileSpecification}
###		  #
###		}
###
###		function whatever() {
###		  #
###		  clut_global_initialize  createConfigurationFile .program.conf
###		  #
###		}
###  @endcode
###
#----------------------------------------------------------------------------------------------------------------------

function clut_global_initialize() {
  #
  __ClutGlobalPriorizerList="${__ClutGlobalPriorizerList}; ${*}"
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_global_initializer
###  @param	Command	The command and arguments to be used for initialization.
###  @brief	Synonym for @ref clut_global_initialize.
###
#----------------------------------------------------------------------------------------------------------------------

function clut_global_initializer() { clut_global_initialize ${*}; }

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_global_notation
###  @param	Title		The user-defined notation title.
###  @param	Paragraph	The user-defined notation paragraph.
###  @brief	Allows the user to define a notation that will appear in the global information section.
###
###  @remark	This function may be called more than once for the same title. For a primary and secondary call,
###		an error will be raised if the secondary paragraph does not match the primary paragraph when the
###		primary and secondary titles match.
###
###  @details	The clut_global_notation function allows the user to define a notation that applies to the entire test
###		set.
### 
###  @code
###		clut_global_notation	"Exception Test Method"							\
###					"An exception test method is one that causes the program to crash."
###  @endcode
###
###  Notations are reported in the Global Information section of a CLUT report:
###
###  @code
###		0. Global Information
###		0.1. Notations
###		0.1.1. Exception Test Method
###		    |An exception test method is one that causes the program to crash.
###		0.1.2. ...
###  @endcode
###
#----------------------------------------------------------------------------------------------------------------------

function clut_global_notation() {
  #
  local -r Title=${1-}
  shift 1
  local -r Paragraph=${*}
  #
  if [ ${#Title} -eq 0 ]
  then
     #
     echoErrorAndExit 1 "${FUNCNAME} used without <title> and <description> information."
     #
  elif [ ${#Paragraph} -eq 0 ]
  then
     #
     echoErrorAndExit 2 "${FUNCNAME} with <title> of '${Title}' has no <description> information."
     #
  fi
  #
  local -r Spaceless=${Title// /&nbsp;}
  #
  if [ ! -z "${__ClutGlobalNotation[${Spaceless}]+IS_SET}" ]
  then
     #
     if [ "${__ClutGlobalNotation[${Spaceless}]}" != "${Paragraph}" ]
     then
        #
        echo "INFO: Old description is '${__ClutGlobalNotation[${Spaceless}]:0:99}'" 1>&2
        echo "INFO: New description is '${Paragraph:0:99}'" 1>&2
        echoErrorAndExit 3 "Attempt to redefine notation '${Title}' using ${FUNCNAME}."
        #
     fi
     #
  else
     #
     __ClutGlobalNotation["${Spaceless}"]="${Paragraph}"
     #
     __ClutGlobalNotationCount+=1
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_global_requirement
###  @param	Identifier	The user-defined requirement identifier.
###  @param	Description	A description of the requirement.
###  @brief	Allows the user to define a requirement that can be cited by test cases later.
###
###  @remark	This function may be called more than once for the same identifier.  For a primary and secondary call,
###		an error will be raised if the secondary description does not match the primary description when the
###		primary and secondary identifiers match.
###
###  @details	The clut_global_requirement function allows the user to define a requirement; associate an Identifier
###		with a Description.  The user may refer to defined requirement identifiers using the @ref
###		clut_case_requirement function.
###		Error conditions are raised if the given Identifier is already associated with a Description.
### 
###  @code
###		clut_global_requirement    ABCD-0030                                                 \
###		                          "When the program is invoked,"                             \
###		                        "\nThen it will draw seven red lines,"                       \
###		                        "\nAnd all of them will be strictly perpendicular,"          \
###		                        "\nAnd some of them will be drawn with green ink,"           \
###		                        "\nAnd some of them will be drawn with transparent ink."
###  @endcode
###
###  Requirement definitions are reported in the Global Information section of a CLUT report:
###
###  @code
###		0. Global Information
###		0.1. Notations
###		0.2. Requirement Statements
###		0.2.1. ABCD-0030
###		    |When the program is invoked,
###		    |Then it will draw seven red lines,
###		    |And all of them will be strictly perpendicular,
###		    |And some of them will be drawn with green ink,
###		    |And some of them will be drawn with transparent ink.
###		0.2.2. ...
###  @endcode
###
#----------------------------------------------------------------------------------------------------------------------

function clut_global_requirement() {
  #
  local -r Identifier=${1-}
  shift 1
  local -r Description=${*}
  #
  if [ ${#Identifier} -eq 0 ]
  then
     #
     echoErrorAndExit 1 "${FUNCNAME} used without <identifier> and <description> information."
     #
  elif [ ${#Description} -eq 0 ]
  then
     #
     echoErrorAndExit 2 "${FUNCNAME} with <identifier> of '${Identifier}' has no <description> information."
     #
  elif [ ! -z "${__ClutGlobalRequirementStatement[${Identifier}]+IS_SET}" ]
  then
     #
     if [ "${__ClutGlobalRequirementStatement[${Identifier}]}" != "${Description}" ]
     then
        #
        echo "INFO: Old description is '${__ClutGlobalRequirementStatement[${Identifier}]:0:99}'" 1>&2
        echo "INFO: New description is '${Description:0:99}'" 1>&2
        echoErrorAndExit 3 "Attempt to redefine requirement '${Identifier}' using ${FUNCNAME}."
        #
     fi
     #
  else
     #
     __ClutGlobalRequirementStatement["${Identifier}"]="${Description}"
     #
     __ClutGlobalRequirementSortOrder+=("${Identifier}")
     #
     __ClutGlobalRequirementExercised["${Identifier}"]=
     #
     __ClutGlobalRequirementCount+=1
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_shared_finalize
###  @param	Command	The command and arguments to be used for finalization.
###  @brief	Use the given command to finalize the workspace of every test case that follows this statement in the
###		current definition function.
###
###  @details	The clut_shared_finalize function is used to request that the given command be applied:
###		* To the Omega version of a test case workspace (i.e. after the CLU is called);
###		* After all case-specific finalization commands have been executed;
###		* After shared finalizations that were defined in the same test case definition function before it;
###		* Before all global finalizations.
###
###		Shared finalizations have a scope that is limited to the test case definition function that they are
###		defined in, and are only applied to cases that are defined after they are. For example, in a test case
###		definition function that contains:
###		* case Alpha
###		* shared finalization Beta
###		* case Gamma
###		* shared finalization Delta
###		* case Epsilon
###
###		The following apply:
###		* No shared finalizations will be applied to case Alpha;
###		* Beta will be applied to case Gamma;
###		* Beta and Delta will be applied to case Epsilon in that order.
###		* Beta and Delta will have no effect on cases defined in other test case definition functions.
###
###  @code
###		function reportCountOfFileType() {
###		  #
###		  local -r FileType=${1}
###		  #
###		  local -r -i Count=$(find . -name "*.${FileType}" | wc --lines)
###		  #
###		  echo "The workspace contains ${Count} ${FileType} files."
###		  #
###		}
###
###		function gifConversionTests() {
###		  #
###		  clut_case_begin         Convert PNG To GIF File Target
###		  clut_case_initialize	  makeDataFileNotShown INPUT.png
###		  clut_case_parameter     --input:file=INPUT.png
###		  clut_case_end
###		  #
###		  clut_shared_initialize  makeDataDirectoryNotShown INPUT-1
###		  #
###		  clut_shared_finalize    reportCountOfFileType PNG
###		  clut_shared_finalize    reportCountOfFileType GIF
###		  #
###		  clut_case_begin         Convert PNG To GIF Single Directory Target
###		  clut_case_initialize	  makeDataDirectoryNotShown INPUT-1
###		  clut_case_parameter     --input:directory=INPUT
###		  clut_case_end
###		  #
###		  clut_shared_initialize  makeDataDirectoryNotShown INPUT-2
###		  #
###		  clut_case_begin         Convert PNG To GIF Multiple Directory Target
###		  clut_case_parameter     --input:directory:1=INPUT-1
###		  clut_case_parameter     --input:directory:2=INPUT-2
###		  clut_case_end
###		  #
###		}
###  @endcode
###
#----------------------------------------------------------------------------------------------------------------------

function clut_shared_finalize() {
  #
  __ClutSharedFinalizerList="${__ClutSharedFinalizerList}; ${*}"
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_shared_finalizer
###  @param	Command	The command and arguments to be used for initialization.
###  @brief	Synonym for @ref clut_shared_finalize.
###
#----------------------------------------------------------------------------------------------------------------------

function clut_shared_finalizer() { clut_shared_finalize ${*}; }
 
#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_shared_initialize
###  @param	Command	The command and arguments to be used for initialization.
###  @brief	Use the given command to initialize the workspace of every test case that follows this statement in the
###		current definition function.
###
###  @details	The clut_shared_initialize function is used to request that the given command be applied:
###		* To the Alpha version of a test case workspace (i.e. before the CLU is called);
###		* After all global initializations.
###		* After shared initializations that were defined in the same test case definition function before it;
###		* Before all case-specific initialization commands have been executed;
###
###		Shared initializations have a scope that is limited to the test case definition function that they are
###		defined in, and are only applied to cases that are defined after they are. For example, in a test
###		case definition function that contains:
###		* case Alpha
###		* shared initialization Beta
###		* case Gamma
###		* shared initialization Delta
###		* case Epsilon
###
###		The following apply:
###		* No shared initializations will be applied to case Alpha;
###		* Beta will be applied to case Gamma;
###		* Beta and Delta will be applied to case Epsilon in that order.
###		* Beta and Delta will have no effect on cases defined in other test case definition functions.
###
###  @code
###		function makeDataDirectory() {
###		  #
###		  local -r DirectorySpecification=${1}
###		  #
###		  mkdir ${DirectorySpecification)/
###		  #
###		  :  More files created but not shown here.
###		  #
###		}
###
###		function gifConversionTests() {
###		  #
###		  clut_case_begin         Convert PNG To GIF File Target
###		  clut_case_initialize	  makeDataFileNotShown INPUT.png
###		  clut_case_parameter     --input:file=INPUT.png
###		  clut_case_end
###		  #
###		  clut_shared_initialize  makeDataDirectory INPUT-1
###		  #
###		  clut_case_begin         Convert PNG To GIF Single Directory Target
###		  clut_case_initialize	  makeDataDirectoryNotShown INPUT-1
###		  clut_case_parameter     --input:directory=INPUT
###		  clut_case_end
###		  #
###		  clut_shared_initialize  makeDataDirectory INPUT-2
###		  #
###		  clut_case_begin         Convert PNG To GIF Multiple Directory Target
###		  clut_case_parameter     --input:directory:1=INPUT-1
###		  clut_case_parameter     --input:directory:2=INPUT-2
###		  clut_case_end
###		  #
###		}
###  @endcode
###
#----------------------------------------------------------------------------------------------------------------------

function clut_shared_initialize() {
  #
  __ClutSharedPriorizerList="${__ClutSharedPriorizerList}; ${*}"
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_shared_initializer
###  @param	Command	The command and arguments to be used for initialization.
###  @brief	Synonym for @ref clut_shared_initialize.
###
#----------------------------------------------------------------------------------------------------------------------

function clut_shared_initializer() { clut_shared_initialize ${*}; }
 
#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_definition_set
###  @param	Function	The name of a function that contains test case definitions.
###  @brief	Connect a test case definition function into the framework.
###  @details	The clut_definition_set function is used to request that the framework pull test case definitions from
###		the given Function.
###
###  @code
###		function allMyTestCases() {
###		  #
###		  clut_case_begin       "No Parameters Given"
###		  clut_case_end
###		  #
###		}
###
###		clut_definition_set     allMyTestCases
###  @endcode
###
#----------------------------------------------------------------------------------------------------------------------

function clut_definition_set() {
  #
  __ClutDefinitionSet="${__ClutDefinitionSet}; __ClutSharedPriorizerList=; __ClutSharedFinalizerList=; ${*}"
  #
  __ClutCaseDefiner[${__ClutCaseIndex}]="${*}"
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clut_definitions_set
###  @param	Function	The name of a function that contains test case definitions.
###  @brief	Synonym for @ref clut_definition_set.
###
#----------------------------------------------------------------------------------------------------------------------

function clut_definitions_set() { clut_definition_set ${*}; }

#----------------------------------------------------------------------------------------------------------------------
#
#  We must determine the name of the CLUT and associated CLU before we do anything else.
#
#----------------------------------------------------------------------------------------------------------------------

source <(__evaluateScriptArguments __ClutSourceFSpec __ClutTargetFSpec __ClutResultFSpec ${__ScriptArgumentList})

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutSourceFName
###  @brief	The name portion of the @ref __ClutSourceFSpec.
###
#----------------------------------------------------------------------------------------------------------------------

declare -r __ClutSourceFName=$(basename ${__ClutSourceFSpec})

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutTargetFName
###  @brief	The name portion of the @ref __ClutTargetFSpec.
###
#----------------------------------------------------------------------------------------------------------------------

declare -r __ClutTargetFName=$(basename ${__ClutTargetFSpec})

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutWorkinDRoot
###  @brief	The root name (without a date and time stamp) of the workspace name.
###
#----------------------------------------------------------------------------------------------------------------------

declare -r __ClutWorkinDRoot=$(dirname ${__ClutResultFSpec})/${__ClutSourceFName%.*}.clutc.

#----------------------------------------------------------------------------------------------------------------------
###
###  @var	__ClutWorkinDName
###  @brief	The compile-time working directory name; the @ref __ClutWorkinDRoot with a date and time stamp.
###
#----------------------------------------------------------------------------------------------------------------------

declare -r __ClutWorkinDName=$(echoDatStampedFSpec ${__ClutWorkinDRoot})_$$

#----------------------------------------------------------------------------------------------------------------------
#
#  Create a compile-time working directory.
#
#----------------------------------------------------------------------------------------------------------------------

mkdir --parents ${__ClutWorkinDName}

#----------------------------------------------------------------------------------------------------------------------
#
#  Load the user's CLUT definitions.
#
#  The __ClutCaseIndex should increase, and files should be created in __ClutWorkinDSpec.
#
#----------------------------------------------------------------------------------------------------------------------

cd ${__ClutWorkinDName}
   #
   declare -r __ClutWorkinDSpec=${PWD}
   #
   source ${__ClutSourceFSpec}
   #
   if [ ${#__ClutDefinitionSet} -eq 0 ]
   then
      #
      echo -n "ERROR: The '${__ClutSourceFSpec}' CLUT file does not identify definitions to compile; "
      echo "it does not call the clut_definition_set function."
      #
      exit 5
      #
   fi
   #
   eval : ${__ClutDefinitionSet}
   #
cd ${__WhereWeWereDSpec}

#----------------------------------------------------------------------------------------------------------------------
#
#  Make sure the user has not redefined critical functions in their CLUT definition file (sourced above).
#
#----------------------------------------------------------------------------------------------------------------------

function __checkFunctionDeclarationLocation() {
  #
  local -r FuncName=${1}
  local -r FileName=${2}
  #
  shopt -s extdebug
  #
  local -a Declocation=($(declare -F ${FuncName}))
  #
  shopt -u extdebug
  #
  if [ "${Declocation[2]}" != "${FileName}" ]
  then
     #
     echoErrorAndExit 6 "The ${FuncName} function has been redefined within ${Declocation[2]}."
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------

__checkFunctionDeclarationLocation  spit			${__BashLibraryDSpec}/spit_spite_spitn_and_spew.bash
__checkFunctionDeclarationLocation  spite			${__BashLibraryDSpec}/spit_spite_spitn_and_spew.bash
__checkFunctionDeclarationLocation  spitn			${__BashLibraryDSpec}/spit_spite_spitn_and_spew.bash
__checkFunctionDeclarationLocation  spew			${__BashLibraryDSpec}/spit_spite_spitn_and_spew.bash
__checkFunctionDeclarationLocation  clut_case_begin		${0}
__checkFunctionDeclarationLocation  clut_case_comment		${0}
__checkFunctionDeclarationLocation  clut_case_disable		${0}
__checkFunctionDeclarationLocation  clut_case_end		${0}
__checkFunctionDeclarationLocation  clut_case_ended		${0}
__checkFunctionDeclarationLocation  clut_case_finalize		${0}
__checkFunctionDeclarationLocation  clut_case_finalizer		${0}
__checkFunctionDeclarationLocation  clut_case_initialize	${0}
__checkFunctionDeclarationLocation  clut_case_initializer	${0}
__checkFunctionDeclarationLocation  clut_case_name		${0}
__checkFunctionDeclarationLocation  clut_case_parameter		${0}
__checkFunctionDeclarationLocation  clut_case_purpose		${0}
__checkFunctionDeclarationLocation  clut_case_requirement	${0}
__checkFunctionDeclarationLocation  clut_case_start		${0}
__checkFunctionDeclarationLocation  clut_case_stdin_source	${0}
__checkFunctionDeclarationLocation  clut_definition_set		${0}
__checkFunctionDeclarationLocation  clut_definitions_set	${0}
__checkFunctionDeclarationLocation  clut_global_comparison_mask	${0}
__checkFunctionDeclarationLocation  clut_global_dump_format	${0}
__checkFunctionDeclarationLocation  clut_global_finalize	${0}
__checkFunctionDeclarationLocation  clut_global_finalizer	${0}
__checkFunctionDeclarationLocation  clut_global_initialize	${0}
__checkFunctionDeclarationLocation  clut_global_initializer	${0}
__checkFunctionDeclarationLocation  clut_global_requirement	${0}
__checkFunctionDeclarationLocation  clut_shared_finalize	${0}
__checkFunctionDeclarationLocation  clut_shared_finalizer	${0}
__checkFunctionDeclarationLocation  clut_shared_initialize	${0}
__checkFunctionDeclarationLocation  clut_shared_initializer	${0}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	__clutCompileTimeMain
###  @brief	Creates a script that can be used to execute CLUT cases.
###  @details	The __clutCompileTimeMain function finalizes the work done by the CLUT functions that were called
###		directly by the user's CLUT case definition; it creates a complete Bash script.
###
#----------------------------------------------------------------------------------------------------------------------

function __clutCompileTimeMain() {
  #
  local -r -i ClutCaseCount=$((${__ClutCaseIndex} - 1))
  #
  if [ ${ClutCaseCount} -eq 0 ]
  then
     #
     echoErrorAndExit 5 "The '${__ClutSourceFName}' CLUT file did not define any test cases."
     #
  fi
  #
  local -r ClutRunTimeFSpec=${__ClutWorkinDName}/$(${__ClutCaseIndexOutputFormat} 0).compiled.bash
  #
  local    MaskList Index Number
  #
  spit  ${ClutRunTimeFSpec} "#!/bin/bash"
  spit  ${ClutRunTimeFSpec} "#----------------------------------------------------------------------------------------"
  spit  ${ClutRunTimeFSpec} "#"
  spit  ${ClutRunTimeFSpec} "#  ${ClutRunTimeFSpec}..."
  spit  ${ClutRunTimeFSpec} "#"
  spit  ${ClutRunTimeFSpec} "#  Created by ${__ScriptFName} on $(date '+%Y-%m-%d at %H:%M:%S')."
  spit  ${ClutRunTimeFSpec} "#"
  spit  ${ClutRunTimeFSpec} "#  CLUT cases were defined in ${__ClutSourceFName}; there were ${ClutCaseCount} of them."
  spit  ${ClutRunTimeFSpec} "#"
  spit  ${ClutRunTimeFSpec} "#----------------------------------------------------------------------------------------"
  spit  ${ClutRunTimeFSpec} ""
  spit  ${ClutRunTimeFSpec} "set -u"
  spit  ${ClutRunTimeFSpec} ""
  spit  ${ClutRunTimeFSpec} "source \$(whereHolmespunLibraryBashing)/Library/echoDatStampedFSpec.bash"
  spit  ${ClutRunTimeFSpec} ""
  spit  ${ClutRunTimeFSpec} "declare -r __ScriptFName=\$(basename \${0})"
  spit  ${ClutRunTimeFSpec} ""
  spit  ${ClutRunTimeFSpec} "declare -r __ScriptArgumentList=\"\${*}\""
  spit  ${ClutRunTimeFSpec} ""
  spit  ${ClutRunTimeFSpec} "declare -r __WhereWeWereDSpec=\"\${PWD}\""
  spit  ${ClutRunTimeFSpec} ""
  spit  ${ClutRunTimeFSpec} "declare    __ClutWorkingDSpec"
  spit  ${ClutRunTimeFSpec} ""
  spit  ${ClutRunTimeFSpec} "#----------------------------------------------------------------------------------------"
  spit  ${ClutRunTimeFSpec} "#"
  spit  ${ClutRunTimeFSpec} "#  Set the PATH variable to make sure it can find the CLU we want to test."
  spit  ${ClutRunTimeFSpec} "#"
  spit  ${ClutRunTimeFSpec} "#----------------------------------------------------------------------------------------"
  spit  ${ClutRunTimeFSpec} ""
  spit  ${ClutRunTimeFSpec} "export PATH=\"$(cd $(dirname ${__ClutTargetFSpec}); echo ${PWD}):\${PATH}\""
  spit  ${ClutRunTimeFSpec} ""
  spit  ${ClutRunTimeFSpec} "#----------------------------------------------------------------------------------------"
  spit  ${ClutRunTimeFSpec} "#"
  spit  ${ClutRunTimeFSpec} "#  Define the clut_definition_set function as a no-op during run-time."
  spit  ${ClutRunTimeFSpec} "#"
  spit  ${ClutRunTimeFSpec} "#  None of the other clut_case_* functions will be called when sourcing the user's CLUT"
  spit  ${ClutRunTimeFSpec} "#  definitions because they must only be called within functions that are defined for use"
  spit  ${ClutRunTimeFSpec} "#  by the clut_definition_set function."
  spit  ${ClutRunTimeFSpec} "#"
  spit  ${ClutRunTimeFSpec} "#----------------------------------------------------------------------------------------"
  spit  ${ClutRunTimeFSpec} ""
  spit  ${ClutRunTimeFSpec} "function clut_definition_set() { : ; }"
  spit  ${ClutRunTimeFSpec} ""
  spit  ${ClutRunTimeFSpec} "#----------------------------------------------------------------------------------------"
  spit  ${ClutRunTimeFSpec} "#"
  spit  ${ClutRunTimeFSpec} "#  Load the CLUT framework run-time support functions."
  spit  ${ClutRunTimeFSpec} "#"
  spit  ${ClutRunTimeFSpec} "#----------------------------------------------------------------------------------------"
  spit  ${ClutRunTimeFSpec} ""
  spit  ${ClutRunTimeFSpec} "source \$(whereHolmespunTestingSupport)/Library/clutr.bash"
  spit  ${ClutRunTimeFSpec} ""
  spit  ${ClutRunTimeFSpec} "#----------------------------------------------------------------------------------------"
  spit  ${ClutRunTimeFSpec} "#"
  spit  ${ClutRunTimeFSpec} "#  clutFileRunTimeGlobalInitializations..."
  spit  ${ClutRunTimeFSpec} "#"
  spit  ${ClutRunTimeFSpec} "#  Execute each of the global initializations at run-time."
  spit  ${ClutRunTimeFSpec} "#"
  spit  ${ClutRunTimeFSpec} "#----------------------------------------------------------------------------------------"
  spit  ${ClutRunTimeFSpec} ""
  spit  ${ClutRunTimeFSpec} "function clutFileRunTimeGlobalInitializations() {"
  #
  if [ ${#__ClutGlobalPriorizerList} -gt 0 ]
  then
     #
     __clutCaseCompileTimeListExpansion	"clutCaseRunTimeInitialization"	"     "					\
					${ClutRunTimeFSpec} "${__ClutGlobalPriorizerList}"
     #
  else
     #
     spit ${ClutRunTimeFSpec} "  #"
     spit ${ClutRunTimeFSpec} "  : No global initializations."
     #
  fi
  #
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "}"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "#-----------------------------------------------------------------------------------------"
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#  clutFileRunTimeGlobalFinalizations..."
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#  Execute each of the global finalizations at run-time."
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#-----------------------------------------------------------------------------------------"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "function clutFileRunTimeGlobalFinalizations() {"
  #
  if [ ${#__ClutGlobalFinalizerList} -gt 0 ]
  then
     #
     __clutCaseCompileTimeListExpansion "clutCaseRunTimeFinalization" "     "					\
					${ClutRunTimeFSpec} "${__ClutGlobalFinalizerList}"
     #
  else
     #
     spit ${ClutRunTimeFSpec} "  #"
     spit ${ClutRunTimeFSpec} "  : No global finalizations."
     #
  fi
  #
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "}"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "#-----------------------------------------------------------------------------------------"
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#  clutFileRunTimeNotations..."
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#-----------------------------------------------------------------------------------------"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "function clutFileRunTimeNotations() {"
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  clutCaseRunTimeReport 1 Notations"
  #
  if [ ${__ClutGlobalNotationCount} -eq 0 ]
  then
     #
     spit ${ClutRunTimeFSpec} "  #"
     spit ${ClutRunTimeFSpec} "  clutCaseRunTimeParagraph No notations defined."
     #
  else
     #
     for Index in $(printf "%s\n" ${!__ClutGlobalNotation[@]} | sort)
     do
       #
       spit ${ClutRunTimeFSpec} "  #"
       spit ${ClutRunTimeFSpec} "  clutCaseRunTimeReport 2 ${Index//&nbsp;/ }"
       spit ${ClutRunTimeFSpec} "  #"
       #
       while read Line
       do
	 #
	 __clutCaseCompileTimeSpitPrettyPrefix ${ClutRunTimeFSpec} "  clutCaseRunTimeParagraph" "${Line}"
	 #
       done <<< "$(echo -e ${__ClutGlobalNotation[${Index}]})"
       #
     done
     #
  fi
  #
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "}"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "#-----------------------------------------------------------------------------------------"
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#  clutFileRunTimeRequirementStatements..."
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#-----------------------------------------------------------------------------------------"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "function clutFileRunTimeRequirementStatements() {"
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  clutCaseRunTimeReport 1 Requirement Statements"
  #
  if [ ${__ClutGlobalRequirementCount} -eq 0 ]
  then
     #
     spit ${ClutRunTimeFSpec} "  #"
     spit ${ClutRunTimeFSpec} "  clutCaseRunTimeParagraph No requirements defined."
     #
  else
     #
     for Index in ${!__ClutGlobalRequirementSortOrder[@]}
     do
       #
       Number=${__ClutGlobalRequirementSortOrder[${Index}]}
       #
       spit ${ClutRunTimeFSpec} "  #"
       spit ${ClutRunTimeFSpec} "  clutCaseRunTimeReport 2 ${Number}"
       spit ${ClutRunTimeFSpec} "  #"
       #
       while read Line
       do
	 #
	 __clutCaseCompileTimeSpitPrettyPrefix ${ClutRunTimeFSpec} "  clutCaseRunTimeParagraph" "${Line}"
	 #
       done <<< "$(echo -e ${__ClutGlobalRequirementStatement[${Number}]})"
       #
     done
     #
  fi
  #
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "}"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "#-----------------------------------------------------------------------------------------"
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#  clutFileRunTimeRequirementCoverage..."
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#-----------------------------------------------------------------------------------------"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "function clutFileRunTimeRequirementCoverage() {"
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  clutCaseRunTimeReport 1 Requirement Coverage"
  #
  if [ ${__ClutGlobalRequirementCount} -eq 0 ]
  then
     #
     spit ${ClutRunTimeFSpec} "  #"
     spit ${ClutRunTimeFSpec} "  clutCaseRunTimeParagraph No requirements defined."
     #
  else
     #
     for Index in ${!__ClutGlobalRequirementSortOrder[@]}
     do
       #
       Number=${__ClutGlobalRequirementSortOrder[${Index}]}
       #
       spit ${ClutRunTimeFSpec} "  #"
       spit ${ClutRunTimeFSpec} "  clutCaseRunTimeReport 2 ${Number}"
       spit ${ClutRunTimeFSpec} "  #"
       #
       if [ ${#__ClutGlobalRequirementExercised[${Number}]} -eq 0 ]
       then
	  #
	  : spit ${ClutRunTimeFSpec} "  clutCaseRunTimeParagraph No coverage."
	  #
       else
	  #
          echo -e "  ${__ClutGlobalRequirementExercised[${Number}]:2}"			\
			| sed --expression='s,; ,\n  ,g'				>> ${ClutRunTimeFSpec}
	  #
       fi
       #
     done
     #
  fi
  #
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "}"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "#-----------------------------------------------------------------------------------------"
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#  clutFileRunTimeDescribeGlobalInformation..."
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#-----------------------------------------------------------------------------------------"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "function clutFileRunTimeDescribeGlobalInformation() {"
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  echo \"\""
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  clutCaseRunTimeReport 0 Global Information"
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  clutFileRunTimeNotations"
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  clutFileRunTimeRequirementStatements"
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  clutFileRunTimeRequirementCoverage"
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  clutCaseRunTimeReport 1 Comparable Masks"
  spit ${ClutRunTimeFSpec} "  #"
  #
  if [ ${#__ClutGlobalCompareMaskList} -eq 0 ]
  then
     #
     spit ${ClutRunTimeFSpec} "  clutCaseRunTimeParagraph No masks defined."
     #
  else
     #
     MaskList="${__ClutGlobalCompareMaskList}"
     #
     MaskList="${MaskList// --expression=/'"\n  clutCaseRunTimeReport 2 "'}"
     #
     MaskList="${MaskList//\'/}"
     #
     spite ${ClutRunTimeFSpec} "  ${MaskList:5}\""
     #
  fi
  #
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "}"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "#-----------------------------------------------------------------------------------------"
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#  clutFileRunTimeMask..."
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#  Apply the global compare masks.  Two arguments may take either of these forms:"
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#	File <file-specification>"
  spit ${ClutRunTimeFSpec} "#	Text <message>"
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#-----------------------------------------------------------------------------------------"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "function clutFileRunTimeMask() {"
  spit ${ClutRunTimeFSpec} "  #"
  spit  ${ClutRunTimeFSpec} "  local -r Format=\${1}"
  spit  ${ClutRunTimeFSpec} "  local -r Target=\"\${2}\""
  spit  ${ClutRunTimeFSpec} "  #"
  #
  if [ ${#__ClutGlobalCompareMaskList} -gt 0 ]
  then
     #
     MaskList="${__ClutGlobalCompareMaskList:1}"
     #
     MaskList="${MaskList// --expression=/'"\n  SedExpressionList+=" --expression='}"
     #
     spit  ${ClutRunTimeFSpec} "  local    SedExpressionList="
     spit  ${ClutRunTimeFSpec} "  #"
     spite ${ClutRunTimeFSpec} "  SedExpressionList+=\" ${MaskList}\""
     spit  ${ClutRunTimeFSpec} "  #"
     spit  ${ClutRunTimeFSpec} "  if [ \"\${Format}\" = File ]"
     spit  ${ClutRunTimeFSpec} "  then"
     spit  ${ClutRunTimeFSpec} "     #"
     spit  ${ClutRunTimeFSpec} "     eval sed --in-place \${SedExpressionList} \${Target}"
     spit  ${ClutRunTimeFSpec} "     #"
     spit  ${ClutRunTimeFSpec} "  elif [ \"\${Format}\" = Text ]"
     spit  ${ClutRunTimeFSpec} "  then"
     spit  ${ClutRunTimeFSpec} "     #"
     spit  ${ClutRunTimeFSpec} "     echo \"\${Target}\" | eval sed \${SedExpressionList}"
     spit  ${ClutRunTimeFSpec} "     #"
     spit  ${ClutRunTimeFSpec} "  fi"
     #
  else
     #
     spit  ${ClutRunTimeFSpec} "  [ \"\${Format}\" = Text ] && echo \"\${Target}\""
     #
  fi
  #
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "}"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "#-----------------------------------------------------------------------------------------"
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#  clutFileRunTimeMaskDataInFile..."
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#  Apply the global compare masks to the contents of one file."
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#  The man page for the 'test' command states that, \"Except for -h and -L, all"
  spit ${ClutRunTimeFSpec} "#  FILE-related tests dereference symbolic links.\"  As such, we need to test for"
  spit ${ClutRunTimeFSpec} "#  symbolic link type before we do for directory type."
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#-----------------------------------------------------------------------------------------"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "function clutFileRunTimeMaskDataInFile() {"
  spit ${ClutRunTimeFSpec} "  #"
  #
  if [ ${#__ClutGlobalCompareMaskList} -gt 0 ]
  then
     #
     spit ${ClutRunTimeFSpec} "  local -r TargetFSpec=\${1}"
     spit ${ClutRunTimeFSpec} "  #"
     spit ${ClutRunTimeFSpec} "  if [ -L \${TargetFSpec} ]"
     spit ${ClutRunTimeFSpec} "  then"
     spit ${ClutRunTimeFSpec} "     #"
     spit ${ClutRunTimeFSpec} "     local -r Maskage=\$(clutFileRunTimeMask Text \$(readlink \${TargetFSpec}))"
     spit ${ClutRunTimeFSpec} "     #"
     spit ${ClutRunTimeFSpec} "     rm \${TargetFSpec}"
     spit ${ClutRunTimeFSpec} "     #"
     spit ${ClutRunTimeFSpec} "     ln --symbolic \${Maskage} \${TargetFSpec}"
     spit ${ClutRunTimeFSpec} "     #"
     spit ${ClutRunTimeFSpec} "  elif [ ! -d \${TargetFSpec} ]"
     spit ${ClutRunTimeFSpec} "  then"
     spit ${ClutRunTimeFSpec} "     #"
     spit ${ClutRunTimeFSpec} "     clutFileRunTimeMask File \${TargetFSpec}"
     spit ${ClutRunTimeFSpec} "     #"
     spit ${ClutRunTimeFSpec} "  fi"
     #
  else
     #
     spit  ${ClutRunTimeFSpec} "  : No global comparison masks to apply."
     #
  fi
  #
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "}"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "#-----------------------------------------------------------------------------------------"
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#  clutFileRunTimeMaskFilesInDirectory..."
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#  Apply the global compare masks to the files in the given workspace."
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#-----------------------------------------------------------------------------------------"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "function clutFileRunTimeMaskFilesInDirectory() {"
  spit ${ClutRunTimeFSpec} "  #"
  #
  if [ ${#__ClutGlobalCompareMaskList} -gt 0 ]
  then
     #
     spit ${ClutRunTimeFSpec} "  local -r TargetDName=\${1}"
     spit ${ClutRunTimeFSpec} "  #"
     spit ${ClutRunTimeFSpec} "  local FSpec OriginalFName ModifiedFName"
     spit ${ClutRunTimeFSpec} "  #"
     spit ${ClutRunTimeFSpec} "  cd \${TargetDName}"
     spit ${ClutRunTimeFSpec} "     #"
     spit ${ClutRunTimeFSpec} "     local -r ListOfFSpec=\$(find . | sed --expression='1d' | sort --reverse)"
     spit ${ClutRunTimeFSpec} "     #"
     spit ${ClutRunTimeFSpec} "     if [ \${#ListOfFSpec} -gt 0 ]"
     spit ${ClutRunTimeFSpec} "     then"
     spit ${ClutRunTimeFSpec} "        #"
     #
     MaskList="${__ClutGlobalCompareMaskList:1}"
     #
     MaskList="${MaskList// --expression=/'"\n        clutCaseRunTimeReport 2 Apply mask "--expression='}"
     #
     spit ${ClutRunTimeFSpec} "        clutCaseRunTimeReport 2 Applying comparable masks."
     spit ${ClutRunTimeFSpec} "        #"
     spit ${ClutRunTimeFSpec} "        for FSpec in \${ListOfFSpec}"
     spit ${ClutRunTimeFSpec} "        do"
     spit ${ClutRunTimeFSpec} "          #"
     spit ${ClutRunTimeFSpec} "          [ ! -d \${FSpec} ] && clutFileRunTimeMaskDataInFile \${FSpec}"
     spit ${ClutRunTimeFSpec} "          #"
     spit ${ClutRunTimeFSpec} "          OriginalFName=\$(basename \${FSpec})"
     spit ${ClutRunTimeFSpec} "          #"
     spit ${ClutRunTimeFSpec} "          ModifiedFName=\$(clutFileRunTimeMask Text \${OriginalFName})"
     spit ${ClutRunTimeFSpec} "          #"
     spit ${ClutRunTimeFSpec} "          if [ \"\${OriginalFName}\" != \"\${ModifiedFName}\" ]"
     spit ${ClutRunTimeFSpec} "          then"
     spit ${ClutRunTimeFSpec} "             #"
     spit ${ClutRunTimeFSpec} "             if [ -e \"\${ModifiedFName}\" ]"
     spit ${ClutRunTimeFSpec} "             then"
     spit ${ClutRunTimeFSpec} "                #"
     spit ${ClutRunTimeFSpec} "                echo \"WARNING: The '\${ModifiedFName}' file already exists.\""
     spit ${ClutRunTimeFSpec} "                echo \"WARNING: The '\${OriginalFName}' file will not be renamed.\""
     spit ${ClutRunTimeFSpec} "                #"
     spit ${ClutRunTimeFSpec} "             else"
     spit ${ClutRunTimeFSpec} "                #"
     spit ${ClutRunTimeFSpec} "                mv \${FSpec} \$(dirname \${FSpec})/\${ModifiedFName}"
     spit ${ClutRunTimeFSpec} "                #"
     spit ${ClutRunTimeFSpec} "             fi"
     spit ${ClutRunTimeFSpec} "             #"
     spit ${ClutRunTimeFSpec} "          fi"
     spit ${ClutRunTimeFSpec} "          #"
     spit ${ClutRunTimeFSpec} "        done"
     spit ${ClutRunTimeFSpec} "        #"
     spit ${ClutRunTimeFSpec} "     fi"
     spit ${ClutRunTimeFSpec} "     #"
     spit ${ClutRunTimeFSpec} "  cd .."
     #
  else
     #
     spit ${ClutRunTimeFSpec} "  : No global comparison masks to apply."
     #
  fi
  #
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "}"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "#-----------------------------------------------------------------------------------------"
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#  Load the user's run-time support functions."
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#-----------------------------------------------------------------------------------------"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "source ${__ClutSourceFSpec}"
  spit ${ClutRunTimeFSpec} ""
  #
  local -i ClutCaseIndex=1
  #
  local    ClutCaseIndexFormal
  #
  while [ ${ClutCaseIndex} -le ${ClutCaseCount} ]
  do
    #
    ClutCaseIndexFormal=$(${__ClutCaseIndexOutputFormat} ${ClutCaseIndex})
    #
    spit ${ClutRunTimeFSpec} "#---------------------------------------------------------------------------------------"
    spit ${ClutRunTimeFSpec} ""
    spew ${ClutRunTimeFSpec} ${__ClutWorkinDName}/${ClutCaseIndexFormal}.bash
    spit ${ClutRunTimeFSpec} ""
    #
    ClutCaseIndex+=1
    #
  done
  #
  spit ${ClutRunTimeFSpec} "#-----------------------------------------------------------------------------------------"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "function clutCaseRunTimeForTestCaseAll() {"
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  local -r Instrumentation=\${*}"
  spit ${ClutRunTimeFSpec} "  #"
  #
  ClutCaseIndex=1
  #
  while [ ${ClutCaseIndex} -le ${ClutCaseCount} ]
  do
    #
    if [ "${__ClutCaseDefiner[${ClutCaseIndex}]+SET}" = "SET" ]
    then
       #
       spit ${ClutRunTimeFSpec} "  #"
       spit ${ClutRunTimeFSpec} "  #  ${__ClutCaseDefiner[${ClutCaseIndex}]}"
       spit ${ClutRunTimeFSpec} "  #"
       #
    fi
    #
    ClutCaseIndexFormal=$(${__ClutCaseIndexOutputFormat} ${ClutCaseIndex})
    #
    spit ${ClutRunTimeFSpec} "  clutCaseRunTimeForTestCase${ClutCaseIndexFormal} \${Instrumentation}"
    #
    ClutCaseIndex+=1
    #
  done
  #
  local -r HeaderFooterInfo="${__ClutSourceFName} ${__ClutOutputFormatVersion} ${ClutCaseCount}"
  #
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "}"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "#-----------------------------------------------------------------------------------------"
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#  clutFileRunTimeMain..."
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#  Run a single test case if the user has requested it; run all of the otherwise."
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#  Instrumentation only applies to the CLU."
  spit ${ClutRunTimeFSpec} "#"
  spit ${ClutRunTimeFSpec} "#-----------------------------------------------------------------------------------------"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "function clutFileRunTimeMain() {"
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  local -r ArgumentList=\${*}"
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  local -r IntegerRegex=\"^[0-9]+$\""
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  local    Instrumentation="
  spit ${ClutRunTimeFSpec} "  local    TestCaseIndex="
  spit ${ClutRunTimeFSpec} "  local    WorkinLName="
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  local    ArgumentItem"
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  for ArgumentItem in \${ArgumentList}"
  spit ${ClutRunTimeFSpec} "  do"
  spit ${ClutRunTimeFSpec} "    #"
  spit ${ClutRunTimeFSpec} "    #  If we are still checking the lead arguments..."
  spit ${ClutRunTimeFSpec} "    #"
  spit ${ClutRunTimeFSpec} "    if [ \${#Instrumentation} -eq 0 ]"
  spit ${ClutRunTimeFSpec} "    then"
  spit ${ClutRunTimeFSpec} "       #"
  spit ${ClutRunTimeFSpec} "       #  If the lead argument..."
  spit ${ClutRunTimeFSpec} "       #     Is an integer then the user only wants to run one test case."
  spit ${ClutRunTimeFSpec} "       #  Else if the lead argument..."
  spit ${ClutRunTimeFSpec} "       #     Begins with the option name '--working=' then it names the working directory."
  spit ${ClutRunTimeFSpec} "       #  Else..."
  spit ${ClutRunTimeFSpec} "       #     It marks the beginning of the instrumentation command."
  spit ${ClutRunTimeFSpec} "       #  Endif"
  spit ${ClutRunTimeFSpec} "       #"
  spit ${ClutRunTimeFSpec} "       if [[ \"\${ArgumentItem}\" =~ \${IntegerRegex} ]]"
  spit ${ClutRunTimeFSpec} "       then"
  spit ${ClutRunTimeFSpec} "          #"
  spit ${ClutRunTimeFSpec} "          TestCaseIndex=\${ArgumentItem}"
  spit ${ClutRunTimeFSpec} "          #"
  spit ${ClutRunTimeFSpec} "       elif [ \"\${ArgumentItem:0:10}\" = \"--working=\" ]"
  spit ${ClutRunTimeFSpec} "       then"
  spit ${ClutRunTimeFSpec} "          #"
  spit ${ClutRunTimeFSpec} "          WorkinLName=\"\${ArgumentItem:10}\""
  spit ${ClutRunTimeFSpec} "          #"
  spit ${ClutRunTimeFSpec} "       else"
  spit ${ClutRunTimeFSpec} "          #"
  spit ${ClutRunTimeFSpec} "          Instrumentation=\"\${ArgumentItem}\""
  spit ${ClutRunTimeFSpec} "          #"
  spit ${ClutRunTimeFSpec} "       fi"
  spit ${ClutRunTimeFSpec} "       #"
  spit ${ClutRunTimeFSpec} "    else"
  spit ${ClutRunTimeFSpec} "       #"
  spit ${ClutRunTimeFSpec} "       Instrumentation+=\" \${ArgumentItem}\""
  spit ${ClutRunTimeFSpec} "       #"
  spit ${ClutRunTimeFSpec} "    fi"
  spit ${ClutRunTimeFSpec} "    #"
  spit ${ClutRunTimeFSpec} "  done"
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  #  Register dump format functions."
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  clutFileRunTimeDumpFormatRegistrationStandard"
  #
  __clutCaseCompileTimeListExpansion	"clutFileRunTimeDumpFormatRegistration" "  "				\
					${ClutRunTimeFSpec} "${__ClutGlobalDumpFormatList}"
  #
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  #  Create a run-time working directory, and remember its specification."
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  [ \${#WorkinLName} -eq 0 ] && WorkinLName=\"${__ClutSourceFName%.clut}.clutr\""
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  local -r WorkinDName=\$(echoDatStampedFSpec \${WorkinLName}.)_\$\$"
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  mkdir \${WorkinDName}"
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  cd \${WorkinDName}"
  spit ${ClutRunTimeFSpec} "     #"
  spit ${ClutRunTimeFSpec} "     __ClutWorkingDSpec=\${PWD}"
  spit ${ClutRunTimeFSpec} "     #"
  spit ${ClutRunTimeFSpec} "     if [ \${#TestCaseIndex} -gt 0 ] && [[ \${TestCaseIndex} =~ ^[0-9]+$ ]]"
  spit ${ClutRunTimeFSpec} "     then"
  spit ${ClutRunTimeFSpec} "        #"
  spit ${ClutRunTimeFSpec} "        local -r ClutCaseIndexFormal=\$(${__ClutCaseIndexOutputFormat} \${TestCaseIndex})"
  spit ${ClutRunTimeFSpec} "        #"
  spit ${ClutRunTimeFSpec} "        clutCaseRunTimeForTestCase\${ClutCaseIndexFormal} \${Instrumentation}"
  spit ${ClutRunTimeFSpec} "        #"
  spit ${ClutRunTimeFSpec} "     else"
  spit ${ClutRunTimeFSpec} "        #"
  spit ${ClutRunTimeFSpec} "        clutFileRunTimeDescribeStart ${HeaderFooterInfo}"
  spit ${ClutRunTimeFSpec} "        #"
  spit ${ClutRunTimeFSpec} "        clutFileRunTimeDescribeGlobalInformation"
  spit ${ClutRunTimeFSpec} "        #"
  spit ${ClutRunTimeFSpec} "        clutCaseRunTimeForTestCaseAll \${Instrumentation}"
  spit ${ClutRunTimeFSpec} "        #"
  spit ${ClutRunTimeFSpec} "        clutFileRunTimeDescribeEnded ${HeaderFooterInfo}"
  spit ${ClutRunTimeFSpec} "        #"
  spit ${ClutRunTimeFSpec} "     fi"
  spit ${ClutRunTimeFSpec} "     #"
  spit ${ClutRunTimeFSpec} "  cd .."
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  [ -L \${WorkinLName} ] && rm \${WorkinLName}"
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  [ -e \${WorkinLName} ] && mv \${WorkinLName} \${WorkinLName}.was"
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "  ln --symbolic \${WorkinDName} \${WorkinLName}"
  spit ${ClutRunTimeFSpec} "  #"
  spit ${ClutRunTimeFSpec} "}"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "#-----------------------------------------------------------------------------------------"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "clutFileRunTimeMain \${__ScriptArgumentList}"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "exit 0"
  spit ${ClutRunTimeFSpec} ""
  spit ${ClutRunTimeFSpec} "#-----------------------------------------------------------------------------------------"
  #
  chmod 755 ${ClutRunTimeFSpec}
  #
  [ -L ${__ClutResultFSpec} ] && rm ${__ClutResultFSpec}
  #
  [ -e ${__ClutResultFSpec} ] && mv ${__ClutResultFSpec} ${__ClutResultFSpec}.was
  #
  local -r ClutResultLinkTargetDSpec=$(echoRelativePath $(dirname ${__ClutResultFSpec}) $(dirname ${ClutRunTimeFSpec}))
  #
  ln --symbolic ${ClutResultLinkTargetDSpec}/$(basename ${ClutRunTimeFSpec}) ${__ClutResultFSpec}
  #
}

#----------------------------------------------------------------------------------------------------------------------

__clutCompileTimeMain

exit

#----------------------------------------------------------------------------------------------------------------------
