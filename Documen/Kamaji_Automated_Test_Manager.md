# Kamaji Automated Test Manager

Kamaji manages a work-flow for test programs.
Its primary purposes are to assign a pass-fail grade to each test,
and to revise that grade when new information is available.
Its secondary purpose is fulfill its primary purpose in a way that makes generating test results easy.

* [Overview](#overview)>
[Related Documentation](#related-documentation)
* [Overview](#overview)>
[Modification History](#modification-history)
* [Overview](#overview)>
[Demonstrative Output Paradigm](#demonstrative-output-paradigm)
* [Overview](#overview)>
[Testing Resources and Derived Works](#testing-resources-and-derived-works)
* [Overview](#overview)>
[Kinds of Testing Resources](#kinds-of-testing-resources)
* [Overview](#overview)>
[Derive Me Crazy](#derive-me-crazy)
* [Overview](#overview)>
[Kamaji, Test Thyself](#kamaji-test-thyself)
* [Overview](#overview)>
[Help](#help)
* [Overview](#overview)>
[Configuration](#configuration)
* [Overview](#overview)>
[General Workflow](#general-workflow)
* [Overview](#overview)>
[Verbosity And Silence](#verbosity-and-silence)
* [Installation](#installation)
* [Best Practices](#best-practices) 

## Overview

Kamaji is designed for users who believe in the use of automated testing, test-driven development, and
the demonstrative output paradigm.
Automated testing and a wide test base introduces confidence into the otherwise uncertain process of
modifying software.
Test-driven development allows the developer to measure the impact of every modification made.
Use of the demonstrative output paradigm casts a wide net that can detect small and unexpected impacts.

Tests that generate demonstrative output require the user to review and approve baseline test results.
Baselined test results should be produced by the same test every time it is invoked.
Matching test results are granted a passing grade.
Mismatching test results can demonstrate impacts that may be positive or negative.
The user may review and approve new test results to redefine the baseline.

Given a test program, Kamaji can be used to perform the following:
1. Compile the program by issuing a make command, if necessary;
1. Run the program to generate *current* output;
1. Mask the output to hide non-deterministic values (e.g. dates and times);
1. Compare the masked current output to the masked baseline output;
1. Grant a passing grade if the current output matches the baseline;
1. Help the user review differences between current and baseline output;
1. Help the user redefine the baseline as the current output after it has been reviewed.

Test programs can be defined as compilable code or scripts.

Given a set of test programs, Kamaji can:
1. Detect additions or subtractions from the test set automatically;
1. Detect changes to the baseline output and re-grade accordingly;
1. Re-generate a target iff one of its sources has changed;
1. Grade one or more of the tests upon request;
1. Do so in an order based on the most recently modified test first;
1. Assist user-review of every test that failed;
1. Allow the user to redefine that baseline of every test that was reviewed.

Test grades are not stored.
Grades are re-calculated and explicitly reported every time they are requested.

In addition, Kamaji allows the user to:
1. Export and import a rule-set for faster execution;
1. Export a makefile that can be used to incorporate Kamaji into an existing development work-flow;
1. Request help for every command and modifier he supports.
1. Request that Kamaji re-create the last target that he created;
1. Define output masking that should be applied to each baseline and current output before they are compared;
1. Define the commands used to perform output reviews (e.g. diff, vimdiff);
1. Declare explicit dependencies that kamaji should track to make sure that its test results are up-to-date;
1. Record execution time and resource utilization for every test it runs in a format defined by the user.


### Related Documentation

* [Kamaji Automated Test Manager Quickstart Guide](Kamaji_Automated_Test_Manager_Quickstart_Guide.md)

* [CLUT Framework](CLUT_Framework.md)

* [CLUT Framework Quickstart Guide](CLUT_Framework_Quickstart_Guide.md)


### Modification History

* 2019-09-02 BGH; Initial version.
* 2019-12-14 BGH; Added related documentation.


### Demonstrative Output Paradigm

Test code should not be trusted to determine its own pass-fail status.
Test programs are notoriously buggy because they are written in relative haste.

Software engineers test their software because they know that mistakes will be made during development
and they want to catch those mistakes as soon as possible.
Test programs are not as well developed as the code they exercise; test programs are more likely to contain errors.
Test program errors are also less likely to be caught because tests for test programs are rare.

Test programs should produce output that describes data as it flows through them,
including input data and intermediate data,
so that the developer (and subsequent developers) can see what assumptions were
made, what data conversions occurred, and all of the impacts that the tested program had on that data.

The resulting output should be is evaluated and approved by a human.
If the output is determined to be correct then it should become the definitive result;
it should be declared the baseline output.
Outputs produced by the same test in the future will only be
automatically judged to be a success if and when they do **not** differ from the baseline.


### Testing Resources and Derived Works

Kamaji needs to know about source code, baseline test output, and some forms of data,
but only if they are *testing resources* that represent CLUT and unit test exercises.
Kamaji does not concern itself with source code that represents the program or programs being tested.
Kamaji uses a *baseline-folder* configuration variable to
represent the directory in which it can find testing resources.
As such, you can most easily configure Kamaji if your testing resources are separate from the programmatic ones;
if they are not separate then you will have to tell Kamaji which files to ignore.

Source code, baseline test output, and some forms of data are golden;
they are worthy of keeping safe in a source repository.
Files that are derived from these things can be derived from them again.
Derived files are only important for a brief time; they represent a snapshot of the current development.
Even derived files that are bundled into a release are only important until the code that they represent is improved.

Kamaji creates derived files in a separate directory called a *working-folder*.
Source code and baseline output files are represented in the working folder using symbolic links;
in this way, the working folder represents a flattened version of the baseline folder.

Use of a separate working folder has several advantages to a developer:
1. Derived files will not clutter the source code hierarchy;
1. There will be fewer files to add to your .gitignore list;
1. There is only one place you need to look for Kamaji output.
1. There is only one file to remove if you want to force Kamaji to generate test data from a clean slate.

The baseline folder may be in a remote location.
The working folder will always be created locally.


### Kinds of Testing Resources

Kamaji views testing resources as being a member of several different classes.
These are the classes of files it expects to find in the baseline-folder:

* **Command-Line Utility Test (CLUT) Script** [\*.clut]:
A special kind of Bash script that uses the CLUT framework.
Kamaji knows to compile these using the [clutc](bin/clutc) program to create a program that can be invoked.

* **Executable and Linkable Format (ELF) Source Code** [\*.cpp]:
Source code that must be compiled and linked to create an ELF file before it can be invoked.
Currently, only C++ code is recognized.
Kamaji will call the *make* command to create ELF files from source code when it needs to;
users may want to provide a testing makefile in the baseline-folder as well.

* **Executable Script** [\*.bash \*.py \*.rb]:
Script files that are executable.
These files should also also start with a hash-bang declaration (e.g. #!/bin/bash).
Scripts can have any file name extension that is declared using the script-type-list configuration variable.
Script files that are not executable will not be invoked by Kamaji, and should be declared *data* files.

* **Output** [\*.output]:
Output files are the that contain the output that a unit test or CLUT should produce every time.
Output files should be named without the extension of the source code or script from which they are derived;
for example, the myunittest.bash script will be associated with the myunittest.output file.

* **Data**:
The Data class is used as a catch-all for files that do not fit into the other classes;
for example, script library, makefile, documentation, and input files.
Data files can be identified explicitly or by file name extension
using the data-filename-list and data-extension-list configuration variables.

Kamaji will represent each of these files in the working-folder using a symbolic link.
These symbolic link representatives allow Kamaji to refer to each file without concern for where they are actually
stored.
Representative link names are the same as those used in the baseline-folder with one exception:
Output files are linked by a file with the *golden* extension instead of an *output* extension;
this is done so that the output extension can be used to store the current output.

As such, files in the baseline-directory have two limitations:
1. ELF source and executable script files must have unique names before their name extensions;
for example mytestprogram.cpp and the executable mytestprogram.bash script cannot be used in the same baseline-folder.
1. The use of the golden file name extension should be avoided.


### Derive Me Crazy

The user does not need to know what the working-folder contains to use Kamaji.
The most important thing about the working-folder is that it can be removed without impacting baseline files.

The working-folder will contain many different files that are derived from the baseline-folder representatives:

* **ELF**:
ELF files are created from ELF source code representatives.
ELF files are created via the make command,
so there may also be object files, library archives, and any number of other intermediate files produced by the
compilation and linking procedure that the user has defined.

* **CLUT Compilation Directory** [\*.clutc.\*]:
The clutc program stores its intermediate data and the executable script it produces in a date-and-time stamped
directory.

* **CLUT Run-Time Directory** [\*.clutr.\*]:
The executable CLUT script produced by the clutc program stores its intermediate data and the output report it
produces in a date-and-time stamped directory.

* **Output** [\*.output]:
The stdout and stderr output of every unit test and CLUT is captured in an output file.

* **Masked** [\*.golden.masked and \*.output.masked]:
Output files are masked to remove data that cannot be compared from run to run;
for example, any form of the current date and time.
The masking procedure is defined by the user.

* **Delta** [\*.output.delta]:
A delta file represents the differences between the masked versions of
a current output file and a baseline output file.
A test will receive a failing grade if its delta file represents any differences.

Also, past copies of files are often renamed with a *was* extension, and incomplete output files are stored in files
with a *partial* extension.


### Kamaji, Test Thyself

Kamaji is used to manage its own testing resources.
At the time of writing, the [Testing](../Testing) directory contained the following:

~~~~
    CLUT_Framework_Quickstart_Guide_exercise.bash
    CLUT_Framework_Quickstart_Guide_exercise.output
    clutc_exercise.bash
    clutc_exercise.output
    kamaji.00.common_functions.bash
    kamaji.00.common_requirements.clut
    kamaji.01.usage.clut
    kamaji.01.usage.clut.output
    kamaji.02.modifiers.clut
    kamaji.02.modifiers.clut.output
    kamaji.03.clut_processing.clut
    kamaji.03.clut_processing.clut.output
    kamaji.04.script_exercise_processing.clut
    kamaji.04.script_exercise_processing.clut.output
    kamaji.05.compiled_exercise_processing.clut
    kamaji.05.compiled_exercise_processing.clut.output
    kamaji.06.export_ruleset.clut
    kamaji.06.export_ruleset.clut.output
    kamaji.07.export_makefile.clut
    kamaji.07.export_makefile.clut.output
    kamaji.08.configuration.clut
    kamaji.08.configuration.clut.output
    kamaji.09.review.clut
    kamaji.09.review.clut.output
~~~~

The CLUT\_Framework\_Quickstart\_Guide\_exercise.bash and clutc\_exercise.bash files are executable.

The *exercise* scripts are unit tests;
one of them generates markdown format output that is the
[CLUT Framework Quickstart Guide](CLUT_Framework_Quickstart_Guide.md).
The CLUT files contain test cases that exercise the Kamaji program.

The working-folder created for these testing resources contains well over a hundred files.
Here are the derived files for the clutc\_exercise.bash and clutc\_exercise.output files:

~~~~
    clutc_exercise.bash
    clutc_exercise.golden
    clutc_exercise.golden.masked
    clutc_exercise.output
    clutc_exercise.output.delta
    clutc_exercise.output.masked
~~~~

Here are the derived files for the kamaji.09.review.clut and kamaji.09.review.clut.output files:

~~~~
    kamaji.09.review.clut
    kamaji.09.review.clut.bash
    kamaji.09.review.clut.golden
    kamaji.09.review.clut.golden.masked
    kamaji.09.review.clut.output
    kamaji.09.review.clut.output.delta
    kamaji.09.review.clut.output.masked
    kamaji.09.review.clutc.20191031_142504_3343
    kamaji.09.review.clutr
    kamaji.09.review.clutr.20191031_142505_5545
~~~~

The kamaji.09.review.clut.bash script is a symbolic link to a file in the
kamaji.09.review.clutc.20191031\_142504\_3343 directory.
The kamaji.09.review.clutr file is a symbolic link to the kamaji.09.review.clutr.20191031\_142505\_5545 directory;
it is a shortcut to the workspace that was used the last time the kamaji.09.review.clut.bash script was invoked.

### Help

Kamaji can provide help information upon request.
At the time of writing, a general request for help looked like this:

~~~~
    USAGE: kamaji [<modifier>]... [<request>] [<parameter>]...

    Where <modifier> is one of the following:
          fast
          help
          silent
          verbose

    Where <request> is one of the following:
          bless  [ <filename> | last ]...
          delta  [ <filename> | last ]...
          export [ makefile | ruleset ]
          grade  [ <filename> | last ]...
          invoke [ <filename> | last ]...
          make   [ <filename> | last | grades | outputs ]...
          review [ <filename> | last ]...
          set    <name> <value>
          show   [ configuration [ names | variables ] | copyright | version ]

    Synonyms compare (delta), configure (set), noisy (verbose), pre-grade (delta),
    quiet (silent), and usage (help) are supported. Modifier and request
    abbreviations are also supported; ambiguity is resolved using alphabetical
    order. No other modifiers or requests are applied after a help request is
    fulfilled.

    Specific usage may be displayed by following a help request by the subject of
    interest; for example, "kamaji help fast" or "kamaji help grade"

    CLUT cases and unit test exercises are used and evaluated in similar ways:
    compile it (if not already executable), invoke it to produce output, mask that
    output, compare the masked output to its baseline, and then grade it based on
    that comparison.

    CLUT definitions are compiled into Bash scripts. Unit test exercises may be
    written in compilable code or a scripting language. Compilable code must be
    compiled and linked into executable files using a make framework. Scripts need
    not be compiled.

    CLUT cases and unit test exercises produce demonstrative output that need not
    be valid or invalid on its face. Users must evaluate the initial output from
    these tests to determine whether it is valid; valid output must be blessed by
    the user and copied to a safe location as baseline output. Future changes to
    the tested code will result in output that differs from the baseline; these
    differences should also be blessed to update the baseline. Users will benefit
    from retesting frequently between minor and controlled functional changes to
    the code being tested.

    Passing grades are only granted when current output matches baseline output,
    but this matching is only attempted after the current and baseline output are
    masked. Masking is performed using a user-defined sed script.

    Copyright (c) 2019 Brian G. Holmes.
~~~~


### Configuration

Kamaji uses three configuration files, if they are available:

* **.kamaji.conf**: Contains name-value pairs for configuration variables that are used by Kamaji at run time.

* **.kamaji.deps**: Contains source-dependent pairs that associate two testing resources.

* **.kamaji.sed**: Contains a *sed* command script that is used to mask output files.

At the time of writing, each of the following variables could be defined in the .kamaji.conf file:

~~~~
    $ kamaji show conf names
    baseline-folder
    data-extension-list
    data-filename-list
    last-target-filename
    long-review-command
    long-review-line-count
    long-review-tailpipe
    makefile-filename
    mask-sed-script
    new-review-command
    new-review-tailpipe
    ruleset-filename
    script-type-list
    short-review-command
    short-review-tailpipe
    time-output-format
    verbosity-level
    working-folder
~~~~

Please issue a *kamaji help configuration* request for a description of how each variable is used.

The repository
[.kamaji.conf](../.kamaji.conf),
[.kamaji.deps](../.kamaji.deps), and
[.kamaji.sed](../.kamaji.sed) are good examples of how you might use each kind of configuration file.


### General Workflow

With your testing resources in place, and your configuration properly set,
the general workflow is as follows:
1. Grade one test or all of them. Kamaji will compile, invoke, mask, and compare files as it needs to.
1. If all of your tests passed then you are done; otherwise...
1. Review one or all of the tests that failed.  Kamaji will remember which ones you reviewed.
1. Bless the current output (use it to re-define the baseline)
   of one or all of the tests that failed if you feel that the current output is more accurate than the baseline.

If you were forced to make corrections during the process above,
then be sure to issue a general *kamaji grade* request to make sure that the impact of your changes are measured by
all of your test cases.


### Verbosity And Silence

When you make a request, the information display by Kamaji is controlled by
the verbosity-level configuration variable,
and the use of the *verbose* and *silent* modifiers on the command line.
The silent modifier overrides the verbosity-level configuration
and any verbose modifiers that precede it on the command line.
The verbose modifier builds upon the verbosity-level configuration
and any silent or verbose modifiers that precede it on the command line.

A verbosity-level of *quiet* or the silent modifier will cause Kamaji to display no more information than it needs to
in order to fulfill your request; only error messages or grades if they apply.

~~~~
    $ kamaji fast silent grade kamaji.01.usage.clut
    PASS: kamaji.01.usage.clut.output.grade
~~~~

A verbosity-level of *light* or a single verbose modifier will cause Kamaji to display requests as it attempts to
fulfill them.

~~~~
    $ kamaji fast silent verbose grade kamaji.01.usage.clut
    kamaji export ruleset
    kamaji make kamaji.01.usage.clut.golden.masked
    kamaji make kamaji.01.usage.clut.bash
    kamaji make kamaji.01.usage.clut.output
    kamaji make kamaji.01.usage.clut.output.masked
    kamaji make kamaji.01.usage.clut.output.delta
    kamaji make kamaji.01.usage.clut.output.grade
    PASS: kamaji.01.usage.clut.output.grade
~~~~

A verbosity-level of *heavy*, or a verbosity-level of *light* with a single verbose modifier,
or multiple verbose modifiers
will cause Kamaji to display requests and system commands as it attempts to fulfill them, as well as comment upon why
they were necessary.

~~~~
    $ kamaji fast silent ver verbose grade kamaji.01.usage.clut
    # Building rules based on baseline files...
    #       Testing/kamaji.00.common_functions.bash
    #       Testing/kamaji.01.usage.clut
    #       Testing/kamaji.01.usage.clut.output
    .
    . <snip>
    .
    kamaji export ruleset
    ln --symbolic ../.kamaji.sed .kamaji.sed
    ln --symbolic ../Testing/kamaji.00.common_functions.bash kamaji.00.common_functions.bash
    ln --symbolic ../Testing/kamaji.01.usage.clut kamaji.01.usage.clut
    ln --symbolic ../Testing/kamaji.01.usage.clut.output kamaji.01.usage.clut.golden
    ln --symbolic ../bin/kamaji kamaji
    .
    . <snip>
    .
    echo "kamaji.01.usage.clut.output.grade" > Working/.kamaji.last_target.text
    # GT Working/kamaji.01.usage.clut.golden.masked does not exist
    kamaji make kamaji.01.usage.clut.golden.masked
    sed --file=.kamaji.sed kamaji.01.usage.clut.golden > kamaji.01.usage.clut.golden.masked.partial
    mv kamaji.01.usage.clut.golden.masked.partial kamaji.01.usage.clut.golden.masked
    # GT Working/kamaji.01.usage.clut.bash does not exist
    kamaji make kamaji.01.usage.clut.bash
    clutc kamaji.01.usage.clut ../bin/kamaji kamaji.01.usage.clut.bash
    # GT Working/kamaji.01.usage.clut.output does not exist
    kamaji make kamaji.01.usage.clut.output
    kamaji.01.usage.clutc.20191101_111846_2547/00.compiled.bash > kamaji.01.usage.clut.output.partial 2>&1
    mv kamaji.01.usage.clut.output.partial kamaji.01.usage.clut.output
    # GT Working/kamaji.01.usage.clut.output.masked does not exist
    kamaji make kamaji.01.usage.clut.output.masked
    sed --file=.kamaji.sed kamaji.01.usage.clut.output > kamaji.01.usage.clut.output.masked.partial
    mv kamaji.01.usage.clut.output.masked.partial kamaji.01.usage.clut.output.masked
    # GT Working/kamaji.01.usage.clut.output.delta does not exist
    kamaji make kamaji.01.usage.clut.output.delta
    diff --text --ignore-space-change kamaji.01.usage.clut.golden.masked kamaji.01.usage.clut.output.masked > kamaji.01.usage.clut.output.delta 2>&1
    # GT Working/kamaji.01.usage.clut.output.grade does not exist
    kamaji make kamaji.01.usage.clut.output.grade
    PASS: kamaji.01.usage.clut.output.grade
~~~~

By default, the PASS prefix of a grade is colored green, the FAIL prefix of a grade is colored red,
and heavy diagnostic output is colored blue.
Colors can be disabled by assigning the HOLMESPUN\_MONOCHROMATIC variable any value.

The examples above were each generated after removing the working-folder.


## Installation

Installation must be done by cloning two Holmespun repositories:

1. Clone the repositories.

    ~~~~bash
    git clone https://github.com/Holmespun/HolmespunLibraryBashing.git
    git clone https://github.com/Holmespun/HolmespunTestingSupport.git
    ~~~~

1. Give yourself temporary access to the utilities in each of these repositories.
You do not want this addition to the PATH variable to be active after the repository is installed.

    ~~~~bash
    export PATH=${PWD}/HolmespunLibraryBashing/bin:${PATH}
    export PATH=${PWD}/HolmespunTestingSupport/bin:${PATH}
    ~~~~

1. [Optional] Import variable and alias definitions for use with the utilities.
You may want to add these commands to the Bash configuration file you use (i.e. $HOME/.bashrc or $HOME/.bash\_profile).
The *where* commands allow you to avoid hard-coding the repository location,
and apply before and after installation.

    ~~~~bash
    source $(whereHolmespunLibraryBashing)/.bash.conf
    source $(whereHolmespunTestingSupport)/.bash.conf
    ~~~~

1. [Optional] Verify that the utility and library code will work properly in your environment.
All unit test and CLUT scripts should pass.

    ~~~~bash
    cd HolmespunLibraryBashing
    make test
    cd ..
    cd HolmespunTestingSupport
    make test-fast
    cd ..
    ~~~~

1. Install the repositories.
After installation, each repository will be represented in the /opt/holmespun directory,
and each of its utilities will be represented in the /usr/bin directory.
An UNINSTALL.bash script will also be created in each of the new /opt/holmespun subdirectories.

    ~~~~bash
    cd HolmespunLibraryBashing
    sudo make install
    cd ..
    cd HolmespunTestingSupport
    sudo make install
    cd ..
    ~~~~

1. Remove the repository clones.

    ~~~~bash
    moveToGarbage HolmespunLibraryBashing
    moveToGarbage HolmespunTestingSupport
    ~~~~


## Best Practices

1. Use the moveToGarbage utility to remove the working-folder.
It costs very little to keep files around until you **know** they are not needed.

1. Source the [.bash.conf](../.bash.conf) file or define your own aliases for the kamaji requests you use most often.
One-word aliases allow easy use of the bang-splat (!\*) command-line shortcut
to apply a different request to the same target.

1. Refer to targets using the working-folder name.
Kamaji will remove any directory path information from your target name before attempting to process it.
    * You can use the filename tab autocomplete keyboard shortcut if you are specifying a file that already exists.
    * You can use wildcard characters to specify a group of tests.

1. Save yourself some keystrokes by abbreviating Kamaji requests and modifiers.

1. Define the review configuration variables to suit your style.


## Copyright 2019 Brian G. Holmes

This documentation is part of the Holmespun Testing Support repository.

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
