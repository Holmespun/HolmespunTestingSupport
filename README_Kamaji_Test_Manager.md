# Kamaji Test Manager

Kamaji manages a work-flow for test programs.
Its primary purposes are to assign a pass-fail grade to each test,
and to revise that grade when new information is avalable.
Its secondary purpose is fulfill its primary purpose in a way that makes generating test results easy.

## Overview

Kamaji is designed for users who believe in automated regression testing, test-driven development, and
the use of the demonstrative output paradigm.
Automated regression testing and a wide test base introduces confidence into the otherwise uncertain practice of
software modification.
Test-driven development allows the developer to measure the impact of every modification made.
Use of the demonstrative output paradigm casts a wide net that can detect small and unexpected impacts.

Tests that generate demonstrative output require the user to review and approve baseline test results.
Baselined test results should be produced by the same test every time it is invoked.
Matching test results are granted a passing grade.
Mismatchng test results can demonstrate impacts that may be possitive or negative.
The user may review and approve new test results to redefine the baseline.

Given a test program, Kamaji can be used to perform the following:
1. Compile the program by issuing a make command, if necessary;
1. Run the program to generate *current* output;
1. Mask the output to hide non-deterministic values (e.g. dates and times);
1. Compare the masked current output to the masked baseline output;
1. Grant a passing grade if the current output matches the baseline;
1. Help the user review differences between current and baseline output;
1. Help the user redefine the baseline as the current output after it has been reviewed.

Test programs can be defined as compilable code, scripts, or Command-Line Utility Test (CLUT) scripts.

Given a set of test programs, Kamaji can:
1. Detect additions or subtractions from the test set automatically;
1. Detect changes to the baseline output and re-grade accordingly;
1. Re-generate a target iff one of its sources has changed;
1. Grade one or more of the tests upon request;
1. Do so in an order based on the most recently modified test first;
1. Assist user-review of every test that failed;
1. Allow the user to redefine that baseline of every test that was reviewed.

Test grades are not stored.
Grades are reported explictly every time they are requested.

In addition, Kamaji allows the user to:
1. Export and import a rule-set for faster execution;
1. Export a makefile that can be used to incorporate Kamaji into an existing work-flow;
1. Define the commands used to perform output reviews (e.g. diff, vimdiff).

### Related Articles

TBD

### Modification History

* 2019-09-02 BGH; Initial version.

### Demonstrative Output Paradigm

Test code should not be trusted to determine its own pass-fail status.
Test programs are notoriously buggy because they are written in relative haste.
Software engineers test their software because they know that mistakes will be made during development,
and they want to catch those mistakes as soon as possible.

Test programs are much more likely to contain errors than well-developed code,
and those errors are less likely to be caught because tests of test programs are rare.
As such, test programs should produce output that describes the data as it flows through them,
including inputs and intermdiate data, so that the developer (and subsequent developers) can see what assumptions were 
made, what data conversions occurred, and all of the impacts that the tested program had on that data.

The output should be is evaluated and approved by a human.
If the report is determined to be correct then it should become the definitive result;
it should be declared the baseline output.
Outputs produced by the same test in the future will only be
automatically judged to be a success if and when they do **not** differ from the baseline.


## Copyright 2019 Brian G. Holmes

This README file is part of the Holmespun Testing Support repository.

The Holmespun Testing Support repository contains free software:
you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any later version.

The Holmespun Testing Support repository is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.
If not, see [<https://www.gnu.org/licenses/>](<https://www.gnu.org/licenses/>).

See the [COPYING.text](COPYING.text) file for further licensing information.

**(eof)**