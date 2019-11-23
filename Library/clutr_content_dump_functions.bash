#----------------------------------------------------------------------------------------------------------------------
###
###		Bash/Library/clutr_content_dump_functions.bash
###
###  @file
###  @author	Brian G. Holmes
###  @copyright	GNU General Public License
###  @brief	Command-Line Utility Test (CLUT) run-time support functions.
###  @remark	This file is sourced by the clutr.bash script.
###
#----------------------------------------------------------------------------------------------------------------------
#
#  20180219 BGH; created based on past work.
#  20180314 BGH; added __clutCaseRunTimeDumpPrecompiledHeader function.
#  20180315 BGH; added __clutCaseRunTimeDumpObjectFile function.
#  20190411 BGH; added SQLite database file handling functions.
#  20190707 BGH; moved to the HolmespunTestingSupport repository.
#  20191017 BGH; using improved SQLite database dump.
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
###
###  @fn	__clutCaseRunTimeDumpUnknown
###  @param	TargetFSpec	The specification for the target file.
###  @param	TargetFType	The file/content type of the target file.
###  @brief	Displays meta-data about a file whose content is unknown.
###
#----------------------------------------------------------------------------------------------------------------------

function __clutCaseRunTimeDumpUnknown() {
  #
  local -r TargetFSpec="${1}"
  local -r TargetFType="${2}"
  #
  local -r MimeType=$(file --mime "${TargetFSpec}" | sed --expression='s,.*: ,,')
  #
# local -r Checksum=$(md5sum "${TargetFSpec}" | sed --expression='s, .*,,')
  #
  echo "<meta> Data file type (${TargetFType}) without well-defined dump handler."
  echo "<meta> The file utility describes its MIME type as \"${MimeType}\""
# echo "<meta> The file has an md5sum of ${Checksum}."
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	__clutCaseRunTimeDumpTextPlain
###  @param	TargetFSpec	The specification for the target file.
###  @brief	Displays the contents of a plain text file.
###
#----------------------------------------------------------------------------------------------------------------------

function __clutCaseRunTimeDumpTextPlain() {
  #
  local -r TargetFSpec="${1}"
  #
  cat "${TargetFSpec}"
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	__clutCaseRunTimeDumpTextTabSeparatedValues
###  @param	TargetFSpec	The specification for the target file.
###  @brief	Displays the contents of a text file that contains data in Tab-Separated Value (TSV) format.
###  @remark	The tabs are changed to spaced to make the data display more easily.
###
#----------------------------------------------------------------------------------------------------------------------

function __clutCaseRunTimeDumpTextTabSeparatedValues() {
  #
  local -r TargetFSpec="${1}"
  #
  cat "{TargetFSpec}" | sed --expression='s,\t, ,g'
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	__clutCaseRunTimeDumpGzip
###  @param	TargetFSpec	The specification for the target file.
###  @brief	Displays meta-data about a file whose content is compressed using gzip format.
###  @remark	See https://en.wikipedia.org/wiki/Gzip
###
#----------------------------------------------------------------------------------------------------------------------

function __clutCaseRunTimeDumpGzip() {
  #
  local -r TargetFSpec="${1}"
  #
# local -r Checksum=$(md5sum "${TargetFSpec}" | sed --expression='s, .*,,')
  #
  echo "<meta> Gzip file."
  #
# echo "<meta> The file has an md5sum of ${Checksum}."
  #
  echo "<meta> The archive contains the following files..."
  #
  gunzip --list "${TargetFSpec}" | sed --expression='s,^,<meta>     ,'
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	__clutCaseRunTimeDumpImageFile
###  @param	TargetFSpec	The specification for the target file.
###  @brief	Displays meta-data about a file whose content is an image.
###
#----------------------------------------------------------------------------------------------------------------------

function __clutCaseRunTimeDumpImageFile() {
  #
  local -r TargetFSpec="${1}"
  #
# local -r Checksum=$(md5sum "${TargetFSpec}" | sed --expression='s, .*,,')
  #
  echo "<meta> Image file:$(file ${TargetFSpec} | sed --expression='s,.*:,,')."
  #
# echo "<meta> The file has an md5sum of ${Checksum}."
  #
  echo "<meta> No further information available."
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	__clutCaseRunTimeDumpImageFile
###  @param	TargetFSpec	The specification for the target file.
###  @brief	Displays meta-data about a file whose content is compiled object or archive of compiled objects.
###
#----------------------------------------------------------------------------------------------------------------------

function __clutCaseRunTimeDumpObjectFile() {
  #
  local -r TargetFSpec="${1}"
  #
  echo "<meta> Object (compiler output) or Object Archive (ar output) file."
  #
  echo "<meta> The file contains the following symbolic information..."
  #
  nm ${TargetFSpec} | sed --expression='s,^,<meta>     ,'
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	__clutCaseRunTimeDumpPrecompiledHeader
###  @param	TargetFSpec	The specification for the target file.
###  @brief	Describes the contents of a file that contains a GCC pre-compiled header.
###
#----------------------------------------------------------------------------------------------------------------------

function __clutCaseRunTimeDumpPrecompiledHeader() {
  #
  local -r TargetFSpec="${1}"
  #
  echo "<meta> Pre-Compiled header file."
  #
  echo "<meta> No information can be extracted."
  #
}

#----------------------------------------------------------------------------------------------------------------------

function __echoSqliteTableSchema() {
  #
  local -r DatabaseFSpec="${1}"
  local -r TableNameItem="${2}"
  #
  sqlite3 ${DatabaseFSpec} ".schema ${TableNameItem}"					\
		| tr '[[:cntrl:]]' ' '							\
		| sed --expression='s,[[:space:]][[:space:]]*, ,g'			\
		      --expression='s/([[:space:]]*\([[:alpha:]]\)/\n       ( \1/'	\
		      --expression='s/,[[:space:]]*\([[:alpha:]]\)/\n       , \1/g'	\
		      --expression='s/;[[:space:]]/;\n/g'
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	__clutCaseRunTimeDumpSqliteDatabaseExpose
###  @param	TargetFSpec	The specification for the target database file.
###  @brief	Describes the schema and contents of tables that are defined in an SQLite database file.
###
#----------------------------------------------------------------------------------------------------------------------

function __clutCaseRunTimeDumpSqliteDatabaseExpose() {
  #
  local -r DatabaseFSpec="${1}"
  #
  local -r TableNameList=$(sqlite3 ${DatabaseFSpec} ".tables" | xargs printf '%s\n' | sort)
  #
  local    TableNameItem
  #
  local -A TableRowCount
  local -i TotalRowCount=0
  #
  local -i SizeWidth=1
  local    TextCount
  #
  for TableNameItem in ${TableNameList}
  do
    #
    TextCount=$(sqlite3 ${DatabaseFSpec} "SELECT COUNT(rowid) FROM ${TableNameItem};")
    #
    [ ${#TextCount} -gt ${SizeWidth} ] && SizeWidth=${#TextCount}
    #
    TableRowCount[${TableNameItem}]=${TextCount}
    #
    TotalRowCount+=${TextCount}
    #
  done
  #
  if [ ${TotalRowCount} -eq 0 ]
  then
     #
     echo "Empty"
     #
     return
     #
  fi
  #
  echo "Table sizes..."
  #
  for TableNameItem in ${TableNameList}
  do
    #
    printf "    %${SizeWidth}u %s\n" ${TableRowCount[${TableNameItem}]} ${TableNameItem}
    #
  done
  #
  echo
  #
  for TableNameItem in ${TableNameList}
  do
    #
    if [ ${TableRowCount[${TableNameItem}]} -gt 0 ]
    then
       #
       __echoSqliteTableSchema ${DatabaseFSpec} ${TableNameItem}
       #
       echo
       #
       sqlite3 -header ${DatabaseFSpec} "SELECT * FROM ${TableNameItem};"
#      sqlite3 -column -header ${DatabaseFSpec} "SELECT * FROM ${TableNameItem};"
       #
       echo
       #
    fi
    #
  done
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	__clutCaseRunTimeDumpSqliteDatabaseHidden
###  @param	TargetFSpec	The specification for the target database file.
###  @brief	Describes the schema of tables that are defined in an SQLite database file.
###
#----------------------------------------------------------------------------------------------------------------------

function __clutCaseRunTimeDumpSqliteDatabaseHidden() {
  #
  local -r DatabaseFSpec="${1}"
  #
  for Table in $(sqlite3 ${DatabaseFSpec} ".tables" | xargs printf '%s\n' | sort)
  do
    #
    __echoSqliteTableSchema ${DatabaseFSpec} ${Table}
    #
    echo
    echo -n "Table record count: "
    #
    sqlite3 ${DatabaseFSpec} "SELECT COUNT(rowid) FROM ${Table};"
    #
    echo
    #
  done
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	__clutCaseRunTimeDumpSqliteDatabaseMasked
###  @param	TargetFSpec	The specification for the target database file.
###  @brief	Describes the schema and masked contents of tables that are defined in an SQLite database file.
###
#----------------------------------------------------------------------------------------------------------------------

function __clutCaseRunTimeDumpSqliteDatabaseMasked() {
  #
  __clutCaseRunTimeDumpSqliteDatabaseExpose ${*} | sed	--expression='s,[0-9+-][0-9\.]*|,NUMBER|,g'	\
							--expression='s,|[0-9+-][0-9\.]*,|NUMBER,g'	\
							--expression='s,[0-9],N,g'
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	__clutCaseRunTimeDumpZip
###  @param	TargetFSpec	The specification for the target file.
###  @brief	Displays meta-data about a file whose content is compressed using zip format.
###  @remark	See https://en.wikipedia.org/wiki/Zip_(file_format)
###
#----------------------------------------------------------------------------------------------------------------------

function __clutCaseRunTimeDumpZip() {
  #
  local -r TargetFSpec="${1}"
  #
# local -r Checksum=$(md5sum "${TargetFSpec}" | sed --expression='s, .*,,')
  #
  echo "<meta> Zip file."
  #
# echo "<meta> The file has an md5sum of ${Checksum}."
  #
  echo "<meta> The archive contains the following files..."
  #
  unzip -l "${TargetFSpec}" | sed --expression='s,^,<meta>     ,'
  #
}

#----------------------------------------------------------------------------------------------------------------------
###
###  @fn	clutFileRunTimeDumpFormatRegistrationStandard
###  @brief	Registers standard dump functions for well-known content types.
###  @remark	Calls the clutFileRunTimeDumpFormatRegistration function to perform each registration.
###
#----------------------------------------------------------------------------------------------------------------------

function clutFileRunTimeDumpFormatRegistrationStandard() {
  #
  clutFileRunTimeDumpFormatRegistration	BASH		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	C		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	C++		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	CC		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	CHANGES		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	CLUT		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	CONF		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	CPP		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	CSS		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	CSV		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	DELTA		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	DIFF		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	FA		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	FAI		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	FASTA		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	FASTQ		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	FQ		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	H		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	H++		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	HH		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	HMMCPP		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	HMMHPP		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	HPP		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	HTML		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	JS		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	JSON		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	LOG		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	MAKE		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	MAKEFILE	__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	MASKED		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	OUT		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	OUTPUT		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	PY		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	SECONDS		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	SED		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	SH		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	TEXT		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	TXT		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	XML		__clutCaseRunTimeDumpTextPlain
  clutFileRunTimeDumpFormatRegistration	YAML		__clutCaseRunTimeDumpTextPlain
  #
  clutFileRunTimeDumpFormatRegistration GIF		__clutCaseRunTimeDumpImageFile
  clutFileRunTimeDumpFormatRegistration JPEG		__clutCaseRunTimeDumpImageFile
  clutFileRunTimeDumpFormatRegistration JPG		__clutCaseRunTimeDumpImageFile
  clutFileRunTimeDumpFormatRegistration PNG		__clutCaseRunTimeDumpImageFile
  #
  clutFileRunTimeDumpFormatRegistration SQLITE		__clutCaseRunTimeDumpSqliteDatabaseExpose
  clutFileRunTimeDumpFormatRegistration SQLITE_EXPOSE	__clutCaseRunTimeDumpSqliteDatabaseExpose
  #
  clutFileRunTimeDumpFormatRegistration SQLITE_EXTERNAL	__clutCaseRunTimeDumpSqliteDatabaseHidden
  clutFileRunTimeDumpFormatRegistration SQLITE_HIDDEN	__clutCaseRunTimeDumpSqliteDatabaseHidden
  clutFileRunTimeDumpFormatRegistration SQLITE_HIDE	__clutCaseRunTimeDumpSqliteDatabaseHidden
  #
  clutFileRunTimeDumpFormatRegistration SQLITE_MASKED	__clutCaseRunTimeDumpSqliteDatabaseMasked
  #
  clutFileRunTimeDumpFormatRegistration	A		__clutCaseRunTimeDumpObjectFile
  clutFileRunTimeDumpFormatRegistration	BED		__clutCaseRunTimeDumpTextTabSeparatedValues
  clutFileRunTimeDumpFormatRegistration	GCH		__clutCaseRunTimeDumpPrecompiledHeader
  clutFileRunTimeDumpFormatRegistration	GZIP		__clutCaseRunTimeDumpGzip
  clutFileRunTimeDumpFormatRegistration	O		__clutCaseRunTimeDumpObjectFile
  clutFileRunTimeDumpFormatRegistration	SAM		__clutCaseRunTimeDumpTextTabSeparatedValues
  clutFileRunTimeDumpFormatRegistration	TSV		__clutCaseRunTimeDumpTextTabSeparatedValues
  clutFileRunTimeDumpFormatRegistration	ZIP		__clutCaseRunTimeDumpZip
  #
  clutFileRunTimeDumpFormatRegistration	UNKNOWN		__clutCaseRunTimeDumpUnknown
  #
}

#----------------------------------------------------------------------------------------------------------------------
