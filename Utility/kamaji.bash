#!/bin/bash
#----------------------------------------------------------------------------------------------------------------------
###
###     kamaji.bash...
###
###     @file
###     @author         Brian G. Holmes
###     @copyright      GNU General Public License
###     @brief          Holmespun Testing Manager (HTM) script.
###     @todo           https://github.com/Holmespun/HolmespunTestingSupport/issues
###     @remark         kamaji.bash [<modifier>]... [<request>] [<parameter>]..."
###
###     @details        Unit test exercise and CLUT program output and evaluation manager.
###
#----------------------------------------------------------------------------------------------------------------------
#
#       AppendArrayIndexValue
#       RetrieveArrayValueAtIndex
#
#       DiagnosticHeavy
#       DiagnosticLight
#       DiagnosticComplex
#       EchoAbsoluteDirectorySpecFor
#       EchoAgeRelation
#       EchoAndExecuteStandardCheckingStderr
#       EchoAndExecuteInWorkingStdout
#       EchoAndExecuteInWorkingToFile
#       EchoAndExecute
#       EchoErrorAndExit
#       EchoExecutableFilesMatching
#       EchoFailureAndExit
#       EchoFileSpec
#       EchoImportantMessage
#       EchoMeaningOf
#       EchoPara
#       EchoPara80
#       EchoPara80-4
#       Xtension
#       SortArray
#
#       KamajiEchoArrayAssignments
#       KamajiEchoListOfDescendantFName
#       KamajiExitAfterUsage
#       KamajiFileClassification
#       KamajiOrderByLatestBaseSource
#
#       KamajiConfigurationCheckValues
#       KamajiConfigurationEchoValue
#       KamajiConfigurationLoadValues
#       KamajiConfigurationReadFile
#
#       KamajiModifierFast
#       KamajiModifierSilent
#       KamajiModifierUsage_bless
#       KamajiModifierUsage_configure
#       KamajiModifierUsage_delta
#       KamajiModifierUsage_grades
#       KamajiModifierUsage_export
#       KamajiModifierUsage_invoke
#       KamajiModifierUsage_make
#       KamajiModifierUsage_review
#       KamajiModifierUsage_show
#       KamajiModifierUsage_fast
#       KamajiModifierUsage
#       KamajiModifierVerbose
#
#       KamajiBuildRulesForTestingSource_Clut
#       KamajiBuildRulesForTestingSource_Elf
#       KamajiBuildRulesForTestingSource_Naked
#       KamajiBuildRulesForTestingSource_Output
#       KamajiBuildRulesForTestingSource_Script
#       KamajiBuildRulesForTestingSource_Unknown
#       KamajiBuildRulesForTestingSource
#       KamajiBuildRulesLoadXtraDependents
#       KamajiBuildRules
#
#       KamajiRequestBless
#       KamajiRequestConfigure
#       KamajiRequestDelta
#       KamajiRequestExport_configuration
#       KamajiRequestExport_makefile
#       KamajiRequestExport_ruleset
#       KamajiRequestExport
#       KamajiRequestGradeOrOutputOrReviewOrDelta
#       KamajiRequestGrade
#       KamajiRequestInvoke
#       KamajiRequestMake
#       KamajiRequestReview
#       KamajiRequestShow_configuration
#       KamajiRequestShow_copyright
#       KamajiRequestShow_version
#       KamajiRequestShow
#
#       KamajiMake_Delta_from_GoldenMasked_OutputMasked
#       KamajiMake_Delta_from_OutputMasked
#       KamajiMake_Delta_from_OutputMasked_GoldenMasked
#       KamajiMake_GoldenMasked_from_Golden_SedScriptComposit
#       KamajiMake_GoldenMasked_from_SedScriptComposit_Golden
#       KamajiMake_Grade_from_Delta
#       KamajiMake_Output_from_Naked
#       KamajiMake_Output_from_Script
#       KamajiMake_OutputMasked_from_Output_SedScriptComposit
#       KamajiMake_OutputMasked_from_SedScriptComposit_Output
#       KamajiMake_Review_from_Delta_Grade
#       KamajiMake_Review_from_Grade_Delta
#       KamajiMake_Script_from_Clut_Naked
#       KamajiMake_Script_from_Clut_Script
#       KamajiMake_Script_from_Naked_Clut
#       KamajiMake_Script_from_Script_Clut
#       KamajiMake_SedScriptComposit_from_SedScriptListing
#       KamajiMake
#
#       KamajiMain
#
#----------------------------------------------------------------------------------------------------------------------
#
#  20190704 BGH; created.
#  20190720 BGH; version 0.2.
#  20190817 BGH; version 0.3, kamaji knows the source files, calculates all output files, functions based on both.
#  20190910 BGH; readlink representative invoke (see below).
#  20191027 BGH; version 0.4, testing the clutc utility.
#  20191028 BGH; version 0.5, silent running for specific makefile targets, delta command.
#  20191214 BGH; version 1.00, repository documentation in place.
#  20210101 BGH; modifications for improved use with the Holmespun Makefile Method revamp began.
#  20210526 BGH; data class defined.
#  20210526 BGH; sed masking scripts treated same as configuration files, mask-sed-script configuration item removed.
#  20210528 BGH; removed makefile-filename and ruleset-filename configuration variables.
#
#  Problems detected when the representative of a script is called: The files it sources are  not in the same relative
#  hierarchy as the symbolic link. Created a Bash script representative that worked very well, but a Bash script
#  representative does not carry the same modification date as the file it is supposed to represent. As such, we invoke
#  the readlink version of each representative. 20190910 BGH.
#
#----------------------------------------------------------------------------------------------------------------------
#
#  Copyright (c) 2019 Brian G. Holmes
#
#       This program is part of the Holmespun Testing Support repository.
#
#       The Holmespun Testing Support repository only contains free software: you can redistribute it and/or modify it
#       under the terms of the GNU General Public License as published by the Free Software Foundation, either version
#       three (3) of the License, or (at your option) any later version.
#
#       The Holmespun Testing Support repository is distributed in the hope that it will be useful, but WITHOUT ANY
#       WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
#       General Public License for more details.
#
#       You should have received a copy of the GNU General Public License along with this file. If not, see
#       <https://www.gnu.org/licenses/>.
#
#  See the COPYING.text file for further information.
#
#----------------------------------------------------------------------------------------------------------------------

set -u

export LC_COLLATE=C

source $(whereHolmespunLibraryBashing)/Library/echoInColor.bash
source $(whereHolmespunLibraryBashing)/Library/echoListOfConfigurationFSpec.bash
source $(whereHolmespunLibraryBashing)/Library/echoRelativePath.bash
source $(whereHolmespunLibraryBashing)/Library/spit_spite_spitn_and_spew.bash

#----------------------------------------------------------------------------------------------------------------------

declare -r __KamajiIfsOriginal="${IFS}"

declare -r __KamajiPartialSuffix="pid_$$.partial.text"

declare -r __KamajiUserRequest="${*}"

declare -r __KamajiDatStamp=$(date '+%Y%m%d_%H%M%S')

#----------------------------------------------------------------------------------------------------------------------

declare -r __KamajiScriptFName=$(basename ${0})
declare -r __KamajiScriptFRoot=${__KamajiScriptFName%%.*}

declare -r __KamajiConfigurationFName=.${__KamajiScriptFRoot}.conf
declare -r __KamajiMaskingScriptFName=.${__KamajiScriptFRoot}.sed
declare -r __KamajiXtraDependentFName=.${__KamajiScriptFRoot}.deps

declare -r __KamajiConfigLogFSpec=$(mktemp --dry-run -t ${__KamajiConfigurationFName}_${__KamajiDatStamp}_$$_XXXX.text)

declare -r __KamajiMakefileFName=.${__KamajiScriptFRoot}.make

declare -r __KamajiSedCompositFName=${__KamajiMaskingScriptFName}.composit.sed
declare -r __KamajiSedFileListFName=${__KamajiMaskingScriptFName}.filelist.text

declare -r __KamajiRulesetFName=.${__KamajiScriptFRoot}.ruleset.bash

#----------------------------------------------------------------------------------------------------------------------

declare -A __KamajiConfigurationDefault

declare -A __KamajiConfigurationValue

declare    __KamajiDataFileNameList="TBD"

declare    __KamajiEnvironmentMasking="TBD"

declare    __KamajiGoldenDSpec="TBD"

declare    __KamajiLastMakeTargetFSpec="TBD"

declare    __KamajiMalleableConfigFSpec="TBD"

declare    __KamajiNikrowDSpec="TBD"    # Back out of the working-folder.

declare    __KamajiScriptExtensionList="TBD"

declare    __KamajiTimeFormat="TBD"

declare    __KamajiVerbosityRequested="TBD"

declare    __KamajiWorkinDSpec="TBD"

#----------------------------------------------------------------------------------------------------------------------

declare -i __KamajiFailureCount=0

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

function RetrieveArrayValueAtIndex() {
  #
  local -r ArrayName=${1}
  local -r IndexText="${2}"
  #
  local -r ItemReference=${ArrayName}["${IndexText}"]
  #
  local -r Conditional="[ \"\${${ItemReference}+IS_SET}\" = \"IS_SET\" ] && Result=\"\${${ItemReference}}\""
  #
  local    Result="UNDEFINED"
  #
  eval "${Conditional}"
  #
  [ "${Result}" = "UNDEFINED" ] && echoInColorMauve "${ItemReference}=${Result}" >&2
  #
  echo "${Result}"
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
  local -r WhereWeWere=${PWD}

  cd ${ParentDSpec}/${NestedDSpec}
     #
     echo ${PWD}
     #
  cd ${WhereWeWere}/
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
#
#  EchoAndExecuteStandardCheckingStderr interprets any information written to stderr by the given SystemRequest as an
#  error message, outputs that information as a colored error message, and adjusted the return status appropriately.
#  Error output is written to stderr. Information originally written to stdout by the SystemRequest is written to
#  stderr.
# 
#----------------------------------------------------------------------------------------------------------------------

function EchoAndExecuteStandardCheckingStderr() {
  #
  local -r SystemRequest="${*}"
  #
  local -i Status=0
  #
  local    ErrorMessage=
  #
  exec 5>&2
     #
     ErrorMessage=$(eval ${SystemRequest} 2>&1 1>&5)
     #
     Status=${?}
     #
  exec 5>&-
  #
  if [ ${#ErrorMessage} -gt 0 ]
  then
     #
     [ ${Status} -eq 0 ] && Status=33
     #
     echoInColorRed ${ErrorMessage}
     #
  fi
  #
  return ${Status}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function EchoAndExecuteInWorkingStdout() {
  #
  local -r SystemRequest="${*}"
  #
  local -i Status
  #
  DiagnosticHeavy "${SystemRequest}" 1>&2
  #
  cd ${__KamajiWorkinDSpec}/
     #
     IFS=
        #
        EchoAndExecuteStandardCheckingStderr ${SystemRequest} 2>&1 1>&2
        #
        Status=${?}
        #
     IFS="${__KamajiIfsOriginal}"
     #
  cd ${__KamajiNikrowDSpec}/
  #
  return ${Status}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function EchoAndExecuteInWorkingToFile() {
  #
  local -r CaptureOutput="${1}"
  shift 1
  local -r SystemRequest="${*}"
  #
  local -i Status
  #
  DiagnosticHeavy "${SystemRequest} > ${CaptureOutput} 2>&1" 1>&2
  #
  cd ${__KamajiWorkinDSpec}/
     #
     eval ${SystemRequest} > ${CaptureOutput} 2>&1
     #
     Status=${?}
     #
  cd ${__KamajiNikrowDSpec}/
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
     EchoAndExecuteStandardCheckingStderr ${SystemRequest} 2>&1 1>&2
     #
     Status=${?}
     #
  IFS="${__KamajiIfsOriginal}"
  #
  return ${Status}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function EchoConfigurationFileList() {
  #
  local ConfigDSpec=${PWD}
  #
  echo ${HOME}/${__KamajiConfigurationFName}
  #
  while [ ${ConfigDSpec} != / ] && [ ${ConfigDSpec} != ${HOME} ]
  do
    #
    echo ${ConfigDSpec}/${__KamajiConfigurationFName}
    #
    ConfigDSpec=$(dirname ${ConfigDSpec})
    #
  done | sort
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
     #  Check for the root of a script name.
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
  local -r WordLessSimple=${WordList%:${Target}*}
  #
  local -r WordLessGreedy=${WordList%%:${Target}*}
  #
  local    Result=${Default}
  #
  if [ ${#WordLessSimple} -eq ${#WordLessGreedy} ] && [ ${#WordLessSimple} -lt ${#WordList} ]
  then
     #
     Result=${WordList:${#WordLessSimple}}
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

function WasWorkingFile() {
  #
  local -r TargetFName=${1}
  #
  [ -e ${__KamajiWorkinDSpec}/${TargetFName} ] && EchoAndExecuteInWorkingStdout mv ${TargetFName} ${TargetFName}.was
  #
}

#----------------------------------------------------------------------------------------------------------------------

function PublishWorkingFile() {
  #
  local -r SourceFName=${1}     # Must have a __KamajiPartialSuffix.
  #
  local -r TargetFName=${SourceFName%.${__KamajiPartialSuffix}}
  #
  if [ ${#TargetFName} -ne ${#SourceFName} ]
  then
     #
     WasWorkingFile ${TargetFName}
     #
     EchoAndExecuteInWorkingStdout mv ${SourceFName} ${TargetFName}
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------

function StartWorkingFile() {
  #
  local -r TargetFName=${1}     # May have a __KamajiPartialSuffix.
  #
  WasWorkingFile ${TargetFName}
  #
  spit ${__KamajiWorkinDSpec}/${TargetFName} "#"
  spit ${__KamajiWorkinDSpec}/${TargetFName} "#  ${TargetFName%.${__KamajiPartialSuffix}}"
  spit ${__KamajiWorkinDSpec}/${TargetFName} "#"
  spit ${__KamajiWorkinDSpec}/${TargetFName} "#  User request:  ${__KamajiScriptFName} ${__KamajiUserRequest}"
  spit ${__KamajiWorkinDSpec}/${TargetFName} "#"
  spit ${__KamajiWorkinDSpec}/${TargetFName} "#  Date and time: $(date '+%Y-%m-%d') at $(date '+%H:%M:%S')"
  spit ${__KamajiWorkinDSpec}/${TargetFName} "#"
  #
}

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
# [ ${#KeyValueList} -gt 0 ] && spit ${RulesetFSpec} "#"
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiEchoListOfDescendantFName() {
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
       ResultFList+=" $(KamajiEchoListOfDescendantFName ${ChildsFName} ${TargetClass})"
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
  local -r SourceFName=$(basename ${SourceFSpec})
  #
  local -r SourceFTest=${__KamajiScriptExtensionList/:${SourceFType}:/}
  #
  local -r DataDefined=${__KamajiDataFileNameList/:${SourceFName}:/}
  #
  local    Result=Unknown
  #
  if [ ${#DataDefined} -ne ${#__KamajiDataFileNameList} ]
  then
     #
     Result="Data"
     #
  elif [ "${SourceFName}" = "${__KamajiSedCompositFName}" ]
  then
     #
     Result="SedScriptComposit"
     #
  elif [ "${SourceFName}" = "${__KamajiSedFileListFName}" ]
  then
     #
     Result="SedScriptListing"
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
  [ ${#__KamajiWorkinDSpec} -eq 0 ] && EchoErrorAndExit 2 "The working-folder is improperly configured."
  #
  [ ${#__KamajiGoldenDSpec} -eq 0 ] && EchoErrorAndExit 2 "The baseline-folder is improperly configured."
  #
  [ ! -d ${__KamajiGoldenDSpec} ] && EchoErrorAndExit 2 "The baseline-folder '${__KamajiGoldenDSpec}' does not exist."
  #
  [ ! -d ${__KamajiWorkinDSpec} ] && mkdir --parents ${__KamajiWorkinDSpec}
  #
  local -r GoldenDSpec=$(EchoAbsoluteDirectorySpecFor . ${__KamajiGoldenDSpec})
  local -r WorkinDSpec=$(EchoAbsoluteDirectorySpecFor . ${__KamajiWorkinDSpec})
  #
  if [ "${GoldenDSpec}" = "${WorkinDSpec}" ]
  then
     #
     EchoErrorAndExit 2 "The baseline-folder and/or working-folder are improperly configured;"        \
                        "these cannot be the same."
     #
  fi
  #
  local -r EnvMaskMarker="$(KamajiConfigurationEchoValue environment-masking)"
  #
  local -r EnvMaskPrefix="${EnvMaskMarker%% *}"
  local    EnvMaskSuffix="${EnvMaskMarker#* }"
  #
  __KamajiEnvironmentMasking=
  #
  if [ "${EnvMaskPrefix}" != "NONE" ]
  then
     #
     [ "${EnvMaskSuffix}" = "${EnvMaskMarker}" ] && EnvMaskSuffix=
     #
     __KamajiEnvironmentMasking+=" --expression='s,${WorkinDSpec},${EnvMaskPrefix}WORKING${EnvMaskSuffix},g'"
     __KamajiEnvironmentMasking+=" --expression='s,${HOME},${EnvMaskPrefix}HOME${EnvMaskSuffix},g'"
     __KamajiEnvironmentMasking+=" --expression='s,${USER},${EnvMaskPrefix}USER${EnvMaskSuffix},g'"
     __KamajiEnvironmentMasking+=" --expression='s,${LOGNAME},${EnvMaskPrefix}LOGNAME${EnvMaskSuffix},g'"
     __KamajiEnvironmentMasking+=" --expression='s,$(uname -n),${EnvMaskPrefix}HOSTNAME${EnvMaskSuffix},g'"
     __KamajiEnvironmentMasking+=" --expression='s,\<$(date '+%Z')\>,${EnvMaskPrefix}TIMEZONE${EnvMaskSuffix},g'"
     __KamajiEnvironmentMasking+=" --expression='s,pid_$$,pid_${EnvMaskPrefix}PID${EnvMaskSuffix},g'"
     #
  fi
  #
  local -r DefaultTimeFormat="Time %E %e %S %U %P Memory %M %t %K %D %p %X %Z %F %R %W %c %w I/O %I %O %r %s %k %x %C"
  #
  __KamajiTimeFormat="$(KamajiConfigurationEchoValue time-output-format)"
  #
  if [ "${__KamajiTimeFormat}" = "NONE" ] || [ ! -x /usr/bin/time ]
  then
     #
     __KamajiTimeFormat=
     #
  else
     #
     [ "${__KamajiTimeFormat}" = "FULL" ] && __KamajiTimeFormat="${DefaultTimeFormat}"
     #
  fi
  #
  __KamajiNikrowDSpec=$(echoRelativePath ${WorkinDSpec} ${PWD})         # ".." if working-folder is simple name.
  #
  #  Generate a list of the current user-defined sed scripts.
  #
  local -r ListOfSedFSpec=$(echoListOfConfigurationFSpec ${__KamajiMaskingScriptFName} KAMAJI_CONFIG_BASE_DSPEC)
  #
  spit ${__KamajiWorkinDSpec}/${__KamajiSedFileListFName}.${__KamajiPartialSuffix} "${ListOfSedFSpec}"
  #
  diff --brief ${__KamajiWorkinDSpec}/${__KamajiSedFileListFName}.${__KamajiPartialSuffix}      \
               ${__KamajiWorkinDSpec}/${__KamajiSedFileListFName} > /dev/null 2>&1
  #
  if [ ${?} -ne 0 ]
  then
     #
     #  The composit must be rebuilt because its list of sources has changed.
     #
     PublishWorkingFile ${__KamajiSedFileListFName}.${__KamajiPartialSuffix}
     #
  else
     #
     rm ${__KamajiWorkinDSpec}/${__KamajiSedFileListFName}.${__KamajiPartialSuffix}
     #
     for ItemOfSedFSpec in ${ListOfSedFSpec}
     do
       #
       if [ ${ItemOfSedFSpec} -nt ${__KamajiWorkinDSpec}/${__KamajiSedFileListFName} ]
       then
          #
          #  The composit must be rebuilt because one of its sources has changed.
          #
          #  __KamajiMyParentalList[TargetFName]="SourceFName...": What files are direct sources of this target?
          #
          AppendArrayIndexValue __KamajiMyParentalList "${__KamajiSedCompositFName}" " ${ItemOfSedFSpec}"
          #
          break
          #
       fi
       #
     done
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
  local Key Value ItemOfConfigFSpec
  #
  #  Set default configuration values.
  #
  __KamajiConfigurationDefault["baseline-folder"]="Testing"
  __KamajiConfigurationDefault["data-extension-list"]=
  __KamajiConfigurationDefault["data-filename-list"]=
  __KamajiConfigurationDefault["environment-masking"]="% %"
  __KamajiConfigurationDefault["find-expression-list"]=
  __KamajiConfigurationDefault["last-target-filename"]="${__KamajiConfigurationFName%.*}.last_target.text"
  __KamajiConfigurationDefault["long-review-command"]="vimdiff -R"
  __KamajiConfigurationDefault["long-review-line-count"]=51
  __KamajiConfigurationDefault["long-review-tailpipe"]=
  __KamajiConfigurationDefault["new-review-command"]="cat --number"
  __KamajiConfigurationDefault["new-review-tailpipe"]=
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
  #  Record the user-defined configuration as it is loaded.
  #
  local -r ConfigBaseMessage="The KAMAJI_CONFIG_BASE_DSPEC variable is being used to limit configuration file scope."
  #
  local -i ConfigFileCount=0
  #
  local -r ListOfConfigFSpec=$(echoListOfConfigurationFSpec ${__KamajiConfigurationFName} KAMAJI_CONFIG_BASE_DSPEC)
  #
  if [ "${KAMAJI_CONFIG_BASE_DSPEC+IS_SET}" = "IS_SET" ]
  then
     #
     spit ${__KamajiConfigLogFSpec} "#  ${ConfigBaseMessage}"
     spit ${__KamajiConfigLogFSpec} "#"
     #
  fi
  #
  __KamajiMalleableConfigFSpec=
  #
  for ItemOfConfigFSpec in ${ListOfConfigFSpec}
  do
    #
    if [ -f ${ItemOfConfigFSpec} ]
    then
       #
       KamajiConfigurationReadFile ${ItemOfConfigFSpec} ${__KamajiConfigLogFSpec}
       #
       ConfigFileCount+=1
       #
       [ -w ${ItemOfConfigFSpec} ] && __KamajiMalleableConfigFSpec=${ItemOfConfigFSpec}
       #
    elif [ -w $(dirname ${ItemOfConfigFSpec}) ]
    then
       #
       __KamajiMalleableConfigFSpec=${ItemOfConfigFSpec}
       #
    fi
    #
  done
  #
  [ ${ConfigFileCount} -eq 0 ] && spite ${__KamajiConfigLogFSpec} "#  No configuration files active.\n#\n"
  #
  spit ${__KamajiConfigLogFSpec} "#  (eof)"
  #
  #  Define oft-used configuration items.
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
  __KamajiVerbosityRequested=$(KamajiConfigurationEchoValue verbosity-level)
  #
  __KamajiWorkinDSpec=$(KamajiConfigurationEchoValue working-folder)
  #
  __KamajiLastMakeTargetFSpec=${__KamajiWorkinDSpec}/$(KamajiConfigurationEchoValue last-target-filename)
  #
}
  
#----------------------------------------------------------------------------------------------------------------------

function KamajiConfigurationReadFile() {
  #
  local -r ConfigFSpec="${1}"
  local -r LoggedFSpec="${2}"
  #
  local    Key Value KeyIsNotListCheck
  #
  spit ${LoggedFSpec} "#  BEGIN ${ConfigFSpec}"
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
             spit ${LoggedFSpec} "${Key} ${Value}"
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
  done < ${ConfigFSpec}
  #
  spit ${LoggedFSpec} "#  END   ${ConfigFSpec}"
  spit ${LoggedFSpec} "#"
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
  local -r RulesetFSpec=${__KamajiWorkinDSpec}/${__KamajiRulesetFName}
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
  EchoPara80    "$(echoInColorWhiteBold "Baseline|Bless...")"
  #
  EchoPara80    "The 'bless' request allows you to baseline current output files after you have reviewed them." \
                "A 'bless' request will not generate any test data;"                                            \
                "it can only be applied to output files that have already been generated and reviewed."         \
                "it is a convenient shorthand, but it will cost you if you baseline output that is not valid."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_configure() {
  #
  local -r Request="${1}"
  #
  EchoPara80    "$(echoInColorWhiteBold "Configure|Set...")"
  #
  EchoPara80    "Named configuration items and their values are stored in"                                      \
                "${__KamajiConfigurationFName} files."                                                          \
                "If it exists, then configuration items are first read from the"                                \
                "\$HOME/${__KamajiConfigurationFName} file."                                                    \
                "If the \$PWD is within the \$HOME hierarchy, then configuration files from every"              \
                "subdirectory between \$HOME and \$PWD are read."                                               \
                "If the \$PWD is not within the \$HOME hierarchy, then configuration files from every"          \
                "subdirectory between / and \$PWD are read, with the exception of / itself."
  #
  EchoPara80    "The user can limit the number of directories searched for configuration files by defining the" \
                "KAMAJI_CONFIG_BASE_DSPEC variable:"                                                            \
                "If defined then only configuration files within that directory and its subdirectries will be"  \
                "used."
  #
  EchoPara80    "Based on the order read, items set later will re-define or augment items that were defined"    \
                "earlier."
  #
  EchoPara80    "Configuration files may contain comments (#), blank lines, and item settings."                 \
                "Item settings must name the item and provide a value; the values cannot be empty."
  #
  EchoPara80    "The following settings represent the non-empty defaults:"
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
  EchoPara80    "The following items may be set:"
  #
  EchoPara80-4  "baseline-folder <directory-specification> -"                                                   \
                "Specification for the directory where baseline output files are stored."
  #
  EchoPara80-4  "data-extension-list <extension>... -"                                                          \
                "A list of name extensions for \"data\" files that are stored in the baseline-folder,"          \
                "but do not represent CLUT or unit test exercises or their output."                             \
                "Data files are represented in the working-folder."
  #
  EchoPara80-4  "data-filename-list <filename>... -"                                                            \
                "A list of names for \"data\" files that are stored in the baseline-folder,"                    \
                "but do not represent CLUT or unit test exercises or their output."                             \
                "Data files are represented in the working-folder."
  #
  EchoPara80-4  "environment-masking { <prefix> | NONE } [ <suffix> ]... -"                                     \
                "Environment masking is used to remove system details from output files,"                       \
                "so that those details are not preserved in repositories:"                                      \
                "The full directory specification of the working-folder;"                                       \
                "Text that matches the dereferenced \$HOME, \$USER, and \$LOGNAME enviroment variables;"        \
                "The \$(uname -n) host name; and"                                                               \
                "The \$(date '+%Z') time zone."                                                                 \
                "These are represented in the output by a mask name surrounded by the given prefix and suffix." \
                "Mask names are WORKING, USER, LOGNAME, HOSTNAME, AND TIMEZONE, respectvely."                   \
                "If the prefix is set to NONE then environment masking is disabled."                            
  #
  EchoPara80-4  "find-expression-list <expression>... -"                                                        \
                "Expressions that are passed to the find command when determining which files within the"       \
                "baseline-folder should be represented in the working-folder."                                  \
                "The default '-type f' expression is ignored if this configuration item is set."                \
                "The maxdepth, name, path, and prune options are best for building useful expressions here."    \
                "For example, the compound expression"                                                          \
                "'-name \"W*\" -prune -o -path ./.git -prune -o -print'"                                        \
                "instructs find to ignore files that start with the capital letter W,"                          \
                "and any files in the ./.git subdirectory."
  #
  EchoPara80-4  "last-target-filename <filename> -"                                                             \
                "The name of the file in which the filename of the last make target is stored;"                 \
                "the file is stored in the working-folder."
  #
  EchoPara80-4  "long-review-command <command> -"                                                               \
                "The command used to perform a long review."                                                    \
                "A long review is defined by the configured long-review-line-count value."                      \
                "The command is called from within the working-folder, and is passed the"                       \
                "masked baseline output and masked current output files in that order."
  #
  EchoPara80-4  "long-review-line-count <integer> -"                                                            \
                "The number of diff command output lines that are too many to be considered"                    \
                "the subject of a short review."                                                                \
                "This number is used to define the difference between a short and long review."
  #
  EchoPara80-4  "long-review-tailpipe <command> [ | <command> ]... -"                                           \
                "A command into which the long-review-command output is piped."                                 \
                "For example, if you set the long-review-command to \"diff\" then you might want to"            \
                "set the review-tailpipe to \"sed --expression='s,^,    ,' | less\" so that the diff"           \
                "output will be indented, you can view it a page at a time, and it will not"                    \
                "clutter your display after your review."
  #
  EchoPara80-4  "new-review-command <command> -"                                                                \
                "The command used to perform a new review."                                                     \
                "A new review is one for which there is no baseline output file to compare to."                 \
                "The command is called from within the working-folder, and is passed the"                       \
                "masked current output file."
  #
  EchoPara80-4  "new-review-tailpipe <command> [ | <command> ]... -"                                            \
                "A command into which the new-review-command output is piped."                                  \
  #
  EchoPara80-4  "script-type-list [<extension>]... -"                                                           \
                "A list of file name extensions that are used to store executable scripts."                     \
  #
  EchoPara80-4  "short-review-command <command> -"                                                              \
                "The command used to perform a short review."                                                   \
                "A short review is defined by the configured long-review-line-count value."                     \
                "The command is called from within the working-folder, and is passed the"                       \
                "masked baseline output and masked current output files in that order."
  #
  EchoPara80-4  "short-review-tailpipe <command> [ | <command> ]... -"                                          \
                "A command into which the short-review-command output is piped."                                \
  #
  EchoPara80-4  "time-output-format { <time-format> | FULL | NONE } -"                                          \
                "The output format used by the /usr/bin/time program to provide run-time statistics about"      \
                "CLUT scripts and unit test scripts and programs; please see the GNU VERSION section of the"    \
                "description produced by the man time command."                                                 \
                "A pre-defined, verbose format can be applied by using the FULL value."                         \
                "The time program is not used if this variable is set to NONE"                                  \
                "or if the /usr/bin/time program is not available."
  #
  EchoPara80-4  "verbosity-level <adjective> -"                                                                 \
                "The level of diagnostic output produced."                                                      \
                "The 'quiet' level suppresses diagnostic output."                                               \
                "The 'light' level will describe the 'make' requests used to fulfill the user's request."       \
                "The 'heavy' level will augment light output with a description of commands applied to files"   \
                "in the working-folder and comments that describe data that it uses to decide what commands"    \
                "should be applied."
  #
  EchoPara80-4  "working-folder <directory-specification> -"                                                    \
                "The specification for the directory where intermediate and unverified output files are"        \
                "created."                                                                                      \
                "If the working-folder does not already exist then it will be silently created."                \
  #
  EchoPara80    "Subsequent variable settings override previous values for the variable they name,"             \
                "unless that variable represents a list, in which case the value is augmented."
  #
  EchoPara80    "A list of the configuration variable names can be displayed using a"                           \
                "'show configuration' request."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_delta() {
  #
  local -r Request="${1}"
  #
  EchoPara80    "$(echoInColorWhiteBold "Compare|Delta|Pre-Grade...")"
  #
  EchoPara80    "A 'delta' request asks ${__KamajiScriptFName} to compare the current output of each"            \
                "CLUT or unit test exercise to its baseline."                                                   \
                "The main reason that the delta command exists is that output file comparisons may be"          \
                "expensive, and thus they are a good candidate to apply apply parallel processing to."
  #
  EchoPara80    "A 'delta last' request will compare the current output of the last make target processed"      \
                "by ${__KamajiScriptFName} the last time it was invoked."                                        \
                "The \"last\" target is the same no matter where it appears in the list of targets"             \
                "passed to an 'delta' request."
  #
  EchoPara80    "A 'delta' request without any specific targets is the same as an 'delta' request for"          \
                "all known targets."                                                                            \
                "Furthermore, those targets will be processed based on when their base sources were"            \
                "last modified."                                                                                \
                "In this way, when the user modifies the source file for a specific CLUT or unit test,"         \
                "${__KamajiScriptFName} will make processing that test a higher priority than all others."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_grade() {
  #
  local -r Request="${1}"
  #
  EchoPara80    "$(echoInColorWhiteBold "Grade...")"
  #
  EchoPara80    "A 'grade' request will determine the pass or fail status of a one or more"                     \
                "CLUT or unit test exercise."
  #
  EchoPara80    "A passing grade is granted for a test program when the program produces output"                \
                "that matches its expected/golden baseline output."                                             \
                "Comparisons are made to output files only after they are masked to remove"                     \
                "non-deterministic values (e.g. dates, times, account names)."
  #
  EchoPara80    "Masking is performed by a user-defined sed script;"                                            \
                "one or more ${__KamajiMaskingScriptFName} scripts are used based on their position in the"      \
                "development directory hierarchy (i.e. in the same manner as user-defined configuration files)."
  #
  EchoPara80    "A 'grade last' request with grade the output associated with the last make target processed"   \
                "by ${__KamajiScriptFName} the last time it was invoked."                                        \
                "The \"last\" target is the same no matter where it appears in the list of targets"             \
                "passed to a 'grade' request."
  #
  EchoPara80    "A 'grade' request without any specific targets is the same as a 'grade' request for all known" \
                "targets."                                                                                      \
                "Furthermore, those targets will be evaluated based when their base sources were"               \
                "last modified."                                                                                \
                "In this way, when the user modifies the source file for a specific CLUT or unit test,"         \
                "${__KamajiScriptFName} will give evaluation of that test a higher priority than for all others."
  #
  EchoPara80    "Although grades are identified using the \"grade\" file name extension,"                       \
                "the actual grade is not stored."                                                               \
                "This practice will cause ${__KamajiScriptFName} to evaluate a CLUT or unit test exercise,"      \
                "and display the assigned grade, every time the user requests it."                              \
                "As such, the user will get explicit grade feedback for every test every time it is requested."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_export() {
  #
  local -r Request="${1}"
  #
  EchoPara80    "$(echoInColorWhiteBold "Export...")"
  #
  EchoPara80    "The ${__KamajiScriptFName} script allows the user to export three forms of data:"               \
                "configuration, makefile, and ruleset."
  #
  EchoPara80    "$(echoInColorWhiteBold "Export Configuration...")"
  #
  EchoPara80    "The 'export configuration' request is used to produce a configuration file that represents"    \
                "all of the active configuration sources."                                                      \
                "The exported configuration file is placed in the working-folder."                              \
                "It contains the same information as shown in the 'Active configuration sources' section of"    \
                "the information displayed by the 'show configuration' command."
  #
  EchoPara80    "$(echoInColorWhiteBold "Export Makefile...")"
  #
  EchoPara80    "The 'export makefile' request is used to produce a makefile that can be used to integrate"     \
                "${__KamajiScriptFName} into a makefile system."                                                 \
                "An exported makefile contains a rule for every derived file known to ${__KamajiScriptFName}."   \
                "Use of the make command --jobs switch with the exported makefile can produce results even"     \
                "faster than invoking parallel ${__KamajiScriptFName} grade requests."
  #
  EchoPara80    "$(echoInColorWhiteBold "Export Ruleset...")"
  #
  EchoPara80    "The ${__KamajiScriptFName} script defines a ruleset that it uses to guide creation of every"    \
                "file in the working-folder;"                                                                   \
                "to determine what files need to be made or re-made, and the"                                   \
                "proper order in which that should happen."
  #
  EchoPara80    "By default, ${__KamajiScriptFName} generates its ruleset every time it is called"               \
                "so that it can properly react to dramatic changes in the baseline-folder."                     \
                "As the ruleset only changes when files are added or removed from the baseline-folder, it is"   \
                "inefficient to regenerate the ruleset when the baseline-folder has not changed in this way."
  #
  EchoPara80    "Users can request that ${__KamajiScriptFName} export its current ruleset for future use"        \
                "using the 'export' request."                                                                   \
  #
  EchoPara80    "The 'fast' modifier can be used to ask ${__KamajiScriptFName} to"                               \
                "load an exported ruleset instead of generating one itself."                                    \
                "The 'fast' modifier will generate and export a ruleset when it does not find one to load."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_invoke() {
  #
  local -r Request="${1}"
  #
  EchoPara80    "$(echoInColorWhiteBold "Execute|Invoke|Run...")"
  #
  EchoPara80    "An 'invoke' request causes each CLUT or unit test exercise to be executed."                    \
                "Output from each CLUT or unit test exercise is captured in an output file."
  #
  EchoPara80    "An 'invoke last' request will invoke the last make target processed"                           \
                "by ${__KamajiScriptFName} the last time it was itself invoked."                                 \
                "The \"last\" target is the same no matter where it appears in the list of targets"             \
                "passed to an 'invoke' request."
  #
  EchoPara80    "An 'invoke' request without any specific targets is the same as an 'invoke' request for"       \
                "all known targets."                                                                            \
                "Furthermore, those targets will be invoked based when their base sources were"                 \
                "last modified."                                                                                \
                "In this way, when the user modifies the source file for a specific CLUT or unit test,"         \
                "then ${__KamajiScriptFName} will give output generation for that test a higher priority"        \
                "than for all others."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_make() {
  #
  local -r Request="${1}"
  #
  EchoPara80    "$(echoInColorWhiteBold "Make...")"
  #
  EchoPara80    "Users can request that ${__KamajiScriptFName} generate one or more specific files by"           \
                "naming them in a 'make' request."                                                              \
                "When the user asks ${__KamajiScriptFName} to make a file that is already the most"              \
                "up-to-date version of itself, then ${__KamajiScriptFName} ignores the request;"                 \
                "it is not an error."                                                                           \
                "Files are only remade after the files that they are created from are remade, if necessary."    \
                "Files are only remade when files that they are created from have changed;"                     \
                "either because the user changed them or because they themselves were remade."
  #
  EchoPara80    "A 'make grades' request is the same as a 'grade' request: Every output file is generated,"     \
                "compared to its associated baseline, and then graded based on that comparison."
  #
  EchoPara80    "A 'make outputs' request is the same as an 'invoke' request: Every output file is generated."
  #
  EchoPara80    "A 'make last' request will attempt to remake the last specific target of"                      \
                "a 'grade' or 'invoke' or 'make' request."                                                      \
                "This is an especially useful shorthand when ${__KamajiScriptFName} is used for"                 \
                "test-driven development."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_review() {
  #
  local -r Request="${1}"
  #
  EchoPara80    "$(echoInColorWhiteBold "Review...")"
  #
  EchoPara80    "A 'review' request can be used to inspect the masked output differences that led to a"         \
                "failed grade."                                                                                 \
                "Reviews are based on grades, and they are only performed for failing grades."                  \
                "After the user reviews a failing grade,"                                                       \
                "then ${__KamajiScriptFName} will allow the user to baseline the new output using a 'bless' request."
  #
  EchoPara80    "There are three different kinds of review: new, short, and long."                              \
                "New reviews are performed on output for which there is no baseline to compare to."             \
                "Short reviews are performed when the changes between the baseline and current output"          \
                "are so few that specialized tools are not necessary to perform a detailed review."             \
                "Long reviews are performed for all other results."
  #
  EchoPara80    "The vimdiff command is a useful tool for performing long reviews."                             \
                "Users not familiar with the editor may want to make note of the following vim commands:"       \
                "the :help command to request help; the :qa command to exit the editor;"                        \
                "the h, j, k, l, and arrow keys to move around in a pane;"                                      \
                "and the [ctrl]-h, [ctrl]-l, and [ctrl]-w combinations to switch panes."
  #
  EchoPara80    "The long-review-line-count configuration variables allow the user to define"                   \
                "the boundary between a short and long review."                                                 \
                "The new-, short-, and long-review-command"                                                     \
                "configuration variables can be used to change the command used to perform a review."           \
                "The new-, short-, and long-review-tailpipe configuration variables allow the user to"          \
                "manipulate the output produced by the new-, short-, and long-review-command variables,"        \
                "respectively."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_show() {
  #
  local -r Request="${1}"
  #
  EchoPara80    "$(echoInColorWhiteBold "Show...")"
  #
  EchoPara80    "The 'show' request can be used to display the configuration, the copyright, or the software version."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_fast() {
  #
  local -r Request="${1}"
  #
  EchoPara80    "$(echoInColorWhiteBold "Fast...")"
  #
  EchoPara80    "When the number of files in the baseline-folder does not change,"                              \
                "the 'fast' modifier can be used to improve the efficiency of ${__KamajiScriptFName}."           \
                "When the 'fast' modifier is used,"                                                             \
                "${__KamajiScriptFName} loads a stored ruleset instead of generating a new one."                 \
                "An 'export ruleset' request can be used to store the current ruleset."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_usage() {
  #
  local -r Request="${1}"
  #
  EchoPara80    "$(echoInColorWhiteBold "Usage|Help...")"
  #
  EchoPara80    "You can get addition help by specifying the modifier or request you are interested"            \
                "in after the 'usage' or 'help' keyword."                                                       \
                "For example, \"${__KamajiScriptFName} help silent\" and \"${__KamajiScriptFName} usage export\""
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage_verbose_and_silent() {
  #
  local -r Request="${1}"
  #
  EchoPara80    "$(echoInColorWhiteBold "Verbose|Noisy and Silent|Quiet...")"
  #
  EchoPara80    "Three levels of diagnostic output are controlled by the verbose and silent modifiers:"         \
                "A single verbose modifier is a request for light diagnostic output."                           \
                "Multiple verbose modifiers will produce heavy diagnostic output."                              \
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
  echo "$(echoInColorYellow USAGE:) ${__KamajiScriptFName} [<modifier>]... [<request>] [<parameter>]..."
  echo ""
  echo "Where <modifier> is one of the following:"
  echo "      fast"
  echo "      help"
  echo "      silent"
  echo "      verbose"
  echo ""
  echo "Where <request> is one of the following:"
  echo "      bless  [ <filename> | last ]..."
  echo "      delta  [ <filename> | last ]..."
  echo "      export [ configuration | makefile | ruleset ]"
  echo "      grade  [ <filename> | last ]..."
  echo "      invoke [ <filename> | last ]..."
  echo "      make   [ <filename> | last | grades | outputs ]..."
  echo "      review [ <filename> | last ]..."
  echo "      set    <name> <value>"
  echo "      show   [ configuration | copyright | version ]"
  echo ""
  #
  declare -A UsageModifierSubjectList
  #
  UsageModifierSubjectList[baseline]=bless
  UsageModifierSubjectList[bless]=bless
  UsageModifierSubjectList[compare]=delta
  UsageModifierSubjectList[configure]=configure
  UsageModifierSubjectList[delta]=delta
  UsageModifierSubjectList[export]=export
  UsageModifierSubjectList[execute]=invoke
  UsageModifierSubjectList[fast]=fast
  UsageModifierSubjectList[grades]=grade
  UsageModifierSubjectList[invoke]=invoke
  UsageModifierSubjectList[help]=usage
  UsageModifierSubjectList[make]=make
  UsageModifierSubjectList[noisy]=verbose_and_silent
  UsageModifierSubjectList[pre-grade]=delta
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
     ModifiedCorrected=$(EchoMeaningOf "${ModifiedRequest}" "NA" ${!UsageModifierSubjectList[*]})
  fi
  #
  if [ "${ModifiedCorrected}" = "NA" ]
  then
     #
     EchoPara80 "Synonyms compare (delta), configure (set), noisy (verbose), pre-grade (delta),"                \
                "quiet (silent), and usage (help) are supported."                                               \
                "Modifier and request abbreviations are also supported;"                                        \
                "ambiguity is resolved using alphabetical order."                                               \
                "No other modifiers or requests are applied after a help request is fulfilled."
     #
     EchoPara80 "Specific usage may be displayed by following a help request by the subject of interest;"       \
                "for example, \"${__KamajiScriptFName} help fast\" or \"${__KamajiScriptFName} help grade\""
     #
     EchoPara80 "CLUT cases and unit test exercises are used and evaluated in similar ways:"                    \
                "compile it (if not already executable), invoke it to produce output, mask that output,"        \
                "compare the masked output to its baseline, and then grade it based on that comparison."
     #
     EchoPara80 "CLUT definitions are compiled into Bash scripts."                                              \
                "Unit test exercises may be written in compilable code or a scripting language."                \
                "Compilable code must be compiled and linked into executable files using a make framework."     \
                "Scripts need not be compiled."
     #
     EchoPara80 "CLUT cases and unit test exercises produce demonstrative output that need not be"              \
                "valid or invalid on its face."                                                                 \
                "Users must evaluate the initial output from these tests to determine whether it is valid;"     \
                "valid output must be blessed by the user and copied to a safe location as baseline output."    \
                "Future changes to the tested code will result in output that differs from the baseline;"       \
                "these differences should also be blessed to update the baseline."                              \
                "Users will benefit from retesting frequently"                                                  \
                "between minor and controlled functional changes to the code being tested."
     #
     EchoPara80 "Passing grades are only granted when current output matches baseline output,"                  \
                "but this matching is only attempted after the current and baseline output are masked."         \
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
  RunnerDList[${RunnerDIndx}]=$(find . -type d | sed --expression='1d'  \
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
            RunnerFSpec="${__KamajiNikrowDSpec}/${RunnerFSpec:2}"
         else
            RunnerFSpec="${__KamajiNikrowDSpec}/${RunnerFSpec}"
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
  __KamajiRepresentative["${SourceFName}"]="${__KamajiNikrowDSpec}/${SourceFSpec}"
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
  #                                             Key: TargetFName                Data: SourceFSpec
  #                                             ----------------                -----------------
  AppendArrayIndexValue __KamajiBaseSourceList  "${RunnerFName}"                "${RunnerFSpec}"
  #                                             ----------------                -----------------
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFName}"                "${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFName}.bash"           "${RunnerFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFName}.bash"           "${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFName}.output"         "${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFName}.output.masked"  "${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFName}.output.delta"   "${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFName}.output.grade"   "${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFName}.output.review"  "${SourceFSpec}"
  #                                             ----------------                -----------------
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFName}.output.masked"  "${__KamajiSedCompositFName}"
  #                                             ----------------                -----------------
  #
  #  __KamajiMyChildrenList[SourceFName]="TargetFName...": What files are created directly from this source?
  #
  #  All SourceFName and TargetFName are in __KamajiWorkinDSpec.
  #
  #  The __KamajiMyChildrenList is used to determine of the target needs to be re-created.
  #
  #                                             Key: SourceFName                Data: TargetFName
  #                                             ----------------                -----------------
  AppendArrayIndexValue __KamajiMyChildrenList  "${RunnerFName}"                "${SourceFName}.bash"
  AppendArrayIndexValue __KamajiMyChildrenList  "${SourceFName}"                "${SourceFName}.bash"
  AppendArrayIndexValue __KamajiMyChildrenList  "${SourceFName}.bash"           "${SourceFName}.output"
  AppendArrayIndexValue __KamajiMyChildrenList  "${SourceFName}.output"         "${SourceFName}.output.masked"
  AppendArrayIndexValue __KamajiMyChildrenList  "${SourceFName}.output.masked"  "${SourceFName}.output.delta"
  AppendArrayIndexValue __KamajiMyChildrenList  "${SourceFName}.output.delta"   "${SourceFName}.output.grade"
  AppendArrayIndexValue __KamajiMyChildrenList  "${SourceFName}.output.delta"   "${SourceFName}.output.review"
  AppendArrayIndexValue __KamajiMyChildrenList  "${SourceFName}.output.grade"   "${SourceFName}.output.review"
  #                                             ----------------                -----------------
  AppendArrayIndexValue __KamajiMyChildrenList  "${__KamajiSedCompositFName}"   "${SourceFName}.output.masked"
  #                                             ----------------                -----------------
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
  __KamajiRepresentative["${SourceFName}"]="${__KamajiNikrowDSpec}/${SourceFSpec}"
  #
  #  __KamajiBaseSourceList[TargetFName]=SourceFName: What recipe should I follow given FName as a target?
  #
  #  All SourceFName are in __KamajiGoldenDSpec. All TargetFName are in __KamajiWorkinDSpec.
  #
  #  __KamajiBaseSourceList is used to determine where to start the evaluation process for a target given by the user.
  #
  #                                             Key: TargetFName                Data: SourceFSpec
  #                                             ----------------                -----------------
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFRoot}"                "${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFRoot}.output"         "${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFRoot}.output.masked"  "${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFRoot}.output.delta"   "${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFRoot}.output.grade"   "${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFRoot}.output.review"  "${SourceFSpec}"
  #                                             ----------------                -----------------
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFRoot}.output.masked"  "${__KamajiSedCompositFName}"
  #                                             ----------------                -----------------
  #
  #  __KamajiMyChildrenList[SourceFName]="TargetFName...": What files are created directly from this source?
  #
  #  All SourceFName and TargetFName are in __KamajiWorkinDSpec.
  #
  #  The __KamajiMyChildrenList is used to determine of the target needs to be re-created.
  #
  #                                             Key: SourceFName                Data: TargetFName
  #                                             ----------------                -----------------
  AppendArrayIndexValue __KamajiMyChildrenList  "${SourceFName}"                "${SourceFRoot}"
  AppendArrayIndexValue __KamajiMyChildrenList  "${SourceFRoot}"                "${SourceFRoot}.output"
  AppendArrayIndexValue __KamajiMyChildrenList  "${SourceFRoot}.output"         "${SourceFRoot}.output.masked"
  AppendArrayIndexValue __KamajiMyChildrenList  "${SourceFRoot}.output.masked"  "${SourceFRoot}.output.delta"
  AppendArrayIndexValue __KamajiMyChildrenList  "${SourceFRoot}.output.delta"   "${SourceFRoot}.output.grade"
  AppendArrayIndexValue __KamajiMyChildrenList  "${SourceFRoot}.output.delta"   "${SourceFRoot}.output.review"
  AppendArrayIndexValue __KamajiMyChildrenList  "${SourceFRoot}.output.grade"   "${SourceFRoot}.output.review"
  #                                             ----------------                -----------------
  AppendArrayIndexValue __KamajiMyChildrenList  "${__KamajiSedCompositFName}"   "${SourceFRoot}.output.masked"
  #                                             ----------------                -----------------
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiBuildRulesForTestingSource_Naked() {
  #
  local -r SourceFSpec=${1}
  local -r SourceFType=${2-}
  #
  local -r SourceFName=$(basename ${SourceFSpec})
  #
  if [ "${SourceFName^^}" = "MAKEFILE" ]
  then
     #
     __KamajiRepresentative["${SourceFName}"]="${__KamajiNikrowDSpec}/${SourceFSpec}"
     #
     AppendArrayIndexValue __KamajiMyParentalList "${SourceFName}" ""
     #
  fi
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
  __KamajiRepresentative["${SourceFRoot}.golden"]="${__KamajiNikrowDSpec}/${SourceFSpec}"
  #
  #  __KamajiBaseSourceList[TargetFName]=SourceFName: What recipe should I follow given FName as a target?
  #
  #  All SourceFName are in __KamajiGoldenDSpec. All TargetFName are in __KamajiWorkinDSpec.
  #
  #  __KamajiBaseSourceList is used to determine where to start the evaluation process for a target given by the user.
  #
  #                                             Key: TargetFName                Data: SourceFSpec
  #                                             ----------------                -----------------
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFRoot}.golden"         "${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFRoot}.golden.masked"  "${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFRoot}.output.delta"   "${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFRoot}.output.grade"   "${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFRoot}.output.review"  "${SourceFSpec}"
  #                                             ----------------                -----------------
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFRoot}.golden.masked"  "${__KamajiSedCompositFName}"
  #                                             ----------------                -----------------
  #
  #  __KamajiMyChildrenList[SourceFName]="TargetFName...": What files are created directly from this source?
  #
  #  All SourceFName and TargetFName are in __KamajiWorkinDSpec.
  #
  #  The __KamajiMyChildrenList is used to determine of the target needs to be re-created.
  #
  #                                             Key: SourceFName                Data: TargetFName
  #                                             ----------------                -----------------
  AppendArrayIndexValue __KamajiMyChildrenList  "${SourceFRoot}.golden"         "${SourceFRoot}.golden.masked"
  AppendArrayIndexValue __KamajiMyChildrenList  "${SourceFRoot}.golden.masked"  "${SourceFRoot}.output.delta"
  #                                             ----------------                -----------------
  AppendArrayIndexValue __KamajiMyChildrenList  "${__KamajiSedCompositFName}"   "${SourceFRoot}.golden.masked"
  #                                             ----------------                -----------------
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
  __KamajiRepresentative["${SourceFName}"]="${__KamajiNikrowDSpec}/${SourceFSpec}"
  #
  #  __KamajiBaseSourceList[TargetFName]=SourceFName: What recipe should I follow given FName as a target?
  #
  #  All SourceFName are in __KamajiGoldenDSpec. All TargetFName are in __KamajiWorkinDSpec.
  #
  #  __KamajiBaseSourceList is used to determine where to start the evaluation process for a target given by the user.
  #
  #                                             Key: TargetFName                Data: SourceFSpec
  #                                             ----------------                -----------------
# AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFRoot}"                "${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFRoot}.output"         "${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFRoot}.output.masked"  "${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFRoot}.output.delta"   "${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFRoot}.output.grade"   "${SourceFSpec}"
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFRoot}.output.review"  "${SourceFSpec}"
  #                                             ----------------                -----------------
  AppendArrayIndexValue __KamajiBaseSourceList  "${SourceFRoot}.output.masked"  "${__KamajiSedCompositFName}"
  #                                             ----------------                -----------------
  #
  #  __KamajiMyChildrenList[SourceFName]="TargetFName...": What files are created directly from this source?
  #
  #  All SourceFName and TargetFName are in __KamajiWorkinDSpec.
  #
  #  The __KamajiMyChildrenList is used to determine of the target needs to be re-created.
  #
  #                                             Key: SourceFName                Data: TargetFName
  #                                             ----------------                -----------------
  AppendArrayIndexValue __KamajiMyChildrenList  "${SourceFName}"                "${SourceFRoot}.output"
  AppendArrayIndexValue __KamajiMyChildrenList  "${SourceFRoot}.output"         "${SourceFRoot}.output.masked"
  AppendArrayIndexValue __KamajiMyChildrenList  "${SourceFRoot}.output.masked"  "${SourceFRoot}.output.delta"
  AppendArrayIndexValue __KamajiMyChildrenList  "${SourceFRoot}.output.delta"   "${SourceFRoot}.output.grade"
  AppendArrayIndexValue __KamajiMyChildrenList  "${SourceFRoot}.output.delta"   "${SourceFRoot}.output.review"
  AppendArrayIndexValue __KamajiMyChildrenList  "${SourceFRoot}.output.grade"   "${SourceFRoot}.output.review"
  #                                             ----------------                -----------------
  AppendArrayIndexValue __KamajiMyChildrenList  "${__KamajiSedCompositFName}"   "${SourceFRoot}.output.masked"
  #                                             ----------------                -----------------
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
     __KamajiRepresentative["${SourceFName}"]="${__KamajiNikrowDSpec}/${SourceFSpec}"
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
  DiagnosticHeavy "#    ${SourceFSpec}"
  #
  local -r SourceFName=$(basename ${SourceFSpec})
  local -r SourceFType=$(Xtension ${SourceFName})
  #
  #  Detect a Script that is not executable.
  #
  local    SourceClass=$(KamajiFileClassification ${SourceFSpec} ${SourceFType})
  #
  if [ "${SourceClass}" = "Script" ] && [ ! -x ${SourceFSpec} ]
  then
     EchoErrorAndExit 1 "The ${SourceFSpec} is neither executable nor declared data."
  fi
  #
  #  Process the source file as non-data or data.
  #
  if [ "${SourceClass}" = "Data" ]
  then
     #
     #  __KamajiRepresentative[TargetFName]="SourceFSpec": What external file does this file name represent?
     #
     __KamajiRepresentative["${SourceFName}"]="${__KamajiNikrowDSpec}/${SourceFSpec}"
     #
     AppendArrayIndexValue __KamajiMyParentalList "${SourceFName}" ""
     #
  else
     #
     local -r FunctionWeWant=${FUNCNAME}_${SourceClass}
     #
     local -r FunctionToCall=$(declare -F ${FunctionWeWant})
     #
     [ ${#FunctionToCall} -eq 0 ] && EchoErrorAndExit 2 "Fatal programming flaw; ${FunctionWeWant} is undefined."
     #
     ${FunctionToCall} ${SourceFSpec} ${SourceFType}
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------
#
#  KamajiBuildRulesLoadXtraDependents
#
#  <target-fname> : <source-fname>...
#
#----------------------------------------------------------------------------------------------------------------------

function KamajiBuildRulesLoadXtraDependents() {
  #
  local    Directory SourceFName
  local    TargetFName ColonSeparator ListOfSourceFName
  local    ListOfTargetFName
  #
  local -i LastIndexOfTargetFName
  local -i LineNumber
  #
  local -A IncompleteXtraDependency
  #
  for Directory in ${HOME} .
  do
    #
    if [ -s ${Directory}/${__KamajiXtraDependentFName} ]
    then
       #
       LineNumber=0
       #
       while read TargetFName ColonSeparator ListOfSourceFName
       do
         #
         LineNumber+=1
         #
         [ ${#TargetFName} -eq 0 ] && continue
         #
         [ "${TargetFName:0:1}" = "#" ] && continue
         #
         if [ "${ColonSeparator}" != ":" ]
         then
            #
            LastIndexOfTargetFName=$((${#TargetFName}-1))
            #
            if [ "${TargetFName:${LastIndexOfTargetFName}:1}" = ":" ]
            then
               #
               TargetFName=${TargetFName:0:${LastIndexOfTargetFName}}
               #
            else
               #
               EchoErrorAndExit 1 "In ${Directory}/${__KamajiXtraDependentFName} on line ${LineNumber}:"        \
                                  "Missing colon separator."
               #
            fi
            #
            ListOfSourceFName="${ColonSeparator} ${ListOfSourceFName}"
            #
         fi
         #
         #  Files can only be identified with names; otherwise misleading to user.
         #
         for SourceFName in ${TargetFName} ${ListOfSourceFName}
         do
           #
           if [ "$(basename ${SourceFName})" != "${SourceFName}" ]
           then
              #
              EchoErrorAndExit 1 "In ${Directory}/${__KamajiXtraDependentFName} on line ${LineNumber}:" \
                                 "Targets and dependencies must be filenames, not specifications with paths."
              #
           fi
           #
         done
         #
         #  Source files must be known to Kamaji already.
         #
         #  __KamajiRepresentative[TargetFName]="SourceFSpec": What external file does this file name represent?
         #  __KamajiBaseSourceList[TargetFName]="SourceFName": What recipe should I follow given FName as a target?
         #
         for SourceFName in ${ListOfSourceFName}
         do
           #
           if [ "${__KamajiRepresentative[${SourceFName}]+IS_SET}" != "IS_SET" ]
           then
              #
              if [ "${__KamajiBaseSourceList[${SourceFName}]+IS_SET}" != "IS_SET" ]
              then
                 #
                 EchoErrorAndExit 1 "In ${Directory}/${__KamajiXtraDependentFName} on line ${LineNumber}:" \
                                    "Dependency '${SourceFName}' is not a baseline file or a known derivative."
                 #
              fi
              #
           fi
           #
         done
         #
         #  Stash the relationship until all Xtra relationships are known.
         #
         AppendArrayIndexValue __KamajiMyChildrenList "${SourceFName}" "${TargetFName}"
         #
         AppendArrayIndexValue IncompleteXtraDependency "${TargetFName}" "${SourceFName}"
         #
       done < ${Directory}/${__KamajiXtraDependentFName}
       #
    fi
    #
  done
  #
  for TargetFName in $(echo ${!IncompleteXtraDependency[*]} | tr ' ' '\n' | sort)
  do
    #
    for SourceFName in $(echo ${IncompleteXtraDependency[${TargetFName}]} | tr ' ' '\n' | sort)
    do
      #
      #  Representatives cannot have extra parents, but their children can.
      #
      #  __KamajiRepresentative[TargetFName]="SourceFSpec": What external file does this file name represent?
      #  __KamajiMyChildrenList[SourceFName]="TargetFName...": What files are created directly from this source?
      #
      ListOfTargetFName=${TargetFName}
      NextOfTargetFName=
      #
      while [ ${#ListOfTargetFName} -gt 0 ]
      do
        #
        for QuarryFName in ${ListOfTargetFName}
        do
          #
          if [ "${__KamajiRepresentative[${QuarryFName}]+IS_SET}" = "IS_SET" ]
          then
             #
             if [ "${__KamajiMyChildrenList[${QuarryFName}]+IS_SET}" = "IS_SET" ]
             then
                #
                NextOfTargetFName+=" ${__KamajiMyChildrenList[${QuarryFName}]}"
                #
             else
                #
                EchoErrorAndExit 1 "Dependency '${SourceFName}' target '${QuarryFName}' has no known derivatives."
                #
             fi
             #
          else
             #
             #  __KamajiMyParentalList[TargetFName]="SourceFName...": What files are direct sources of this target?
             #  __KamajiXtraParentList[TargetFName]="SourceFName...": What files are user-defined sources of target?
             #
             AppendArrayIndexValue __KamajiXtraParentList "${QuarryFName}" "${SourceFName}"
             AppendArrayIndexValue __KamajiMyParentalList "${SourceFName}" ""
             #
          fi
          #
        done
        #
        ListOfTargetFName=${NextOfTargetFName}
        NextOfTargetFName=
        #
      done
      #
    done
    #
  done
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiBuildRules() {
  #
  DiagnosticHeavy "# Building rules based on baseline files..."
  #
  local -r FindCommand="find -L ${__KamajiGoldenDSpec} $(KamajiConfigurationEchoValue find-expression-list -type f)"
  #
  DiagnosticHeavy "${FindCommand}"
  #
  local -r ListOfSourceFSpec=$(${FindCommand} | sort)
  #
  local    ItemOfSourceFSpec SourceFName SourceFSpec SourceClass
  #
  #  The composit masking sed script is based on the file list created at initialization time.
  #
  #  __KamajiBaseSourceList[TargetFName]="SourceFName": What recipe should I follow given FName as a target?
  #  __KamajiMyChildrenList[SourceFName]="TargetFName...": What files are created directly from this source?
  #  __KamajiMyParentalList[TargetFName]="SourceFName...": What files are direct sources of this target?
  #  __KamajiRepresentative[TargetFName]="SourceFSpec": What external file does this file name represent?
  #
  AppendArrayIndexValue __KamajiRepresentative "${__KamajiSedFileListFName}" ""
  #
  AppendArrayIndexValue __KamajiMyChildrenList "${__KamajiSedFileListFName}" " ${__KamajiSedCompositFName}"
  AppendArrayIndexValue __KamajiBaseSourceList "${__KamajiSedCompositFName}" " ${__KamajiSedFileListFName}"
  AppendArrayIndexValue __KamajiMyParentalList "${__KamajiSedCompositFName}" ""
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
  #  __KamajiMyChildrenList[SourceFName]="TargetFName...": What files are created directly from this source?
  #  __KamajiMyParentalList[TargetFName]="SourceFName...": What files are direct sources of this target?
  #
  local ParentFName ChildsFName
  #
  for ParentFName in $(echo ${!__KamajiMyChildrenList[*]} | tr ' ' '\n' | sort)
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
  for SourceFName in $(echo ${!__KamajiMyParentalList[*]} | tr ' ' '\n' | sort)
  do
    #
    SourceClass=$(KamajiFileClassification ${SourceFName} $(Xtension ${SourceFName}))
    #
    AppendArrayIndexValue __KamajiClassifiedList "${SourceClass}" "${SourceFName}"
    #
  done
  #
  #  Load the user-configured list of dependencies.
  #
  #  __KamajiXtraParentList[TargetFName]="SourceFName...": What files are user-defined sources of target?
  #
  KamajiBuildRulesLoadXtraDependents
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
       #  Find the Review descendants of the target.
       #
       TargetFList+=" $(KamajiEchoListOfDescendantFName ${SourceFName} Review)"
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
       DiagnosticLight "${__KamajiScriptFName} ${Request} ${TargetFName%.review}"
       #
       EchoAndExecute "echo \"${TargetFName}\" > ${__KamajiLastMakeTargetFSpec}"
       #
       #  Determine the golden output file associated with this output.
       #
       GoldenFName=${TargetFName%.output.review}.golden
       #
       if [ "${__KamajiRepresentative[${GoldenFName}]+IS_SET}" = "IS_SET" ]
       then
          #
          #  The golden output file is known and will be replaced.
          #
          GoldenDSpec=$(dirname ${__KamajiRepresentative[${GoldenFName}]})
          #
       else
          #
          #  The golden output file is new.
          #
          GoldenDSpec=${__KamajiNikrowDSpec}/${__KamajiGoldenDSpec}/${TargetFName%.review}
          #
          #  Remove the ruleset used for fast processing if it exists because it is obsolete.
          #
          WasWorkingFile ${__KamajiRulesetFName}
          #
       fi
       #
       #  Replace the golden output file with the current one.
       #
       EchoAndExecuteInWorkingStdout "cp ${TargetFName%.review} ${GoldenDSpec}"
       #
       #  Remove the reviewed file so that it cannot be used again.
       #
       EchoAndExecuteInWorkingStdout "rm ${TargetFName}ed"
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
  DiagnosticLight "${__KamajiScriptFName} ${Request} ${Name} ${Value}"
  #
  [ ${#Value} -eq 0 ] && EchoErrorAndExit 2 "Empty values are not allowed in a configuration file."
  #
  local -r VariableName=$(EchoMeaningOf "${Name}" "" ${!__KamajiConfigurationValue[*]})
  #
  [ ${#VariableName} -eq 0 ] && EchoErrorAndExit 2 "The '${Name}' configuration variable is not supported."
  #
  if [ ${#__KamajiMalleableConfigFSpec} -eq 0 ]
  then
     EchoErrorAndExit 2 "No malleable configuration files found; check KAMAJI_CONFIG_BASE_DSPEC and file permissions."
  fi
  #
  EchoAndExecute "echo \"${VariableName} ${Value}\" >> ${__KamajiMalleableConfigFSpec}"
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestDelta() {
  #
  local -r Request=${1}
  shift 1
  local -r SourceFList="${*}"
  #
  KamajiRequestGradeOrOutputOrReviewOrDelta ${Request} Delta ${SourceFList}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestExport_configuration() {
  #
  local -r Request=${1}
  local -r Object=${2}
  #
  DiagnosticLight "${__KamajiScriptFName} ${Request} ${Object}"
  #
  StartWorkingFile   ${__KamajiConfigurationFName}.${__KamajiPartialSuffix}
  #
  spew ${__KamajiWorkinDSpec}/${__KamajiConfigurationFName}.${__KamajiPartialSuffix} ${__KamajiConfigLogFSpec}
  #
  PublishWorkingFile ${__KamajiConfigurationFName}.${__KamajiPartialSuffix}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestExport_makefile() {
  #
  local -r Request=${1}
  local -r Object=${2}
  #
  DiagnosticLight "${__KamajiScriptFName} ${Request} ${Object}"
  #
  local -r MakefileFName=${__KamajiMakefileFName}.${__KamajiPartialSuffix}
  #
  local    TargetClass TargetFName
  #
  #  Export an explicit makefile.
  #
  StartWorkingFile ${MakefileFName}
  #
  cd ${__KamajiWorkinDSpec}/
     #
     spit  ${MakefileFName} "#"
     spit  ${MakefileFName} "#  ${__KamajiScriptFName} ${Request} ${Object}"
     spit  ${MakefileFName} "#"
     spit  ${MakefileFName} "#  This makefile will allow the user to request creation of specific files using the"
     spit  ${MakefileFName} "#  system make command in the same way that '${__KamajiScriptFName} make' request does."
     spit  ${MakefileFName} "#"
     spit  ${MakefileFName} "#  Let the make command determine what needs to be re-made,"
     spit  ${MakefileFName} "#  but have it then call ${__KamajiScriptFName} to make sure it is done right."
     spit  ${MakefileFName} "#"
     spit  ${MakefileFName} "#  The phony targets ${__KamajiScriptFName}-output, ${__KamajiScriptFName}-delta, and"
     spit  ${MakefileFName} "#  ${__KamajiScriptFName}-grade are defined for user convenience."
     spit  ${MakefileFName} "#  Output targets are likely to be the most time-expensive targets. Preparing"
     spit  ${MakefileFName} "#  delta files for grading gets more expensive as output files grow."
     spit  ${MakefileFName} "#  The user is advised to use parallel-processing make calls for the"
     spit  ${MakefileFName} "#  ${__KamajiScriptFName}-output and/or ${__KamajiScriptFName}-delta targets;"
     spit  ${MakefileFName} "#  the ${__KamajiScriptFName}-grade can then be used for presentation only."
     spit  ${MakefileFName} "#"
     spit  ${MakefileFName} "#  When the makefile specifies the target, ${__KamajiScriptFName} is asked to perform its"
     spit  ${MakefileFName} "#  work in silent mode."
     spit  ${MakefileFName} "#"
     spit  ${MakefileFName} ""
     spit  ${MakefileFName} "QUIET ?= @"
     #
     for TargetClass in Output Delta Grade
     do
       #
       spit ${MakefileFName} ""
       spit ${MakefileFName} "Kamaji${TargetClass}TargetList :="
       #
       if [ "${__KamajiClassifiedList[${TargetClass}]+IS_SET}" = "IS_SET" ]
       then
          #
          for TargetFName in ${__KamajiClassifiedList[${TargetClass}]}
          do
            #
            spit  ${MakefileFName} "Kamaji${TargetClass}TargetList += ${__KamajiWorkinDSpec}/${TargetFName}"
            #
          done
          #
       fi
       #
     done
     #
     spit  ${MakefileFName} ""
     spit  ${MakefileFName} ".PHONY: ${__KamajiScriptFName}-grade  ${__KamajiScriptFName}-delta"
     spit  ${MakefileFName} ".PHONY: ${__KamajiScriptFName}-output ${__KamajiScriptFName}-last"
     spit  ${MakefileFName} ""
     spit  ${MakefileFName} "${__KamajiScriptFName}-grade : \$(KamajiGradeTargetList)"
     spite ${MakefileFName} "\t@echo \"make \$@\""
     spite ${MakefileFName} "\t\$(QUIET) ${__KamajiScriptFName} fast grade"
     spit  ${MakefileFName} ""
     spit  ${MakefileFName} "${__KamajiScriptFName}-delta : \$(KamajiDeltaTargetList)"
     spite ${MakefileFName} "\t@echo \"make \$@\""
     spite ${MakefileFName} "\t\$(QUIET) ${__KamajiScriptFName} fast delta"
     spit  ${MakefileFName} ""
     spit  ${MakefileFName} "${__KamajiScriptFName}-output : \$(KamajiOutputTargetList)"
     spite ${MakefileFName} "\t@echo \"make \$@\""
     spite ${MakefileFName} "\t\$(QUIET) ${__KamajiScriptFName} fast invoke"
     spit  ${MakefileFName} ""
     spit  ${MakefileFName} "${__KamajiScriptFName}-last :"
     spite ${MakefileFName} "\t@echo \"make \$@\""
     spite ${MakefileFName} "\t\$(QUIET) ${__KamajiScriptFName} fast make last"
     spit  ${MakefileFName} ""
     spit  ${MakefileFName} "${__KamajiWorkinDSpec}/${__KamajiRulesetFName} :"
     spite ${MakefileFName} "\t@echo \"make \$@\""
     spite ${MakefileFName} "\t\$(QUIET) ${__KamajiScriptFName} fast silent show version"
     spit  ${MakefileFName} ""
     spit  ${MakefileFName} "\$(KamajiOutputTargetList) : | ${__KamajiWorkinDSpec}/${__KamajiRulesetFName}"
     spit  ${MakefileFName} ""
     #
     #  Generate makefile dependency rules for each of the targets leading up to the grades.
     #
     local    ItemOfParentFName
     local    ListOfParentFName
     local    NextOfParentFName
     #
     local -a OutputList
     local    OutputLine
     #
     local -i OutputIndx=0
     local -i CheckIndex
     #
     for TargetClass in Grade
     do
       #
       ListOfParentFName=${__KamajiClassifiedList[${TargetClass}]}
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
              OutputLine+="${__KamajiRepresentative[${ItemOfParentFName}]#${__KamajiNikrowDSpec}/}"
              #
           elif [ ${#__KamajiMyParentalList[${ItemOfParentFName}]} -eq 0 ]
           then
              #
              OutputLine+="$(RetrieveArrayValueAtIndex __KamajiBaseSourceList ${ItemOfParentFName})"
#             OutputLine+="${__KamajiBaseSourceList[${ItemOfParentFName}]}"
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
              OutputLine+="${__KamajiXtraParentList[${ItemOfParentFName}]// / ${__KamajiWorkinDSpec}/}"
              #
           fi
           #
           OutputList[${OutputIndx}]="${__KamajiWorkinDSpec}/${ItemOfParentFName} :"
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
       printf "%s\n" "${OutputList[@]}" | sort --unique > ${MakefileFName}.data
       #
       while read OutputLine
       do
         #
         spit  ${MakefileFName} "${OutputLine}"
         spite ${MakefileFName} "\t@echo \"${__KamajiScriptFName} make \$@\""
         spite ${MakefileFName} "\t\$(QUIET) ${__KamajiScriptFName} fast make \$@"
         spit  ${MakefileFName}
         #
       done < ${MakefileFName}.data
       #
       rm     ${MakefileFName}.data
       #
     done
     #
     spit ${MakefileFName} "#"
     spit ${MakefileFName} "#  (eof}"
     #
  cd ${__KamajiNikrowDSpec}/
  #
  PublishWorkingFile ${MakefileFName}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestExport_ruleset() {
  #
  local -r Request=${1}
  local -r Object=${2}
  #
  local -r RulesetFName=${__KamajiRulesetFName}.${__KamajiPartialSuffix}
  #
  local    ArrayName ArrayReference
  #
  DiagnosticLight "${__KamajiScriptFName} ${Request} ${Object}"
  #
  StartWorkingFile ${RulesetFName}
  #
  cd ${__KamajiWorkinDSpec}/
     #
     spit ${RulesetFName} "#  __KamajiBaseSourceList[TargetFName]=\"SourceFName\":"                        \
                                "What recipe should I follow given FName as a target?"
     spit ${RulesetFName} "#  __KamajiClassifiedList[TargetPhony]=\"SourceFName...\":"                     \
                                "What files are direct sources of this target?"
     spit ${RulesetFName} "#  __KamajiMyChildrenList[SourceFName]=\"TargetFName...\":"                     \
                                "What files are created directly from this source?"
     spit ${RulesetFName} "#  __KamajiMyParentalList[TargetFName]=\"SourceFName...\":"                     \
                                "What files are direct sources of this target?"
     spit ${RulesetFName} "#  __KamajiRepresentative[TargetFName]=\"SourceFSpec\":"                        \
                                "What external file does this file name represent?"
     spit ${RulesetFName} "#  __KamajiXtraParentList[TargetFName]=\"SourceFName...\":"                     \
                                "What files are user-defined sources of target?"
     spit ${RulesetFName} "#"
     spit ${RulesetFName} "#  Where FName == file name within the working-folder"
     spit ${RulesetFName} "#        FSpec == file specification outside of the working-folder"
     #
     KamajiEchoArrayAssignments __KamajiBaseSourceList ${!__KamajiBaseSourceList[*]} | sort >> ${RulesetFName}
     KamajiEchoArrayAssignments __KamajiClassifiedList ${!__KamajiClassifiedList[*]} | sort >> ${RulesetFName}
     KamajiEchoArrayAssignments __KamajiMyChildrenList ${!__KamajiMyChildrenList[*]} | sort >> ${RulesetFName}
     KamajiEchoArrayAssignments __KamajiMyParentalList ${!__KamajiMyParentalList[*]} | sort >> ${RulesetFName}
     KamajiEchoArrayAssignments __KamajiRepresentative ${!__KamajiRepresentative[*]} | sort >> ${RulesetFName}
     KamajiEchoArrayAssignments __KamajiXtraParentList ${!__KamajiXtraParentList[*]} | sort >> ${RulesetFName}
     #
     spit ${RulesetFName} "#"
     spit ${RulesetFName} "#  (eof)"
     #
  cd ${__KamajiNikrowDSpec}/
  #
  PublishWorkingFile ${RulesetFName}
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
  local -r Target=$(EchoMeaningOf "${Object}" "" configuration makefile ruleset)
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

function KamajiRequestGradeOrOutputOrReviewOrDelta() {
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
       #  Find the ${TargetClass} descendants of the target.
       #
       TargetCheck=$(KamajiEchoListOfDescendantFName ${SourceFName} ${TargetClass})
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
  KamajiRequestGradeOrOutputOrReviewOrDelta ${Request} Grade ${SourceFList}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestInvoke() {
  #
  local -r Request=${1}
  shift 1
  local -r SourceFList="${*}"
  #
  KamajiRequestGradeOrOutputOrReviewOrDelta ${Request} Output ${SourceFList}
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
    Target=$(EchoMeaningOf "${GivnSourceFSpec}" "$(basename ${GivnSourceFSpec})" grades last outputs)
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
  KamajiRequestGradeOrOutputOrReviewOrDelta ${Request} Review ${SourceFList}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestShow_configuration() {
  #
  local -r Request=${1}
  local -r Object=${2}
  #
  local    Key
  #
  DiagnosticLight "${__KamajiScriptFName} ${Request} ${Object}"
  #
  echo "List of configurable items:"
  #
  printf "   %s\n" ${!__KamajiConfigurationValue[*]} | sort
  #
  echo "Active configuration sources:"
  #
  sed --expression='s,^,   ,' ${__KamajiConfigLogFSpec}
  #
  echo "Active configuration items:"
  #
  for Key in ${!__KamajiConfigurationValue[*]}
  do
    #
    if [ ${#__KamajiConfigurationValue[${Key}]} -gt 0 ]
    then
       #
       printf "   %-23s %s\n" ${Key} "$(echo ${__KamajiConfigurationValue[${Key}]})"
       #
    fi
    #
  done | sort
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
  echo "${__KamajiScriptFName} version 1.00"
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
  local -r Target=$(EchoMeaningOf "${Object}" "" configuration copyright version)
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
  EchoAndExecuteInWorkingToFile ${TargetFName}  \
        "diff --text --ignore-space-change ${GoldenMaskedFName} ${OutputMaskedFName}"
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
  EchoAndExecuteInWorkingStdout "cp ${OutputMaskedFName} ${TargetFName}"
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

function KamajiMake_GoldenMasked_from_Golden_SedScriptComposit() {
  #
  local -r TargetFName=${1}
  local -r GoldenSourceFName=${2}
  local -r SedScriptFName=${3}
  #
  EchoAndExecuteInWorkingToFile ${TargetFName}.${__KamajiPartialSuffix} \
                                "sed --file=${SedScriptFName} ${GoldenSourceFName}"
  #
  Status=${?}
  #
  [ ${Status} -eq 0 ] || EchoErrorAndExit ${Status} "The sed command failed."
  #
  PublishWorkingFile ${TargetFName}.${__KamajiPartialSuffix}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_GoldenMasked_from_SedScriptComposit_Golden() {
  #
  local -r TargetFName=${1}
  local -r SedScriptFName=${2}
  local -r GoldenSourceFName=${3}
  #
  KamajiMake_GoldenMasked_from_Golden_SedScriptComposit ${TargetFName} ${GoldenSourceFName} ${SedScriptFName}
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
     __KamajiFailureCount+=1
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
  EchoAndExecuteInWorkingStdout "make --no-print-directory ${TargetFName}"
  #
  Status=${?}
  #
  [ ${Status} -eq 0 ] || EchoFailureAndExit ${Status} "The 'make ${TargetFName}' command failed."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_Output_from_Naked_Or_Script() {
  #
  local -r TargetFName=${1}.${__KamajiPartialSuffix}
  local -r SourceFName=${2}
  local -r SourceLabel=${3}     # program | script
  #
  local -r SedFailText="environmental masking sed command failed"
  #
# local    ActualFSpec=./${SourceFName}
  #
# [ -L ${__KamajiWorkinDSpec}/${SourceFName} ] && ActualFSpec=$(readlink ${__KamajiWorkinDSpec}/${SourceFName})
  #
  local    TimeCommand=
  #
  if [ ${#__KamajiTimeFormat} -gt 0 ]
  then
     #
     TimeCommand+="/usr/bin/time --format='${__KamajiTimeFormat}' --output=${TargetFName}.time.text "
     #
  fi
  #
  EchoAndExecuteInWorkingToFile ${TargetFName} "${TimeCommand}./${SourceFName}"
  #
  Status=${?}
  #
  if [ ${Status} -ne 0 ]
  then
     EchoFailureAndExit ${Status} "The ${SourceFName} ${SourceLabel} failed; exit status ${Status}."
  fi
  #
  if [ ${#__KamajiEnvironmentMasking} -gt 0 ]
  then
     #
     EchoAndExecuteInWorkingStdout "sed --in-place ${__KamajiEnvironmentMasking} ${TargetFName}"
     #
     Status=${?}
     #
     if [ ${Status} -ne 0 ]
     then
        EchoErrorAndExit ${Status} "The ${SourceLabel} output ${SedFailText}; exit status ${Status}."
     fi
     #
  fi
  #
  PublishWorkingFile ${TargetFName}
  #
  if [ ${#__KamajiTimeFormat} -gt 0 ]
  then
     #
     EchoAndExecuteInWorkingStdout "echo \"#  ${__KamajiTimeFormat}\" >> ${TargetFName}.time.text"
     #
     EchoAndExecuteInWorkingStdout "cat ${TargetFName}.time.text >> ${TargetFName%.${__KamajiPartialSuffix}}.time.text"
     #
     EchoAndExecuteInWorkingStdout "rm  ${TargetFName}.time.text"
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_Output_from_Naked() {
  #
  local -r TargetFName=${1}
  local -r SourceFName=${2}
  #
  KamajiMake_Output_from_Naked_Or_Script ${TargetFName} ${SourceFName} program
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_Output_from_Script() {
  #
  local -r TargetFName=${1}
  local -r SourceFName=${2}
  #
  KamajiMake_Output_from_Naked_Or_Script ${TargetFName} ${SourceFName} script
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_OutputMasked_from_Output_SedScriptComposit() {
  #
  KamajiMake_GoldenMasked_from_Golden_SedScriptComposit ${*};
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_OutputMasked_from_SedScriptComposit_Output() {
  #
  KamajiMake_GoldenMasked_from_SedScriptComposit_Golden ${*};
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
     EchoAndExecuteInWorkingStdout "${ReviewCommand}"
     #
     EchoAndExecuteInWorkingStdout touch ${TargetFName}ed
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
  EchoAndExecuteInWorkingStdout "clutc ${ClutSourceFName} ${ExecActualFSpec} ${TargetFName}"
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

function KamajiMake_SedScriptComposit_from_SedScriptListing() {
  #
  local -r TargetFName=${1}.${__KamajiPartialSuffix}
  local -r SourceFName=${2}
  #
  local -r ConfigBaseMessage="The KAMAJI_CONFIG_BASE_DSPEC variable is being used to limit configuration file scope."
  #
  local -i ConfigFileCount=0
  #
  local    ItemOfSedFSpec
  #
  StartWorkingFile ${TargetFName}
  #
  cd ${__KamajiWorkinDSpec}/
     #
     if [ "${KAMAJI_CONFIG_BASE_DSPEC+IS_SET}" = "IS_SET" ]
     then
        spit ${TargetFName} "#  ${ConfigBaseMessage}"
        spit ${TargetFName} "#"
     fi
     #
     for ItemOfSedFSpec in $(cat ${SourceFName})
     do
       #
       ConfigFileCount+=1
       #
       spit ${TargetFName} "#  BEGIN ${ItemOfSedFSpec}"
       spew ${TargetFName} ${ItemOfSedFSpec}
       spit ${TargetFName} "#  END   ${ItemOfSedFSpec}"
       #
     done
     #
     [ ${ConfigFileCount} -eq 0 ] && spite ${TargetFName} "#  No masking sed script files active.\n#"
     #
     spit ${TargetFName} "#  (eof)"
     #
  cd ${__KamajiNikrowDSpec}/
  #
  PublishWorkingFile ${TargetFName}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake() {
  #
  local -r TargetFName=${1}
  #
  local -r TargetClass=$(KamajiFileClassification ${TargetFName} $(Xtension ${TargetFName}))
  #
  #  Representatives must only exist; the files they represent are updated by the user.
  #
  local    ListOfMyParentalFName=$(RetrieveArrayValueAtIndex __KamajiMyParentalList ${TargetFName})
  local    ListOfXtraParentFName=
  #
  if [ ${#ListOfMyParentalFName} -eq 0 ] && [ ! -f ${__KamajiWorkinDSpec}/${TargetFName} ]
  then
     #
     local -r GoldenFSpec=$(RetrieveArrayValueAtIndex __KamajiRepresentative ${TargetFName})
     #
     EchoAndExecuteInWorkingStdout "ln --symbolic ${GoldenFSpec} ${TargetFName}"
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
     DiagnosticLight "${__KamajiScriptFName} make ${TargetFName}"
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
     #  Check to see if the user wants to use a command that can be invoked without checking configuration.
     #
     local -A RequestFunctionFor
     #
     RequestFunctionFor[configure]=KamajiRequestConfigure
     RequestFunctionFor[set]=KamajiRequestConfigure
     RequestFunctionFor[show]=KamajiRequestShow
     RequestFunctionFor[usage]=KamajiModifierUsage
     #
     local -r RequestCorrectedEarly=$(EchoMeaningOf "${RequestedAction}" "N/A" ${!RequestFunctionFor[*]})
     #
     if [ "${RequestCorrectedEarly}" != "N/A" ]
     then
        #
        ${RequestFunctionFor[${RequestCorrectedEarly}]} ${RequestCorrectedEarly} ${ParameterList}
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
              for SourceFName in $(echo ${!__KamajiRepresentative[*]} | tr ' ' '\n' | sort)
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
        RequestFunctionFor[baseline]=KamajiRequestBless
        RequestFunctionFor[bless]=KamajiRequestBless
        RequestFunctionFor[delta]=KamajiRequestDelta
        RequestFunctionFor[execute]=KamajiRequestInvoke
        RequestFunctionFor[export]=KamajiRequestExport
        RequestFunctionFor[grades]=KamajiRequestGrade
        RequestFunctionFor[invoke]=KamajiRequestInvoke
        RequestFunctionFor[make]=KamajiRequestMake
        RequestFunctionFor[review]=KamajiRequestReview
        RequestFunctionFor[run]=KamajiRequestInvoke
        #
        local -r RequestCorrectedLater=$(EchoMeaningOf "${RequestedAction}" "N/A" ${!RequestFunctionFor[*]})
        #
        if [ "${RequestCorrectedLater}" = "N/A" ]
        then
           #
           KamajiExitAfterUsage "Unable to fulfill a '${RequestedAction}' request."
           #
        else
           #
           ${RequestFunctionFor[${RequestCorrectedLater}]} ${RequestCorrectedLater} ${ParameterList}
           #
        fi
        #
     fi
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------

KamajiConfigurationLoadValues

KamajiMain ${*}

__KamajiFailureCount+=${?}

rm --force ${__KamajiConfigLogFSpec}

exit ${__KamajiFailureCount}

#----------------------------------------------------------------------------------------------------------------------
