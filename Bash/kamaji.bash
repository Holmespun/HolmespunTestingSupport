#!/bin/bash
#----------------------------------------------------------------------------------------------------------------------
###
###	kamaji.bash...
###
###	@file
###	@author		Brian G. Holmes
###	@copyright	GNU General Public License
###	@brief		Holmespun Testing Manager (HTM) script.
###	@todo		https://github.com/Holmespun/HolmespunMakefileMethod/issues
###	@remark		kamaji.bash [<modifier>]... [<request>] [<parameter>]..."
###
###	@details	Unit test exercise and CLUT program output and evaluation manager.
###
#----------------------------------------------------------------------------------------------------------------------
#
#	AppendArrayIndexValue
#	DiagnosticHeavy
#	DiagnosticLight
#	DiagnosticComplex
#	EchoAbsoluteDirectorySpecFor
#	EchoAgeRelation
#	EchoAndExecuteOutputSwap
#	EchoAndExecuteInWorking
#	EchoErrorAndExit
#	EchoExecutableFilesMatching
#	EchoFailureAndExit
#	EchoFileSpec
#	EchoImportantMessage
#	EchoMeaningOf
#	EchoPara
#	EchoPara80
#	EchoPara80-4
#	Xtension
#	SortArray
#
#	KamajiEchoArrayAssignments
#	KamajiEchoListOfDecendantFName
#	KamajiExitAfterUsage
#	KamajiFileClassification
#	KamajiOrderByLatestBaseSource
#
#	KamajiConfigurationCheckValues
#	KamajiConfigurationEchoValue
#	KamajiConfigurationLoadValues
#
#	KamajiModifierFast
#	KamajiModifierSilent
#	KamajiModifierUsage_bless
#	KamajiModifierUsage_configure
#	KamajiModifierUsage_grades
#	KamajiModifierUsage_export
#	KamajiModifierUsage_invoke
#	KamajiModifierUsage_make
#	KamajiModifierUsage_review
#	KamajiModifierUsage_show
#	KamajiModifierUsage_fast
#	KamajiModifierUsage
#	KamajiModifierVerbose
#
#	KamajiBuildRulesForTestingSource_Clut
#	KamajiBuildRulesForTestingSource_Elf
#	KamajiBuildRulesForTestingSource_Output
#	KamajiBuildRulesForTestingSource_Script
#	KamajiBuildRulesForTestingSource_Unknown
#	KamajiBuildRulesForTestingSource
#	KamajiBuildRulesLoadXtraDependents
#	KamajiBuildRules
#
#	KamajiRequestBless
#	KamajiRequestConfigure
#	KamajiRequestExport_ruleset
#	KamajiRequestExport
#	KamajiRequestGradeOrOutputOrReview
#	KamajiRequestGrade
#	KamajiRequestInvoke
#	KamajiRequestMake
#	KamajiRequestReview
#	KamajiRequestShow_makefile_explicit
#	KamajiRequestShow_makefile_layered
#	KamajiRequestShow_makefile
#	KamajiRequestShow
#
#	KamajiMake_Delta_from_GoldenMasked_OutputMasked
#	KamajiMake_Delta_from_OutputMasked
#	KamajiMake_Delta_from_OutputMasked_GoldenMasked
#	KamajiMake_GoldenMasked_from_Golden_SedMaskingScript
#	KamajiMake_GoldenMasked_from_SedMaskingScript_Golden
#	KamajiMake_Grade_from_Delta
#	KamajiMake_Output_from_Naked
#	KamajiMake_Output_from_Script
#	KamajiMake_OutputMasked_from_Output_SedMaskingScript
#	KamajiMake_OutputMasked_from_SedMaskingScript_Output
#	KamajiMake_Review_from_Delta_Grade
#	KamajiMake_Review_from_Grade_Delta
#	KamajiMake_Script_from_Clut_Naked
#	KamajiMake_Script_from_Clut_Script
#	KamajiMake_Script_from_Naked_Clut
#	KamajiMake_Script_from_Script_Clut
#	KamajiMake
#
#	KamajiMain
#
#----------------------------------------------------------------------------------------------------------------------
#
#  20190704 BGH; created.
#  20190720 BGH; version 2.
#  20190817 BGH; version 3, kamaji knows the source files, calculates all output files, functions based on both.
#
#  TODO: New requests rework, workout, vimdiff=review (grade and vimdiff), and bless=baseline (cp if fresh, or grade)
#  TODO: Save the rules to a bash file that can be reused if all Golden and SedScript files represented there.
#
#  Copyright (c) 2019 Brian G. Holmes
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

source $(whereHolmespunLibraryBashing)/Library/echoInColor.bash
source $(whereHolmespunLibraryBashing)/Library/echoRelativePath.bash
source $(whereHolmespunLibraryBashing)/Library/spit_spite_spitn_and_spew.bash

#----------------------------------------------------------------------------------------------------------------------

declare -r __KamajiScriptName=$(basename ${0})

declare -r __KamajiConfigurationFName=.${__KamajiScriptName%%.*}.conf
declare -r __KamajiXtraDependentFName=.${__KamajiScriptName%%.*}.deps

declare -r __KamajiIfsOriginal="${IFS}"

#----------------------------------------------------------------------------------------------------------------------

declare -A __KamajiConfigurationValue

declare    __KamajiGoldenDSpec="TBD"

declare    __KamajiDataFileNameList="TBD"

declare    __KamajiLastMakeTargetFSpec="TBD"

declare    __KamajiReviewCommand="TBD"

declare    __KamajiReviewTailpipe="TBD"

declare    __KamajiScriptExtensionList="TBD"

declare    __KamajiVerbosityRequested="TBD"

declare -r __KamajiWhereWeWere=${PWD}

declare    __KamajiWorkinDSpec="TBD"

declare    __KamajiSedScriptFSpec="TBD"
declare    __KamajiSedScriptFName="TBD"

declare    __KamajiRulesetIsReady="false"

#----------------------------------------------------------------------------------------------------------------------

declare -A __KamajiBaseSourceList
declare -A __KamajiClassifiedList
declare -A __KamajiMyChildrenList
declare -A __KamajiMyParentalList
declare -A __KamajiRepresentative
declare -A __KamajiXtraParentList

#----------------------------------------------------------------------------------------------------------------------

declare -r __KamajiErrorTag=$(echoInColorRedBold "ERROR:")

declare -r __KamajiFailTag=$(echoInColorRedBold "FAIL:")

declare -r __KamajiInfoTag=$(echoInColorYellow "INFO:")

declare -r __KamajiPassTag=$(echoInColorGreenBold "PASS:")

#----------------------------------------------------------------------------------------------------------------------

function AppendArrayIndexValue() {
  #
  local -r ArrayName=${1}
  local -r IndexText="${2}"
  local -r ValueText="${3}"
  #
  local -r ItemReference=${ArrayName}["${IndexText}"]
  #
  local -r Conditional="[ \"\${${ItemReference}+IS_SET}\" = \"IS_SET\" ] || ${ItemReference}="
  #
  local -r Appendiment="${ItemReference}+=\" ${ValueText}\""
  #
  eval "${Conditional}"
  #
  [ ${#ValueText} -gt 0 ] && eval "${Appendiment}"
  #
}

#----------------------------------------------------------------------------------------------------------------------

function DiagnosticHeavy() { [ "${__KamajiVerbosityRequested}" = "heavy" ] && echoInColorBlue "${*}" 1>&2; }

#----------------------------------------------------------------------------------------------------------------------

function DiagnosticLight() { [ "${__KamajiVerbosityRequested}" != "quiet" ] && echo "${*}" 1>&2; }

#----------------------------------------------------------------------------------------------------------------------

function DiagnosticComplex() {
  #
  local MessageLight="${1}"
  local MessageHeavy="${2}"
  #
  if [ "${__KamajiVerbosityRequested}" = "light" ]
  then
     #
     echoInColorWhite "${MessageLight}" 1>&2
     #
  elif [ "${__KamajiVerbosityRequested}" = "heavy" ]
  then
     #
     echoInColorWhite "${MessageLight} $(echoInColorBlue ${MessageHeavy})" 1>&2
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------

function EchoAbsoluteDirectorySpecFor() {
  #
  local -r ParentDSpec=${1}
  local -r NestedDSpec=${2}
  #
  cd ${ParentDSpec}/${NestedDSpec}
     #
     echo ${PWD}
     #
  cd ${__KamajiWhereWeWere}
  #
}

#----------------------------------------------------------------------------------------------------------------------
#
#  EchoAgeRelation returns GT if SourceFSpec exists but TargetFSpec does not, and LT vice versa
#
#----------------------------------------------------------------------------------------------------------------------

function EchoAgeRelation() {
  #
  local -r SourceFSpec="${1}"
  local -r TargetFSpec="${2}"
  #
  local    Result="ZZ"
  local    Reason="For no raisin"
  #
  if [ -e "${SourceFSpec}" ]
  then
     #
     if [ -e "${TargetFSpec}" ]
     then
        #
        if [ "${SourceFSpec}" -nt "${TargetFSpec}" ]
        then
	   #
           Result="GT"
	   #
	   Reason="${SourceFSpec} is newer-than ${TargetFSpec}"
	   #
        elif [ "${TargetFSpec}" -nt "${SourceFSpec}" ]
        then
	   #
           Result="LT"
	   #
	   Reason="${SourceFSpec} is older-than ${TargetFSpec}"
	   #
        else
	   #
           Result="EQ"
	   #
	   Reason="${SourceFSpec} and ${TargetFSpec} are the same age"
	   #
        fi
        #
     else
        #
        Result="GT"
        #
	Reason="${TargetFSpec} does not exist"
	#
     fi
     #
  else
     #
     if [ -e "${TargetFSpec}" ]
     then
        #
        Result="LT"
        #
	Reason="${SourceFSpec} does not exist"
	#
     else
        #
        Result="EQ"
        #
	Reason="Neither ${SourceFSpec} nor ${TargetFSpec} exist"
	#
     fi
     #
  fi
  #
  echo ${Result} ${Reason}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function EchoAndExecuteOutputSwap() {
  #
  local -r SystemRequest="${*}"
  #
  exec 5>&2
     #
     local -r ErrorMessage=$(eval ${SystemRequest} 2>&1 1>&5)
     #
     local    Status=${?}
     #
  exec 5>&-
  #
  if [ ${#ErrorMessage} -gt 0 ]
  then
     #
     [ ${Status} -eq 0 ] && Status=1
     #
     echoInColorRed ${ErrorMessage}
     #
  fi
  #
  return ${Status}
  #
}
#----------------------------------------------------------------------------------------------------------------------

function EchoAndExecuteInWorking() {
  #
  local -r SystemRequest="${*}"
  #
  local -i Status
  #
  DiagnosticHeavy "${SystemRequest}" 1>&2
  #
  cd ${__KamajiWorkinDSpec}
     #
     IFS=
        #
        EchoAndExecuteOutputSwap ${SystemRequest} 2>&1 1>&2
        #
        Status=${?}
        #
     IFS="${__KamajiIfsOriginal}"
     #
  cd ..
  #
  return ${Status}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function EchoErrorAndExit() {
  #
  local -r -i ExitStatus=${1}
  shift 1
  local -r    Message=${*}
  #
  EchoImportantMessage "${__KamajiErrorTag}" "${Message}"
  #
  exit ${ExitStatus}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function EchoExecutableFilesMatching() {
  #
  local -r TargetFRoot=${1}
  shift
  local -r ListOfTargetDSpec=${*}
  #
  local    ResultsFList= 
  #
  local    ProgramFSpec
  #
  for TargetDSpec in ${ListOfTargetDSpec}
  do
    #
    for ProgramFSpec in ${TargetDSpec}/${TargetFRoot}*
    do
      #
      [ -d ${ProgramFSpec} ] && continue
      #
      [ -x ${ProgramFSpec} ] && ResultsFList+=" ${ProgramFSpec}"
      #
    done
    #
  done
  #
  if [ ${#ResultsFList} -eq 0 ]
  then
     #
     ProgramFSpec=${TargetFRoot%.*}
     #
     [ ${#ProgramFSpec} -lt ${#TargetFRoot} ] && EchoExecutableFilesMatching ${ProgramFSpec} ${ListOfTargetDSpec}
     #
  else
     #
     echo ${ResultsFList}
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------

function EchoFailureAndExit() {
  #
  local -r -i ExitStatus=${1}
  shift 1
  local -r    Message=${*}
  #
  EchoImportantMessage "${__KamajiFailTag}" "${Message}"
  #
  exit ${ExitStatus}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function EchoFileSpec() {
  #
  local -r TargetDSpec=${1}
  local -r TargetFRoot=${2}
  local -r TargetFType=${3-}
  #
  local    Result=${TargetDSpec}/${TargetFRoot}
  #
  [ ${#TargetFType} -gt 0 ] && Result+=.${TargetFType}
  #
  echo "${Result}"
  #
}

#----------------------------------------------------------------------------------------------------------------------

function EchoImportantMessage() {
  #
  local -r    Tag=${1}
  shift 1
  local -r    Message=${*}
  #
  echo "${Tag} $(echoInColorWhiteBold ${Message})" 1>&2
  #
  return 1
  #
}

#----------------------------------------------------------------------------------------------------------------------

function EchoMeaningOf() {
  #
  local -r Target=${1,,}
  local -r Default=${2}
  shift 2
  local -r AcceptableValueList="${*}"
  #
  local -r WordList=":${AcceptableValueList// /:}:"
  #
  local -r WordLess=${WordList%%:${Target}*}
  #
  local    Result=${Default}
  #
  if [ ${#WordLess} -lt ${#WordList} ]
  then
     #
     Result=${WordList:${#WordLess}}
     Result=${Result:1}
     Result=${Result%%:*}
     #
  fi
  #
  echo ${Result}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function EchoPara() {
  #
  local -r -i CharWide=${1}
  shift 1
  local -r    WordList="${*}"
  #
  local    ParagraphText=
  local -i ParagraphWide=0
  #
  for WordItem in ${WordList}
  do
    #
    ParagraphWide+=1
    ParagraphWide+=${#WordItem}
    #
    if [ ${ParagraphWide} -gt ${CharWide} ]
    then
       #
       echo "${ParagraphText:1}"
       #
       ParagraphText=
       ParagraphWide=0
       #
       ParagraphWide+=1
       ParagraphWide+=${#WordItem}
       #
    fi
    #
    ParagraphText+=" ${WordItem}"
    #
  done
  #
  echo "${ParagraphText:1}"
  echo ""
  #
}

#----------------------------------------------------------------------------------------------------------------------

function EchoPara80() { EchoPara 80 ${*}; }

#----------------------------------------------------------------------------------------------------------------------

function EchoPara80-4() { EchoPara 76 ${*} | sed --expression='s,^,    ,'; }

#----------------------------------------------------------------------------------------------------------------------

function Xtension() {
  #
  local -r FileNameOrSpec=${1,,}
  #
  local    Result=${FileNameOrSpec##*.}
  #
  [ "${Result}" = "${FileNameOrSpec}" ] && Result=
  #
  echo ${Result}
  #
}

#----------------------------------------------------------------------------------------------------------------------
#
#  https://stackoverflow.com/questions/40193122/how-to-sort-string-array-in-descending-order-in-bash
#
#----------------------------------------------------------------------------------------------------------------------

function SortArray() { local v="$1[*]" IFS=$'\n'; read -d $'\0' -a "$1" < <(sort "${@:2}" <<< "${!v}"); }

#----------------------------------------------------------------------------------------------------------------------

function KamajiEchoArrayAssignments() {
  #
  local -r ArrayName=${1}
  shift 1
  local -r KeyValueList=${*}
  #
  for KeyValueItem in ${KeyValueList}
  do
    #
    ArrayReference=${ArrayName}[${KeyValueItem}]
    #
    echo "${ArrayReference}=\"${!ArrayReference}\""
    #
  done
  #
  [ ${#KeyValueList} -gt 0 ] && spit ${RulesetFSpec} "#"
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiEchoListOfDecendantFName() {
  #
  local -r SourceFName=${1}
  local -r TargetClass=${2}
  #
  local -r SourceFType=$(Xtension ${SourceFName})
  #
  local -r SourceClass=$(KamajiFileClassification ${SourceFName} ${SourceFType})
  #
  local    ChildsFName
  #
  local    ResultFList=
  #
  if [ "${SourceClass}" = "${TargetClass}" ]
  then
     #
     echo "${SourceFName}"
     #
  elif [ "${__KamajiMyChildrenList[${SourceFName}]+IS_SET}" = "IS_SET" ]
  then
     #
     for ChildsFName in ${__KamajiMyChildrenList[${SourceFName}]}
     do
       #
       ResultFList+=" $(KamajiEchoListOfDecendantFName ${ChildsFName} ${TargetClass})"
       #
     done
     #
     echo " ${ResultFList}"
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiExitAfterUsage() {
  #
  local -r Message=${*}
  #
  EchoImportantMessage "${__KamajiErrorTag}" "${Message}"
  #
  KamajiModifierUsage N/A
  #
  exit 1
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiFileClassification() {
  #
  local -r SourceFSpec=${1}
  local -r SourceFType=${2-}
  #
  local -r SourceFTest=${__KamajiScriptExtensionList/:${SourceFType}:/}
  #
  local    Result=Unknown
  #
  if [ "${SourceFSpec}" = "${__KamajiSedScriptFSpec}" ]
  then
     #
     Result="SedMaskingScript"
     #
  elif [ ${#SourceFTest} -ne ${#__KamajiScriptExtensionList} ]
  then
     #
#    [ ! -e ${SourceFSpec} ] && Result="Script"
     #
#    [   -x ${SourceFSpec} ] && Result="Script"
     #
     Result="Script"
     #
  elif [ "${SourceFType}" = "clut" ]
  then
     #
     Result="Clut"
     #
  elif [ "${SourceFType}" = "cpp" ]
  then
     #
     Result="Elf"
     #
  elif [ "${SourceFType}" = "delta" ]
  then
     #
     Result="Delta"
     #
  elif [ "${SourceFType}" = "golden" ]
  then
     #
     Result="Golden"
     #
  elif [ "${SourceFType}" = "grade" ]
  then
     #
     Result="Grade"
     #
  elif [ "${SourceFType}" = "masked" ]
  then
     #
     local -r SourceFRoot=${SourceFSpec%.${SourceFType}}
     #
     Result=$(KamajiFileClassification ${SourceFRoot} $(Xtension ${SourceFRoot}))Masked
     #
  elif [ "${SourceFType}" = "output" ]
  then
     #
     Result="Output"
     #
  elif [ "${SourceFType}" = "review" ]
  then
     #
     Result="Review"
     #
  elif [ ${#SourceFType} -eq 0 ]
  then
     #
     Result="Naked"
     #
  fi
  #
  echo "${Result}"
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiOrderByLatestBaseSource() {
  #
  local -r TargetFList="${*}"
  #
  local    TargetFName
  #
  local    SortingHat=
  #
  local -i BigTime
  local -i OneTime
  #
  for TargetFName in ${TargetFList}
  do
    #
    BigTime=0
    #
    for SourceFName in ${__KamajiBaseSourceList[${TargetFName}]}
    do
      #
      OneTime=$(stat --format="%Y" ${SourceFName})
      #
      [ ${OneTime} -gt ${BigTime} ] && BigTime=${OneTime}
      #
    done
    #
    SortingHat+="${BigTime}:${TargetFName} "
    #
  done
  #
  for TargetFName in $(printf ${SortingHat// /\\n} | sort --reverse)
  do
    #
    echo "${TargetFName##*:}"
    #
  done
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiConfigurationCheckValues() {
  #
  [ ${#__KamajiWorkinDSpec} -eq 0 ] && KamajiExitAfterUsage "The working-folder is improperly configured."
  #
  [ ${#__KamajiGoldenDSpec} -eq 0 ] && KamajiExitAfterUsage "The baseline-folder is improperly configured."
  #
  [ ! -d ${__KamajiGoldenDSpec} ] && KamajiExitAfterUsage "The baseline-folder '${__KamajiGoldenDSpec}' does not exist."
  #
  [ ! -d ${__KamajiWorkinDSpec} ] && mkdir --parents ${__KamajiWorkinDSpec}
  #
  [ ! -e ${__KamajiSedScriptFSpec} ] && touch ${__KamajiSedScriptFSpec}
  #
  local -r GoldenDSpec=$(EchoAbsoluteDirectorySpecFor . ${__KamajiGoldenDSpec})
  local -r WorkinDSpec=$(EchoAbsoluteDirectorySpecFor . ${__KamajiWorkinDSpec})
  #
  if [ "${GoldenDSpec}" = "${WorkinDSpec}" ]
  then
     #
     KamajiExitAfterUsage "The baseline-folder and/or working-folder are improperly configured;"	\
			  "these cannot be the same."
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiConfigurationEchoValue() {
  #
  local -r Name=${1}
  local -r Default="${2-}"
  #
  local    Result="${Default}"
  #
  if [ "${__KamajiConfigurationValue[${Name}]+IS_SET}" = IS_SET ]
  then
     Result="${__KamajiConfigurationValue[${Name}]}"
  fi
  #
  echo "${Result}"
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiConfigurationLoadValues() {
  #
  local Key Value Directory
  #
  for Directory in . ${HOME}
  do
    #
    if [ -s ${Directory}/${__KamajiConfigurationFName} ]
    then
       #
       while read Key Value
       do
         #
         if [ ${#Key} -gt 0 ] && [ "${Key:0:1}" != "#" ]
	 then
            #
            KeyIsNotListCheck=${Key%-list}
            #
            if [ ${#KeyIsNotListCheck} -eq ${#Key} ]
	    then
               #
	       __KamajiConfigurationValue[${Key}]=${Value}
               #
            else
               #
	       AppendArrayIndexValue __KamajiConfigurationValue "${Key}" "${Value}"
               #
            fi
            #
         fi
         #
       done < ${Directory}/${__KamajiConfigurationFName}
       #
    fi
    #
  done
  #
  __KamajiGoldenDSpec=$(KamajiConfigurationEchoValue baseline-folder .)
  #
  __KamajiDataFileNameList=$(KamajiConfigurationEchoValue data-filename-list)
  #
  __KamajiDataFileNameList=":${__KamajiDataFileNameList// /:}:"
  #
  __KamajiReviewCommand=$(KamajiConfigurationEchoValue review-command "vimdiff")
  #
  __KamajiReviewTailpipe=$(KamajiConfigurationEchoValue review-tailpipe)
  #
  [ ${#__KamajiReviewTailpipe} -gt 0 ] && __KamajiReviewTailpipe="| ${__KamajiReviewTailpipe}"
  #
  __KamajiScriptExtensionList=$(KamajiConfigurationEchoValue script-type-list "bash sh py rb")
  #
  __KamajiScriptExtensionList=":${__KamajiScriptExtensionList// /:}:"
  #
  __KamajiSedScriptFSpec=$(KamajiConfigurationEchoValue mask-sed-script ${__KamajiConfigurationFName%.*}.sed)
  #
  __KamajiSedScriptFName=$(basename ${__KamajiSedScriptFSpec})
  #
  __KamajiVerbosityRequested=$(KamajiConfigurationEchoValue verbosity-level quiet)
  #
  __KamajiWorkinDSpec=$(KamajiConfigurationEchoValue working-folder Working)
  #
  local LastMakeTargetFName=$(KamajiConfigurationEchoValue last-target-file-name .kamaji.last_target.text)
  #
  __KamajiLastMakeTargetFSpec=${__KamajiWorkinDSpec}/${LastMakeTargetFName}
  #
# local LastMakeTargetFType=$(Xtension ${LastMakeTargetFName})
# local LastMakeTargetFRoot=${LastMakeTargetFName%.${LastMakeTargetFType}}
# #
# __KamajiLastMakeTargetFSpec=${__KamajiWorkinDSpec}/${LastMakeTargetFRoot}.$$.${LastMakeTargetFType}
# #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_bless() {
  #
  local -r Request="${1}"
  #
  EchoPara80	"$(echoInColorWhiteBold "Baseline|Bless...")"
  #
  EchoPara80	"The 'bless' request allows you to baseline current output files after you have reviewed them."	\
		"A 'bless' request will not generate any test data;"						\
		"it can only be applied to output files that have already been generated and reviewed."		\
		"it is a convenient shorthand, but it will cost you if you baseline output that is not valid."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_configure() {
  #
  local -r Request="${1}"
  #
  EchoPara80	"$(echoInColorWhiteBold "Configure|Set...")"
  #
  EchoPara80	"Configuration vales are stored in the ./${__KamajiConfigurationFName} file,"			\
		"a text file that contains comments, blank lines, and named value pairs:"
  #
  EchoPara80-4	"$(echoInColorWhiteBold "baseline-folder") <directory-specification> -"				\
		"Specification for the directory where baseline output files are stored."			\
		"The default baseline-folder is the current directory."
  #
  EchoPara80-4	"$(echoInColorWhiteBold "mask-sed-script") <file-specification> -"				\
		"Specification for the user-defined sed script that is used to mask output files."		\
		"The default mask-sed-script is the ${__KamajiConfigurationFName%.*}.sed file in the current"	\
		"directory."	
  #
  EchoPara80-4	"$(echoInColorWhiteBold "script-type-list") [<extension>]... -"					\
		"List of file name extensions that are used to store executable scripts."			\
		"The ${__KamajiConfigurationFName} script will assume that files with these extensions are"	\
		"up-to-date and ready for use."
  #
  EchoPara80-4	"$(echoInColorWhiteBold "verbosity-level") <adjective> -"					\
		"Level of disgnostic output produced by the ${__KamajiConfigurationFName} script."		\
		"The default level is called 'quiet' and results in no disgnostic output at all."		\
		"The 'light' level will describe the acttions used to fulfill the user request."		\
		"The 'heavy' level will augment light output with every significant Linux command it uses"	\
		"to fulfill the user request."
  #
  EchoPara80-4	"$(echoInColorWhiteBold "working-folder") <directory-specification> -"				\
		"Specification for the directory where intermediate and unverified output files are created."	\
		"If the working-folder does not already exist then it will be silently created."		\
		"The default working-folder is called Working."
  #
  EchoPara80	"The \$HOME/${__KamajiConfigurationFName} configuration file can be used to"			\
		"override values in the file with the same name in the current directory."			\
		"Named values may also be used to override values previously named in the same file."		\
		"Here is an example of what one might contain:"
  #
  echo		"    #"
  echo		"    #  My kamaji configuration file."
  echo		"    #"
  echo		"    baseline-folder  Testing"
  echo		"    mask-sed-script  Testing/kamaji_masking_script.sed"
  echo		"    script-type-list bash rb ruby sh"
  echo		"    verbosity-level  heavy"
  echo		"    working-folder   working"
  echo		"    working-folder   Workspace"
  echo		""
  #
  EchoPara80	"Kamaji ignores values with names it does not recognize."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_grades() {
  #
  local -r Request="${1}"
  #
  EchoPara80	"$(echoInColorWhiteBold "Grade...")"
  #
  EchoPara80	"A 'grade' request will determine the pass or fail status of a one or more"			\
		"CLUT or unit test exercise."
  #
  EchoPara80	"A passing grade is granted for a test program when the program produces output"		\
		"that matches its expected/golden baseline output."						\
		"Comparisons are made to output files only after they are masked to remove"			\
		"non-deterministic values (e.g. dates, times, account names)."
  #
  EchoPara80	"Masking is performed by a user-defined sed script;"						\
		"the mask-sed-script configuration value can be used to specify the location of that script."
  #
  EchoPara80	"A 'grade last' request with grade the output associated with the last make target processed"	\
		"by kamaji the last time it was invoked."							\
		"The \"last\" target is the same no matter where it appears in the list of targets"		\
		"passed to a 'grade' request."
  #
  EchoPara80	"A 'grade' request without any specific targets is the same as a 'grade' request for all known"	\
		"targets."											\
		"Furthermore, those targets will be evaluated based when their base sources were"		\
		"last modified."										\
		"In this way, when the user modifies the source file for a specific CLUT or unit test,"		\
		"then kamaji will give evaluation of that test a higher priority than for all others."
  #
  EchoPara80	"Although grades are identified using the \"grade\" file name extension,"			\
		"the actual grade is not stored."								\
		"This practice will cause kamaji to evaluate a CLUT or unit test exercise,"			\
		"and display the assigned grade, every time the user requests it."				\
		"As such, the user will get explicit grade feedback for every test every time it is requested."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_export() {
  #
  local -r Request="${1}"
  #
  EchoPara80	"$(echoInColorWhiteBold "Export...")"
  #
  EchoPara80	"The kamaji script defines a ruleset that it uses to guide creation of every"			\
		"file in the working-folder;"									\
		"to determine what files need to be made or re-made, and the"					\
		"proper order in which that should happen."
  #
  EchoPara80	"By default, kamaji generates its ruleset every time it is called"				\
		"so that it can properly react to dramatic changes in the baseline-folder."			\
  		"As the ruleset only changes when files are added or removed from the baseline-folder, it is"	\
		"inefficient to regenerate the ruleset when the baseline-folder has not changed in this way."
  #
  EchoPara80	"Users can request that kamaji export its current ruleset for future use"			\
		"using the 'export' request."									\
		"The ruleset-file-name configuration variable can be used to"					\
		"name the file in which the ruleset is stored."
  #
  EchoPara80	"The 'fast' modifier can be used to ask kamaji to"						\
		"load an exported ruleset instead of generating one itself."					\
		"The 'fast' modifier will generate and export a ruleset when it does not find one to load."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_invoke() {
  #
  local -r Request="${1}"
  #
  EchoPara80	"$(echoInColorWhiteBold "Execute|Invoke|Run...")"
  #
  EchoPara80	"An 'invoke' request causes each CLUT or unit test exercise to be executed."			\
		"Output from each CLUT or unit test exercise is captured in an output file."
  #
  EchoPara80	"An 'invoke last' request will invoke the last make target processed"				\
		"by kamaji the last time it was itself invoked."						\
		"The \"last\" target is the same no matter where it appears in the list of targets"		\
		"passed to an 'invoke' request."
  #
  EchoPara80	"An 'invoke' request without any specific targets is the same as an 'invoke' request for"	\
		"all known targets."										\
		"Furthermore, those targets will be invoked based when their base sources were"			\
		"last modified."										\
		"In this way, when the user modifies the source file for a specific CLUT or unit test,"		\
		"then kamaji will give output generation for that test a higher priority than for all others."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_make() {
  #
  local -r Request="${1}"
  #
  EchoPara80	"$(echoInColorWhiteBold "Make...")"
  #
  EchoPara80	"Users can request that kamaji generate one or more specific files by naming them in"		\
		"a 'make' request."										\
		"When the user asks kamaji to make a file that is already the most up-to-date version of"	\
		"itself, then kamaji ignores the request; it is not an error."					\
		"Files are only remade after the files that thay are created from are remade, if necessary."	\
		"Files are only remade when files that thay are created from have changed;"			\
		"either because the user changed them or because they themselves were remade."
  #
  EchoPara80	"A 'make grades' request is the same as a 'grade' request: Every output file is generated,"	\
		"compared to its associated baseline, and then graded based on that comparision."
  #
  EchoPara80	"A 'make outputs' request is the same as an 'invoke' request: Every output file is generated."
  #
  EchoPara80	"A 'make last' request will attempt to remake the last specific target of"			\
		"a 'grade' or 'invoke' or 'make' request."							\
		"This is an especially useful shorthand when kamaji is used for test-driven development."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_review() {
  #
  local -r Request="${1}"
  #
  EchoPara80	"$(echoInColorWhiteBold "Review...")"
  #
  EchoPara80	"A 'review' request can be used to inspect the masked output differences that led to a"		\
		"failed grade."											\
		"The 'review' request is very similar to the 'grade' request:"					\
		"Reviews are based on grades, and they are always performed for failing grades."		\
		"After you review a failing grade, then kamaji will make it easy to baseline the new output."
  #
  EchoPara80	"The default command used to perform is vimdiff;"						\
		"it is used to present differences between the baseline and new output,"			\
		"with the masked baseline output in the left pane and the new output in the right pane."
  #
  EchoPara80	"Users not familiar with the editor may want to make note of the following vim commands:"	\
		"the :help command to request help; the :qa command to exit the editor;"			\
		"the h, j, k, l, and arrow keys to move around in a pane;"					\
		"and the [ctrl]-h, [ctrl]-l, and [ctrl]-w combinations to switch panes."
  #
  EchoPara80	"The review-command configuration variable can be used to change the command used to perform a"	\
		"review; the comand may be decorated with any number of options."				\
		"The command is called from within the working-folder, and is passed the"			\
		"masked baseline output and masked current output files in that order."				\
		"A script can be used as a facade to make the simple, two-parameter interface"			\
		"match a command that requires something else."
  #
  EchoPara80	"The review-tailpipe configuration variable can be used to define a command into which the"	\
		"review-command output is piped."								\
		"For example, if you set the review-command to \"diff\" then you might want to"			\
		"set the review-tailpipe to \"sed --expression='s,^,    ,' | less\" so that the diff"		\
		"output will be indented, you can view that output a page at a time, and that output will not"	\
		"clutter your display after your review."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_show() {
  #
  local -r Request="${1}"
  #
  EchoPara80	"$(echoInColorWhiteBold "Show...")"
  #
  EchoPara80	"The 'show' request is used to produce makefiles that can be used to integrate kamaji into"	\
		"a makefile system."										\
		"Two forms of makefile may be produced: explicit and layered."					\
		"An explicit makefile contains a rule for every target that can be used in kamaji"		\
		"make requests."										\
		"A layered makefile only contains rules for the most computing-intensive targets,"		\
		"so that the load-balancing aspects of a makefile can be used without"				\
		"translating every relationship into a makefle rule."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_fast() {
  #
  local -r Request="${1}"
  #
  EchoPara80	"$(echoInColorWhiteBold "Fast...")"
  #
  EchoPara80	"When the number of files in the baseline-folder does not change,"				\
		"the 'fast' modifier can be used to improve the efficiency of kamaji."				\
		"When the 'fast' modifier is used,"								\
		"kamaji loads a stored ruleset instead of generating a new one."				\
		"An 'export ruleset' request can be used to store the current ruleset."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_usage() {
  #
  local -r Request="${1}"
  #
  EchoPara80	"$(echoInColorWhiteBold "Usage|Help...")"
  #
  EchoPara80	"You can get addition help by specifying the modifier or request you are interested"		\
		"in after the 'usage' or 'help' keyword."							\
		"For example, \"${__KamajiScriptName} help silent\" and \"${__KamajiScriptName} usage export\""
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_verbose_and_silent() {
  #
  local -r Request="${1}"
  #
  EchoPara80	"$(echoInColorWhiteBold "Verbose|Noisy and Silent|Quiet...")"
  #
  EchoPara80	"Three levels of diagnostic output are controlled by the verbose and silent modifiers:"		\
		"A single verbose modifier is a request for light diagnostic output."				\
		"Multiple verbose modifiers will produce heavy diagnostic output."				\
		"The silent modifier turns off all diagnostic output."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierFast() {
  #
  local -r Modifier=${1}
  shift 1
  local -r ModifiedRequest="${*}"
  #
  [ "${__KamajiRulesetIsReady}" = "true" ] && KamajiMain ${ModifiedRequest} && return
  #
  local -r RulesetFName=$(KamajiConfigurationEchoValue ruleset-file-name .kamaji.ruleset.bash)
  #
  local -r RulesetFSpec=${__KamajiWorkinDSpec}/${RulesetFName}
  #
  if [ ! -s ${RulesetFSpec} ]
  then
     #
     __KamajiRulesetIsReady="save"
     #
     KamajiMain ${ModifiedRequest}
     #
     return
     #
  fi
  #
  DiagnosticHeavy "source ${RulesetFSpec}"
  #
  source ${RulesetFSpec}
  #
  __KamajiRulesetIsReady="true"
  #
  KamajiMain ${ModifiedRequest}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierSilent() {
  #
  local -r Modifier=${1}
  shift 1
  local -r ModifiedRequest="${*}"
  #
  __KamajiVerbosityRequested="quiet"
  #
  KamajiMain ${ModifiedRequest}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage() {
  #
  local -r Modifier=${1}
  shift 1
  local -r ModifiedRequest="${*}"
  #
  exec 1>&2
  #
  echo "$(echoInColorYellow USAGE:) ${__KamajiScriptName} [<modifier>]... [<request>] [<parameter>]..."
  echo ""
  echo "Where <modifier> is one of the following:"
  echo "      fast"
  echo "      help"
  echo "      silent"
  echo "      verbose"
  echo ""
  echo "Where <request> is one of the following:"
  echo "      bless  [ <filename> | last ]..."
  echo "      export [ ruleset ]"
  echo "      grade  [ <filename> | last ]..."
  echo "      invoke [ <filename> | last ]..."
  echo "      make   [ <filename> | last | grades | outputs ]..."
  echo "      review [ <filename> | last ]..."
  echo "      set    <name> <value>"
  echo "      show   [ makefile [ explicit | layered ] ]"
  echo ""
  #
  declare -A UsageModifierSubjectList
  #
  UsageModifierSubjectList[baseline]=bless
  UsageModifierSubjectList[bless]=bless
  UsageModifierSubjectList[configure]=configure
  UsageModifierSubjectList[export]=export
  UsageModifierSubjectList[execute]=invoke
  UsageModifierSubjectList[fast]=fast
  UsageModifierSubjectList[grades]=grades
  UsageModifierSubjectList[invoke]=invoke
  UsageModifierSubjectList[help]=usage
  UsageModifierSubjectList[make]=make
  UsageModifierSubjectList[noisy]=verbose_and_silent
  UsageModifierSubjectList[quiet]=verbose_and_silent
  UsageModifierSubjectList[review]=review
  UsageModifierSubjectList[run]=invoke
  UsageModifierSubjectList[set]=configure
  UsageModifierSubjectList[show]=show
  UsageModifierSubjectList[silent]=verbose_and_silent
  UsageModifierSubjectList[usage]=usage
  UsageModifierSubjectList[verbose]=verbose_and_silent
  #
  local    ModifiedCorrected="NA"
  #
  if [ ${#ModifiedRequest} -gt 0 ]
  then
     ModifiedCorrected=$(EchoMeaningOf ${ModifiedRequest} "NA" ${!UsageModifierSubjectList[*]})
  fi
  #
  if [ "${ModifiedCorrected}" = "NA" ]
  then
     #
     EchoPara80	"Synonyms configure (set), noisy (verbose), quiet (silent), and usage (help)"			\
		"are supported."										\
		"Modifier and request abbreviations are also supported;"					\
		"ambiguity is resolved using alphabetical order."						\
		"No other modifiers or requests are applied after a usage request is fulfilled."
     #
     EchoPara80	"Further help may be displayed by following the usage request by the subject of interest;"	\
		"for example, \"${__KamajiScriptName} help fast\" or \"${__KamajiScriptName} usage grade\""
     #
     EchoPara80	"CLUT cases and unit test exercises are used and evaluated in similar ways:"			\
		"compile it (if not already executable), invoke it to produce output, mask that output,"	\
		"compare the masked output to its baseline, and then grade it based on that comparison."
     #
     EchoPara80	"CLUT definitions are compiled into Bash scripts."						\
		"Unit test exercises may be written in compilable code or a scripting language."		\
		"Compilable code must be compiled and linked into executable files using a make framework."	\
		"Scripts need not be compiled."
     #
     EchoPara80	"CLUT cases and unit test exercises produce demonstrative output that need not be"		\
		"valid or invalid on its face."									\
		"Users must evaluate the initial output from these tests to determine whether it is valid;"	\
		"valid output must be blessed by the user and copied to a safe location as baseline output."	\
		"Future changes to the tested code will result in output that differs from the baseline;"	\
		"these differences should also be blessed to update the baseline."				\
		"Users will benefit from retesting frequently"							\
		"between minor and controlled functional changes to the code being tested."
     #
     EchoPara80	"Passing grades are only granted when current output matches baseline output,"			\
		"but this matching is only attempted after the current and baseline output are masked."		\
		"Masking is performed using a user-defined sed script."
     #
  else
     #
     local -r FunctionWeWant=${FUNCNAME}_${UsageModifierSubjectList[${ModifiedCorrected}]}
     #
     local -r FunctionToCall=$(declare -F ${FunctionWeWant})
     #
     [ ${#FunctionToCall} -gt 0 ] && ${FunctionToCall} ${Modifier} ${ModifiedCorrected}
     #
  fi
  #
  false
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierVerbose() {
  #
  local -r Modifier=${1}
  shift 1
  local -r ModifiedRequest="${*}"
  #
  if [ "${__KamajiVerbosityRequested}" = "quiet" ]
  then
     #
     __KamajiVerbosityRequested="light"
     #
  elif [ "${__KamajiVerbosityRequested}" = "light" ]
  then
     #
     __KamajiVerbosityRequested="heavy"
     #
  fi
  #
  KamajiMain ${ModifiedRequest}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiBuildRulesForTestingSource_Clut() {
  #
  local -r SourceFSpec=${1}
  local -r SourceFType=${2-}
  #
  local -r SourceFName=$(basename ${SourceFSpec})
  #
  #  Determine the CLU specification.
  #
  local -r RunnerDList="$(find ${__KamajiGoldenDSpec} -type d) ${PATH//:/ }"
  #
  local    RunnerFSpec=
  #
  for RunnerFSpec in $(EchoExecutableFilesMatching ${SourceFName%.${SourceFType}} ${RunnerDList})
  do
    #
    [ "${RunnerFSpec//clut.bash/}" != "${RunnerFSpec}" ] && continue
    #
    if [ "${RunnerFSpec:0:1}" != "/" ]
    then
       if [ "${RunnerFSpec:0:2}" = "./" ]
       then
	  RunnerFSpec=".${RunnerFSpec}"
       else
          RunnerFSpec="../${RunnerFSpec}"
       fi
    fi
    #
    break
    #
  done
  #
  [ ${#RunnerFSpec} -eq 0 ] && EchoErrorAndExit 1 "Unable to find the executable file exercised by ${SourceFSpec}."
  #
  local -r RunnerFName=$(basename ${RunnerFSpec})
  #
  #  __KamajiRepresentative[TargetFName]="SourceFSpec": What external file does this file name represent?
  #
  #  All SourceFSpec are somewhere in __KamajiGoldenDSpec. All TargetFName are in __KamajiWorkinDSpec.
  #
  #  Root representatives are links in the __KamajiWorkinDSpec to files in the __KamajiGoldenDSpec.
  #
  #  __KamajiRepresentative allow Kamaji to assume most complicated work is done in __KamajiWorkinDSpec.
  #
  __KamajiRepresentative["${SourceFName}"]="../${SourceFSpec}"
  __KamajiRepresentative["${RunnerFName}"]="${RunnerFSpec}"
  #
  #  __KamajiBaseSourceList[TargetFName]=SourceFName: What recipe should I follow given FName as a target?
  #
  #  All SourceFName are somewhere in __KamajiGoldenDSpec. All TargetFName are in __KamajiWorkinDSpec.
  #
  #  __KamajiBaseSourceList is used to determine where to start the evaluation process for a target given by the user.
  #
  #  The golden output file may not be in the same location as the CLUT file.
  #
  #						Key: TargetFName		Data: SourceFSpec
  #						----------------		-----------------
  AppendArrayIndexValue __KamajiBaseSourceList	"${RunnerFName}"		"${RunnerFSpec}"
  #						----------------		-----------------
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFName}"		"${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFName}.bash"		"${RunnerFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFName}.bash"		"${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFName}.output"		"${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFName}.output.masked"	"${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFName}.output.delta"	"${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFName}.output.grade"	"${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFName}.output.review"	"${SourceFSpec}"
  #						----------------		-----------------
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFName}.output.masked"	"${__KamajiSedScriptFSpec}"
  #						----------------		-----------------
  #
  #  __KamajiMyChildrenList[SourceFName]="TargetFName...": What files are created directly from this source?
  #
  #  All SourceFName and TargetFName are in __KamajiWorkinDSpec.
  #
  #  The __KamajiMyChildrenList is used to determine of the target needs to be re-created.
  #
  #						Key: SourceFName		Data: TargetFName
  #						----------------		-----------------
  AppendArrayIndexValue __KamajiMyChildrenList	"${RunnerFName}"		"${SourceFName}.bash"
  AppendArrayIndexValue __KamajiMyChildrenList	"${SourceFName}"		"${SourceFName}.bash"
  AppendArrayIndexValue __KamajiMyChildrenList	"${SourceFName}.bash"		"${SourceFName}.output"
  AppendArrayIndexValue __KamajiMyChildrenList	"${SourceFName}.output"		"${SourceFName}.output.masked"
  AppendArrayIndexValue __KamajiMyChildrenList	"${SourceFName}.output.masked"	"${SourceFName}.output.delta"
  AppendArrayIndexValue __KamajiMyChildrenList	"${SourceFName}.output.delta"	"${SourceFName}.output.grade"
  AppendArrayIndexValue __KamajiMyChildrenList	"${SourceFName}.output.delta"	"${SourceFName}.output.review"
  AppendArrayIndexValue __KamajiMyChildrenList	"${SourceFName}.output.grade"	"${SourceFName}.output.review"
  #						----------------		-----------------
  AppendArrayIndexValue __KamajiMyChildrenList	"${__KamajiSedScriptFName}"	"${SourceFName}.output.masked"
  #						----------------		-----------------
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiBuildRulesForTestingSource_Elf() {
  #
  local -r SourceFSpec=${1}
  local -r SourceFType=${2-}
  #
  local -r SourceFName=$(basename ${SourceFSpec})
  #
  local -r SourceFRoot=${SourceFName%.${SourceFType}}
  #
  #  __KamajiRepresentative[TargetFName]="SourceFSpec": What external file does this file name represent?
  #
  #  All SourceFName are somewhere in __KamajiGoldenDSpec. All TargetFName are in __KamajiWorkinDSpec.
  #
  #  Root representatives are links in the __KamajiWorkinDSpec to files in the __KamajiGoldenDSpec.
  #
  #  __KamajiRepresentative allow Kamaji to assume most complicated work is done in __KamajiWorkinDSpec.
  #
  __KamajiRepresentative["${SourceFName}"]="../${SourceFSpec}"
  #
  #  __KamajiBaseSourceList[TargetFName]=SourceFName: What recipe should I follow given FName as a target?
  #
  #  All SourceFName are in __KamajiGoldenDSpec. All TargetFName are in __KamajiWorkinDSpec.
  #
  #  __KamajiBaseSourceList is used to determine where to start the evaluation process for a target given by the user.
  #
  #						Key: TargetFName		Data: SourceFSpec
  #						----------------		-----------------
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFRoot}"		"${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFRoot}.output"		"${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFRoot}.output.masked"	"${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFRoot}.output.delta"	"${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFRoot}.output.grade"	"${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFRoot}.output.review"	"${SourceFSpec}"
  #						----------------		-----------------
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFRoot}.output.masked"	"${__KamajiSedScriptFSpec}"
  #						----------------		-----------------
  #
  #  __KamajiMyChildrenList[SourceFName]="TargetFName...": What files are created directly from this source?
  #
  #  All SourceFName and TargetFName are in __KamajiWorkinDSpec.
  #
  #  The __KamajiMyChildrenList is used to determine of the target needs to be re-created.
  #
  #						Key: SourceFName		Data: TargetFName
  #						----------------		-----------------
  AppendArrayIndexValue	__KamajiMyChildrenList	"${SourceFName}"		"${SourceFRoot}"
  AppendArrayIndexValue	__KamajiMyChildrenList	"${SourceFRoot}"		"${SourceFRoot}.output"
  AppendArrayIndexValue	__KamajiMyChildrenList	"${SourceFRoot}.output"		"${SourceFRoot}.output.masked"
  AppendArrayIndexValue	__KamajiMyChildrenList	"${SourceFRoot}.output.masked"	"${SourceFRoot}.output.delta"
  AppendArrayIndexValue	__KamajiMyChildrenList	"${SourceFRoot}.output.delta"	"${SourceFRoot}.output.grade"
  AppendArrayIndexValue	__KamajiMyChildrenList	"${SourceFRoot}.output.delta"	"${SourceFRoot}.output.review"
  AppendArrayIndexValue	__KamajiMyChildrenList	"${SourceFRoot}.output.grade"	"${SourceFRoot}.output.review"
  #						----------------		-----------------
  AppendArrayIndexValue __KamajiMyChildrenList	"${__KamajiSedScriptFName}"	"${SourceFRoot}.output.masked"
  #						----------------		-----------------
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiBuildRulesForTestingSource_Output() {
  #
  local -r SourceFSpec=${1}
  local -r SourceFType=${2-}
  #
  local -r SourceFName=$(basename ${SourceFSpec})
  #
  local -r SourceFRoot=${SourceFName%.${SourceFType}}
  #
  #  __KamajiRepresentative[TargetFName]="SourceFSpec": What external file does this file name represent?
  #
  #  All SourceFName are somewhere in __KamajiGoldenDSpec. All TargetFName are in __KamajiWorkinDSpec.
  #
  #  Root representatives are links in the __KamajiWorkinDSpec to files in the __KamajiGoldenDSpec.
  #
  #  __KamajiRepresentative allow Kamaji to assume most complicated work is done in __KamajiWorkinDSpec.
  #
  __KamajiRepresentative["${SourceFRoot}.golden"]="../${SourceFSpec}"
  #
  #  __KamajiBaseSourceList[TargetFName]=SourceFName: What recipe should I follow given FName as a target?
  #
  #  All SourceFName are in __KamajiGoldenDSpec. All TargetFName are in __KamajiWorkinDSpec.
  #
  #  __KamajiBaseSourceList is used to determine where to start the evaluation process for a target given by the user.
  #
  #						Key: TargetFName		Data: SourceFSpec
  #						----------------		-----------------
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFRoot}.golden"		"${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFRoot}.golden.masked"	"${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFRoot}.output.delta"	"${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFRoot}.output.grade"	"${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFRoot}.output.review"	"${SourceFSpec}"
  #						----------------		-----------------
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFRoot}.golden.masked"	"${__KamajiSedScriptFSpec}"
  #						----------------		-----------------
  #
  #  __KamajiMyChildrenList[SourceFName]="TargetFName...": What files are created directly from this source?
  #
  #  All SourceFName and TargetFName are in __KamajiWorkinDSpec.
  #
  #  The __KamajiMyChildrenList is used to determine of the target needs to be re-created.
  #
  #						Key: SourceFName		Data: TargetFName
  #						----------------		-----------------
  AppendArrayIndexValue	__KamajiMyChildrenList	"${SourceFRoot}.golden"		"${SourceFRoot}.golden.masked"
  AppendArrayIndexValue	__KamajiMyChildrenList	"${SourceFRoot}.golden.masked"	"${SourceFRoot}.output.delta"
  #						----------------		-----------------
  AppendArrayIndexValue __KamajiMyChildrenList	"${__KamajiSedScriptFName}"	"${SourceFRoot}.golden.masked"
  #						----------------		-----------------
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiBuildRulesForTestingSource_Script() {
  #
  local -r SourceFSpec=${1}
  local -r SourceFType=${2-}
  #
  local -r SourceFName=$(basename ${SourceFSpec})
  #
  local -r SourceFRoot=${SourceFName%.${SourceFType}}
  #
  #  __KamajiRepresentative[TargetFName]="SourceFSpec": What external file does this file name represent?
  #
  #  All SourceFName are somewhere in __KamajiGoldenDSpec. All TargetFName are in __KamajiWorkinDSpec.
  #
  #  Root representatives are links in the __KamajiWorkinDSpec to files in the __KamajiGoldenDSpec.
  #
  #  __KamajiRepresentative allow Kamaji to assume most complicated work is done in __KamajiWorkinDSpec.
  #
  __KamajiRepresentative["${SourceFName}"]="../${SourceFSpec}"
  #
  #  __KamajiBaseSourceList[TargetFName]=SourceFName: What recipe should I follow given FName as a target?
  #
  #  All SourceFName are in __KamajiGoldenDSpec. All TargetFName are in __KamajiWorkinDSpec.
  #
  #  __KamajiBaseSourceList is used to determine where to start the evaluation process for a target given by the user.
  #
  #						Key: TargetFName		Data: SourceFSpec
  #						----------------		-----------------
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFRoot}"		"${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFRoot}.output"		"${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFRoot}.output.masked"	"${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFRoot}.output.delta"	"${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFRoot}.output.grade"	"${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFRoot}.output.review"	"${SourceFSpec}"
  #						----------------		-----------------
  AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFRoot}.output.masked"	"${__KamajiSedScriptFSpec}"
  #						----------------		-----------------
  #
  #  __KamajiMyChildrenList[SourceFName]="TargetFName...": What files are created directly from this source?
  #
  #  All SourceFName and TargetFName are in __KamajiWorkinDSpec.
  #
  #  The __KamajiMyChildrenList is used to determine of the target needs to be re-created.
  #
  #						Key: SourceFName		Data: TargetFName
  #						----------------		-----------------
  AppendArrayIndexValue	__KamajiMyChildrenList	"${SourceFName}"		"${SourceFRoot}.output"
  AppendArrayIndexValue	__KamajiMyChildrenList	"${SourceFRoot}.output"		"${SourceFRoot}.output.masked"
  AppendArrayIndexValue	__KamajiMyChildrenList	"${SourceFRoot}.output.masked"	"${SourceFRoot}.output.delta"
  AppendArrayIndexValue	__KamajiMyChildrenList	"${SourceFRoot}.output.delta"	"${SourceFRoot}.output.grade"
  AppendArrayIndexValue	__KamajiMyChildrenList	"${SourceFRoot}.output.delta"	"${SourceFRoot}.output.review"
  AppendArrayIndexValue	__KamajiMyChildrenList	"${SourceFRoot}.output.grade"	"${SourceFRoot}.output.review"
  #						----------------		-----------------
  AppendArrayIndexValue __KamajiMyChildrenList	"${__KamajiSedScriptFName}"	"${SourceFRoot}.output.masked"
  #						----------------		-----------------
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiBuildRulesForTestingSource_Unknown() {
  #
  local -r SourceFSpec=${1}
  local -r SourceFType=${2-}
  #
  local -r SourceFName=$(basename ${SourceFSpec})
  #
  local -r ConfiguredIgnoredExtensionList=$(KamajiConfigurationEchoValue data-extension-list "bak swp")
  #
  local -r ListOfIgnoreFType=":${ConfiguredIgnoredExtensionList// /:}:"
  #
  local -r LessOfIgnoreFType="${ListOfIgnoreFType/:${SourceFType}:/}"
  #
# __KamajiRepresentative["${SourceFName}"]="../${SourceFSpec}"
  #
  if [ ${#LessOfIgnoreFType} -eq ${#ListOfIgnoreFType} ]
  then
     #
     DiagnosticLight "# Ignoring ${SourceFSpec} (unknown classification)."
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiBuildRulesForTestingSource() {
  #
  local -r SourceFSpec=${1}
  #
  local -r SourceFName=$(basename ${SourceFSpec})
  local -r SourceFType=$(Xtension ${SourceFName})
  #
  local -r DataFileNameLess=${__KamajiDataFileNameList/:${SourceFName}:/}
  #
  local    TargetFName
  #
  if [ ${#DataFileNameLess} -ne ${#__KamajiDataFileNameList} ]
  then
     #
     #  __KamajiRepresentative[TargetFName]="SourceFSpec": What external file does this file name represent?
     #
     __KamajiRepresentative["${SourceFName}"]="../${SourceFSpec}"
     #
     AppendArrayIndexValue __KamajiMyParentalList "${SourceFName}" ""
     #
     return
     #
  fi
  #
  local    SourceClass=$(KamajiFileClassification ${SourceFSpec} ${SourceFType})
  #
  local -r FunctionWeWant=${FUNCNAME}_${SourceClass}
  #
  local -r FunctionToCall=$(declare -F ${FunctionWeWant})
  #
  [ ${#FunctionToCall} -eq 0 ] && KamajiExitAfterUsage "Fatal programming flaw; ${FunctionWeWant} is undefined."
  #
  ${FunctionToCall} ${SourceFSpec} ${SourceFType}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiBuildRulesLoadXtraDependents() {
  #
  local Directory ExternFSpec ExternFName TargetFSpec TargetFName
  #
  for Directory in . ${HOME}
  do
    #
    if [ -s ${Directory}/${__KamajiXtraDependentFName} ]
    then
       #
       while read ExternFSpec TargetFSpec
       do
         #
         if [ -s ${ExternFSpec} ]
	 then
            #
	    #  __KamajiXtraParentList[TargetFName]="SourceFName...": What files are user-defined sources of target?
            #
            ExternFName=$(basename ${ExternFSpec})
            TargetFName=$(basename ${TargetFSpec})
            #
            [ "${ExternFSpec:0:1}" != "/" ] && ExternFSpec="../${ExternFSpec}"
            #
	    AppendArrayIndexValue __KamajiXtraParentList "${TargetFName}" "${ExternFName}"
            #
	    __KamajiRepresentative["${ExternFName}"]="../${ExternFSpec}"
            #
         else
            #
            EchoErrorAndExit 1 "Errant specification in extra dependant file: Cannot find the '${ExternFSpec}' file."
            #
         fi
         #
       done < ${Directory}/${__KamajiXtraDependentFName}
       #
    fi
    #
  done
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiBuildRules() {
  #
  if [ ! -d ${__KamajiGoldenDSpec} ]
  then
     KamajiExitAfterUsage "The baseline directory '${__KamajiGoldenDSpec}' does not exist."
  fi
  #
  local -r ListOfSourceFSpec=$(find ${__KamajiGoldenDSpec} -type f)
  #
  local    ItemOfSourceFSpec SourceFName SourceFSpec SourceClass
  #
  #  The Masking sed script is also golden.
  #
  #  __KamajiRepresentative[TargetFName]="SourceFSpec": What external file does this file name represent?
  #  __KamajiBaseSourceList[TargetFName]="SourceFName": What recipe should I follow given FName as a target?
  #  __KamajiMyChildrenList[SourceFName]="TargetFName...": What files are created directly from this source?
  #
  __KamajiRepresentative["${__KamajiSedScriptFName}"]="../${__KamajiSedScriptFSpec}"
  #
  AppendArrayIndexValue __KamajiBaseSourceList "${__KamajiSedScriptFName}" " ${__KamajiSedScriptFName}"
  AppendArrayIndexValue __KamajiMyParentalList "${__KamajiSedScriptFName}" ""
  #
  #  Gather source rules.
  #
  for ItemOfSourceFSpec in ${ListOfSourceFSpec}
  do
    #
    KamajiBuildRulesForTestingSource ${ItemOfSourceFSpec}
    #
  done
  #
  #  Build the list of parents.
  #
  #  __KamajiMyParentalList[TargetFName]="SourceFName...": What files are direct sources of this target?
  #
  for ParentFName in ${!__KamajiMyChildrenList[*]}
  do
    #
    for ChildsFName in ${__KamajiMyChildrenList[${ParentFName}]}
    do
      #
      AppendArrayIndexValue __KamajiMyParentalList "${ChildsFName}" "${ParentFName}"
      AppendArrayIndexValue __KamajiMyParentalList "${ParentFName}" ""
      #
    done
    #
  done
  #
  #  Build the list of phony targets.
  #
  #  __KamajiClassifiedList[TargetPhony]="SourceFName...": What files are direct sources of this target?
  #
  __KamajiClassifiedList[Grade]=
  __KamajiClassifiedList[Output]=
  __KamajiClassifiedList[Review]=
  #
  for SourceFName in ${!__KamajiMyParentalList[*]}
  do
    #
    SourceClass=$(KamajiFileClassification ${SourceFName} $(Xtension ${SourceFName}))
    #
    AppendArrayIndexValue __KamajiClassifiedList "${SourceClass}" "${SourceFName}"
    #
  done
  #
  #  If the user requested a fast build without a saved ruleset then save the current ruleset for use next time.
  #
  [ "${__KamajiRulesetIsReady}" = "save" ] && KamajiRequestExport_ruleset export ruleset
  #
  #  Mark the ruleset ready.
  #
  __KamajiRulesetIsReady="true"
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestBless() {
  #
  local -r Request=${1}
  shift 1
  local -r SourceFList="${*}"
  #
  local    SourceFName TargetFName GoldenDSpec GoldenFName
  #
  local    TargetFList=
  #
  if [ ${#SourceFList} -eq 0 ]
  then
     #
     TargetFList=${__KamajiClassifiedList[Review]}
     #
  else
     #
     for SourceFSpec in ${SourceFList}
     do
       #
       SourceFName=$(basename ${SourceFSpec})
       #
       #  Support a request for a ${Request} based on the last target.
       #  Otherwise, check to see that the target is one that we know.
       #
       if [ "${SourceFName}" = "last" ]
       then
          #
          #  Use the last target as the target here.
          #
          [ -e ${__KamajiLastMakeTargetFSpec} ] || continue
          #
          SourceFName=$(cat ${__KamajiLastMakeTargetFSpec})
          #
       elif [ "${__KamajiBaseSourceList[${SourceFName}]+IS_SET}" != "IS_SET" ]
       then
          #  
          EchoErrorAndExit 1 "The '${SourceFName}' file cannot be ${Request}ed; it is not a known derivative."  
          #  
       fi
       #
       #  Find the Review decendants of the target.
       #
       TargetFList+=" $(KamajiEchoListOfDecendantFName ${SourceFName} Review)"
       #  
     done
     #
  fi
  #
  for TargetFName in ${TargetFList}
  do
    #
    if [ -e ${__KamajiWorkinDSpec}/${TargetFName}ed ]
    then
       #
       #  Save the target name to support the next "make last" request.
       #
       DiagnosticLight "${__KamajiScriptName} ${Request} ${TargetFName}"
       #
       echo "${TargetFName}" > ${__KamajiLastMakeTargetFSpec}
       #
       #  Determine the golden output file associated with this output.
       #
       GoldenFName=${TargetFName%.output.review}.golden
       #
       GoldenDSpec=$(dirname ${__KamajiRepresentative[${GoldenFName}]})
       #
       #  Replace the golden output file with the current one.
       #
       EchoAndExecuteInWorking "cp ${TargetFName%.review} ${GoldenDSpec}"
       #
       #  Remove the reviewed file so that it cannot be used again.
       #
       EchoAndExecuteInWorking "rm ${TargetFName}ed"
       #
    fi
    #
  done
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestConfigure() {
  #
  local -r Request=${1}
  local -r Name="${2}"
  shift 2
  local -r Value="${*}"
  #
  DiagnosticLight "${__KamajiScriptName} ${Request} ${Name} ${Value}"
  #
  echo "${Name} ${Value}" >> ./${__KamajiConfigurationFName}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestExport_ruleset() {
  #
  local -r Request=${1}
  local -r Object=${2}
  #
  local -r RulesetFName=$(KamajiConfigurationEchoValue ruleset-file-name .kamaji.ruleset.bash)
  #
  local -r RulesetFSpec=${__KamajiWorkinDSpec}/${RulesetFName}
  #
  local    ArrayName ArrayReference
  #
  DiagnosticLight "${__KamajiScriptName} ${Request} ${Object}"
  #
  if [ "${__KamajiBaseSourceList[${RulesetFName}]+IS_SET}" = "IS_SET" ]
  then
     #  
     EchoErrorAndExit 1 "The '${RulesetFName}' name cannot be used to store the ruleset."
     #  
  fi
  #
  [ -e ${RulesetFSpec} ] && EchoAndExecuteInWorking mv ${RulesetFName} ${RulesetFName}.was
  #
  spit ${RulesetFSpec} "#"
  spit ${RulesetFSpec} "#  ${RulesetFSpec}"
  spit ${RulesetFSpec} "#"
  spit ${RulesetFSpec} "#  __KamajiBaseSourceList[TargetFName]=\"SourceFName\":"			\
				"What recipe should I follow given FName as a target?"
  spit ${RulesetFSpec} "#  __KamajiClassifiedList[TargetPhony]=\"SourceFName...\":"			\
				"What files are direct sources of this target?"
  spit ${RulesetFSpec} "#  __KamajiMyChildrenList[SourceFName]=\"TargetFName...\":"			\
				"What files are created directly from this source?"
  spit ${RulesetFSpec} "#  __KamajiMyParentalList[TargetFName]=\"SourceFName...\":"			\
				"What files are direct sources of this target?"
  spit ${RulesetFSpec} "#  __KamajiRepresentative[TargetFName]=\"SourceFSpec\":"			\
				"What external file does this file name represent?"
  spit ${RulesetFSpec} "#  __KamajiXtraParentList[TargetFName]=\"SourceFName...\":"			\
				"What files are user-defined sources of target?"
  spit ${RulesetFSpec} "#"
  spit ${RulesetFSpec} "#  Where FName == file name within the working-folder"
  spit ${RulesetFSpec} "#        FName == file specification outside of the working-folder"
  #
  KamajiEchoArrayAssignments __KamajiBaseSourceList ${!__KamajiBaseSourceList[*]} | sort >> ${RulesetFSpec}
  KamajiEchoArrayAssignments __KamajiClassifiedList ${!__KamajiClassifiedList[*]} | sort >> ${RulesetFSpec}
  KamajiEchoArrayAssignments __KamajiMyChildrenList ${!__KamajiMyChildrenList[*]} | sort >> ${RulesetFSpec}
  KamajiEchoArrayAssignments __KamajiMyParentalList ${!__KamajiMyParentalList[*]} | sort >> ${RulesetFSpec}
  KamajiEchoArrayAssignments __KamajiRepresentative ${!__KamajiRepresentative[*]} | sort >> ${RulesetFSpec}
  KamajiEchoArrayAssignments __KamajiXtraParentList ${!__KamajiXtraParentList[*]} | sort >> ${RulesetFSpec}
  #
  spit ${RulesetFSpec} "#"
  spit ${RulesetFSpec} "#  (eof)"
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestExport() {
  #
  local -r Request=${1}
  local -r Object=${2-ruleset}
  shift 2
  local -r ArgumentList="${*}"
  #
  local -r FunctionWeWant=${FUNCNAME}_${Object}
  #
  local -r FunctionToCall=$(declare -F ${FunctionWeWant})
  #
  [ ${#FunctionToCall} -eq 0 ] && KamajiExitAfterUsage "Unable to '${Request} ${Object}' objects."
  #
  ${FunctionToCall} ${Request} ${Object} ${ArgumentList}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestGradeOrOutputOrReview() {
  #
  local -r Request=${1}
  local -r TargetClass=${2}
  shift 2
  local -r SourceFList="${*}"
  #
  local    SourceFName TargetFName
  #
  local    TargetFList=
  #
  if [ ${#SourceFList} -eq 0 ]
  then
     #
     if [ ${#__KamajiClassifiedList[${TargetClass}]} -gt 0 ]
     then
        TargetFList=$(KamajiOrderByLatestBaseSource ${__KamajiClassifiedList[${TargetClass}]})
     else
	DiagnosticHeavy "# There are no files to ${Request}; no CLUT or unit test exercises defined."
     fi
     #
  else
     #
     for SourceFSpec in ${SourceFList}
     do
       #
       SourceFName=$(basename ${SourceFSpec})
       #
       #  Support a request for a ${Request} based on the last target.
       #  Otherwise, check to see that the target is one that we know.
       #
       if [ "${SourceFName}" = "last" ]
       then
          #
          #  Use the last target as the target here.
          #
	  [ -e ${__KamajiLastMakeTargetFSpec} ] || continue
	  #
          SourceFName=$(cat ${__KamajiLastMakeTargetFSpec})
          #
       elif [ "${__KamajiBaseSourceList[${SourceFName}]+IS_SET}" != "IS_SET" ]
       then
          #  
          EchoErrorAndExit 1 "The '${SourceFName}' file cannot be ${Request}d; it is not a known derivative."  
          #  
       fi
       #
       #  Find the ${TargetClass} decendants of the target.
       #
       TargetFList+=" $(KamajiEchoListOfDecendantFName ${SourceFName} ${TargetClass})"
       #  
     done
     #
  fi
  #
  for TargetFName in ${TargetFList}
  do
    #
    #  Save the target name to support the next "make last" request.
    #
    echo "${TargetFName}" > ${__KamajiLastMakeTargetFSpec}
    #
    #  Call for the target to be made.
    #
    KamajiMake ${TargetFName}
    #  
  done
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestGrade() {
  #
  local -r Request=${1}
  shift 1
  local -r SourceFList="${*}"
  #
  KamajiRequestGradeOrOutputOrReview ${Request} Grade ${SourceFList}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestInvoke() {
  #
  local -r Request=${1}
  shift 1
  local -r SourceFList="${*}"
  #
  KamajiRequestGradeOrOutputOrReview ${Request} Output ${SourceFList}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestMake() {
  #
  local -r Request=${1}
  local -r GivnSourceFList="${2-}"
  #
  local    GivnSourceFName GivnSourceFSpec
  #
  local    GivnSourceFLast=
  #
  for GivnSourceFSpec in ${GivnSourceFList}
  do
    #
    GivnSourceFName=$(basename ${GivnSourceFSpec})
    #
    if [ "${GivnSourceFName}" = "last" ]
    then
       #
       #  Use the last target as the current one.
       #
       if [ ${#GivnSourceFLast} -eq 0 ]
       then
	  #
	  [ -e ${__KamajiLastMakeTargetFSpec} ] || continue
	  #
          GivnSourceFLast=$(cat ${__KamajiLastMakeTargetFSpec})
	  #
       fi
       #
       GivnSourceFName=${GivnSourceFLast}
       #
    elif [ "${GivnSourceFName}" = "grades" ]
    then
       #
       KamajiRequestGrade grade
       #
       break
       #
    elif [ "${GivnSourceFName}" = "outputs" ]
    then
       #
       KamajiRequestInvoke invoke
       #
       break
       #
    else
       #
       #  Check to see that the target is one that we know.
       #
       if [ "${__KamajiBaseSourceList[${GivnSourceFName}]+IS_SET}" != "IS_SET" ]
       then
          #  
          EchoErrorAndExit 1 "The '${GivnSourceFName}' file cannot be made; it is not a known derivative."  
          #  
       fi
       #
       #  Save the target name to support the next "make last" request.
       #
       GivnSourceFLast=${GivnSourceFName}
       #
       echo "${GivnSourceFLast}" > ${__KamajiLastMakeTargetFSpec}
       #
    fi
    #
    #  Call for the target to be made.
    #
    KamajiMake ${GivnSourceFName}
    #
  done
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestReview() {
  #
  local -r Request=${1}
  shift 1
  local -r SourceFList="${*}"
  #
  KamajiRequestGradeOrOutputOrReview ${Request} Review ${SourceFList}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestShow_makefile_explicit() {
  #
  local -r Request=${1}
  local -r Object=${2}
  local -r Kind=${3}
  #
  local -r MakefileFName=.kamaji.${Object}.${Kind}
  #
  local -r MakefileFSpec=${__KamajiWorkinDSpec}/${MakefileFName}.partial
  #
  local    TargetClass TargetFName
  #
  #  Export a makefile that can be used to perform load-balanced works...
  #
  rm --force ${MakefileFSpec}
  rm --force ${MakefileFSpec}.later
  #
  spit  ${MakefileFSpec} "#"
  spit  ${MakefileFSpec} "#  ${__KamajiScriptName} ${Request} ${Object} ${Kind}"
  spit  ${MakefileFSpec} "#"
  spit  ${MakefileFSpec} "#  This makefile will allow the user to request creation of specific files using the"
  spit  ${MakefileFSpec} "#  system make command in the same way that 'kamaji make' request does."
  spit  ${MakefileFSpec} "#"
  spit  ${MakefileFSpec} "#  Let the make command determine what needs to be re-made,"
  spit  ${MakefileFSpec} "#  but have it then call kamaji to make sure it is done right."
  spit  ${MakefileFSpec} "#"
  spit  ${MakefileFSpec} "#  One phony target 'kamaji-grade' is defined for user convenience."
  spit  ${MakefileFSpec} "#"
  #
  for TargetClass in Grade
  do
    #
    spit ${MakefileFSpec} "Kamaji${TargetClass}TargetList :="
    #
    if [ "${__KamajiClassifiedList[${TargetClass}]+IS_SET}" = "IS_SET" ]
    then
       #
       for TargetFName in ${__KamajiClassifiedList[${TargetClass}]}
       do
         #
         spit  ${MakefileFSpec} "Kamaji${TargetClass}TargetList += ${__KamajiWorkinDSpec}/${TargetFName}"
         #
       done
       #
    fi
    #
    spit ${MakefileFSpec} ""
    #
  done
  #
  spit  ${MakefileFSpec} ".PHONY: kamaji-grade"
  spit  ${MakefileFSpec} ""
  spit  ${MakefileFSpec} "kamaji-grade : \$(KamajiGradeTargetList)"
  spite ${MakefileFSpec} "\t@echo \"make \$@\""
  spite ${MakefileFSpec} "\t@kamaji fast grade"
  spit  ${MakefileFSpec} ""
  #
  #  Generate makefile dependency rules for each of the targets leading up to the grades.
  #
  local    NextOfParentFName
  #
  local    ListOfParentFName=${__KamajiClassifiedList[Grade]}
  local    ItemOfParentFName
  #
  local -a OutputList
  local    OutputLine
  #
  local -i OutputIndx=0
  local -i CheckIndex
  #
  until [ ${#ListOfParentFName} -eq 0 ]
  do
    #
    NextOfParentFName=
    #
    for ItemOfParentFName in ${ListOfParentFName}
    do
      #
      OutputLine="${__KamajiWorkinDSpec}/${ItemOfParentFName}:"
      #
      if [ ${#__KamajiMyParentalList[${ItemOfParentFName}]} -eq 0 ]
      then
         #
         OutputLine+="${__KamajiBaseSourceList[${ItemOfParentFName}]}"
         #
      else
	 #
	 OutputLine+="${__KamajiMyParentalList[${ItemOfParentFName}]// / ${__KamajiWorkinDSpec}/}"
	 #
	 NextOfParentFName+="${__KamajiMyParentalList[${ItemOfParentFName}]}"
	 #
      fi
      #
      if [ "${__KamajiXtraParentList[${ItemOfParentFName}]+IS_SET}" = "IS_SET" ]
      then
         #
         OutputLine+="${__KamajiXtraParentList[${ItemOfParentFName}]}"
         #
      fi
      #
      CheckIndex=0
      #
      while [ ${CheckIndex} -lt ${OutputIndx} ]
      do
	#
	[ "${OutputLine}" = "${OutputList[${CheckIndex}]}" ] && break
	#
	CheckIndex+=1
	#
      done
      #
      [ ${CheckIndex} -eq ${OutputIndx} ] && OutputList[${OutputIndx}]="${OutputLine}" && OutputIndx+=1
      #
    done
    #
    ListOfParentFName="${NextOfParentFName}"
    #
  done
  #
  printf "%s\n\t@echo \"make \$@\"\n\t@kamaji fast \$@\n\n" "${OutputList[@]}" >> ${MakefileFSpec}
  #
  spit ${MakefileFSpec} "#"
  spit ${MakefileFSpec} "#  (eof}"
  #
  #  Now show the user.
  #
  mv ${MakefileFSpec}	${__KamajiWorkinDSpec}/${MakefileFName}
  cat			${__KamajiWorkinDSpec}/${MakefileFName}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestShow_makefile_layered() {
  #
  local -r Request=${1}
  local -r Object=${2}
  local -r Kind=${3}
  #
  local -r MakefileFName=.kamaji.${Object}.${Kind}
  #
  local -r MakefileFSpec=${__KamajiWorkinDSpec}/${MakefileFName}.partial
  #
  local    TargetClass TargetFName
  #
  #  Export a makefile that can be used to perform load-balanced works...
  #
  rm --force ${MakefileFSpec}
  rm --force ${MakefileFSpec}.later
  #
  spit  ${MakefileFSpec} "#"
  spit  ${MakefileFSpec} "#  ${__KamajiScriptName} ${Request} ${Object} ${Kind}"
  spit  ${MakefileFSpec} "#"
  spit  ${MakefileFSpec} "#  Compile everything we can before generating output for everything we can before"
  spit  ${MakefileFSpec} "#  comparing those outputs to the baseline, and then finally grading those outputs."
  spit  ${MakefileFSpec} "#"
  spit  ${MakefileFSpec} "#  One phony target 'kamaji-grade' is defined for user convenience."
  spit  ${MakefileFSpec} "#  Three phony targets are used to define the layers: kamaji-delta, kamaji-output,"
  spit  ${MakefileFSpec} "#  kamaji-compile. The user may use these as well."
  spit  ${MakefileFSpec} "#"
  #
  for TargetClass in Delta Output
  do
    #
    spit ${MakefileFSpec}.later ""
    spit ${MakefileFSpec}.later "Kamaji${TargetClass}TargetList :="
    #
    if [ "${__KamajiClassifiedList[${TargetClass}]+IS_SET}" = "IS_SET" ]
    then
       #
       for TargetFName in ${__KamajiClassifiedList[${TargetClass}]}
       do
         #
         spit  ${MakefileFSpec}.later "Kamaji${TargetClass}TargetList += ${__KamajiWorkinDSpec}/${TargetFName}"
         #
         spit  ${MakefileFSpec} ""
         spit  ${MakefileFSpec} "${__KamajiWorkinDSpec}/${TargetFName} :"
         spite ${MakefileFSpec} "\t@echo \"make \$@\""
         spite ${MakefileFSpec} "\t@kamaji fast make \$@"
         #
       done
       #
    fi
    #
  done
  #
  TargetClass=Compile
  #
  spit ${MakefileFSpec}.later ""
  spit ${MakefileFSpec}.later "Kamaji${TargetClass}TargetList :="
  #
  if [ "${__KamajiClassifiedList[Clut]+IS_SET}" = "IS_SET" ]
  then
     #
     for TargetFName in ${__KamajiClassifiedList[Clut]}
     do
       #
       spit  ${MakefileFSpec}.later "Kamaji${TargetClass}TargetList += ${__KamajiWorkinDSpec}/${TargetFName}.bash"
       #
       spit  ${MakefileFSpec} ""
       spit  ${MakefileFSpec} "${__KamajiWorkinDSpec}/${TargetFName}.bash :"
       spite ${MakefileFSpec} "\t@echo \"make \$@\""
       spite ${MakefileFSpec} "\t@kamaji fast make \$@"
       #
     done
     #
  fi
  #
  if [ "${__KamajiClassifiedList[Elf]+IS_SET}" = "IS_SET" ]
  then
     #
     spit ${MakefileFSpec}.later ""
     #
     for TargetFName in ${__KamajiClassifiedList[Elf]}
     do
       #
       spit ${MakefileFSpec}.later "Kamaji${TargetClass}TargetList += ${__KamajiWorkinDSpec}/${TargetFName%.*}"
       #
     done
     #
  fi
  #
  spew  ${MakefileFSpec} ${MakefileFSpec}.later
  rm --force		 ${MakefileFSpec}.later
  #
  spit  ${MakefileFSpec} ""
  spit  ${MakefileFSpec} ".PHONY: kamaji-grade kamaji-delta kamaji-output kamaji-compile"
  spit  ${MakefileFSpec} ""
  spit  ${MakefileFSpec} "kamaji-grade : kamaji-delta"
  spite ${MakefileFSpec} "\t@echo \"make \$@\""
  spite ${MakefileFSpec} "\t@kamaji fast grade"
  spit  ${MakefileFSpec} ""
  spit  ${MakefileFSpec} "kamaji-delta : kamaji-output \$(KamajiDeltaTargetList)"
  spit  ${MakefileFSpec} ""
  spit  ${MakefileFSpec} "kamaji-output : kamaji-compile \$(KamajiOutputTargetList)"
  spit  ${MakefileFSpec} ""
  spit  ${MakefileFSpec} "kamaji-compile : \$(KamajiCompileTargetList)"
  #
  spit  ${MakefileFSpec} ""
  spit  ${MakefileFSpec} "#  (eof}"
  #
  #  Now show the user.
  #
  mv ${MakefileFSpec}	${__KamajiWorkinDSpec}/${MakefileFName}
  cat			${__KamajiWorkinDSpec}/${MakefileFName}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestShow_makefile() {
  #
  local -r Request=${1}
  local -r Object=${2}
  local -r Kind=${3-layered}
  #
  local FunctionWeWant=${FUNCNAME}_${Kind}
  #
  local FunctionToCall=$(declare -F ${FunctionWeWant})
  #
  [ ${#FunctionToCall} -eq 0 ] && KamajiExitAfterUsage "Unable to '${Request} ${Object} ${Kind}' objects."
  #
  ${FunctionToCall} ${Request} ${Object} ${Kind}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestShow() {
  #
  local -r Request=${1}
  local -r Object=${2-makefile}
  local    Kind=${3-}
  #
  local FunctionWeWant=${FUNCNAME}_${Object}
  #
  local FunctionToCall=$(declare -F ${FunctionWeWant})
  #
  [ ${#FunctionToCall} -eq 0 ] && KamajiExitAfterUsage "Unable to '${Request} ${Object}' objects."
  #
  ${FunctionToCall} ${Request} ${Object} ${Kind}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_Delta_from_GoldenMasked_OutputMasked() {
  #
  local -r TargetFName=${1}
  local -r GoldenMaskedFName=${2}
  local -r OutputMaskedFName=${3}
  #
  local -r TargetFSpec=${__KamajiWorkinDSpec}/${TargetFName}
  #
  EchoAndExecuteInWorking	\
	"diff --text --ignore-space-change ${GoldenMaskedFName} ${OutputMaskedFName} > ${TargetFName} 2>&1"
  #
  Status=${?}
  #
  if [ ${Status} -le 1 ]
  then
     #
     if [ -s ${TargetFSpec} ]
     then
        #
	if [ $(cat ${TargetFSpec} | wc --lines) -le 50 ]
	then
	   #
           local -r GoldenDSpec=$(dirname $(readlink ${__KamajiWorkinDSpec}/${GoldenMaskedFName%.masked}))
	   local -r OutputFSpec=${__KamajiWorkinDSpec}/${OutputMaskedFName%.masked}
	   #
	   spit ${TargetFSpec} "${__KamajiInfoTag} cp ${OutputFSpec} ${GoldenDSpec#../}/"
	   #
        fi
        #
     fi
     #
  else
     #
     EchoErrorAndExit ${Status} "The diff command failed; this most-often happens because masking failed."
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_Delta_from_OutputMasked() {
  #
  local -r TargetFName=${1}
  local -r OutputMaskedFName=${2}
  #
  EchoAndExecuteInWorking "cat ${OutputMaskedFName} > ${TargetFName} 2>&1"
  #
  local -r TargetFSpec=${__KamajiWorkinDSpec}/${TargetFName}
  local -r OutputFSpec=${__KamajiWorkinDSpec}/${OutputMaskedFName%.masked}
  #
  spit ${TargetFSpec} "${__KamajiInfoTag} No baseline output file defined."
  spit ${TargetFSpec} "${__KamajiInfoTag} cp ${OutputFSpec} ${__KamajiGoldenDSpec}/"
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_Delta_from_OutputMasked_GoldenMasked() {
  #
  local -r TargetFName=${1}
  local -r OutputMaskedFName=${2}
  local -r GoldenMaskedFName=${3}
  #
  KamajiMake_Delta_from_GoldenMasked_OutputMasked ${TargetFName} ${GoldenMaskedFName} ${OutputMaskedFName}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_GoldenMasked_from_Golden_SedMaskingScript() {
  #
  local -r TargetFName=${1}
  local -r GoldenSourceFName=${2}
  local -r SedScriptFName=${3}
  #
  EchoAndExecuteInWorking "sed --file=${SedScriptFName} ${GoldenSourceFName} > ${TargetFName}.partial"
  #
  Status=${?}
  #
  [ ${Status} -eq 0 ] || EchoErrorAndExit ${Status} "The sed command failed."
  #
  EchoAndExecuteInWorking "mv ${TargetFName}.partial ${TargetFName}"
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_GoldenMasked_from_SedMaskingScript_Golden() {
  #
  local -r TargetFName=${1}
  local -r SedScriptFName=${2}
  local -r GoldenSourceFName=${3}
  #
  KamajiMake_GoldenMasked_from_Golden_SedMaskingScript ${TargetFName} ${GoldenSourceFName} ${SedScriptFName}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_Grade_from_Delta() {
  #
  local -r TargetFName=${1}
  local -r SourceFName=${2}
  #
  if [ -s ${__KamajiWorkinDSpec}/${SourceFName} ]
  then
     #
     [ "${__KamajiVerbosityRequested}" != "quiet" ] && EchoAndExecuteInWorking "cat ${SourceFName}"
     #
     EchoImportantMessage "${__KamajiFailTag}" "${TargetFName}"
     #
  else
     #
     EchoImportantMessage "${__KamajiPassTag}" "${TargetFName}"
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_Naked_from_Elf() {
  #
  local -r TargetFName=${1}
  local -r SourceFName=${2}
  #
  EchoAndExecuteInWorking "make ${TargetFName}"
  #
  Status=${?}
  #
  [ ${Status} -eq 0 ] || EchoFailureAndExit ${Status} "The 'make ${TargetFName}' command failed."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_Output_from_Naked() {
  #
  local -r TargetFName=${1}
  local -r SourceFName=${2}
  #
  EchoAndExecuteInWorking "./${SourceFName} > ${TargetFName}.partial 2>&1"
  #
  Status=${?}
  #
  [ ${Status} -eq 0 ] || EchoFailureAndExit ${Status} "The ${SourceFName} program failed."
  #
  EchoAndExecuteInWorking "mv ${TargetFName}.partial ${TargetFName}"
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_Output_from_Script() {
  #
  local -r TargetFName=${1}
  local -r SourceFName=${2}
  #
  EchoAndExecuteInWorking "./${SourceFName} > ${TargetFName}.partial 2>&1"
  #
  Status=${?}
  #
  [ ${Status} -eq 0 ] || EchoFailureAndExit ${Status} "The ${SourceFName} script failed."
  #
  EchoAndExecuteInWorking "mv ${TargetFName}.partial ${TargetFName}"
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_OutputMasked_from_Output_SedMaskingScript() {
  #
  KamajiMake_GoldenMasked_from_Golden_SedMaskingScript ${*};
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_OutputMasked_from_SedMaskingScript_Output() {
  #
  KamajiMake_GoldenMasked_from_SedMaskingScript_Golden ${*};
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_Review_from_Delta_Grade() {
  #
  local -r TargetFName=${1}
  local -r DeltaSourceFName=${2}
  local -r GradeSourceFName=${3}
  #
  if [ -s ${__KamajiWorkinDSpec}/${DeltaSourceFName} ]
  then
     #
     local -r OutputFName=${DeltaSourceFName%.delta}
     #
     local -r OutputMskdFName=${OutputFName}.masked
     local -r GoldenMskdFName=${OutputFName%.output}.golden.masked
     #
     EchoAndExecuteInWorking "${__KamajiReviewCommand} ${GoldenMskdFName} ${OutputMskdFName} ${__KamajiReviewTailpipe}"
     #
     EchoAndExecuteInWorking touch ${TargetFName}ed
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_Review_from_Grade_Delta() {
  #
  local -r TargetFName=${1}
  local -r GradeSourceFName=${2}
  local -r DeltaSourceFName=${3}
  #
  KamajiMake_Review_from_Delta_Grade ${TargetFName} ${DeltaSourceFName} ${GradeSourceFName}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_Script_from_Clut_Naked() {
  #
  local -r TargetFName=${1}
  local -r ClutSourceFName=${2}
  local -r ExecSourceFName=${3}
  #
  EchoAndExecuteInWorking "clutc ${ClutSourceFName} ${ExecSourceFName} ${TargetFName}"
  #
  Status=${?}
  #
  [ ${Status} -eq 0 ] || EchoFailureAndExit ${Status} "CLUT compilation failed."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_Script_from_Clut_Script() { KamajiMake_Script_from_Clut_Naked ${*}; }

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_Script_from_Naked_Clut() {
  #
  local -r TargetFName=${1}
  local -r ExecSourceFName=${2}
  local -r ClutSourceFName=${3}
  #
  KamajiMake_Script_from_Clut_Naked ${TargetFName} ${ClutSourceFName} ${ExecSourceFName}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_Script_from_Script_Clut() { KamajiMake_Script_from_Naked_Clut ${*}; }

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake() {
  #
  local -r TargetFName=${1}
  #
  #  Representatives must only exist; the files they represent are updated by the user.
  #
  local    ListOfMyParentalFName=${__KamajiMyParentalList[${TargetFName}]}
  local    ListOfXtraParentFName=
  #
  if [ ${#ListOfMyParentalFName} -eq 0 ] && [ ! -L ${__KamajiWorkinDSpec}/${TargetFName} ]
  then
     #
     local -r GoldenFSpec=${__KamajiRepresentative[${TargetFName}]}
     #
     EchoAndExecuteInWorking "ln --symbolic ${GoldenFSpec} ${TargetFName}"
     #
     return
     #
  fi
  #
  if [ "${__KamajiXtraParentList[${TargetFName}]+IS_SET}" = "IS_SET" ]
  then
     #
     ListOfXtraParentFName="${__KamajiXtraParentList[${TargetFName}]}"
     #
  fi
  #
  #  Make each of the parents of the target.
  #
  local ListOfParentClass=
  #
  local ParentFName
  #
  for ParentFName in ${ListOfMyParentalFName}
  do
    #
    KamajiMake ${ParentFName}
    #
    ListOfParentClass+=" $(KamajiFileClassification ${ParentFName} $(Xtension ${ParentFName}))"
    #
  done
  #
  #  Determine if we now need to make this target.
  #
  local ReasonToAct=
  #
  for ParentFName in ${ListOfMyParentalFName} ${ListOfXtraParentFName}
  do
    #
    ReasonToAct=$(EchoAgeRelation ${__KamajiWorkinDSpec}/${ParentFName} ${__KamajiWorkinDSpec}/${TargetFName})
    #
    DiagnosticHeavy "# ${ReasonToAct}"
    #
    [ "${ReasonToAct:0:2}" = "GT" ] && break
    #
  done
  #
  #  Make the target.
  #
  if [ "${ReasonToAct:0:2}" = "GT" ]
  then
     #
     DiagnosticLight "${__KamajiScriptName} make ${TargetFName}"
     #
     local TargetClass=$(KamajiFileClassification ${TargetFName} $(Xtension ${TargetFName}))
     #
     local SourceClass=$(echo ${ListOfParentClass} | xargs printf "_%s")
     #
     local FunctionWeWant=KamajiMake_${TargetClass}_from_${SourceClass:1}
     #
     local FunctionToCall=$(declare -F ${FunctionWeWant})
     #
     [ ${#FunctionToCall} -eq 0 ] && EchoErrorAndExit 1 "Undefined function ${FunctionWeWant} required."
     #
     ${FunctionToCall} ${TargetFName} ${ListOfMyParentalFName}
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMain() {
  #
  local -r    RequestedAction=${1-}
  shift 1
  local       ParameterList=${*}
  #
  [ ${#RequestedAction} -eq 0 ] && ParameterList=
  #
  local    -A ModifierFunctionFor
  #
  ModifierFunctionFor[fast]=KamajiModifierFast
  ModifierFunctionFor[help]=KamajiModifierUsage
  ModifierFunctionFor[noisy]=KamajiModifierVerbose
  ModifierFunctionFor[quiet]=KamajiModifierSilent
  ModifierFunctionFor[silent]=KamajiModifierSilent
  ModifierFunctionFor[usage]=KamajiModifierUsage
  ModifierFunctionFor[verbose]=KamajiModifierVerbose
  #
  local -r ModifierCorrected=$(EchoMeaningOf "${RequestedAction}" "N/A" ${!ModifierFunctionFor[*]})
  #
  if [ "${ModifierCorrected}" != "N/A" ]
  then
     #
     ${ModifierFunctionFor[${ModifierCorrected}]} ${ModifierCorrected} ${ParameterList}
     #
  else
     #
     KamajiConfigurationCheckValues
     #
     if [ "${__KamajiRulesetIsReady}" != "true" ]
     then
        #
	KamajiBuildRules
        #
        #  __KamajiRepresentative[TargetFName]="SourceFSpec": What external file does this file name represent?
        #
        #  Create each representative first because other files may have undeclared dependency on them.
        #
        if [ "${__KamajiRepresentative[*]+IS_SET}" = "IS_SET" ]
	then
	   #
	   for SourceFName in ${!__KamajiRepresentative[*]}
	   do
	     #
	     KamajiMake ${SourceFName}
	     #
	   done
	   #
        fi
        #
     fi
     #
     local -A RequestFunctionFor
     #
     RequestFunctionFor[baseline]=KamajiRequestBless
     RequestFunctionFor[bless]=KamajiRequestBless
     RequestFunctionFor[configure]=KamajiRequestConfigure
     RequestFunctionFor[execute]=KamajiRequestInvoke
     RequestFunctionFor[export]=KamajiRequestExport
     RequestFunctionFor[grades]=KamajiRequestGrade
     RequestFunctionFor[invoke]=KamajiRequestInvoke
     RequestFunctionFor[make]=KamajiRequestMake
     RequestFunctionFor[review]=KamajiRequestReview
     RequestFunctionFor[run]=KamajiRequestInvoke
     RequestFunctionFor[set]=KamajiRequestConfigure
     RequestFunctionFor[show]=KamajiRequestShow
     #
     RequestFunctionFor[usage]=KamajiModifierUsage
     #
     local -r RequestCorrected=$(EchoMeaningOf ${RequestedAction} "N/A" ${!RequestFunctionFor[*]})
     #
     if [ "${RequestCorrected}" = "N/A" ]
     then
        #
        KamajiExitAfterUsage "Unable to fulfill a '${RequestedAction}' request."
        #
     else
        #
        ${RequestFunctionFor[${RequestCorrected}]} ${RequestCorrected} ${ParameterList}
        #
     fi
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------

KamajiConfigurationLoadValues

KamajiMain ${*}

#----------------------------------------------------------------------------------------------------------------------
