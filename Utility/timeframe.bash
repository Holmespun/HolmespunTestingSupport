#!/bin/bash
#----------------------------------------------------------------------------------------------------------------------
###
###     timeframe.bash...
###
###     @file
###     @author         Brian G. Holmes
###     @copyright      GNU General Public License
###     @brief          Time command output summary and report generator.
###     @todo           https://github.com/Holmespun/HolmespunTestingSupport/issues
###     @remark         timeframe.bash [<modifier>]... [<request>] [<parameter>]..."
###
#----------------------------------------------------------------------------------------------------------------------
#
#       TimeframeMain
#
#----------------------------------------------------------------------------------------------------------------------
#
#  20210516 BGH; created.
#
#----------------------------------------------------------------------------------------------------------------------
#
#  Copyright (c) 2021-2021 Brian G. Holmes
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

#----------------------------------------------------------------------------------------------------------------------

function __PadLeft() {
  #
  local -r -i Width=${1}
  shift 1
  local -r    Stuff="${*}"
  #
  printf "%*s" ${Width} "${Stuff}"
  #
}

#----------------------------------------------------------------------------------------------------------------------

function __FixPoint() {
  #
  local -r LHS="${1}"
  local -r RHS="${2}"
  #
  local    Prefix=
  local    Suffix=
  #
  [ ${#LHS} -eq 0 ] && Prefix="0"
  [ ${#RHS} -eq 1 ] && Suffix="0"
  #
  echo "${Prefix}${LHS}.${RHS}${Suffix}"
  #
}

#----------------------------------------------------------------------------------------------------------------------

function TimeframeMain() {
  #
  local -r ListOfFSpec="${*}"
  #
  local -i ErrorCount=0
  #
  local -r Uniquer="<$$>"
  #
  local    ItemOfFSpec TextLine FormatCurrent
  #
  for ItemOfFSpec in ${ListOfFSpec}
  do
    #
    if [ ! -f ${ItemOfFSpec} ]
    then
       #
       ErrorCount+=1
       #
#      echo "ERROR: The ${ItemOfFSpec} file does not exist." >&2
       #
    fi
    #
  done
  #
  [ ${ErrorCount} -gt 0 ] && return ${ErrorCount}
  #
  local -A FieldType
  #
  FieldType["%D"]="INTEGER"
  FieldType["%F"]="INTEGER"
  FieldType["%I"]="INTEGER"
  FieldType["%K"]="INTEGER"
  FieldType["%M"]="INTEGER"
  FieldType["%O"]="INTEGER"
  FieldType["%R"]="INTEGER"
  FieldType["%S"]="FIXED"
  FieldType["%U"]="FIXED"
  FieldType["%W"]="INTEGER"
  FieldType["%X"]="INTEGER"
  FieldType["%Z"]="INTEGER"
  FieldType["%c"]="INTEGER"
  FieldType["%e"]="FIXED"
  FieldType["%k"]="INTEGER"
  FieldType["%p"]="INTEGER"
  FieldType["%r"]="INTEGER"
  FieldType["%s"]="INTEGER"
  FieldType["%t"]="INTEGER"
  FieldType["%w"]="INTEGER"
  #
  local -a DataLine
  local -a FileName
  local -a FormLine
  #
  local -i DataIndex=0
  #
  for ItemOfFSpec in ${ListOfFSpec}
  do
    #
    FormatCurrent=
    #
    while read TextLine
    do
      #
      if [ "${TextLine:0:1}" = "#" ]
      then
         #
         if [ "${TextLine}" != "${FormatCurrent}" ]
         then
            #
            FormatCurrent="${TextLine}"
            #
         fi
         #
      else
         #
         DataLine[${DataIndex}]="${TextLine}"
         FormLine[${DataIndex}]="${FormatCurrent:1}"
         FileName[${DataIndex}]="${ItemOfFSpec}"
         #
         DataIndex+=1
         #
      fi
      #
    done < ${ItemOfFSpec}
    #
  done
  #
  local -r    ControlCodeList="CDEFIKMOPRSUWXZcekprstwx"
  #
  local -i -r DataCount=${DataIndex}
  #
  local -a    DataTokenList
  local -a    FormTokenList
  #
  local -i    TokenIndex TokenCount
  #
  local -i    CommandIndex=0
  #
  local       FormLineLast=${Uniquer}
  #
  local       CommandText AccumulatorIndex
  #
  local -A    Accumulator
  local -A -i Calculation
  local -A -i IndexFor
  local -a    CommandLineForFormatGroup
  local -A    CommandLineFormatGroupCount
  #
  DataIndex=0
  #
  while [ ${DataIndex} -lt ${DataCount} ]
  do
    #
    #  This data line.
    #
    DataTokenList=(${DataLine[${DataIndex}]})
    #
    TokenCount=${#DataTokenList[*]}
    #
    #  Check to see if the format line matches the last one we used.
    #
    if [ "${FormLine[${DataIndex}]}" != "${FormLineLast}" ]
    then
       #
       #  Reset the data value indexes based on the format line.
       #
       FormTokenList=(${FormLine[${DataIndex}]})
       #
       FormLineLast="${FormLine[${DataIndex}]}"
       #
       #  Generate an indirect index table for the format
       #
       TokenIndex=0
       #
       TokenText=
       #
       while [ ${TokenIndex} -lt ${TokenCount} ]
       do
         #
         TokenText="${FormTokenList[${TokenIndex}]}"
         #
         IndexFor["${TokenText}"]=${TokenIndex}
         #
         TokenIndex+=1
         #
       done
       #
    fi
    #
    #  Determine the command name and parameters.
    #
    CommandText=
    #
    if [ "${IndexFor["%C"]+IS_SET}" = "IS_SET" ]
    then
       #
       TokenIndex=${IndexFor["%C"]}
       #
       if [ "${TokenText}" = "%C" ]
       then
          #
          #  The command and it parameters are at the end of the line.
          #
          while [ ${TokenIndex} -lt ${TokenCount} ]
          do
            #
            CommandText+=" ${DataTokenList[${TokenIndex}]}"
            #
            TokenIndex+=1
            #
          done
          #
       else
          #
          #  Only collect the command name itself.
          #
          CommandText=" ${DataTokenList[${TokenIndex}]}"
          #
       fi
       #
    fi
    #
    if [ ${#CommandText} -eq 0 ]
    then
       CommandText="$(basename ${FileName[${DataIndex}]})"
    else
       CommandText=$(basename ${CommandText})
       CommandText=${CommandText// /${Uniquer}}
    fi
    #
    if [ "${CommandLineFormatGroupCount[${CommandText}]+IS_SET}" = "IS_SET" ]
    then
       CommandLineFormatGroupCount[${CommandText}]+=1
    else
       CommandLineFormatGroupCount[${CommandText}]=1
    fi
    #
    #
    CommandLineForFormatGroup[${CommandIndex}]=${CommandText}
    #
    CommandIndex+=1
    #
    #  Accumulate the data.
    #
    TokenIndex=0
    #
    while [ ${TokenIndex} -lt ${TokenCount} ]
    do
      #
      AccumulatorIndex="${CommandText}${FormTokenList[${TokenIndex}]}"
      #
      if [ "${Accumulator[${AccumulatorIndex}]+IS_SET}" = "IS_SET" ]
      then
         Accumulator[${AccumulatorIndex}]+=" ${DataTokenList[${TokenIndex}]}"
      else
         Accumulator[${AccumulatorIndex}]=" ${DataTokenList[${TokenIndex}]}"
      fi
      #
      TokenIndex+=1
      #
    done
    #
    DataIndex+=1
    #
  done
  #
  #  Generate calculations.
  #
  local -r -i CommandCount=${CommandIndex}
  #
  local -i PartIndx Count Total AverageNum AverageIndx
  local    Part AverageText CountText
  #
  for CommandText in ${!CommandLineFormatGroupCount[*]}
  do
    #
    AccumulatorIndex="${CommandText}%e"
    #
    if [ "${Accumulator[${AccumulatorIndex}]+IS_SET}" = "IS_SET" ]
    then
       #
       Count=0
       Total=0
       #
       for Part in ${Accumulator[${AccumulatorIndex}]}
       do
         #
         PartIndx=$((${#Part} - 3))
         #
         if [ ${Part:0:${PartIndx}} -gt 0 ]
         then
            Total+=${Part:0:${PartIndx}}${Part:$((${PartIndx}+1))}
         else
            Total+=${Part:$((${PartIndx}+1))}
         fi
         #
         Count+=1
         #
       done
       #
       if [ "${Calculation[${AccumulatorIndex}_Total]+IS_SET}" = "IS_SET" ]
       then
          Calculation[${AccumulatorIndex}_Count]+=${Count}
          Calculation[${AccumulatorIndex}_Total]+=${Total}
       else
          Calculation[${AccumulatorIndex}_Count]=${Count}
          Calculation[${AccumulatorIndex}_Total]=${Total}
       fi
       #
    fi
    #
  done
  #
  #  Generate reportable data.
  #
  printf "%6s %6s  %s\n" "  Mean" "Sample" "Command"
  printf "%6s %6s  %s\n" "======" "======" "======="
  #
  for CommandText in ${!CommandLineFormatGroupCount[*]}
  do
    #
    #  Calculate average elapsed time.
    #
    AccumulatorIndex="${CommandText}%e"
    #
    if [ "${Accumulator[${AccumulatorIndex}]+IS_SET}" = "IS_SET" ]
    then
       #
       Count=${Calculation[${AccumulatorIndex}_Count]}
       Total=${Calculation[${AccumulatorIndex}_Total]}
       #
       AverageNum=$((${Total} / ${Count}))
       #
       AverageIndx=$((${#AverageNum} - 2))
       #
       AverageText=$(__PadLeft 6 $(__FixPoint "${AverageNum:0:${AverageIndx}}" "${AverageNum:${AverageIndx}}"))
       #
       CountText="$(__PadLeft 6 ${Count})"
       #
    else
       #
       AverageText="$(__PadLeft 6 0.0)"
       #
       CountText="$(__PadLeft 6 0)"
       #
    fi
    #
    printf "%s %s  %s\n" "${AverageText}" "${CountText}" ${CommandText/${Uniquer}//}
    #
  done | sort --key=1,1 --numeric --reverse
  #
  printf "%6s %6s  %s\n" "======" "======" "======="
  #
}

#----------------------------------------------------------------------------------------------------------------------

TimeframeMain ${*}

#----------------------------------------------------------------------------------------------------------------------
