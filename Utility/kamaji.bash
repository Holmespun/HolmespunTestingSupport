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
#	EchoAndExecute
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
#	KamajiBuildRulesForTestingSource_Naked
#	KamajiBuildRulesForTestingSource_Output
#	KamajiBuildRulesForTestingSource_Script
#	KamajiBuildRulesForTestingSource_Unknown
#	KamajiBuildRulesForTestingSource
#	KamajiBuildRulesLoadXtraDependents
#	KamajiBuildRules
#
#	KamajiRequestBless
#	KamajiRequestConfigure
#	KamajiRequestExport_makefile
#	KamajiRequestExport_ruleset
#	KamajiRequestExport
#	KamajiRequestGradeOrOutputOrReview
#	KamajiRequestGrade
#	KamajiRequestInvoke
#	KamajiRequestMake
#	KamajiRequestReview
#	KamajiRequestShow_configuration
#	KamajiRequestShow_copyright
#	KamajiRequestShow_version
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
#  20190720 BGH; version 0.2.
#  20190817 BGH; version 0.3, kamaji knows the source files, calculates all output files, functions based on both.
#  20190910 BGH; readlink representative invoke (see below).
#
#  Problems detected when the representative of a script is called: The files it sources are  not in the same relative
#  hierarchy as the symbolic link. Created a Bash script representative tha worked very well, but a Bash script
#  representative does not carry the same modification date as the file it is supposed to represent. As such, we invoke
#  the readlink version of each representative. 20190910 BGH.
#
#  TODO: New requests rework, workout, vimdiff=review (grade and vimdiff), and bless=baseline (cp if fresh, or grade)
#  TODO: Save the rules to a bash file that can be reused if all Golden and SedScript files represented there.
#
#----------------------------------------------------------------------------------------------------------------------
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

declare -r __KamajiWhereWeWere=${PWD}

#----------------------------------------------------------------------------------------------------------------------

declare -A __KamajiConfigurationDefault

declare -A __KamajiConfigurationValue

declare    __KamajiGoldenDSpec="TBD"

declare    __KamajiDataFileNameList="TBD"

declare    __KamajiLastMakeTargetFSpec="TBD"

declare    __KamajiScriptExtensionList="TBD"

declare    __KamajiSystemMasking="TBD"

declare    __KamajiTimeCommand="TBD"

declare    __KamajiVerbosityRequested="TBD"

declare    __KamajiWorkinDSpec="TBD"

declare    __KamajiSedScriptFSpec="TBD"
declare    __KamajiSedScriptFName="TBD"

#----------------------------------------------------------------------------------------------------------------------

declare -i __kamajiFailureCount=0

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

function EchoAndExecute() {
  #
  local -r SystemRequest="${*}"
  #
  local -i Status
  #
  DiagnosticHeavy "${SystemRequest}" 1>&2
  #
  IFS=
     #
     EchoAndExecuteOutputSwap ${SystemRequest} 2>&1 1>&2
     #
     Status=${?}
     #
  IFS="${__KamajiIfsOriginal}"
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
  local    ProgramFSpec ProgramFName
  #
  #  Check for an ELF name.
  #
  for TargetDSpec in ${ListOfTargetDSpec}
  do
    #
    for ProgramFSpec in ${TargetDSpec}/${TargetFRoot}
    do
      #
      [ -d ${ProgramFSpec} ] && continue
      #
      ProgramFName=$(basename ${ProgramFSpec})
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
     #  Check for a script name.
     #
     for TargetDSpec in ${ListOfTargetDSpec}
     do
       #
       for ProgramFSpec in ${TargetDSpec}/${TargetFRoot}.*
       do
         #
         [ -d ${ProgramFSpec} ] && continue
         #
         ProgramFName=$(basename ${ProgramFSpec})
         #
         [ -x ${ProgramFSpec} ] && ResultsFList+=" ${ProgramFSpec}"
         #
       done
       #
     done
     #
  fi
  #
  if [ ${#ResultsFList} -eq 0 ]
  then
     #
     #  Check for the root of a scrpt name.
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
  local -r    WordList=${*}
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

function EchoPara80-4() {
  #
  local -r WordList=${*}
  #
  local -r WordHead=${WordList%% *}
  #
  local -r HighHead=$(echoInColorWhiteBold "${WordHead}")
  #
  EchoPara 76 ${WordList} | sed --expression="1s,${WordHead},${HighHead}," --expression='s,^,    ,'
  #
}

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
     printf "%s\n" ${ResultFList} | sort --unique
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
  __KamajiSystemMasking=
  __KamajiSystemMasking+=" --expression='s,${WorkinDSpec},_WORKING_,g'"
  __KamajiSystemMasking+=" --expression='s,${HOME},_HOME_,g'"
  __KamajiSystemMasking+=" --expression='s,${USER},_USER_,g'"
  __KamajiSystemMasking+=" --expression='s,${LOGNAME},_LOGNAME_,g'"
  __KamajiSystemMasking+=" --expression='s,$(uname -n),_HOSTNAME_,g'"
  __KamajiSystemMasking+=" --expression='s,$(date '+%Z'),_TIMEZONE_,g'"
  #
  local -r DefaultTimeFormat="Time %E %e %S %U %P Memory %M %t %K %D %p %X %Z %F %R %W %c %w I/O %I %O %r %s %k %C %x"
  #
  local -r TimeOutputFormat=$(KamajiConfigurationEchoValue time-output-format)
  #
  if [ "${TimeOutputFormat}" = "NONE" ] || [ ! -x /usr/bin/time ]
  then
     #
     __KamajiTimeCommand=
     #
  else
     #
     [ "${TimeOutputFormat}" = "FULL" ] && TimeOutputFormat="${DefaultTimeFormat}"
     #
     __KamajiTimeCommand="/usr/bin/time --format='${TimeOutputFormat}' --append "
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiConfigurationEchoValue() {
  #
  local -r Name=${1}
  shift 1
  local -r Default="${*}"
  #
  local    Result="${Default}"
  #
  if [ "${__KamajiConfigurationValue[${Name}]+IS_SET}" = IS_SET ] && [ ${#__KamajiConfigurationValue[${Name}]} -gt 0 ]
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
  #  Set default configuration values.
  #
  __KamajiConfigurationDefault["baseline-folder"]="Testing"
  __KamajiConfigurationDefault["data-extension-list"]=
  __KamajiConfigurationDefault["data-filename-list"]=
  __KamajiConfigurationDefault["last-target-filename"]="${__KamajiConfigurationFName%.*}.last_target.text"
  __KamajiConfigurationDefault["long-review-command"]="vimdiff -R"
  __KamajiConfigurationDefault["long-review-line-count"]=51
  __KamajiConfigurationDefault["long-review-tailpipe"]=
  __KamajiConfigurationDefault["makefile-filename"]=
  __KamajiConfigurationDefault["mask-sed-script"]="${__KamajiConfigurationFName%.*}.sed"
  __KamajiConfigurationDefault["new-review-command"]="cat --number"
  __KamajiConfigurationDefault["new-review-tailpipe"]=
  __KamajiConfigurationDefault["ruleset-filename"]=
  __KamajiConfigurationDefault["script-type-list"]="bash sh py rb"
  __KamajiConfigurationDefault["short-review-command"]="diff"
  __KamajiConfigurationDefault["short-review-tailpipe"]=
  __KamajiConfigurationDefault["time-output-format"]="NONE"
  __KamajiConfigurationDefault["verbosity-level"]="quiet"
  __KamajiConfigurationDefault["working-folder"]="Working"
  #
  for Key in ${!__KamajiConfigurationDefault[*]}
  do
    __KamajiConfigurationValue[${Key}]=${__KamajiConfigurationDefault[${Key}]}
  done
  #
  #  Load user-defined configuration.
  #
  for Directory in ${HOME} .
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
            if [ ${#Value} -gt 0 ]
	    then
               #
               if [ "${__KamajiConfigurationValue[${Key}]+IS_SET}" = "IS_SET" ]
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
               else
                  #
                  EchoErrorAndExit 1 "The '${Key}' is not a known configuration variable name."
                  #
               fi
               #
            else
               #
               EchoErrorAndExit 1 "Empty configuration values are not allowed (${key} variable)."
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
  #  Define oft-used configuration variables.
  #
  __KamajiGoldenDSpec=$(KamajiConfigurationEchoValue baseline-folder)
  #
  __KamajiDataFileNameList=$(KamajiConfigurationEchoValue data-filename-list)
  #
  __KamajiDataFileNameList=":${__KamajiDataFileNameList// /:}:"
  #
  __KamajiScriptExtensionList=$(KamajiConfigurationEchoValue script-type-list)
  #
  __KamajiScriptExtensionList=":${__KamajiScriptExtensionList// /:}:"
  #
  __KamajiSedScriptFSpec=$(KamajiConfigurationEchoValue mask-sed-script)
  #
  __KamajiSedScriptFName=$(basename ${__KamajiSedScriptFSpec})
  #
  __KamajiVerbosityRequested=$(KamajiConfigurationEchoValue verbosity-level)
  #
  __KamajiWorkinDSpec=$(KamajiConfigurationEchoValue working-folder)
  #
  __KamajiLastMakeTargetFSpec=${__KamajiWorkinDSpec}/$(KamajiConfigurationEchoValue last-target-filename)
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
  local -r RulesetFName=$(KamajiConfigurationEchoValue ruleset-filename .kamaji.ruleset.bash)
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
  EchoPara80	"Named configuration variables and their values are stored in the"				\
		"\$HOME/${__KamajiConfigurationFName} and ./${__KamajiConfigurationFName} files;"		\
		"settings in the latter will re-define or augment variables in the former."			\
		"Both files can contain comments, blank lines, and variable settings."				\
		"Variables cannot be set to an empty value."
  #
  EchoPara80	"The following settings represent the non-empty defaults:"
  #
  for Key in ${!__KamajiConfigurationValue[*]}
  do
    #
    if [ ${#__KamajiConfigurationDefault[${Key}]} -gt 0 ]
    then
       #
       printf "    %-23s %s\n" ${Key} "$(echo ${__KamajiConfigurationDefault[${Key}]})"
       #
    fi
    #
  done | sort
  #
  echo
  #
  EchoPara80	"The following variables are defined":
  #
  EchoPara80-4	"baseline-folder <directory-specification> -"							\
		"Specification for the directory where baseline output files are stored."
  #
  EchoPara80-4	"data-extension-list <extension>... -"								\
		"A list of name extensions for \"data\" files that are stored in the baseline-folder,"		\
		"but do not represent CLUT or unit test exercises or their output."				\
		"Data files are represented in the working-folder."
  #
  EchoPara80-4	"data-filename-list <filename>... -"								\
		"A list of names for \"data\" files that are stored in the baseline-folder,"			\
		"but do not represent CLUT or unit test exercises or their output."				\
		"Data files are represented in the working-folder."
  #
  EchoPara80-4  "last-target-filename <filename> -"								\
		"The name of the file in which the filename of the last make target is stored;"			\
		"the file is stored in the working-folder."
  #
  EchoPara80-4	"long-review-command <command> -"								\
  		"The command used to perform a long review."							\
		"A long review is defined by the configured long-review-line-count value."			\
		"The command is called from within the working-folder, and is passed the"			\
		"masked baseline output and masked current output files in that order."
  #
  EchoPara80-4	"long-review-line-count <integer> -"								\
		"The number of diff command output lines that are too many to be considered"			\
		"the subject of a short review."								\
		"This number is used to define the difference between a short and long review."
  #
  EchoPara80-4	"long-review-tailpipe <command> [ | <command> ]... -"						\
		"A command into which the long-review-command output is piped."					\
		"For example, if you set the long-review-command to \"diff\" then you might want to"		\
		"set the review-tailpipe to \"sed --expression='s,^,    ,' | less\" so that the diff"		\
		"output will be indented, you can view it a page at a time, and it will not"			\
		"clutter your display after your review."
  #
  EchoPara80-4	"makefile-filename <filename> -"								\
		"The name of the file into which a makefile is exported."					\
  #
  EchoPara80-4	"mask-sed-script <file-specification> -"							\
		"Specification for the user-defined sed script that is used to mask output files."
  #
  EchoPara80-4	"new-review-command <command> -"								\
  		"The command used to perform a new review."							\
		"A new review is one for which there is no baseline output file to compare to."			\
		"The command is called from within the working-folder, and is passed the"			\
		"masked current output file."
  #
  EchoPara80-4	"new-review-tailpipe <command> [ | <command> ]... -"						\
		"A command into which the new-review-command output is piped."					\
  #
  EchoPara80-4	"ruleset-filename <filename> -"									\
		"The name of the file in which the ruleset is stored."						\
		"The ruleset is stored and used by the 'export ruleset' request and 'fast' modifier."		\
		"the file is stored in the working-folder."
  #
  EchoPara80-4	"script-type-list [<extension>]... -"								\
		"A list of file name extensions that are used to store executable scripts."			\
  #
  EchoPara80-4	"short-review-command <command> -"								\
  		"The command used to perform a short review."							\
		"A short review is defined by the configured long-review-line-count value."			\
		"The command is called from within the working-folder, and is passed the"			\
		"masked baseline output and masked current output files in that order."
  #
  EchoPara80-4	"short-review-tailpipe <command> [ | <command> ]... -"						\
		"A command into which the short-review-command output is piped."				\
  #
  EchoPara80-4	"time-output-format { <time-format> | FULL | NONE } -"						\
		"The output format used by the /usr/bin/time program to provide run-time statistics about"	\
		"CLUT scripts and unit test scripts and programs; please see the GNU VERSION section of the"	\
		"description produced by the man time command."							\
		"A pre-defined, verbose format can be applied by using the FULL value."				\
		"The time program is not used if this variable is set to NONE"					\
		"or if the /usr/bin/time program is not available."
  #
  EchoPara80-4	"verbosity-level <adjective> -"									\
		"The level of disgnostic output produced."							\
		"The 'quiet' level suppresses diagnostic output."						\
		"The 'light' level will describe the 'make' requests used to fulfill the user's request."	\
		"The 'heavy' level will augment light output with a description of commands applied to files"	\
		"in the working-folder and comments that describe data that it uses to decide what commands"	\
		"should be applied."
  #
  EchoPara80-4	"working-folder <directory-specification> -"							\
		"The specification for the directory where intermediate and unverified output files are"	\
		"created."											\
		"If the working-folder does not already exist then it will be silently created."		\
  #
  EchoPara80	"Subsequent variable settings override previous values for the variable they name,"		\
		"unless that variable represents a list, in which case the value is augmented."
  #
  EchoPara80	"A list of the configuration variable names can be displayed using a"				\
		"'show configuration variables' request."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_grade() {
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
  EchoPara80	"The kamaji script allows the user to export data in two forms: makefile and ruleset."
  #
  EchoPara80	"$(echoInColorWhiteBold "Export Makefile...")"
  #
  EchoPara80	"The 'export makefile' request is used to produce a makefile that can be used to integrate"	\
		"kamaji into a makefile system."								\
		"An exported makefile contains a rule for every derived file known to kamaji."			\
		"Use of the make command --jobs switch with the exported makefile can produce results even"	\
		"faster than invoking parallel kamaji grade requests."
  #
  EchoPara80	"$(echoInColorWhiteBold "Export Ruleset...")"
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
		"The ruleset-filename configuration variable can be used to"					\
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
		"Reviews are based on grades, and they are only performed for failing grades."			\
		"After the user reviews a failing grade,"							\
		"then kamaji will allow the user to baseline the new output using a 'bless' request."
  #
  EchoPara80	"There are three different kinds of review: new, short, and long."				\
		"New reviews are performed on output for which there is no baseline to compare to."		\
		"Short reviews are performed when the changes between the baseline and current output"		\
		"are so few that specialized tools are not necessary to perform a detailed review."		\
		"Long reviews are performed for all other results."
  #
  EchoPara80	"The vimdiff command is a very useful tool for perfoming long reviews."				\
		"Users not familiar with the editor may want to make note of the following vim commands:"	\
		"the :help command to request help; the :qa command to exit the editor;"			\
		"the h, j, k, l, and arrow keys to move around in a pane;"					\
		"and the [ctrl]-h, [ctrl]-l, and [ctrl]-w combinations to switch panes."
  #
  EchoPara80	"The long-review-line-count configuration variables allow the user to define"			\
		"the boundary between a short and long review."							\
  		"The new-, short-, and long-review-command"							\
		"configuration variables can be used to change the command used to perform a review."		\
		"The new-, short-, and long-review-tailpipe configuration variables allow the user to"		\
		"manipulate the output produced by the new-, short-, and long-review-command variables,"	\
		"respectively."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_show() {
  #
  local -r Request="${1}"
  #
  EchoPara80	"$(echoInColorWhiteBold "Show...")"
  #
  EchoPara80	"The 'show' request can be used to display the configuration, the copyright, or the software version."
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
  echo "      show   [ configuration [ names | variables ] | copyright | version ]"
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
  UsageModifierSubjectList[grades]=grade
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
  KamajiRequestShow_copyright show copyright
  KamajiRequestShow_version   show version
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
  local -a RunnerDList
  #
  local -i RunnerDIndx=0
  #
  RunnerDList[${RunnerDIndx}]=.
  #
  RunnerDIndx+=1
  #
  RunnerDList[${RunnerDIndx}]=$(find . -type d | sed --expression='1d'	\
			      | grep --invert-match ${__KamajiWorkinDSpec} | grep --invert-match "^\./\.")
  #
  RunnerDIndx+=1
  #
  RunnerDList[${RunnerDIndx}]=="${PATH//:/ }"
  #
  local -i RunnerDLast=${RunnerDIndx}
  #
  local    RunnerFSpec=
  #
  RunnerDIndx=0
  #
  while [ ${RunnerDIndx} -le ${RunnerDLast} ] && [ ${#RunnerFSpec} -eq 0 ]
  do
    #
    for RunnerFSpec in $(EchoExecutableFilesMatching ${SourceFName%%.*} ${RunnerDList[${RunnerDIndx}]})
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
    RunnerDIndx+=1
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

function KamajiBuildRulesForTestingSource_Naked() {
  #
  : Nothing needs to be done.
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
# AppendArrayIndexValue __KamajiBaseSourceList	"${SourceFRoot}"		"${SourceFSpec}"
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
  if [ ${#LessOfIgnoreFType} -eq ${#ListOfIgnoreFType} ]
  then
     #
     DiagnosticLight "# Ignoring ${SourceFSpec} (unknown classification)."
     #
  else
     #
     __KamajiRepresentative["${SourceFName}"]="../${SourceFSpec}"
     #
     AppendArrayIndexValue __KamajiMyParentalList "${SourceFName}" ""
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiBuildRulesForTestingSource() {
  #
  local -r SourceFSpec=${1}
  #
  DiagnosticHeavy "#	${SourceFSpec}"
  #
  local -r SourceFName=$(basename ${SourceFSpec})
  local -r SourceFType=$(Xtension ${SourceFName})
  #
  #  Detect a SourceFType amonst the delclared data file names.
  #
  local -r DataFileNameLess=${__KamajiDataFileNameList/:${SourceFName}:/}
  #
  local    DataFileNameFlag=0
  #
  [ ${#DataFileNameLess} -ne ${#__KamajiDataFileNameList} ] && DataFileNameFlag=1
  #
  #  Detect a Script that is not executable.
  #
  local    SourceClass=Undetermined
  #
  if [ ${DataFileNameFlag} -eq 0 ]
  then
     #
     SourceClass=$(KamajiFileClassification ${SourceFSpec} ${SourceFType})
     #
     [ "${SourceClass}" = "Script" ] && [ ! -x ${SourceFSpec} ] && DataFileNameFlag=1
     #
  fi
  #
  #  Process the source file as non-data or data.
  #
  if [ ${DataFileNameFlag} -eq 0 ]
  then
     #
     local -r FunctionWeWant=${FUNCNAME}_${SourceClass}
     #
     local -r FunctionToCall=$(declare -F ${FunctionWeWant})
     #
     [ ${#FunctionToCall} -eq 0 ] && KamajiExitAfterUsage "Fatal programming flaw; ${FunctionWeWant} is undefined."
     #
     ${FunctionToCall} ${SourceFSpec} ${SourceFType}
     #
  else
     #
     #  __KamajiRepresentative[TargetFName]="SourceFSpec": What external file does this file name represent?
     #
     __KamajiRepresentative["${SourceFName}"]="../${SourceFSpec}"
     #
     AppendArrayIndexValue __KamajiMyParentalList "${SourceFName}" ""
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiBuildRulesLoadXtraDependents() {
  #
  local Directory ExternFSpec ExternFName TargetFSpec TargetFName
  #
  for Directory in ${HOME} .
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
  DiagnosticHeavy "# Building rules based on baseline files..."
  #
  if [ ! -d ${__KamajiGoldenDSpec} ]
  then
     KamajiExitAfterUsage "The baseline directory '${__KamajiGoldenDSpec}' does not exist."
  fi
  #
  local -r ListOfSourceFSpec=$(find -L ${__KamajiGoldenDSpec} -type f)
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
  local ParentFName ChildsFName
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
       DiagnosticLight "${__KamajiScriptName} ${Request} ${TargetFName%.review}"
       #
       EchoAndExecute "echo \"${TargetFName}\" > ${__KamajiLastMakeTargetFSpec}"
       #
       #  Determine the golden output file associated with this output.
       #
       GoldenFName=${TargetFName%.output.review}.golden
       #
       if [ "${__KamajiRepresentative[${GoldenFName}]+IS_SET}" = "IS_SET" ]
       then
          GoldenDSpec=$(dirname ${__KamajiRepresentative[${GoldenFName}]})
       else
	  GoldenDSpec=../${__KamajiGoldenDSpec}/${TargetFName%.review}
       fi
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
  [ ${#Value} -eq 0 ] && KamajiExitAfterUsage "Empty values are not useful in a configuration file."
  #
  local -r VariableName=$(EchoMeaningOf ${Name} "" ${!__KamajiConfigurationValue[*]})
  #
  [ ${#VariableName} -eq 0 ] && KamajiExitAfterUsage "The '${Name}' configuration variable is not supported."
  #
  EchoAndExecute "echo \"${VariableName} ${Value}\" >> ./${__KamajiConfigurationFName}"
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestExport_makefile() {
  #
  local -r Request=${1}
  local -r Object=${2}
  #
  DiagnosticLight "${__KamajiScriptName} ${Request} ${Object}"
  #
  local -r MakefileFName=$(KamajiConfigurationEchoValue makefile-filename .kamaji.make)
  #
  local -r MakefileFSpec=${__KamajiWorkinDSpec}/${MakefileFName}.partial
  #
  local    TargetClass TargetFName
  #
  [ -e ${MakefileFSpec} ] && EchoAndExecuteInWorking mv ${MakefileFName} ${MakefileFName}.was
  #
  #  Export an explicit makefile.
  #
  rm --force ${MakefileFSpec}
  rm --force ${MakefileFSpec}.later
  #
  spit  ${MakefileFSpec} "#"
  spit  ${MakefileFSpec} "#  ${__KamajiScriptName} ${Request} ${Object}"
  spit  ${MakefileFSpec} "#"
  spit  ${MakefileFSpec} "#  This makefile will allow the user to request creation of specific files using the"
  spit  ${MakefileFSpec} "#  system make command in the same way that 'kamaji make' request does."
  spit  ${MakefileFSpec} "#"
  spit  ${MakefileFSpec} "#  Let the make command determine what needs to be re-made,"
  spit  ${MakefileFSpec} "#  but have it then call kamaji to make sure it is done right."
  spit  ${MakefileFSpec} "#"
  spit  ${MakefileFSpec} "#  The phony targets 'kamaji-output' and 'kamaji-grade' are defined for user convenience."
  spit  ${MakefileFSpec} "#"
  spit  ${MakefileFSpec} ""
  spit  ${MakefileFSpec} "QUIET ?= @"
  #
  for TargetClass in Grade
  do
    #
    spit ${MakefileFSpec} ""
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
  done
  #
  local -r RulesetFName=$(KamajiConfigurationEchoValue ruleset-filename .kamaji.ruleset.bash)
  #
  local -r RulesetFSpec=${__KamajiWorkinDSpec}/${RulesetFName}
  #
  spit  ${MakefileFSpec} ""
  spit  ${MakefileFSpec} ".PHONY: kamaji-grade kamaji-output"
  spit  ${MakefileFSpec} ""
  spit  ${MakefileFSpec} "kamaji-grade : \$(KamajiGradeTargetList)"
  spite ${MakefileFSpec} "\t@echo \"make \$@\""
  spite ${MakefileFSpec} "\t\$(QUIET) kamaji fast grade"
  spit  ${MakefileFSpec} ""
  spit  ${MakefileFSpec} "kamaji-output : \$(KamajiGradeTargetList:.grade=)"
  spite ${MakefileFSpec} "\t@echo \"make \$@\""
  spite ${MakefileFSpec} "\t\$(QUIET) kamaji fast invoke"
  spit  ${MakefileFSpec} ""
  spit  ${MakefileFSpec} "${RulesetFSpec} :"
  spite ${MakefileFSpec} "\t@echo \"make \$@\""
  spite ${MakefileFSpec} "\t\$(QUIET) kamaji fast show version"
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
      [ "${__KamajiRepresentative[${ItemOfParentFName}]+IS_SET}" = "IS_SET" ] && continue
      #
      OutputLine=
      #
      if [ "${__KamajiRepresentative[${ItemOfParentFName}]+IS_SET}" = "IS_SET" ]
      then
         #
         OutputLine+="${__KamajiRepresentative[${ItemOfParentFName}]#../}"
         #
      elif [ ${#__KamajiMyParentalList[${ItemOfParentFName}]} -eq 0 ]
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
      OutputList[${OutputIndx}]="${__KamajiWorkinDSpec}/${ItemOfParentFName} : ${RulesetFSpec}"
      #
      OutputList[${OutputIndx}]+="$(echo "${OutputLine}" | tr ' ' '\n' | sort --unique | tr '\n' ' ')"
      #
      OutputIndx+=1
      #
    done
    #
    ListOfParentFName="${NextOfParentFName}"
    #
  done
  #
  printf "%s\n" "${OutputList[@]}" | sort --unique > ${MakefileFSpec}.data
  #
  while read OutputLine
  do
    #
    printf "%s\n\t@echo \"make \$@\"\n\t\$(QUIET) kamaji fast make \$@\n\n" "${OutputLine}" >> ${MakefileFSpec}
    #
  done < ${MakefileFSpec}.data
  #
  rm     ${MakefileFSpec}.data
  #
  spit ${MakefileFSpec} "#"
  spit ${MakefileFSpec} "#  (eof}"
  #
  mv ${MakefileFSpec}	${__KamajiWorkinDSpec}/${MakefileFName}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestExport_ruleset() {
  #
  local -r Request=${1}
  local -r Object=${2}
  #
  local -r RulesetFName=$(KamajiConfigurationEchoValue ruleset-filename .kamaji.ruleset.bash)
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
  local -r Object=${2-}
  shift 2
  local -r ArgumentList="${*}"
  #
  local -r Target=$(EchoMeaningOf ${Object} "" makefile ruleset)
  #
  local -r FunctionWeWant=${FUNCNAME}_${Target}
  #
  local -r FunctionToCall=$(declare -F ${FunctionWeWant})
  #
  [ ${#FunctionToCall} -eq 0 ] && KamajiExitAfterUsage "Unable to '${Request} ${Object}' objects."
  #
  ${FunctionToCall} ${Request} ${Target} ${ArgumentList}
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
  local    SourceFName TargetFName TargetCheck
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
       fi
       #
       #  Find the ${TargetClass} decendants of the target.
       #
       TargetCheck=$(KamajiEchoListOfDecendantFName ${SourceFName} ${TargetClass})
       #
       if [ ${#TargetCheck} -eq 0 ]
       then
          #  
          EchoErrorAndExit 1 "Cannot ${Request} the '${SourceFName}' file; it has no known derivatives."
          #  
       fi
       #
       TargetFList+=" ${TargetCheck}"
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
    EchoAndExecute "echo \"${TargetFName}\" > ${__KamajiLastMakeTargetFSpec}"
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
  local    GivnSourceFName GivnSourceFSpec Target
  #
  local    GivnSourceFLast=
  #
  for GivnSourceFSpec in ${GivnSourceFList}
  do
    #
    Target=$(EchoMeaningOf ${GivnSourceFSpec} "$(basename ${GivnSourceFSpec})" grades last outputs)
    #
    if [ "${Target}" = "last" ]
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
       Target=${GivnSourceFLast}
       #
    elif [ "${Target}" = "grades" ]
    then
       #
       KamajiRequestGrade grade
       #
       break
       #
    elif [ "${Target}" = "outputs" ]
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
       if [ "${__KamajiBaseSourceList[${Target}]+IS_SET}" != "IS_SET" ]
       then
          #  
          EchoErrorAndExit 1 "The '${Target}' file cannot be made; it is not a known derivative."  
          #  
       fi
       #
       #  Save the target name to support the next "make last" request.
       #
       GivnSourceFLast=${Target}
       #
       EchoAndExecute "echo \"${GivnSourceFLast}\" > ${__KamajiLastMakeTargetFSpec}"
       #
    fi
    #
    #  Call for the target to be made.
    #
    KamajiMake ${Target}
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

function KamajiRequestShow_configuration() {
  #
  local -r Request=${1}
  local -r Object=${2}
  local -r Target=${3-}
  #
  local    Key
  #
  local -r Addition=$(EchoMeaningOf ${Target} "" names variables)
  #
  DiagnosticLight "${__KamajiScriptName} ${Request} ${Object} ${Addition}"
  #
  if [ ${#Addition} -eq 0 ]
  then
     #
     for Key in ${!__KamajiConfigurationValue[*]}
     do
       #
       if [ ${#__KamajiConfigurationValue[${Key}]} -gt 0 ]
       then
          #
          printf "%-23s %s\n" ${Key} "$(echo ${__KamajiConfigurationValue[${Key}]})"
          #
       fi
       #
     done | sort
     #
  else
     #
     printf "%s\n" ${!__KamajiConfigurationValue[*]} | sort
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestShow_copyright() {
  #
  local -r    Request=${1}
  local -r    Object=${2}
  #
  local -r -i YearCreated=2019
  #
  local -r -i YearCurrent=$(date '+%Y')
  #
  local       YearDisplay=${YearCreated}
  #
  [ ${YearCurrent} -ne ${YearCreated} ] && YearDisplay+="-${YearCurrent}"
  #
  echo "Copyright (c) ${YearDisplay} Brian G. Holmes."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestShow_version() {
  #
  local -r    Request=${1}
  local -r    Object=${2}
  #
  echo "kamaji version 0.4"
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestShow() {
  #
  local -r Request=${1}
  local -r Object=${2-configuration}
  shift 2
  local -r ArgumentList="${*}"
  #
  local -r Target=$(EchoMeaningOf ${Object} "" configuration copyright version)
  #
  local -r FunctionWeWant=${FUNCNAME}_${Target}
  #
  local -r FunctionToCall=$(declare -F ${FunctionWeWant})
  #
  [ ${#FunctionToCall} -eq 0 ] && KamajiExitAfterUsage "Unable to '${Request} ${Object}' objects."
  #
  ${FunctionToCall} ${Request} ${Target} ${ArgumentList}
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
  if [ ${Status} -gt 1 ]
  then
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
     EchoImportantMessage "${__KamajiFailTag}" "${TargetFName}"
     #
     __kamajiFailureCount+=1
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
  EchoAndExecuteInWorking "make --no-print-directory ${TargetFName}"
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
  local    ActualFSpec=./${SourceFName}
  #
  [ -L ${__KamajiWorkinDSpec}/${SourceFName} ] && ActualFSpec=$(readlink ${__KamajiWorkinDSpec}/${SourceFName})
  #
  local    ActualTimeCommand=${__KamajiTimeCommand}
  #
  [ ${#__KamajiTimeCommand} -gt 0 ] && ActualTimeCommand+="--output=${TargetFName}.time.text "
  #
  EchoAndExecuteInWorking "${ActualTimeCommand}${ActualFSpec} > ${TargetFName}.partial 2>&1"
  #
  Status=${?}
  #
  [ ${Status} -eq 0 ] || EchoFailureAndExit ${Status} "The ${SourceFName} program failed."
  #
  EchoAndExecuteInWorking "sed --in-place ${__KamajiSystemMasking} ${TargetFName}.partial"
  #
  Status=${?}
  #
  [ ${Status} -eq 0 ] || EchoErrorAndExit ${Status} "The account and system masking sed command failed."
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
  local    ActualFSpec=./${SourceFName}
  #
  [ -L ${__KamajiWorkinDSpec}/${SourceFName} ] && ActualFSpec=$(readlink ${__KamajiWorkinDSpec}/${SourceFName})
  #
  local    ActualTimeCommand=${__KamajiTimeCommand}
  #
  [ ${#__KamajiTimeCommand} -gt 0 ] && ActualTimeCommand+="--output=${TargetFName}.time.text "
  #
  EchoAndExecuteInWorking "${ActualTimeCommand}${ActualFSpec} > ${TargetFName}.partial 2>&1"
  #
  Status=${?}
  #
  [ ${Status} -eq 0 ] || EchoFailureAndExit ${Status} "The ${SourceFName} script failed."
  #
  EchoAndExecuteInWorking "sed --in-place ${__KamajiSystemMasking} ${TargetFName}.partial"
  #
  Status=${?}
  #
  [ ${Status} -eq 0 ] || EchoErrorAndExit ${Status} "The account and system masking sed command failed."
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
  local    ReviewCommand ReviewTailpipe
  #
  if [ -s ${__KamajiWorkinDSpec}/${DeltaSourceFName} ]
  then
     #
     local -r OutputFName=${DeltaSourceFName%.delta}
     #
     local -r OutputMskdFName=${OutputFName}.masked
     local -r GoldenMskdFName=${OutputFName%.output}.golden.masked
     #
     if [ -e ${__KamajiWorkinDSpec}/${GoldenMskdFName} ]
     then
        #
        local -i DeltaLineCount=$(cat ${__KamajiWorkinDSpec}/${DeltaSourceFName} | wc --lines)
        #
        local -i DeltaLongStart=$(KamajiConfigurationEchoValue long-review-line-count)
        #
        if [ ${DeltaLineCount} -ge ${DeltaLongStart} ]
	then
	   #
	   #  Reviewing "long" results.
	   #
	   ReviewCommand=$(KamajiConfigurationEchoValue long-review-command)
	   ReviewTailpipe=$(KamajiConfigurationEchoValue long-review-tailpipe)
	   #
        else
	   #
	   #  Reviewing "short" results.
	   #
	   ReviewCommand=$(KamajiConfigurationEchoValue short-review-command)
	   ReviewTailpipe=$(KamajiConfigurationEchoValue short-review-tailpipe)
	   #
        fi
        #
        ReviewCommand+=" ${GoldenMskdFName}"
        #
     else
        #
        #  Reviewing "new" results.
        #
        ReviewCommand=$(KamajiConfigurationEchoValue new-review-command)
        ReviewTailpipe=$(KamajiConfigurationEchoValue new-review-tailpipe)
        #
     fi
     #
     #  Perform the review.
     #
     ReviewCommand+=" ${OutputMskdFName}"
     #
     [ ${#ReviewTailpipe} -gt 0 ] && ReviewCommand+=" | ${ReviewTailpipe}"
     #
     EchoAndExecuteInWorking "${ReviewCommand}"
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
  local    ExecActualFSpec=${ExecSourceFName}
  #
  if [ -L ${__KamajiWorkinDSpec}/${ExecSourceFName} ]
  then
     ExecActualFSpec=$(readlink ${__KamajiWorkinDSpec}/${ExecSourceFName})
  fi
  #
  EchoAndExecuteInWorking "clutc ${ClutSourceFName} ${ExecActualFSpec} ${TargetFName}"
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
  local -r TargetClass=$(KamajiFileClassification ${TargetFName} $(Xtension ${TargetFName}))
  #
  #  Representatives must only exist; the files they represent are updated by the user.
  #
  local    ListOfMyParentalFName=${__KamajiMyParentalList[${TargetFName}]}
  local    ListOfXtraParentFName=
  #
  if [ ${#ListOfMyParentalFName} -eq 0 ] && [ ! -e ${__KamajiWorkinDSpec}/${TargetFName} ]
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

__kamajiFailureCount+=${?}

exit ${__kamajiFailureCount}

#----------------------------------------------------------------------------------------------------------------------
