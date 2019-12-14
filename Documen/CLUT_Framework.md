# Command-Line Utility Test Framework

The Command-Line Utility Test (CLUT) Framework allows users to
test command-line programs using a series of test cases that are executed in an isolated directory
with user-defined inputs and command-line parameters.
CLUT cases exercise a utility/program as it is invoked from the command-line.
As such, they exercise software interfaces and integration aspects in ways that class and functional unit tests cannot.
The CLUT framework supports test-driven development in an interactive prototyping development process.

* [Modification History](#modification-history)
* [Overview](#overview)>
[Demonstrative Output](#demonstrative-output)
* [Overview](#overview)>
[Test Case Phases Five](#test-case-phases-five)
* [Overview](#overview)>
[Test Cases Workspaces Alpha and Omega](#test-cases-workspaces-alpha-and-omega)
* [Overview](#overview)>
[Test Case Definition Sets](#test-case-definition-sets)
* [Overview](#overview)>
[Initializations](#initializations)
* [Overview](#overview)>
[Finalizations](#finalizations)
* [Overview](#overview)>
[Initialization Scopes](#initialization-scopes)
* [Overview](#overview)>
[Finalization Scopes](#finalization-scopes)
* [Overview](#overview)>
[Comparable Masks](#comparable-masks)
* [Examples](#examples)>
[Global Information](#global-information)
* [Examples](#examples)>
[Test Case Report](#test-case-report)
* [Examples](#examples)>
[Test Case Definition](#test-case-definition)
* [Examples](#examples)>
[Working Directory Artifacts](#working-directory-artifacts)
* [Framework Functions](#framework-functions)>
[clut_case_begin](#clut_case_begin)
* [Framework Functions](#framework-functions)>
[clut_case_comment](#clut_case_comment)
* [Framework Functions](#framework-functions)>
[clut_case_disable](#clut_case_disable)
* [Framework Functions](#framework-functions)>
[clut_case_end](#clut_case_end)
* [Framework Functions](#framework-functions)>
[clut_case_finalize](#clut_case_finalize)
* [Framework Functions](#framework-functions)>
[clut_case_initialize](#clut_case_initialize)
* [Framework Functions](#framework-functions)>
[clut_case_parameter](#clut_case_parameter)
* [Framework Functions](#framework-functions)>
[clut_case_requirement](#clut_case_requirement)
* [Framework Functions](#framework-functions)>
[clut_case_stdin_source](#clut_case_stdin_source)
* [Framework Functions](#framework-functions)>
[clut_definition_set](#clut_definition_set)
* [Framework Functions](#framework-functions)>
[clut_global_comparison_mask](#clut_global_comparison_mask)
* [Framework Functions](#framework-functions)>
[clut_global_dump_format](#clut_global_dump_format)
* [Framework Functions](#framework-functions)>
[clut_global_finalize](#clut_global_finalize)
* [Framework Functions](#framework-functions)>
[clut_global_initialize](#clut_global_initialize)
* [Framework Functions](#framework-functions)>
[clut_global_requirement](#clut_global_requirement)
* [Framework Functions](#framework-functions)>
[clut_shared_finalize](#clut_shared_finalize)
* [Framework Functions](#framework-functions)>
[clut_shared_initialize](#clut_shared_initialize)
* [Copyright 2018-2019 Brian G. Holmes](#copyright-2018-2019-brian-g-holmes)

You may also want to read the
[Quick-Start Guide (README_CLUT_Framework_Quickstart_Guide.md)](README_CLUT_Framework_Quickstart_Guide.md).

## Modification History

* 2018-10-31 Moved to the Holmespun Testing Support repository.
* 2018-05-07 Improved examples based on those created for Doxygen documentation.
* 2018-03-12 Described new global information section and the requirements handling functions.
* 2018-02-24 Initial document version.
* 2019-12-14 Moved to the Holmespun Testing Support repository.

## Overview

The CLUT framework is a collection of Bash scripts.
The framework supports a two-part process:
1. The first part involves the *compilation* of test cases into an executable form;
2. The second part is run-time support for *execution* of those test cases.

Test cases are compiled into a Bash script, and can be executed by running that script.

The two-step process allows the CLUT case definitions to be verified and evaluated before run-time.
As such, the run-time script need not perform that validation.
Time is saved in the common use-case where the same set of test cases are compiled once and run many times.

### Demonstrative Output

The CLUT framework supports the demonstrative output paradigm:
Test code should not be trusted to determine its own pass/fail status.
Test programs are notoriously buggy because they are written in relative haste.
We test our programs because we know that we will make mistakes and want to catch them as soon as possible,
but our test code does not receive that same treatment.

As such, tests should produce a report that describes every input and output, as well as information about the
environment that might have influenced the outcome.

The report should be is evaluated and approved by a human.
If the report is determined to be correct then it should become the definitive result;
it should be declared the baseline report.
Reports produced by the same test in the future will only be
automatically judged to be a success if and when they do **not** differ from the baseline.

### Test Case Phases Five

The CLUT framework runs each test case in isolation:

1. A fresh workspace is created and populated through a series of initializations.
2. The contents of that directory are dumped for human inspection.
3. The CLU program is executed within that directory.
4. A series of finalizations are performed.
5. Changes to the workspace (after initialization versus after finalization) are detected and reported.

Non-zero exit status values are reported for every program -
including those used for initialization and finalization - but the framework does not pass judgment based on them.
The test case might be exercising an error condition, so an abnormal exit status might be the appropriate response.

### Test Cases Workspaces Alpha and Omega

Two versions of the test case workspace are important to proving the impact of the CLU:
The CLUT framework refers to these versions as the *Alpha* and *Omega*.
The Alpha workspace is populated by step 1 above, and its files are dumped by step 2.
A copy of the Alpha version is set aside for reference purposes.

The Omega version is created by applying the CLU and test case finalizations of steps 3 and 4 to the Alpha version.
The Alpha and Omega versions are thus easily compared in step 5.

### Test Case Definition Sets

Test cases are defined by calling functions that are provided by the framework. A test case begins with a call to clut_case_begin, and it ends with a call to clut_case_end.

~~~~
	function generalExercises() {
	  #
	  clut_case_begin       "No Parameters Given"
	  clut_case_end
	  #
	}

	function specificRequirements() {
	  #
	  clut_case_begin       "CFDX-Input-0010 Rainy-Day Boolean."
	  clut_case_comment     "CFDX-Input-0010 Crash and burn when given a bad parameter value."
	  clut_case_parameter   "--verbose=bobo"
	  clut_case_end
	  #
	}

	clut_definition_set     generalExercises
	clut_definition_set     specificRequirements
~~~~

The framework functions used to define test cases must be nested inside of a local Bash function.

### Initializations

Initializations are used to populate the test case workspace with data that the CLU program can interact with.
Input data should be crafted so that any change to the input data will be reflected in the output of the CLU program.
Otherwise, your test case is subject to side effects that will distract from its purpose.

It is very important to create or copy all input data into the workspace before it is used by a test case
because only files that reside in the workspace are dumped for inspection.
Test case output is far less valuable if the input data that it interacts with is not known:
Changes to the input data will not be recorded or demonstrated, so changes to the output data cannot be explained.

Likewise, the CLU program should only create data in the workspace where it can be reported.

### Finalizations

Finalizations have traditionally been used to prepare output data for demonstration.
For example, convert a binary file to a text format that the framework knows how to dump.
Another reason for them was to mask date and time stamps from output data
so that new reports were comparable to baseline output.

These are still both valid reasons to use a finalization function,
but the framework has been enhanced to support these needs in other ways. For example, the clut\_global\_dump\_format
function can be used to define the way in which specific types of files should be dumped. Masking text data values is
also supported by the kamaji utility.

### Initialization Scopes

Initializations can be defined in one of three different scopes: case-specific, shared, and global.
Case-specific initializations are only used for the case in which they are defined.
Global initializations are used for all test cases defined in a CLUT file.

Shared initializations have a scope defined by their position in the function in which they are defined.
They are used for every test case defined in that function, as long as that case is defined after the initialization.

~~~~
	function generalExercises() {
	  #
	  clut_case_begin         "No Parameters Given"
	  clut_case_initialize    performInitialization Alpha
	  clut_case_end
	  #
	  clut_shared_initialize  performInitialization Beta
	  #
	  clut_case_begin         "Unknown Parameter Given"
	  clut_case_initialize    performInitialization Gamma
	  clut_case_parameter     "--bobo"
	  clut_case_end
	  #
	}

	function specificRequirements() {
	  #
	  clut_case_begin         "CFDX-Input-0010 Rainy-Day Boolean."
	  clut_case_comment       "CFDX-Input-0010 Crash and burn when given a bad parameter value."
	  clut_case_parameter     "--verbose=bobo"
	  clut_case_end
	  #
	  clut_global_initialize  performInitialization Delta
	  #
	}

	clut_definition_set       generalExercises
	clut_definition_set       specificRequirements
~~~~

The following initializations will be performed in order:
* "No Parameters Given" will be initialized using Delta and Alpha.
* "Unknown Parameter Given" will be initialized using Delta, Beta, and Gamma.
* "CFDX-Input-0010 Rainy-Day Boolean." will be initialized using Delta only.

Global initializations are always performed before shared initializations.
Shared initializations are always performed before case-specific initializations.

### Finalization Scopes

Finalizations can be defined in one of three different scopes: case-specific, shared, and global.
Case-specific finalizations are only used for the case in which they are defined.
Global finalizations are used for all test cases defined in a CLUT file.

Shared finalizations have a scope defined by their position in the function in which they are defined.
They are used for every test case defined in that function, as long as that case is defined after the finalization.

~~~~
	function generalExercises() {
	  #
	  clut_case_begin         "No Parameters Given"
	  clut_case_finalize      performFinalization Alpha
	  clut_case_end
	  #
	  clut_shared_finalize    performFinalization Beta
	  #
	  clut_case_begin         "Unknown Parameter Given"
	  clut_case_parameter     "--bobo"
	  clut_case_finalize      performFinalization Gamma
	  clut_case_end
	  #
	}

	function specificRequirements() {
	  #
	  clut_case_begin         "CFDX-Input-0010 Rainy-Day Boolean."
	  clut_case_comment       "CFDX-Input-0010 Crash and burn when given a bad parameter value."
	  clut_case_parameter     "--verbose=bobo"
	  clut_case_end
	  #
	  clut_global_finalize    performFinalization Delta
	  #
	}

	clut_definition_set       generalExercises
	clut_definition_set       specificRequirements
~~~~

The following finalizations will be performed in order:
* "No Parameters Given" will be finalized using Alpha and Delta.
* "Unknown Parameter Given" will be finalized using Gamma, Beta, and Delta.
* "CFDX-Input-0010 Rainy-Day Boolean." will be finalized using Delta only.

Shared finalizations are always performed after case-specific finalizations.
Global finalizations are always performed after shared finalizations.

### Comparable Masks

**CAVEAT:** While masking is an important functionality, the masking mechanism provided by the
kamaji program has significant
advantages over the one provided by the CLUT framework. Masking provided by the CLUT framework removes specifics from
the output report itself, which can obscure the validity of the report, and also makes the output less useful for
examples and documentation. Masking provided by the
kamaji program is applied to the report without modifying it directly, thus
allowing the user to verify the report in its pure form.

Comparable masks are used to modify the data in test case workspace
to mask aspects of the data that are not exactly repeatable from run to run.
This is an important functionality
because the report generated by any given run may be used to set the baseline for all subsequent runs,
and those subsequent runs must be able to to create the same report precisely.

As an example of why this might be necessary, consider a test case that creates data date and time stamp in it.
That test case result is only repeatable within the duration of that specific date and time.
If a comparable mask is used to modify all date and time values to a constant representation
then the results are repeatable for all dates and times.

It is often better to replace specific values with masked values of the same length.
For example, one might replace a date of the for 2018-02-24 with the word DATE,
but the mask YYYYMMDD is a more-accurate representation.

Absolute directory paths will also need to be masked so that a test case result can be repeated by another user
and/or on another machine.

## Examples

The examples below are taken from the
[Bash/Testing/clutc_exercise.bash](Bash/Testing/clutc_exercise.bash)
unit test script.
You can see the output in 
[Bash/Testing/clutc_exercise.bash.output](Bash/Testing/clutc_exercise.bash.output)

### Global Information

The first section of a CLUT report (section zero) contains information that applies to the entire test set:

~~~~
	0. Global Information
	0.1. Requirement Statements
	0.1.1. ABCD-0010
	    |When the program is invoked,
	    |Then it will allow the user to specify an output file;
	    |So that the user can dictate where the result is stored.
	0.1.2. ABCD-0020
	    |When the program attempts to calculate a median value,
	    |Then it will ignore all NA values within the sample set;
	    |So that invalid data will not impact the calculation.
	0.1.3. ABCD-0030
	    |When the program is invoked,
	    |Then it will draw seven red lines,
	    |And all of them will be strictly perpendicular,
	    |And some of them will be drawn with green ink,
	    |And some of them will be drawn with transparent ink.
	0.2. Requirement Coverage
	0.2.1. ABCD-0010
	0.2.1.1. Case 3: Rainy-Day
	0.2.1.2. Case 4 CreateOutputFile: Sunny-Day
	0.2.1.3. Case 5 ModifyInputFile: Sunny-Day
	0.2.2. ABCD-0020
	0.2.2.1. Case 5 ModifyInputFile: Sunny-Day
	0.2.3. ABCD-0030
	    |No coverage.
	0.3. Comparable Masks
	0.3.1. s,[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\},DATE,g
	0.3.2. s,[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\},TIME,g
~~~~

0.1. Describes each requirement that was defined by the user.
Test cases may be associated with one or more requirements, but only if those requirements have been globally defined.

0.2. Lists the test cases that cover each requirement.
The user can specify how the requirements where tested by each case;
here we described the test types as Rainy-Day and Sunny-Day, but any description can be used.

0.3. Presents the substitution expressions used with the *sed* command to
mask data in a test case workspace. The CLU program uses unmasked data.

### Test Case Report

The result of running a CLUT looks like this for a single test case:

~~~~
	5. ModifyInputFile.
	5.1. Requirements.
	    |ABCD-0010 Sunny-Day; ABCD-0020 Sunny-Day
	5.2. Initializations.
	5.2.1. noisyEveryFifthCall
	5.2.2. mkdir empty data
	5.2.3. createTextFile data/configuration.text TMPDIR=/remote/tmp
	5.2.4. createTextFile data/delta.text The only constant is change.
	5.2.5. Applying comparable masks.
	5.3. Initial Workspace contains 4 files...
	    |data
	    |data/configuration.text
	    |data/delta.text
	    |empty
	5.3.1. data contains 2 files.
	5.3.1.1. configuration.text...
	    |TIME TMPDIR=/remote/tmp
	5.3.1.2. delta.text...
	    |TIME The only constant is change.
	5.3.2. empty is empty.
	5.4. Target CLU Call.
	5.4.1. myAwesomeProgram Augment data/delta.text
	5.5. Finalizations.
	5.5.1. noisyEveryFifthCall
	5.5.1.1. Exit Status 0!
	5.5.1.2. STDERR [text]...
	    |The user's counter value is 10.
	5.5.2. Applying comparable masks.
	5.6. Workspace Impact...
	    |diff --text --recursive --no-dereference 05.Alpha/data/delta.text 05.Omega/data/delta.text
	    |1a2
	    |> This is an extra data line.
	5.6.1. data/delta.text (changed)...
	    |TIME The only constant is change.
	    |This is an extra data line.
~~~~

Test case 5 is called *ModifyInputFile*:

5.1. Lists the requirements that this test case is associated with.

5.2. Describes initializations that are applied to create the workspace.
Most of the initializations produce data that the CLU program will need to interact with.

5.3. Shows the files that the Alpha version of the workspace contains.
Its subsections name and dump the contents of each file.

5.4. Shows how the target CLU program was called.
This test case was designed to exercise the myAwesomeProgram script.

5.5. Describes three finalizations that were applied to the workspace after the CLU call.
Subsection 5.4.1. reports the exit status and standard error output produced by the noisyEveryFifthCall function.
Exit status values of zero are only reported when information is written to standard error;
All other exit status values are reported.

5.6. Describes how the Omega version of the workspace from the Alpha version.
Each subsection will contain a full dump of modified files.

### Test Case Definition

The output in the previous section was produced by the following CLUT case definition:

~~~~
	clut_case_begin             ModifyInputFile
	clut_case_requirement       ABCD-0010 Sunny-Day
	clut_case_requirement       ABCD-0020 Sunny-Day
	clut_case_initialize        mkdir empty data
	clut_case_initialize        createTextFile data/configuration.text TMPDIR=/remote/tmp
	clut_case_initialize        createTextFile data/delta.text The only constant is change.
	clut_case_parameter         Augment
	clut_case_parameter         data/delta.text
	clut_case_end

	clut_global_initialize      noisyEveryFifthCall
	clut_global_finalize        noisyEveryFifthCall

	clut_global_comparison_mask 's,[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\},DATE,g'"
	clut_global_comparison_mask 's,[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\},TIME,g'"
~~~~

A CLUT definition file contains function definitions and other valid Bash scripting statements.
Each of the lines in a test case definition is a call to a Bash function that is defined by the framework:

* clut_case_begin set the name of the test case to *ModifyInputFile*.

* clut_case_requirement is used to describe requirement coverage.

* clut_case_initialize is used to request creation of two directories,
and then to request the use of a createTextFile function to generate text files.

* clut_case_parameter defines "Augment data/delta.text" as the parameters passed into the CLU program.

* clut_case_end is used to complete the test case definition.

* clut_global_initialize instructs the framework to call the noisyEveryFifthCall function
while initializing the Alpha version of the workspace for every test case.

* clut_global_finalize instructs the framework to call the noisyEveryFifthCall function
while finalizing the Omega version of the workspace for every test case.

* clut_global_comparison_mask is used mask out YYYY-MM-DD format dates and HH:MM:SS format time values.

These function calls must be wrapped in a Bash function,
and that function must be registered with the framework using a call to the clut_definition_set function.

The createTextFile and noisyEveryFifthCall functions are also defined in the CLUT;
these are simple Bash functions.
The former creates the named text file and populates it with the parameters that follow the name.
The latter increments a global counter and announces when that counter cleanly divisible by 5;
it has no actual effect on the workspace.

### Working Directory Artifacts

The process of compiling a CLUT definition occurs in the callers current working directory;
when the kamaji utility is used, compilation occurs in the configured working-folder.
Compilation will create a date-and-time stamped directory in which the final Bash script is stored:

For example,
the doxygenFilterForBashToCxx.clut (in the HolmespunLibraryBashing repository) defines six test cases
for exercising the doxygenFilterForBashToCxx.bash script.
Compilation of those test cases results in creation of the following working directory and a link to the
00.compiled.bash file inside it:

~~~~
	$ cd Bash
	$ make Working
	$ cd Working
	$ make doxygenFilterForBashToCxx.clut.bash
	$ ls -a1 --classify doxygenFilterForBashToCxx* | sed --expression="s,.* [0-9]\{2\}:[0-9]\{2\} ,,"
	doxygenFilterForBashToCxx.bash -> ../doxygenFilterForBashToCxx.bash*
	doxygenFilterForBashToCxx.clut -> ../Testing/doxygenFilterForBashToCxx.clut
	doxygenFilterForBashToCxx.clut.bash -> doxygenFilterForBashToCxx.clutc.Working.20180508_150321/00.compiled.bash*

	doxygenFilterForBashToCxx.clutc.Working.20180508_150321:
	total 64
	./
	../
	00.compiled.bash*
	00.namelist.text
	01.bash
	02.bash
	03.bash
	04.bash
	05.bash
	06.bash
	$ 
~~~~

Another working directory is created each time the compiled CLUT (the Bash/Working/doxygenFilterForBashToCxx.clut.bash
script) is run:

~~~~
	$ make doxygenFilterForBashToCxx.clut.output
	make doxygenFilterForBashToCxx.clut.output
	make doxygenFilterForBashToCxx.clut.output (0.01 minutes)
	$ ls -al --classify doxygenFilterForBashToCxx* | sed --expression="s,.* [0-9]\{2\}:[0-9]\{2\} ,,"
	doxygenFilterForBashToCxx.bash -> ../doxygenFilterForBashToCxx.bash*
	doxygenFilterForBashToCxx.clut -> ../Testing/doxygenFilterForBashToCxx.clut
	doxygenFilterForBashToCxx.clut.bash ->
	doxygenFilterForBashToCxx.clutc.Working.20180508_150321/00.compiled.bash*
	doxygenFilterForBashToCxx.clut.output
	doxygenFilterForBashToCxx.clut.output.seconds
	doxygenFilterForBashToCxx.clutr.Working -> doxygenFilterForBashToCxx.clutr.Working.20180508_150421/

	doxygenFilterForBashToCxx.clutc.Working.20180508_150321:
	total 64
	./
	../
	00.compiled.bash*
	00.namelist.text
	01.bash
	02.bash
	03.bash
	04.bash
	05.bash
	06.bash

	doxygenFilterForBashToCxx.clutr.Working.20180508_150421:
	total 88
	./
	../
	01.Alpha/
	01.Omega/
	02.Alpha/
	02.Omega/
	03.Alpha/
	03.Omega/
	04.Alpha/
	04.Omega/
	05.Alpha/
	05.Omega/
	06.Alpha/
	06.Omega/
	OUTPUT.text
	$
~~~~

The run-time working directory contains a copy of the output report,
as well as the Alpha and Omega version of each test case workspace;
these may be useful to the user for debugging purposes.

## Framework Functions

The functions provided for defining test cases are described below.
Only the clut_definition_set function can be used outside of the context of a user-defined Bash function.

* **clut_case_begin <name>** Start a new test case definition and name it as specified.
* **clut_case_comment <text>** Describe the test case with the given text.
* **clut_case_disable <text>** Disable a test case and display the given text message in its place.
* **clut_case_end** Complete the current test case definition.
* **clut_case_finalize <command>** Use the given command to finalize the test case workspace.
* **clut_case_initialize <command>** Use the given command to initialize the test case workspace.
* **clut_case_parameter <text>** Pass the given text as a parameter to the CLU program.
* **clut_case_requirement <identifier> <method>** Describe how the test case covers a single requirement.
* **clut_case_stdin_source <file-name>** Use the contents of the named file as stdin for the CLU.
* **clut_definition_set <function>** Extract test case definitions from the given function.
* **clut_global_comparison_mask <expression>** Use the given sed expression to mask workspace contents.
* **clut_global_dump_format <extension> <function>** Use the given function to dump files with the given extension.
* **clut_global_finalize <command>** Like clut_case_finalize applied to all test cases.
* **clut_global_initialize <command>** Like clut_case_initialize applied to all test cases.
* **clut_global_requirement <identifier> <description>** Defines a single requirement.
* **clut_shared_finalize <command>** Like clut_case_finalize for subsequent cases in same function.
* **clut_shared_initialize <command>** Like clut_case_initialize for subsequent cases in same function.

There are also a number of synonyms for these functions:

* **clut_case_ended** clut_case_end
* **clut_case_finalizer** clut_case_finalize
* **clut_case_initializer** clut_case_initialize
* **clut_case_name** clut_case_begin
* **clut_case_purpose** clut_case_comment
* **clut_case_start** clut_case_begin
* **clut_definitions_set** clut_definition_set
* **clut_global_finalizer** clut_global_finalize
* **clut_global_initializer** clut_global_initialize
* **clut_shared_finalizer** clut_shared_finalize
* **clut_shared_initializer** clut_shared_initialize

### clut_case_begin

The clut_case_begin function is used to name a new test case.
This function - or one of its synonyms - must be the first call made to define every test case.

~~~~
	clut_case_begin		"No Parameters Given"
	clut_case_end
~~~~

### clut_case_comment

The clut_case_comment function is used to describe the test case.

~~~~
	clut_case_begin	        "No Parameters Given"
	clut_case_comment       "Illustrate what happened with the program is called without any parameters."
	clut_case_end
~~~~

Comments appear just below the section name in the CLUT report.

~~~~
	1. No Parameters Given.
	    |Illustrate what happened with the program is called without any parameters.
	1.1. Initializations.
	...
~~~~

### clut_case_disable

The user may disable a test case by calling the clut_case_disable function. Test cases are disabled for two main
reasons: (1) The test case is already established (the numbering is test) in the baseline output file, but the
functionality that it exercises is no longer needed; (2) The test case output is overly verbose, that verbosity does
not necessarily prove anything, and/or the output cannot be appropriately masked without a disproportionate amount of
effort to reward.

The clut_case_disable function must be used as soon as the test case is named so that subsequent function calls that
define the case can be ignored.

Given the CLUT case:

~~~~
	clut_case_name        DoItNow_Nominal
	clut_case_disable     Disabled: The DoItNow function is no longer defined.
	clut_case_initialize  spit DATA.text This is stuff that will be done now.
	clut_case_parameter   DATA.text
	clut_case_end
~~~~

Resulting CLUT report:

~~~~
	5. DoItNow_Nominal.
	    |Disabled: The DoItNow function is no longer defined.
	5.1. Requirements.
	5.2. Initializations.
	5.3. Target CLU Call.
	5.4. Finalizations.
~~~~

Disabling a test case has advantages over removing one: The biggest advantage is that the case is still represented in
the CLUT report; subsequent cases will retain their previous numbers, and the report remains comparable to past
versions. Another advantage is that the case can remain defined and can be enabled easily.

### clut_case_end

The clut_case_end function is used to complete the current test case.
This function - or one of its synonyms - must be the last call made to define every test case.

~~~~
	clut_case_begin		"No Parameters Given"
	clut_case_end
~~~~

### clut_case_finalize

The clut_case_finalize function is used to request that the given command be applied
just after the CLU program is called.
Finalization commands are often calls to a locally defined Bash functions.

~~~~
	function removeSideEffectOutputFiles() {
	  #
	  rm --force *.temp *was
	  #
	}
	
	function whatever() {
	  #
	  clut_case_begin         "Nominal"
	  clut_case_finalize      md5sum OUTPUT.db
	  clut_case_finalize      removeSideEffectOutputFiles
	  clut_case_end
	  #
	}
~~~~

See also [clut_global_finalize](#clut_global_finalize-command) and
[clut_shared_finalize](#clut_shared_finalize-command).

### clut_case_initialize

The clut_case_initialize function is used to request that the given command be applied
just before the CLU program is called.
Initialization commands are often calls to a locally defined Bash functions.

~~~~
	function generateInputData() {
	  #
	  local FileSpecification=${1}
	  #
	  echo "This is the first line of data."  >  ${FileSpecification}
	  echo "This is the second line of data." >> ${FileSpecification}
	  #
	}

	function whatever() {
	  #
	  clut_case_begin         "EasyInput"
	  clut_case_initialize    generateInputData INPUT.text
	  clut_case_parameter     --input=INPUT.text
	  clut_case_end
	  #
	}
~~~~

See also [clut_global_initialize](#clut_global_initialize-command) and
[clut_shared_initialize](#clut_shared_initialize-command).

### clut_case_parameter

The clut_case_parameter function is used to define the parameters that a specific test case pass into the CLU program.

~~~~
	clut_case_begin         "Both Input And Output Specified"
	clut_case_parameter     --input=INPUT.text
	clut_case_parameter     --output=OUTPUT.text
	clut_case_parameter     --verbose
	clut_case_end
~~~~

Parameters are passed into the CLU program call in the order defined by the test case.

Best practice: Specify one parameter per call to the clut_case_parameter function
so that you can add and remove parameters from each test case easily.

### clut_case_requirement

The clut_case_requirement function is used to declare that a test case covers a specific requirement.

~~~~
	clut_global_requirement  ABCD-Input-0010 "The program must require the user to specify an input file."
	clut_global_requirement  ABCD-Input-0050 "The program must allow the user to specify an output file."
	clut_global_requirement  ABCD-Input-0050 "All file specifications provided by the user must be unique."

	clut_case_begin         "InputEqualsOutput"
	clut_case_requirement   ABCD-Input-0010 Nominal
	clut_case_requirement   ABCD-Input-0020 Nominal
	clut_case_requirement   ABCD-Input-0050 Contrary
	clut_case_parameter     --input=INPUT.text
	clut_case_parameter     --output=INPUT.text
	clut_case_parameter     --verbose
	clut_case_end
~~~~

The method used to cover the requirement may be expressed in any way that is useful to the user.

The calls to clut_global_requirement above result in report section 0.1 below.
The calls to clut_case_requirement above result in report section 20.1 and subsections 0.2.1.1, 0.2.2.1, and
0.2.3.1 below.

~~~~
	0. Global Information
	0.1. Requirement Statements
	0.1.1. ABCD-Input-0010
	    |The program must require the user to specify an input file.
	0.1.2. ABCD-Input-0020
	    |The program must allow the user to specify an output file.
	0.1.3. ABCD-Input-0050
	    |All file specifications provided by the user must be unique.
	0.2. Requirement Coverage
	0.2.1. ABCD-Input-0010
	0.2.1.1. Case 20 InputEqualsOutput: Nominal
	0.2.2. ABCD-Input-0020
	0.2.2.1. Case 20 InputEqualsOutput: Nominal
	0.2.3. ABCD-Input-0050
	0.2.3.1. Case 20 InputEqualsOutput: Contrary
	...
	20. InputEqualsOutput.
	20.1. Requirements.
	    |ABCD-Input-0010 Nominal; ABCD-Input-0020 Nominal; ABCD-Input-0050 Contrary
	20.2. Initializations.
	...
~~~~

### clut_case_stdin_source

The clut_case_stdin_source parameter can be used to
request the framework to pass the contents of a specific file into the CLU program as standard input.

~~~~
	clut_case_begin		"No Parameters Given But Normative Data on Stdin"
	clut_case_initialize	createNormativeData TO_BE_STDIN.text
	clut_case_stdin_source	TO_BE_STDIN.text
	clut_case_end
~~~~

### clut_definition_set

The clut_definition_set function is used to
request that the framework pull test case definitions from the given function.

~~~~
	function allMyTestCases() {
	  #
	  clut_case_begin	"No Parameters Given"
	  clut_case_end
	  #
	}

	clut_definition_set	allMyTestCases
~~~~

The clut_definition_set is the only one that can be used when it is not wrapped in a function definition.

### clut_global_comparison_mask

The clut_global_comparison_mask function requests that the given *sed* expression be
used to modify the contents of every test case workspace.
Comparison masks are applied as the final step of workspace initialization and finalization.
They are also applied to output written to standard output (stdout) and standard error (stderr).

~~~~
	clut_global_comparison_mask	's,[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\},YYYY-MM-DD,g'
	clut_global_comparison_mask	's,[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\},HH:MM:SS,g'
	clut_global_comparison_mask	"s,${HOME},\$HOME,g"
~~~~

The first two examples above show how to mask two forms of date and time data.
The last two examples will convert user-specific directories to their variable equivalents.

### clut_global_dump_format

The clut_global_dump_format function is used to register dump function with the framework.
The dump function will be used to dump data files that have the specified file name extension.
The function registered should take the name of the file to be dumped as it only positional parameter.

~~~~
	function dumpPdfAsText() {
	  #
	  local -r TargetFSpec="${1}"
	  #
	  pdftotext "${TargetFSpec}" - | sed --expression='s,^,    |,'
	  #
	}
	
	function whatever() {

	  clut_global_dump_format	PDF dumpPdfAsText 

	}
~~~~

The framework associates the given function with all cases (i.e. lower-, upper-, and mixed-cases) of the extension.

### clut_global_finalize

The clut_global_finalize function is used to request that the given command be applied
after the CLU program is called.

~~~~
	function reportCountOfFileType() {
	  #
	  local -r FileType=${1}
	  #
	  local -r -i Count=$(find . -name "*.${FileType}" | wc --lines)
	  #
	  echo "The workspace contains ${Count} ${FileType} files."
	  #
	}

	function whatever() {
	  #
	  clut_global_finalize  reportCountOfFileType gif
	  clut_global_finalize  reportCountOfFileType jpeg
	  #
	}
~~~~

See the [Finalizations](#finalizations) and [Finalization Scopes](#finalizations-scopes)
sections for more details.

### clut_global_initialize

The clut_global_initialize function is used to request that the given command be applied
before the CLU program is called.

~~~~
	function createConfigurationFile() {
	  #
	  local -r FileSpecification=${1}
	  #
	  echo "VERBOSE = FALSE"        >  ${FileSpecification}
	  echo "LANG=en_US.UTF-8"       >> ${FileSpecification}
	  #
	}

	function whatever() {
	  #
	  clut_global_initialize  createConfigurationFile .program.conf
	  #
	}
~~~~

See the [Initializations](#initializations) and [Initialization Scopes](#initializations-scopes)
sections for more details.

### clut_global_requirement

The clut_global_requirement function is used to associate an identifier with a requirement statement.

~~~~
	clut_global_requirement    ABCD-0030                                                    \
	                             "When the program is invoked,"                             \
	                           "\nThen it will draw seven red lines,"                       \
	                           "\nAnd all of them will be strictly perpendicular,"          \
	                           "\nAnd some of them will be drawn with green ink,"           \
	                           "\nAnd some of them will be drawn with transparent ink."
~~~~

Requirement definitions are reported in the Global Information section of a CLUT report:

~~~~
	0. Global Information
	0.1. Requirement Statements
	0.1.1. ABCD-0030
	    |When the program is invoked,
	    |Then it will draw seven red lines,
	    |And all of them will be strictly perpendicular,
	    |And some of them will be drawn with green ink,
	    |And some of them will be drawn with transparent ink.
	0.1.2. ...
~~~~

### clut_shared_finalize

The clut_shared_finalize function is used to request that the given command be applied:
* To the Omega version of a test case workspace (i.e. after the CLU is called);
* After all case-specific finalization commands have been executed;
* After shared finalizations that were defined in the same test case definition function before it;
* Before all global finalizations.

Shared finalizations have a scope that is limited to the test case definition function that they are
defined in, and are only applied to cases that are defined after they are. For example, in a test case
definition function that contains:
* case Alpha
* shared finalization Beta
* case Gamma
* shared finalization Delta
* case Epsilon

The following apply:
* No shared finalizations will be applied to case Alpha;
* Beta will be applied to case Gamma;
* Beta and Delta will be applied to case Epsilon in that order.
* Beta and Delta will have no effect on cases defined in other test case definition functions.

~~~~
	function reportCountOfFileType() {
	  #
	  local -r FileType=${1}
	  #
	  local -r -i Count=$(find . -name "*.${FileType}" | wc --lines)
	  #
	  echo "The workspace contains ${Count} ${FileType} files."
	  #
	}

	function gifConversionTests() {
	  #
	  clut_case_begin         Convert PNG To GIF File Target
	  clut_case_initialize    makeDataFileNotShown INPUT.png
	  clut_case_parameter     --input:file=INPUT.png
	  clut_case_end
	  #
	  clut_shared_initialize  makeDataDirectoryNotShown INPUT-1
	  #
	  clut_shared_finalize    reportCountOfFileType PNG
	  clut_shared_finalize    reportCountOfFileType GIF
	  #
	  clut_case_begin         Convert PNG To GIF Single Directory Target
	  clut_case_initialize    makeDataDirectoryNotShown INPUT-1
	  clut_case_parameter     --input:directory=INPUT
	  clut_case_end
	  #
	  clut_shared_initialize  makeDataDirectoryNotShown INPUT-2
	  #
	  clut_case_begin         Convert PNG To GIF Multiple Directory Target
	  clut_case_parameter     --input:directory:1=INPUT-1
	  clut_case_parameter     --input:directory:2=INPUT-2
	  clut_case_end
	  #
	}
~~~~

See the [Finalizations](#finalizations) and [Finalization Scopes](#finalizations-scopes)
sections for more details.

### clut_shared_initialize

The clut_shared_initialize function is used to request that the given command be applied:
* To the Alpha version of a test case workspace (i.e. before the CLU is called);
* After all global initializations.
* After shared initializations that were defined in the same test case definition function before it;
* Before all case-specific initialization commands have been executed;

Shared initializations have a scope that is limited to the test case definition function that they are
defined in, and are only applied to cases that are defined after they are. For example, in a test
case definition function that contains:
* case Alpha
* shared initialization Beta
* case Gamma
* shared initialization Delta
* case Epsilon

The following apply:
* No shared initializations will be applied to case Alpha;
* Beta will be applied to case Gamma;
* Beta and Delta will be applied to case Epsilon in that order.
* Beta and Delta will have no effect on cases defined in other test case definition functions.

~~~~
	function makeDataDirectory() {
	  #
	  local -r DirectorySpecification=${1}
	  #
	  mkdir ${DirectorySpecification)/
	  #
	  :  More files created but not shown here.
	  #
	}

	function gifConversionTests() {
	  #
	  clut_case_begin         Convert PNG To GIF File Target
	  clut_case_initialize    makeDataFileNotShown INPUT.png
	  clut_case_parameter     --input:file=INPUT.png
	  clut_case_end
	  #
	  clut_shared_initialize  makeDataDirectory INPUT-1
	  #
	  clut_case_begin         Convert PNG To GIF Single Directory Target
	  clut_case_initialize    makeDataDirectoryNotShown INPUT-1
	  clut_case_parameter     --input:directory=INPUT
	  clut_case_end
	  #
	  clut_shared_initialize  makeDataDirectory INPUT-2
	  #
	  clut_case_begin         Convert PNG To GIF Multiple Directory Target
	  clut_case_parameter     --input:directory:1=INPUT-1
	  clut_case_parameter     --input:directory:2=INPUT-2
	  clut_case_end
	  #
	}
~~~~

See the [Initializations](#initializations) and [Initialization Scopes](#initializations-scopes)
sections for more details.


## Copyright 2018-2019 Brian G. Holmes

This documentation is part of the Holmespun Testing Support repository.

The Holmespun Testing Support repository only contains free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free Software Foundation, either version
three (3) of the License, or (at your option) any later version.

The Holmespun Testing Support repository is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.
If not, see [<https://www.gnu.org/licenses/>](<https://www.gnu.org/licenses/>).

See the [COPYING.text](COPYING.text) file for further licensing information.

**(eof)**
