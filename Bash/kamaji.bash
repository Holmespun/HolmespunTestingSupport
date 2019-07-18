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
###	@remark		kamaji.bash [<modifier>]... [<command>] [<parameter>]..."
###
###	@details
###
#----------------------------------------------------------------------------------------------------------------------
#
#  20190704 BGH; created.
#  20190714 BGH; having KamajiMake return the specification of the file it created or verified to exist.
#  20190714 BGH; verbose output to stderr to make the KamajiMake work.
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

#----------------------------------------------------------------------------------------------------------------------

declare    __KamajiAbsoluteGoldenDSpec="TBD"

declare    __KamajiAbsoluteWorkinDSpec="TBD"

declare -A __KamajiConfigurationValue

declare    __KamajiGoldenDSpec="TBD"

declare    __KamajiVerbosityRequested="TBD"

declare -r __KamajiWhereWeWere=${PWD}

declare    __KamajiWorkinDSpec="TBD"

#----------------------------------------------------------------------------------------------------------------------

function BackupIfExists() {
  #
  local -r TargetFSpec=${1}
  #
  [ -e ${TargetFSpec} ] && EchoAndExecute mv ${TargetFSpec} ${TargetFSpec}.was
  #
}

#----------------------------------------------------------------------------------------------------------------------

function DiagnosticHeavy() { [ "${__KamajiVerbosityRequested}" = "heavy" ] && echoInColorBlue "${*}" 1>&2; }

#----------------------------------------------------------------------------------------------------------------------

function DiagnosticLight() { [ "${__KamajiVerbosityRequested}" != "quiet" ] && echoInColorWhite "${*}" 1>&2; }

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
     echoInColorBlue "${MessageLight} ${MessageHeavy}" 1>&2
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
  local    Result="EQ"
  local    Reason=
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

function EchoAndExecute() {
  #
  local -r SystemCommand="${*}"
  #
  DiagnosticHeavy "${SystemCommand}" 1>&2
  #
  local -r ErrorMessage=$(eval ${SystemCommand} 2>&1)
  #
  local    Status=${?}
  #
  if [ ${#ErrorMessage} -gt 0 ]
  then
     #
     [ ${Status} -eq 0 ] && Status=1
     #
     echoInColorRed ${ErrorMessage} 1>&2
     #
  fi
  #
  return ${Status}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function EchoError() {
  #
  local -r    Message=${*}
  #
  local -r    ErrorTag=$(echoInColorRedBold "ERROR:")
  #
  echoInColorWhiteBold "${ErrorTag} ${Message}" 1>&2
  #
  return 1
  #
}

#----------------------------------------------------------------------------------------------------------------------

function EchoAndExit() {
  #
  local -r -i ExitStatus=${1}
  shift 1
  local -r    Message=${*}
  #
  EchoError "${Message}"
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
      [ -x ${ProgramFSpec} ] && echo "${ProgramFSpec}"
      #
    done
    #
  done
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

function EchoFileType() {
  #
  local -r FileNameOrSpec=${1}
  #
  local    Result=${FileNameOrSpec##*.}
  #
  [ "${Result}" = "${FileNameOrSpec}" ] && Result=
  #
  echo ${Result}
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

function EchoPara80() {
  #
  local -r WordList="${*}"
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
    if [ ${ParagraphWide} -gt 80 ]
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

function KamajiEchoConfigurationValue() {
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

function KamajiLoadConfigurationValues() {
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
         [ ${#Key} -gt 0 ] && [ "${Key:0:1}" != "#" ] && __KamajiConfigurationValue[${Key}]=${Value}
         #
       done < ${Directory}/${__KamajiConfigurationFName}
       #
    fi
    #
  done
  #
  __KamajiVerbosityRequested=$(KamajiEchoConfigurationValue verbosity-level quiet)
  #
  __KamajiWorkinDSpec=$(KamajiEchoConfigurationValue working-folder .)
  #
  [ ${#__KamajiWorkinDSpec} -eq 0 ] && EchoAndExit 1 "The working-folder is improperly configured."
  #
  [ ! -d ${__KamajiWorkinDSpec} ] && EchoAndExecute mkdir --parents ${__KamajiWorkinDSpec}
  #
  __KamajiGoldenDSpec=$(KamajiEchoConfigurationValue baseline-folder .)
  #
  [ ${#__KamajiGoldenDSpec} -eq 0 ]  && EchoAndExit 1 "The baseline-folder is improperly configured."
  #
  [ ! -d ${__KamajiGoldenDSpec} ] && EchoAndExit 1 "The baseline-folder '${__KamajiGoldenDSpec}' does not exist."
  #
  __KamajiAbsoluteGoldenDSpec=$(EchoAbsoluteDirectorySpecFor . ${__KamajiGoldenDSpec})
  __KamajiAbsoluteWorkinDSpec=$(EchoAbsoluteDirectorySpecFor . ${__KamajiWorkinDSpec})
  #
  if [ "${__KamajiAbsoluteGoldenDSpec}" = "${__KamajiAbsoluteWorkinDSpec}" ]
  then
     #
     EchoAndExit 1 "The baseline-folder and/or working-folder are improperly configured; these cannot be the same."
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMakeUsingMake() {
  #
  local -r GivenSourceFSpec=${1}
  local -r GivenTargetFType=${2}
  local -r GivenForcingMake=${3-}
  #
  EchoAndExecute make ${GivenSourceFSpec}
  #
  local -i Status=${?}
  #
  local    Result=
  #
  [ ${Status} -eq 0 ] && [ ! -s ${GivenSourceFSpec} ] && Status=1
  #
  if [ ${Status} -ne 0 ]
  then
     #
     EchoAndExit ${Status} "Unable to create ${GivenSourceFSpec} using the make command."
     #
  else
     #
     Result=${GivenSourceFSpec}
     #
  fi
  #
  echo   ${Result}
  #
  return ${Status}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiApplyMasking() {
  #
  local -r SourceFSpec=${1}
  local -r TargetFSpec=${2}
  #
  local -r SedScriptFSpec=$(KamajiEchoConfigurationValue mask-sed-script ${__KamajiConfigurationFName%.*}.sed)
  #
  [ ! -s ${SedScriptFSpec} ] && touch ${SedScriptFSpec}
  #
  EchoAndExecute "sed --file=${SedScriptFSpec} ${SourceFSpec} > ${TargetFSpec}.partial 2>&1"
  #
  local -i Status=${?}
  #
  if [ ${Status} -eq 0 ]
  then
     #
     EchoAndExecute "mv ${TargetFSpec}.partial ${TargetFSpec}"
     #
  else
     #
     EchoAndExit ${Status} "The sed --file=${SedScriptFSpec} command returned a non-zero status."
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_bash() {
  #
  local -r GivenSourceFSpec=${1}
  local -r GivenTargetFType=${2}
  local -r GivenForcingMake=${3-}
  #
  local -r SourceFName=$(basename ${GivenSourceFSpec})
  #
  local -r SourceFRoot=${SourceFName%.*}
  local -r SourceFType=${SourceFName##*.}
  #
  local -i Status=1
  #
  local    Result=
  #
  if [ "${SourceFType}" = "clut" ]
  then
     #
     local -r DefineFSpec=$(KamajiMake ${SourceDSpec}/${SourceFRoot} ${SourceFType})
     #
     Status=${?}
     #
     if [ ${Status} -eq 0 ] && [ ${#DefineFSpec} -gt 0 ]
     then
        #
        local -r WorkinDSpec=${__KamajiWorkinDSpec}
        #
        local -r SourceFSpec=${DefineFSpec}
        local -r TargetFSpec=$(EchoFileSpec ${WorkinDSpec} ${SourceFName} ${TargetFType})
        #
        Result=${TargetFSpec}
        #
        DiagnosticComplex "${__KamajiScriptName} make ${TargetFSpec}" "# from ${SourceFSpec}"
        #
        #  Determine the CLU specification.
        #
        local    RunnerFSpec=
        #
        for RunnerFSpec in $(EchoExecutableFilesMatching ${SourceFRoot} ${WorkinDSpec} $(find . -type d) ${PATH//:/ })
        do
          #
          [ "${RunnerFSpec//clut.bash/}" != "${RunnerFSpec}" ] && continue
          #
          break
          #
        done
        #
        #  Determine if the compiler needs to be invoked.
        #
        local    ReasonToAct=$(EchoAgeRelation ${SourceFSpec} ${TargetFSpec})
        #
        DiagnosticHeavy "# ${ReasonToAct}"
        #
        if [ "${ReasonToAct:0:2}" != "GT" ] 
        then
           #
           ReasonToAct=$(EchoAgeRelation ${RunnerFSpec} ${TargetFSpec})
           #
           DiagnosticHeavy "# ${ReasonToAct}"
           #
        fi
        #
        #  Invoke the compiler.
        #
        if [ "${ReasonToAct:0:2}" = "GT" ] 
        then
           #
           BackupIfExists ${TargetFSpec}
           #
	   local -r AbsWorkinDSpec=$(EchoAbsoluteDirectorySpecFor . ${WorkinDSpec})
	   local -r AbsSourceDSpec=$(EchoAbsoluteDirectorySpecFor . ${SourceDSpec})
	   local -r AbsRunnerDSpec=$(EchoAbsoluteDirectorySpecFor . $(dirname ${RunnerFSpec}))
	   #
           local -r TargetFName=${SourceFName}.${TargetFType}
	   #
	   local -r SourceToRunnerDSpec=$(echoRelativePath ${AbsSourceDSpec} ${AbsRunnerDSpec})
	   local -r SourceToWorkinDSpec=$(echoRelativePath ${AbsSourceDSpec} ${AbsWorkinDSpec})
	   #
	   local -r RelRunnerFSpec=${SourceToRunnerDSpec}/$(basename ${RunnerFSpec})
	   local -r RelTargetFSpec=${SourceToWorkinDSpec}/${TargetFName}
	   #
           EchoAndExecute "(cd ${SourceDSpec}; clutc ${SourceFName} ${RelRunnerFSpec} ${RelTargetFSpec})"
           #
           Status=${?}
           #
           if [ ${Status} -gt 0 ]
	   then
              #
	      EchoAndExit ${Status} "CLUT compilation failed."
              #
	      Result=
              #
	   fi
           #
        fi
        #
     fi
     #
  elif [ -x ${GivenSourceFSpec}.${GivenTargetFType} ]
  then
     #
     Result=${GivenSourceFSpec}.${GivenTargetFType}
     #
     Status=0
     #
  fi
  #
  echo   ${Result}
  #
  return ${Status}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_clut() {
  #
  local -r GivenSourceFSpec=${1}
  local -r GivenTargetFType=${2}
  local -r GivenForcingMake=${3-}
  #
  local    Result=
  #
  local -i Status=1
  #
  local -r TargetFSpec=${GivenSourceFSpec}.${GivenTargetFType}
  #
  if [ -s ${TargetFSpec} ]
  then
     Result=${TargetFSpec}
     Status=0
  else
     EchoAndExit 1 "${TargetFSpec} missing or empty."
  fi
  #
  echo   ${Result}
  #
  return ${Status}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_delta() {
  #
  local -r GivenSourceFSpec=${1}
  local -r GivenTargetFType=${2}
  local -r GivenForcingMake=${3-}
  #
  local    Result=
  #
  local -i Status
  #
  #  Delta files are created from an output.masked and a golden.output.masked file.
  #
  local -r MaskedFSpec=$(KamajiMake ${GivenSourceFSpec%.masked} masked)
  #
  Status=${?}
  #
  if [ ${Status} -eq 0 ] && [ ${#MaskedFSpec} -gt 0 ]
  then
     #
     local -r InfoTag=$(echoInColorYellow "INFO:")
     #
     local -r OutputFSpec=${MaskedFSpec%.masked}
     #
     local -r GoldenFSpec=${OutputFSpec}.golden.masked
     local -r TargetFSpec=${MaskedFSpec}.${GivenTargetFType}
     #
     DiagnosticComplex "${__KamajiScriptName} make ${TargetFSpec}" "# from ${GoldenFSpec} and ${OutputFSpec}"
     #
     Result=${TargetFSpec}
     #
     if [ -e ${GoldenFSpec} ]
     then
        #
        local ReasonToAct
        #
        ReasonToAct=$(EchoAgeRelation ${MaskedFSpec} ${TargetFSpec})
        #
        DiagnosticHeavy "# ${ReasonToAct}"
        #
        if [ "${ReasonToAct:0:2}" != "GT" ]
	then
	   #
	   ReasonToAct=$(EchoAgeRelation ${GoldenFSpec} ${TargetFSpec})
	   #
           DiagnosticHeavy "# ${ReasonToAct}"
           #
        fi
        #
        if [ "${ReasonToAct:0:2}" = "GT" ]
	then
	   #
           EchoAndExecute "diff --text --ignore-space-change ${GoldenFSpec} ${MaskedFSpec} > ${TargetFSpec}"
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
	     	    spit ${TargetFSpec} "${InfoTag} vimdiff ${GoldenFSpec} ${MaskedFSpec}"
	     	    spit ${TargetFSpec} "${InfoTag} cp ${OutputFSpec} ${__KamajiGoldenDSpec}/"
	         else
	     	    spit ${TargetFSpec} "${InfoTag} vimdiff ${GoldenFSpec} ${SourceFSpec}"
                 fi
                 #
	      fi
              #
              Status=0
              #
           else
              #
              EchoAndExit ${Status} "The diff command failed; this most-often happens because masking failed."
              #
              Result=
              #
           fi
           #
        fi
        #
     else
        #
        rm   ${TargetFSpec}
        #
        spew ${TargetFSpec} ${MaskedFSpec}
        #
	spit ${TargetFSpec} "${InfoTag} No baseline output file found..."
	spit ${TargetFSpec} "${InfoTag} cp ${OutputFSpec} ${__KamajiGoldenDSpec}/"
        #
     fi
     #
     Result=${TargetFSpec}
     #
  fi
  #
  echo   ${Result}
  #
  return ${Status}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_grade() {
  #
  local -r GivenSourceFSpec=${1}
  local -r GivenTargetFType=${2}
  local -r GivenForcingMake=${3-}
  #
  local    Result=
  #
  local -i Status
  #
  #  The output.grade files are based on output.masked.delta files.
  #
  local -r DeltasFSpec=$(KamajiMake ${GivenSourceFSpec%.delta} delta)
  #
  Status=${?}
  #
  if [ ${Status} -eq 0 ] && [ ${#DeltasFSpec} -gt 0 ]
  then
     #
     local -r OutputFSpec=${DeltasFSpec%.masked.delta}
     #
     local -r SourceFSpec=${DeltasFSpec}
     local -r TargetFSpec=${OutputFSpec}.${GivenTargetFType}
     #
     DiagnosticComplex "${__KamajiScriptName} make ${TargetFSpec}" "# from ${SourceFSpec}"
     #
     Result=${TargetFSpec}
     #
     local    ReasonToAct=
     #
     [ ${#GivenForcingMake} -gt 0 ] && ReasonToAct="GT Explicitly requested action."
     #
     [ ${#ReasonToAct} -eq 0 ] && ReasonToAct=$(EchoAgeRelation ${SourceFSpec} ${TargetFSpec})
     #
     DiagnosticHeavy "# ${ReasonToAct}"
     #
     if [ "${ReasonToAct:0:2}" = "GT" ]
     then
        #
        if [ -s ${SourceFSpec} ]
        then
           #
           [ -e ${TargetFSpec} ] && EchoAndExecute rm ${TargetFSpec}
           #
           DiagnosticHeavy "cat ${SourceFSpec}" 1>&2
           #
           cat ${SourceFSpec} 1>&2	# EchoAndExecute considers any output an error message.
           #
        else
           #
           EchoAndExecute touch ${TargetFSpec}
           #
        fi
        #
     fi
     #
     local -r VerboseMessage="${__KamajiScriptName} make ${TargetFSpec}"
     #
     if [ -e ${TargetFSpec} ] && [ ! -s ${TargetFSpec} ]
     then
        #
        local -r PassingGrade=$(echoInColorGreen "(pass)")
        #
        [ "${__KamajiVerbosityRequested}" != "quiet" ] && echoInColorWhite "${VerboseMessage} ${PassingGrade}" 1>&2
        #
     else
        #
        local -r FailingGrade=$(echoInColorRedBold "(FAIL)")
        #
        [ "${__KamajiVerbosityRequested}" != "quiet" ] && echoInColorWhite "${VerboseMessage} ${FailingGrade}" 1>&2
        #
        EchoAndExit 1 "${OutputFSpec} differs from the baseline."
        #
        Status=1
        #
        Result=
        #
     fi
     #
  fi
  #
  echo   ${Result}
  #
  return ${Status}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_masked() {
  #
  local -r GivenSourceFSpec=${1}
  local -r GivenTargetFType=${2}
  local -r GivenForcingMake=${3-}
  #
  local -r SourceDSpec=$(dirname  ${GivenSourceFSpec})
  local    SourceFName=$(basename ${GivenSourceFSpec})
  #
  local    SourceFType=$(EchoFileType ${SourceFName})
  local    SourceFRoot=${SourceFName%.${SourceFType}}
  #
  local    SourceFSpec
  local    TargetFSpec
  #
  local    Result=
  #
  local -i Status=0
  #
  #  Make current output file.
  #
  local -r OutputFSpec=$(KamajiMake ${GivenSourceFSpec%.output} output)
  #
  Status=${?}
  #
  if [ ${Status} -eq 0 ] && [ ${#OutputFSpec} -gt 0 ]
  then
     #
     #  Mask the current output file.
     #
     SourceFSpec=${OutputFSpec}
     TargetFSpec=${OutputFSpec}.${GivenTargetFType}
     #
     DiagnosticComplex "${__KamajiScriptName} make ${TargetFSpec}" "# from ${SourceFSpec}"
     #
     local    ReasonToAct=
     #
     [ ${#GivenForcingMake} -gt 0 ] && ReasonToAct="GT Explicitly requested action."
     #
     [ ${#ReasonToAct} -eq 0 ] && ReasonToAct=$(EchoAgeRelation ${SourceFSpec} ${TargetFSpec})
     #
     DiagnosticHeavy "# ${ReasonToAct}"
     #
     if [ "${ReasonToAct:0:2}" = "GT" ]
     then
        #
        KamajiApplyMasking  ${SourceFSpec} ${TargetFSpec}
        #
     fi
     #
     Result=${TargetFSpec}
     #
  fi
  #
  #  Mask the golden baseline output file.
  #
  if [ ${Status} -eq 0 ] && [ ${#OutputFSpec} -gt 0 ]
  then
     #
     local -r OutputFName=$(basename ${OutputFSpec})
     #
     SourceFSpec=${__KamajiGoldenDSpec}/${OutputFName}
     TargetFSpec=${__KamajiWorkinDSpec}/${OutputFName}.golden.${GivenTargetFType}
     #
     DiagnosticComplex "${__KamajiScriptName} make ${TargetFSpec}" "# from ${SourceFSpec}"
     #
     local    ReasonToAct=
     #
     [ ${#GivenForcingMake} -gt 0 ] && ReasonToAct="GT Explicitly requested action."
     #
     [ ${#ReasonToAct} -eq 0 ] && ReasonToAct=$(EchoAgeRelation ${SourceFSpec} ${TargetFSpec})
     #
     DiagnosticHeavy "# ${ReasonToAct}"
     #
     if [ "${ReasonToAct:0:2}" = "GT" ]
     then
        #
        KamajiApplyMasking  ${SourceFSpec} ${TargetFSpec}
        #
     fi
     #
  fi 
  #
  echo   ${Result}
  #
  return ${Status}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_output() {
  #
  local -r GivenSourceFSpec=${1}
  local -r GivenTargetFType=${2}
  local -r GivenForcingMake=${3-}
  #
  local -r SourceDSpec=$(dirname  ${GivenSourceFSpec})
  local    SourceFName=$(basename ${GivenSourceFSpec})
  #
  local    SourceFType=$(EchoFileType ${SourceFName})
  local    SourceFRoot=${SourceFName%.${SourceFType}}
  #
  local    Result=
  #
  local -i Status=0
  #
  #  We create output from an executable source.
  #
  #	SourceFName		KamajiMake
  #	-----------		----------
  #	program.clut		<dspec>/program.clut bash
  #	program.bash		<dspec>/program bash
  #	program			<dspec>/program <empty> (results in use of the make command)
  #	-----------		----------
  #
  local    RunnerFSpec
  #
  if [ "${SourceFType}" = "clut" ]
  then
     #
     SourceFRoot="${SourceFRoot}.${SourceFType}"
     #
     SourceFType="bash"
     #
     RunnerFSpec=$(KamajiMake ${SourceDSpec}/${SourceFRoot} ${SourceFType})
     #
     Status=${?}
     #
  elif [ ${#SourceFType} -eq 0 ]
  then
     #
     #  If the typeless file exists and is executable then that is the source; otherwise...
     #
     if [ ! -x ${SourceDSpec}/${SourceFRoot} ]
     then
        #
        #  Check to see if the source program is a script.
        #
	for ScriptFType in bash py sh
	do
	  #
	  if [ -x ${SourceDSpec}/${SourceFRoot}.${ScriptFType} ]
	  then
	     #
	     SourceFType=${ScriptFType}
	     #
	     break
	     #
	  fi
	  #
	done
	#
     fi
     #
     #  If the source file is not a script then we cannot know if it is out-of-date, but the make command might.
     #
     RunnerFSpec=$(KamajiMake ${SourceDSpec}/${SourceFRoot} ${SourceFType})
     #
     Status=${?}
     #
  else
     #
     RunnerFSpec=${GivenSourceFSpec}
     #
  fi
  #
  if [ ${Status} -ne 0 ] || [ ${#RunnerFSpec} -eq 0 ] || [ ! -x ${RunnerFSpec} ]
  then
     #
     EchoError "The ${RunnerFSpec-given} file is not executable."
     #
     Status=1
     #
  fi
  #
  if [ ${Status} -eq 0 ]
  then
     #
     #  If there is a SourceFType then it is not used in the TargetFSpec.
     #
     #  	SourceFRoot.SourceFType		TargetFName
     #  	-----------------------		-----------
     #  	program.clut.bash		program.clut.output
     #		program.bash			program.output
     #		program				program.output
     #		program.py			program.output
     #  	-----------------------		-----------
     #
     local -r WorkinDSpec=${__KamajiWorkinDSpec}
     #
     local    TargetFSpec=$(EchoFileSpec ${WorkinDSpec} ${SourceFRoot} ${GivenTargetFType})
     local -r SourceFSpec=${RunnerFSpec}
     #
     DiagnosticComplex "${__KamajiScriptName} make ${TargetFSpec}" "# from ${SourceFSpec}"
     #
     local    ReasonToAct=
     #
     [ ${#GivenForcingMake} -gt 0 ] && ReasonToAct="GT Explicitly requested action."
     #
     [ ${#ReasonToAct} -eq 0 ] && ReasonToAct=$(EchoAgeRelation ${SourceFSpec} ${TargetFSpec})
     #
     DiagnosticHeavy "# ${ReasonToAct}"
     #
     Result=${TargetFSpec}
     #
     if [ "${ReasonToAct:0:2}" = "GT" ]
     then
        #
        if [ -x ${SourceFSpec} ]
        then
           #
  	   #  CLUT bash scripts must be run from the directory in which they reside, so we do so for all programs.
           #
           local -r RealSourceFName=$(basename ${SourceFSpec})
           #
           local -r TargetFName=$(basename ${TargetFSpec})
           #
           local -r SourceToTargetDSpec=$(echoRelativePath ${SourceDSpec} ${WorkinDSpec})
           #
           EchoAndExecute "(cd ${SourceDSpec}; ${RealSourceFName} > ${SourceToTargetDSpec}/${TargetFName}.partial 2>&1)"
           #
           Status=${?}
           #
           if [ ${Status} -eq 0 ]
           then
	      #
	      EchoAndExecute "mv ${TargetFSpec}.partial ${TargetFSpec}"
	      #
           else
	      #
	      EchoAndExecute "cat ${TargetFSpec}.partial"
	      #
	      EchoAndExit ${Status} "${SourceFSpec} returned a non-zero exit status."
	      #
	      Result=
	      #
           fi
           #
        else
           #
           EchoAndExit 1 "${SourceFSpec} is not an executable file."
           #
           Result=
           #
        fi
        #
     fi
     #
  fi
  #
  echo   ${Result}
  #
  return ${Status}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake() {
  #
  local -r GivenSourceFSpec=${1}
  local -r GivenTargetFType=${2-}
  local -r GivenForcingMake=${3-}
  #
  local    MakeFunctionName=$(declare -F KamajiMake_${GivenTargetFType})
  #
  [ ${#MakeFunctionName} -eq 0 ] && MakeFunctionName=KamajiMakeUsingMake
  #
  ${MakeFunctionName} ${GivenSourceFSpec} "${GivenTargetFType}" ${GivenForcingMake}
  #
  local ZStatus=${?}
  #
  return $ZStatus
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiCommandCompile() {
  #
  local -r Command=${1}
  local -r SourceFSpec="${2}"
  #
  DiagnosticLight "${__KamajiScriptName} ${Command} ${SourceFSpec}"
  #
  local -r SourceFType=$(EchoFileType ${SourceFSpec})
  #
  local    UnusedResult
  #
  if [ "${SourceFType}" = "clut" ]
  then
     #
     #  Create a clut.bash files from a clut file.
     #
     UnusedResult=$(KamajiMake ${SourceFSpec} bash FORCED)
     #
  else
     #
     UnusedResult=$(KamajiMake ${SourceFSpec} "" FORCED)
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiCommandConfigure() {
  #
  local -r Command=${1}
  local -r Name="${2}"
  shift 2
  local -r Value="${*}"
  #
  DiagnosticLight "${__KamajiScriptName} ${Command} ${SourceFSpec}"
  #
  echo "${Name} ${Value}" >> ./${__KamajiConfigurationFName}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiCommandExecute() {
  #
  local -r Command=${1}
  local -r SourceFSpec="${2}"
  #
  DiagnosticLight "${__KamajiScriptName} ${Command} ${SourceFSpec}"
  #
  #  Create an output file from any executable file.
  #
  local -r UnusedResult=$(KamajiMake ${SourceFSpec} output FORCED)
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiCommandGrade() {
  #
  local -r Command=${1}
  local -r SourceFSpec="${2}"
  #
  DiagnosticLight "${__KamajiScriptName} ${Command} ${SourceFSpec}"
  #
  #  Create an output.grade file from an output.masked.delta file.
  #
  local -r UnusedResult=$(KamajiMake ${SourceFSpec} grade FORCED)
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiCommandMask() {
  #
  local -r Command=${1}
  local -r SourceFSpec="${2}"
  #
  DiagnosticLight "${__KamajiScriptName} ${Command} ${SourceFSpec}"
  #
  #  Create an output.masked file from an output file.
  #
  local -r UnusedResult=$(KamajiMake ${SourceFSpec} masked FORCED)
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierSilent() {
  #
  local -r Modifier=${1}
  shift 1
  local -r ModifiedCommand="${*}"
  #
  __KamajiVerbosityRequested="quiet"
  #
  KamajiMain ${ModifiedCommand}
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiUsageCompile() {
  #
  local -r Command="${1}"
  #
  EchoPara80	"Compile..."
  #
  EchoPara80	"The compile command is used to compile and link both CLUT definitions and unit test"		\
		"exercises. CLUT definitions are stored in files that have the word \"clut\" as their name"	\
		"extension. CLUT definitions are \"compiled\" by translating them to executable Bash scripts;"	\
		"see the clutc.bash program for details. Any form of command-line executable can be the"	\
		"subject of a suite of CLUT cases."
  #
  EchoPara80	"Exercise programs (a.k.a. unit tests and class tests) are executable files with"		\
		"\"_exercise\" in their names. If an exercise file is not already executable then this script"	\
		"will attempt to use the system make command to compile it into an executable program."		\
		"Any form of command-line executable can be used as an exercise."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiUsageConfigure() {
  #
  local -r Command="${1}"
  #
  EchoPara80	"Configuration vales are stored in the ./${__KamajiConfigurationFName} file,"			\
		"a text file that contains named value pairs:"							\
  		"baseline-folder <spec> - the directory where baseline output files are stored;"		\
  		"mask-sed-script <text> - the user-define sed script for masking output files;"			\
  		"verbose-if-true <text> - if \"true\" then this script will produce verbose output."
  #
  EchoPara80	"The \$HOME/${__KamajiConfigurationFName} configuration file can be used to"			\
		"override values in the ./${__KamajiConfigurationFName} file."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiUsageExecute() {
  #
  local -r Command="${1}"
  #
  EchoPara80	"Execute|Invoke|Run..."
  #
  EchoPara80	"Executable files are invoked to produce output files."						\
		"Output file names are based on the executable files that are used to create them."		\
		"Script file name extensions are removed from output file names."				\
		"For example, output for the program.bash script will be stored in the program.output file."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiUsageGrade() {
  #
  local -r Command="${1}"
  #
  EchoPara80	"Grade..."
  #
  EchoPara80	"A passing grade is granted when a current output file matches the baseline output"		\
		"file of the same name."									\
		"Comparisons are made to output files only after they are masked to remove"			\
		"non-deterministic values, like dates, times, and account-specific directory names."
  #
  EchoPara80	"The mask-sed-script configuration value can be used to specify the location of"		\
		"the user-define sed script."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiUsageMask() {
  #
  local -r Command="${1}"
  #
  EchoPara80	"Mask..."
  #
  EchoPara80	"Output files are masked before they are compared to remove"					\
		"non-deterministic values, like dates, times, and account-specific directory names."		\
  		"The mask-sed-script configuration value can be used to specify the location of"		\
		"the user-defined sed script."									\
		"It may be useful to explicitly request masking when the sed script is updated."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiModifierUsage() {
  #
  local -r Modifier=${1}
  shift 1
  local -r ModifiedCommand="${*}"
  #
  echo "USAGE: ${__KamajiScriptName} [<modifier>]... [<command>] [<parameter>]..."
  echo ""
  echo "Where <modifier> is one of the following:"
  echo "      verbose"
  echo "      silent"
  echo "      usage"
  echo ""
  echo "Where <modifier> <command> is one of the following:"
  echo "      compile   [<specification>]..."
  echo "      execute   [<specification>]..."
  echo "      grade     [<specification>]..."
  echo "      mask	[<specification>]..."
  echo "      set	<name> <value>"
  echo ""
  #
  if [ ${#ModifiedCommand} -eq 0 ]
  then
     #
     EchoPara80	"Modifier synonyms help (usage), noisy (verbose), and quiet (silent) are supported."		\
		"Command synonyms configure (set), invoke (execute), and run (execute) are supported."		\
		"Command abbreviations are accepted; ambiguity is resolved using alphabetical order."		\
		"No other actions are applied after a usage request is fulfilled."
     #
     EchoPara80	"Further help may be displayed by following the usage modified by the command or command"	\
		"synonym of interest; for example, \"${__KamajiScriptName} help invoke.\""
     #
     EchoPara80	"CLUT cases and unit test exercises are used and evaluated in similar ways:"			\
		"compile, execute, and then grade;"								\
		"these user requests are always fulfilled whether they need to be or not."			\
		"User requests may require support files to be created."					\
		"For example, a request to grade a set of CLUT definitions may result in those defintions"	\
		"being compiled and executed first."
     #
     EchoPara80	"CLUT definitions are compiled into Bash scripts."						\
		"Unit test exercises may be made of compilable code or scripting languages."			\
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
		"between minor and controlled changes to the code being tested."
     #
     EchoPara80	"Passing grades are only granted when current output matched baseline output,"			\
		"but this matching is only attempted after the current and baseline output are masked."		\
		"Masking is performed using a user-define sed script."
     #
     EchoPara80	"Three levels of diagnostic output are controlled by the silent and verbose modifiers:"		\
		"The silent modifier causes this script to produce no diagnostic output."			\
		"A single verbose modifier is a request for light diagnostic output; internal make commands."	\
		"Multiple verbose modifiers will produce heavy diagnostic output;"				\
		"additional Linux commands in blue."
     #
  else
     #
     local -A UsageFunctionFor
     #
     UsageFunctionFor[compile]=KamajiUsageCompile
     UsageFunctionFor[configure]=KamajiUsageConfigure
     UsageFunctionFor[execute]=KamajiUsageExecute
     UsageFunctionFor[grade]=KamajiUsageGrade
     UsageFunctionFor[invoke]=KamajiUsageExecute
     UsageFunctionFor[mask]=KamajiUsageMask
     UsageFunctionFor[run]=KamajiUsageExecute
     UsageFunctionFor[set]=KamajiUsageConfigure
     #
     local -r UsageCorrected=$(EchoMeaningOf ${ModifiedCommand} "compile" ${!UsageFunctionFor[*]})
     #
     ${UsageFunctionFor[${UsageCorrected}]} ${UsageCorrected}
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
  local -r ModifiedCommand="${*}"
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
  KamajiMain ${ModifiedCommand}
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
     local -A CommandFunctionFor
     #
     CommandFunctionFor[compile]=KamajiCommandCompile
     CommandFunctionFor[configure]=KamajiCommandConfigure
     CommandFunctionFor[execute]=KamajiCommandExecute
     CommandFunctionFor[grade]=KamajiCommandGrade
     CommandFunctionFor[invoke]=KamajiCommandExecute
     CommandFunctionFor[mask]=KamajiCommandMask
     CommandFunctionFor[run]=KamajiCommandExecute
     CommandFunctionFor[set]=KamajiCommandConfigure
     #
     CommandFunctionFor[usage]=KamajiModifierUsage
     #
     local -r CommandCorrected=$(EchoMeaningOf ${RequestedAction} "usage" ${!CommandFunctionFor[*]})
     #
     local    SourceFSpec
     #
     if [ ${#ParameterList} -gt 0 ]
     then
        #
        for SourceFSpec in ${ParameterList}
        do
          #
          ${CommandFunctionFor[${CommandCorrected}]} ${CommandCorrected} ${SourceFSpec}
          #
        done
        #
     else
        #
        ${CommandFunctionFor[${CommandCorrected}]} ${CommandCorrected}
        #
     fi
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------

KamajiLoadConfigurationValues

KamajiMain ${*}

#----------------------------------------------------------------------------------------------------------------------
