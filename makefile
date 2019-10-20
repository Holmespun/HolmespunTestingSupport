#----------------------------------------------------------------------------------------------------------------------
#
#  HolmespunLibraryBashing/makefile
#
#	Supports testing and installation of the items in the HolmespunLibraryBashing repository.
#
#  Copyright 2019 Brian G. Holmes
#
#	This program is part of the Holmespun Makefile Method.
#
#	The Holmespun Makefile Method is free software: you can redistribute it and/or modify it under the terms of the
#	GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#
#	The Holmespun Makefile Method is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
#	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
#	Public License for more details.
#
#	You should have received a copy of the GNU General Public License along with this program.  If not, see
#	<https://www.gnu.org/licenses/>.
#
#  See the COPYING.text file for further information.
#
#  20190907 BGH; created.
#
#----------------------------------------------------------------------------------------------------------------------

QUIET		?= @
#QUIET		?= 

#----------------------------------------------------------------------------------------------------------------------

.PHONY :	install test

#----------------------------------------------------------------------------------------------------------------------

test :
	@echo "make $@"
	$(QUIET) PATH+=":${PWD}/bin" kamaji fast export makefile
	$(QUIET) PATH+=":${PWD}/bin" $(MAKE) --file=Working/.kamaji.make kamaji-grade

#----------------------------------------------------------------------------------------------------------------------

test-slow :
	@echo "make $@"
	$(QUIET) PATH+=":${PWD}/bin" kamaji grade

#----------------------------------------------------------------------------------------------------------------------

install :
	@echo "make $@"
	$(QUIET) Support/INSTALL.bash

#----------------------------------------------------------------------------------------------------------------------
#  (eof)
