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
#	BackupIfExists
#	DiagnosticHeavy
#	DiagnosticLight
#	DiagnosticComplex
#	EchoAbsoluteDirectorySpecFor
#	EchoAgeRelation
#	EchoAndExecute
#	EchoError
#	EchoAndExit
#	EchoExecutableFilesMatching
#	EchoFileSpec
#	EchoMeaningOf
#	EchoPara
#	EchoPara80
#	EchoPara80-4
#	Xtension
#	SortArray
#
#	KamajiEchoArrayAssignments
#	KamajiExitAfterUsage
#	KamajiFileClassification
#
#	KamajiConfigurationCheckValues
#	KamajiConfigurationEchoValue
#	KamajiConfigurationLoadValues
#
#	KamajiModifierFast
#	KamajiModifierSilent
#	KamajiModifierUsage_configure
#	KamajiModifierUsage_grades
#	KamajiModifierUsage_export
#	KamajiModifierUsage_make
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
#	KamajiBuildRules
#
#	KamajiRequestConfigure
#	KamajiRequestExport_ruleset
#	KamajiRequestExport
#	KamajiRequestGrade
#	KamajiRequestMake
#	KamajiRequestShow_makefile_explicit
#	KamajiRequestShow_makefile_layered
#	KamajiRequestShow_makefile
#	KamajiRequestShow
#
#	KamajiMake_Delta_from_GoldenMasked_OutputMasked
#	KamajiMake_Delta_from_OutputMasked
#	KamajiMake_Delta_from_OutputMasked_GoldenMasked
#	KamajiMake_GoldenMasked_from_SedMaskingScript_Golden
#	KamajiMake_Grade_from_Delta
#	KamajiMake_Output_from_Script
#	KamajiMake_OutputMasked_from_SedMaskingScript_Output
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

#----------------------------------------------------------------------------------------------------------------------

declare -A __KamajiConfigurationValue

declare    __KamajiGoldenDSpec="TBD"

declare -r __KamajiInfoTag=$(echoInColorYellow "INFO:")

declare    __KamajiDataFileNameList="TBD"

declare    __KamajiScriptExtensionList="TBD"

declare    __KamajiVerbosityRequested="TBD"

declare -r __KamajiWhereWeWere=${PWD}

declare    __KamajiWorkinDSpec="TBD"

declare    __KamajiSedScriptFSpec="TBD"
declare    __KamajiSedScriptFName="TBD"

declare    __KamajiRulesetIsReady="false"

declare -A __KamajiBaseSourceList
declare -A __KamajiClassifiedList
declare -A __KamajiMyChildrenList
declare -A __KamajiMyParentalList
declare -A __KamajiRepresentative

declare -A __KamajiUserDependants

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

function DiagnosticLight() { [ "${__KamajiVerbosityRequested}" != "quiet" ] && echoInColorYellow "${*}" 1>&2; }

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

function EchoAndExecute() {
  #
  local -r SystemRequest="${*}"
  #
  DiagnosticHeavy "${SystemRequest}" 1>&2
  #
  local -r ErrorMessage=$(eval ${SystemRequest} 2>&1)
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
  spit ${RulesetFSpec} "#"
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiExitAfterUsage() {
  #
  local -r Message=${*}
  #
  EchoError "${Message}"
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
  elif [ "${SourceFType}" = "cpp" ]
  then
     #
     Result="Elf"
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
  local Key Value Tail Directory
  #
  for Directory in . ${HOME}
  do
    #
    if [ -s ${Directory}/${__KamajiConfigurationFName} ]
    then
       #
       while read Key Value Tail
       do
         #
         if [ "${Key^^}" = "DEPENDANT:" ]
         then
            #
	    AppendArrayIndexValue __KamajiUserDependants "$(basename ${Value})" "$(basename ${Tail})"
            #
         elif [ ${#Key} -gt 0 ] && [ "${Key:0:1}" != "#" ]
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
  EchoPara80	"A passing grade is granted for a test program when the program produces output"		\
		"that matches its expected/golden baseline output."						\
		"Comparisons are made to output files only after they are masked to remove"			\
		"non-deterministic values (e.g. dates, times, account names)."
  #
  EchoPara80	"Masking is performed by a user-defined sed script;"						\
		"the mask-sed-script configuration value can be used to specify the location of that script."
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
		"either because the user changed them or because they themselves were remads ."
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
  echo "      silent"
  echo "      verbose"
  echo ""
  echo "Where <request> is one of the following:"
  echo "      export [ruleset]"
  echo "      grade  [<filename>]..."
  echo "      help   [<modifier>|<request>]"
  echo "      make   [<filename>]..."
  echo "      set    <name> <value>"
  echo "      show   [makefile [explicit|layered]]"
  echo ""
  #
  declare -A UsageModifierSubjectList
  #
  UsageModifierSubjectList[configure]=configure
  UsageModifierSubjectList[export]=export
  UsageModifierSubjectList[fast]=fast
  UsageModifierSubjectList[grades]=grades
  UsageModifierSubjectList[help]=usage
  UsageModifierSubjectList[make]=make
  UsageModifierSubjectList[noisy]=verbose_and_silent
  UsageModifierSubjectList[quiet]=verbose_and_silent
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
     EchoPara80	"Synonyms configure (set), help (usage), noisy (verbose), and quiet (silent) are supported."	\
		"Modifier and request abbreviations are also supported;"					\
		"ambiguity is resolved using alphabetical order."						\
		"No other modifiers or requests are applied after a usage request is fulfilled."
     #
     EchoPara80	"Further help may be displayed by following the usage request by the subject of interest;"	\
		"for example, \"${__KamajiScriptName} help fast\" or \"${__KamajiScriptName} usage grade\""
     #
     EchoPara80	"CLUT cases and unit test exercises are used and evaluated in similar ways:"			\
		"compile (if not already executable), execute to produce output, mask that output, compare the"	\
		"masked output to its baseline, and then grade."						\
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
  [ ${#RunnerFSpec} -eq 0 ] && EchoAndExit 1 "Unable to find the executable file exercised by ${SourceFSpec}."
  #
  local -r RunnerFName=$(basename ${RunnerFSpec})
  #
  #  __KamajiRepresentative[TargetFName]="SourceFSpec": What external file does this working file name represent?
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
  #  __KamajiRepresentative[TargetFName]="SourceFSpec": What external file does this working file name represent?
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
  #  __KamajiRepresentative[TargetFName]="SourceFSpec": What external file does this working file name represent?
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
  #  __KamajiRepresentative[TargetFName]="SourceFSpec": What external file does this working file name represent?
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
     #  __KamajiRepresentative[TargetFName]="SourceFSpec": What external file does this working file name represent?
     #  __KamajiBaseSourceList[TargetFName]="SourceFName": What recipe should I follow given FName as a target?
     #  __KamajiMyChildrenList[SourceFName]="TargetFName...": What files are created directly from this source?
     #  __KamajiMyParentalList[TargetFName]="SourceFName...": What files are direct sources of this target?
     #
     #  Use of __KamajiMyChildrenList will cause the file to be added to the __KamajiMyParentalList of the children,
     #  which in turn will cause the parent to be an unexpected part of the Make equasion for the child. For example,
     #  adding a script as a dependant of a CLUT causes kamaji to think it need to create the CLUT from the script.
     #  The __KamajiUserDependants are indirect sources of their targets, not direct ones.
     #
     __KamajiRepresentative["${SourceFName}"]="../${SourceFSpec}"
     AppendArrayIndexValue __KamajiMyParentalList "${SourceFName}" ""
     #
     if [ "${__KamajiUserDependants[${SourceFName}]+IS_SET}" = "IS_SET" ]
     then
        #
        for TargetFName in ${__KamajiUserDependants[${SourceFName}]}
        do
          #
          AppendArrayIndexValue __KamajiBaseSourceList "${TargetFName}" "${SourceFName}"
#         AppendArrayIndexValue __KamajiMyChildrenList "${SourceFName}" "${TargetFName}"
          #
        done
        #
     fi
     #
     return
     #
  fi
  #
  local    SourceClass=$(KamajiFileClassification ${SourceFSpec} ${SourceFType})
  #
#?[ "${SourceClass}" = "Unknown" ] && SourceClass="Elf"
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
  #  __KamajiRepresentative[TargetFName]="SourceFSpec": What external file does this working file name represent?
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
  [ "${__KamajiRulesetIsReady}" = "save" ] && KamajiRequestExport_ruleset create ruleset
  #
  #  Mark the ruleset ready.
  #
  __KamajiRulesetIsReady="true"
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
     EchoAndExit 1 "The '${RulesetFName}' name cannot be used to store the ruleset."
     #  
  fi
  #
  [ -e ${RulesetFSpec} ] && EchoAndExecute mv ${RulesetFSpec} ${RulesetFSpec}.was
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
  spit ${RulesetFSpec} "#  __KamajiRepresentative[TargetFName]=\"SourceFSpec\":"			\
				"What external file does this working file name represent?"
  spit ${RulesetFSpec} "#  __KamajiMyParentalList[TargetFName]=\"SourceFName...\":"			\
				"What files are direct sources of this target?"
  spit ${RulesetFSpec} "#"
  spit ${RulesetFSpec} "#  Where FName == file name withing the working-folder"
  spit ${RulesetFSpec} "#        FName == file specification outside of the working-folder"
  #
  KamajiEchoArrayAssignments __KamajiBaseSourceList ${!__KamajiBaseSourceList[*]} | sort >> ${RulesetFSpec}
  KamajiEchoArrayAssignments __KamajiClassifiedList ${!__KamajiClassifiedList[*]} | sort >> ${RulesetFSpec}
  KamajiEchoArrayAssignments __KamajiMyChildrenList ${!__KamajiMyChildrenList[*]} | sort >> ${RulesetFSpec}
  KamajiEchoArrayAssignments __KamajiMyParentalList ${!__KamajiMyParentalList[*]} | sort >> ${RulesetFSpec}
  KamajiEchoArrayAssignments __KamajiRepresentative ${!__KamajiRepresentative[*]} | sort >> ${RulesetFSpec}
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

function KamajiRequestGrade() {
  #
  local -r Request=${1}
  shift 1
  local    SourceFList="${*}"
  #
  local    SourceFName
  #
  if [ ${#SourceFList} -eq 0 ]
  then
     #
     if [ ${#__KamajiClassifiedList[Grade]} -gt 0 ]
     then
        SourceFList=${__KamajiClassifiedList[Grade]}
     else
	DiagnosticHeavy "# There are no files to grade; no CLUT or unit test exercises defined."
     fi
     #
  fi
  #
  for SourceFSpec in ${SourceFList}
  do
    #
    SourceFName=$(basename ${SourceFSpec})
    #
    if [ "${__KamajiBaseSourceList[${SourceFName}]+IS_SET}" != "IS_SET" ]
    then
       #  
       EchoAndExit 1 "The '${SourceFName}' file cannot be graded; it is not a known derivative."  
       #  
    fi
    #  
    KamajiMake ${SourceFName}
    #  
  done
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiRequestMake() {
  #
  local -r Request=${1}
  local -r GivnSourceFSpec="${2-}"
  #
  [ ${#GivnSourceFSpec} -eq 0 ] && KamajiExitAfterUsage "Make target file name parameter required."
  #
  local -r GivnSourceFName=$(basename ${GivnSourceFSpec})
  #
  if [ "${__KamajiBaseSourceList[${GivnSourceFName}]+IS_SET}" != "IS_SET" ]
  then
     #  
     EchoAndExit 1 "The '${GivnSourceFName}' file cannot be made; it is not a known derivative."  
     #  
  fi
  #
  KamajiMake ${GivnSourceFName}
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
  EchoAndExecute "(cd ${__KamajiWorkinDSpec};"	\
		 "diff --text --ignore-space-change ${GoldenMaskedFName} ${OutputMaskedFName} > ${TargetFName} 2>&1)"
  #
  Status=${?}
  #
  if [ ${Status} -le 1 ]
  then
     #
     if [ -s ${TargetFSpec} ]
     then
        #
	spitn ${TargetFSpec} "${__KamajiInfoTag} vimdiff "
	spit  ${TargetFSpec} "${__KamajiWorkinDSpec}/${GoldenMaskedFName} ${__KamajiWorkinDSpec}/${OutputMaskedFName}"
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
     EchoAndExit ${Status} "The diff command failed; this most-often happens because masking failed."
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
  EchoAndExecute "(cd ${__KamajiWorkinDSpec}; cat ${OutputMaskedFName} > ${TargetFName} 2>&1)"
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
  EchoAndExecute "(cd ${__KamajiWorkinDSpec};"	\
		 "sed --file=${SedScriptFName} ${GoldenSourceFName} > ${TargetFName}.partial 2>&1)"
  #
  Status=${?}
  #
  [ ${Status} -eq 0 ] || EchoAndExit ${Status} "The sed command failed."
  #
  EchoAndExecute "(cd ${__KamajiWorkinDSpec}; mv ${TargetFName}.partial ${TargetFName})"
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
     [ -e ${__KamajiWorkinDSpec}/${TargetFName} ] && EchoAndExecute "rm ${__KamajiWorkinDSpec}/${TargetFName}"
     #
     DiagnosticHeavy "(cd ${__KamajiWorkinDSpec}; cat ${SourceFName})" 1>&2
     #
     (cd ${__KamajiWorkinDSpec}; cat ${SourceFName}) 1>&2	# EchoAndExecute considers any output an error message.
     #
     EchoAndExit 1 "The latest ${TargetFName%.grade} differs from the baseline."
     #
  else
     #
     EchoAndExecute "(cd ${__KamajiWorkinDSpec}; touch ${TargetFName})"
     #
  fi
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_Output_from_Script() {
  #
  local -r TargetFName=${1}
  local -r SourceFName=${2}
  #
  EchoAndExecute "(cd ${__KamajiWorkinDSpec}; ./${SourceFName} > ${TargetFName}.partial 2>&1)"
  #
  Status=${?}
  #
  [ ${Status} -eq 0 ] || EchoAndExit ${Status} "The ${SourceFName} script failed."
  #
  EchoAndExecute "(cd ${__KamajiWorkinDSpec}; mv ${TargetFName}.partial ${TargetFName})"
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_OutputMasked_from_SedMaskingScript_Output() {
  #
  KamajiMake_GoldenMasked_from_SedMaskingScript_Golden ${*};
  #
}

#----------------------------------------------------------------------------------------------------------------------

function KamajiMake_Script_from_Clut_Naked() {
  #
  local -r TargetFName=${1}
  local -r ClutSourceFName=${2}
  local -r ExecSourceFName=${3}
  #
  EchoAndExecute "(cd ${__KamajiWorkinDSpec}; clutc ${ClutSourceFName} ${ExecSourceFName} ${TargetFName})"
  #
  Status=${?}
  #
  [ ${Status} -eq 0 ] || EchoAndExit ${Status} "CLUT compilation failed."
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
  local    ListOfParentFName=${__KamajiMyParentalList[${TargetFName}]}
  #
  if [ ${#ListOfParentFName} -eq 0 ] && [ ! -L ${__KamajiWorkinDSpec}/${TargetFName} ]
  then
     #
     local -r GoldenFSpec=${__KamajiRepresentative[${TargetFName}]}
     #
     EchoAndExecute ln --symbolic ${GoldenFSpec} ${__KamajiWorkinDSpec}/${TargetFName}
     #
     return
     #
  fi
  #
  #  Make each of the parents of the target.
  #
  local ListOfParentClass=
  #
  local ParentFName
  #
  for ParentFName in ${ListOfParentFName}
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
# if [ "${__KamajiUserDependants[${TargetFName}]+IS_SET}" = "IS_SET" ]
# then
#    ListOfParentFName+=" ${__KamajiUserDependants[${TargetFName}]}"
# fi
  #
  local ReasonToAct=
  #
  for ParentFName in ${ListOfParentFName}
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
     [ ${#FunctionToCall} -eq 0 ] && EchoAndExit 1 "Undefined function ${FunctionWeWant} required."
     #
     ${FunctionToCall} ${TargetFName} ${ListOfParentFName}
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
        #  __KamajiRepresentative[TargetFName]="SourceFSpec": What external file does this working file name represent?
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
     RequestFunctionFor[configure]=KamajiRequestConfigure
     RequestFunctionFor[export]=KamajiRequestExport
     RequestFunctionFor[grades]=KamajiRequestGrade
     RequestFunctionFor[make]=KamajiRequestMake
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
