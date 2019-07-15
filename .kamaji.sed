#----------------------------------------------------------------------------------------------------------------------
#
#  kamaji.sed
#
#----------------------------------------------------------------------------------------------------------------------
#
#  In:	PROGRAM.bash.clutc.20190713_123215
#  Out:	PROGRAM.bash.clutc.YYYYMMDD_HHMMSS
#
#----------------------------------------------------------------------------------------------------------------------

s,clutc\.[0-9]\{8\}_[0-9]\{6\},clutc.YYYYMMDD_HHMMSS,

#----------------------------------------------------------------------------------------------------------------------
#
#  In:	Created by clutc on 2019-07-13 at 12:32:16.
#  Out:	Created by clutc on YYYY-MM-DD at HH:MM:SS.
#
#----------------------------------------------------------------------------------------------------------------------

s,on [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} at [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\},on YYYY-MM-DD at HH:MM:SS,

#----------------------------------------------------------------------------------------------------------------------
#
#  In:	clutr.working.20190713_123215.22297
#  Out:	clutr.working.YYYYMMDD_HHMMSS.PID
#
#----------------------------------------------------------------------------------------------------------------------

s,clutr\.working\.[0-9]\{8\}_[0-9]\{6\}\.[0-9]\{1\,5\},clutr.working.YYYYMMDD_HHMMSS.PID,

#----------------------------------------------------------------------------------------------------------------------
#
#  In:	PATH="/home/bgh/Holmespun/HolmespunTestingSupport/Working/kamaji.bash
#  Out: PATH="${HolmespunTestingSupport}/Working/kamaji.bash
#
#----------------------------------------------------------------------------------------------------------------------

s,/[^[:space:]]*/HolmespunTestingSupport,${HolmespunTestingSupport},

#----------------------------------------------------------------------------------------------------------------------