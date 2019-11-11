#!/bin/bash
#----------------------------------------------------------------------------------------------------------------------
#
#  HolmespunTestingSupport/Support/INSTALL.bash
#
#	Installs items in the HolmespunTestingSupport repository.
#
#  20190908 BGH; created.
#
#----------------------------------------------------------------------------------------------------------------------
#
#  Copyright (c) 2019 Brian G. Holmes
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
set -e

source $(whereHolmespunLibraryBashing)/Library/installHolmespunSoftware.bash

#----------------------------------------------------------------------------------------------------------------------

function INSTALL() {
  #
  local -r GivenUsrBinDSpec=${1-/usr/bin}
  local -r GivenOptHpsDSpec=${2-/opt/holmespun}
  #
  installHolmespunSoftware ${GivenUsrBinDSpec} ${GivenOptHpsDSpec} HolmespunTestingSupport Library Utility .bash.conf
  #
}

#----------------------------------------------------------------------------------------------------------------------

INSTALL ${*}

#----------------------------------------------------------------------------------------------------------------------
