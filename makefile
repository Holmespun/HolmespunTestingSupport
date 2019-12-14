#----------------------------------------------------------------------------------------------------------------------
#
#  HolmespunLibraryBashing/makefile
#
#	Supports testing and installation of the items in the HolmespunLibraryBashing repository.
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

QUIET		?= @
#QUIET		?= 

#----------------------------------------------------------------------------------------------------------------------

.PHONY :	install test

#----------------------------------------------------------------------------------------------------------------------

test-fast :
	@echo "make $@"
	$(QUIET) PATH+=":${PWD}/bin" kamaji fast silent export makefile
	$(QUIET) PATH+=":${PWD}/bin" $(MAKE) --file=Working/.kamaji.make --no-print-directory kamaji-output --jobs -l $(shell nproc --all)
	$(QUIET) PATH+=":${PWD}/bin" $(MAKE) --file=Working/.kamaji.make --no-print-directory kamaji-delta  --jobs -l $(shell nproc --all)
	$(QUIET) PATH+=":${PWD}/bin" kamaji fast silent grade

#----------------------------------------------------------------------------------------------------------------------

test-as-directed :
	@echo "make $@"
	$(QUIET) PATH+=":${PWD}/bin" kamaji fast silent export makefile
	$(QUIET) PATH+=":${PWD}/bin" $(MAKE) --file=Working/.kamaji.make --no-print-directory kamaji-output 
	$(QUIET) PATH+=":${PWD}/bin" $(MAKE) --file=Working/.kamaji.make --no-print-directory kamaji-delta  
	$(QUIET) PATH+=":${PWD}/bin" kamaji fast silent grade

#----------------------------------------------------------------------------------------------------------------------

test : test-as-directed

#----------------------------------------------------------------------------------------------------------------------

spell-check:
	@echo "make $@"
	$(QUIET) find . -type f | grep -v -E "\.git/|Working/" | xargs wordsNotKnown

#----------------------------------------------------------------------------------------------------------------------

install :
	@echo "make $@"
	$(QUIET) Support/INSTALL.bash

#----------------------------------------------------------------------------------------------------------------------
#  (eof)
