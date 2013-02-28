<?php
/*
 This class is used to report a job result to the server.

 Source code is under GPL, (c) 2002-2013 the Global Processing Unit Team
*/
include("../utils/utils.inc.php");
include("../utils/constants.inc.php");

$jobqueueid     = getparam('jobqueueid', '');
$jobid          = getparam('jobid', '');
$nodeid         = getparam('nodeid', '');
$nodename       = getparam('nodename', '');
$jobresult      = getparam('jobresult', '');
$workunitresult = getparam('wuresult', '');
$iserroneous    = getparam('iserroneous', '');
$errorid		= getparam('errorid', '');
$errorarg		= getparam('errorarg', '');
$errormsg		= getparam('errormsg', '');

if ( ($jobqueueid=="") || ($jobid=="") || ($nodeid=="") || ($nodename=="") || ($iserroneous) ) die("ERROR: please specify at least jobqueueid, jobid, nodeid, nodename and iserroneous");

$ip = $_SERVER['REMOTE_ADDR'];

include("report_jobresult.inc.php");

$exitmsg = report_jobresult($jobqueueid, $jobid, $nodeid, $nodename, $jobresult, $workunitresult, $iserroneous, $errorid, $errorarg, $errormsg, $ip);

if ($exitmsg == "") echo "OK"; else echo "ERROR: $exitmsg";
					
?>