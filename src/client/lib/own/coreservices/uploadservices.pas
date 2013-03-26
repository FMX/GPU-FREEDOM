unit uploadservices;
{
  TUploadServiceThread is a db aware service which uploads a file
  via HTTP  POST from a jobqueue. It changes the jobqueue status
  from COMPUTED to TRANSMITTING_WORKUNIT to WORKUNIT_TRANSMITTED, if successful.

  (c) by 2002-2013 the GPU Development Team
  This unit is released under GNU Public License (GPL)
}

interface

uses
  managedthreads, servermanagers, dbtablemanagers, workflowmanagers, jobqueuetables,
  uploadutils, loggers, sysutils;


type TUploadServiceThread = class(TManagedThread)
 public
   constructor Create(var srv : TServerRecord; var tableman : TDbTableManager; var workflowman : TWorkflowManager;
                      proxy, port : String; var logger : TLogger);

 protected
    procedure Execute; override;

 private
    url_,
    sourcePath_,
    sourceFile_,
    logHeader_,
    proxy_,
    port_        : String;

    srv_         : TServerRecord;
    tableman_    : TDbTableManager;
    workflowman_ : TWorkflowManager;

    jobqueuerow_ : TDbJobQueueRow;
    logger_      : TLogger;

end;


implementation


constructor TUploadServiceThread.Create(var srv : TServerRecord; var tableman : TDbTableManager; var workflowman : TWorkflowManager;
                                        proxy, port : String; var logger : TLogger);
begin
  inherited Create(true); // suspended
  srv_ := srv;
  tableman_ := tableman_;
  workflowman_ := workflowman;
  logHeader_ := '[TUploadServiceThread]> ';

  logger_ := logger;
  proxy_ := proxy;
  port_ := port;
end;


procedure TUploadServiceThread.execute();
begin
  if not workflowman_.getJobQueueWorkflow().findRowInStatusForWUTransmission(jobqueuerow_) then
         begin
           logger_.log(LVL_DEBUG, logHeader_+'No jobs found in status FOR_WU_TRANSMISSION. Exit.');
           done_      := True;
           erroneous_ := false;
           Exit;
         end;

  if (Trim(jobqueuerow_.workunitresultpath)='') then
        begin
          logger_.log(LVL_SEVERE, logHeader_+'Found a job in status FOR_WU_TRANSMISSION with no workunitresult to be transmitted.');
          workflowman_.getJobQueueWorkflow().changeStatusToError(jobqueuerow_, logHeader_+'Found a job in status FOR_WU_TRANSMISSION with no workunitresult to be transmitted.');
          // note: computationservices.pas is charged with this transition
          done_      := True;
          erroneous_ := True;
          Exit;
        end
   else
    begin
        // main workunit transmission loop
        sourcePath_ := ExtractFilePath(jobqueuerow_.workunitresultpath);
        sourceFile_ := jobqueuerow_.workunitresult;

        if not FileExists(jobqueuerow_.workunitresultpath) then
               begin
                 workflowman_.getJobQueueWorkflow().changeStatusToError(jobqueuerow_, logHeader_+'Could not upload workunit as it does not exist on the filesystem ('+jobqueuerow_.workunitresultpath+')');
                 logger_.log(LVL_SEVERE, 'UploadServiceThread ['+sourceFile_+']> File not found: '+jobqueuerow_.workunitresultpath);
                 erroneous_ := True;
                 done_      := True;
                 Exit;
               end;

        workflowman_.getJobQueueWorkflow().changeStatusFromForWuTransmissionToTransmittingWorkunit(jobqueuerow_);


        url_ := srv_.url+'/workunits/http_upload_workunit.php?wuresult=1';
        erroneous_ := not uploadFromFile(url_, sourcePath_, sourceFile_, proxy_, port_, 'UploadServiceThread ['+sourceFile_+']> ', logger_);
        if erroneous_ then
               workflowman_.getJobQueueWorkflow().changeStatusToError(jobqueuerow_, 'Impossible to upload workunit '+sourceFile_+' to URL '+url_)
        else
         begin
          workflowman_.getJobQueueWorkflow().changeStatusFromTransmittingWorkunitToWorkunitTransmitted(jobqueuerow_);
          workflowman_.getJobQueueWorkflow().changeStatusFromWorkunitTransmittedToForResultTransmission(jobqueuerow_);
         end;

    end;

   done_ := true;
end;

end.