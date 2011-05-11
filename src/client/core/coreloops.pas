unit coreloops;

interface

uses
  SysUtils,
  loggers, lockfiles, coreconfigurations,  identities,
  coremodules, servicefactories, servicemanagers,
  servermanagers, dbtablemanagers, coreservices,
  receiveparamservices, receiveserverservices,
  receiveclientservices, transmitclientservices,
  receivechannelservices, coreobjects, coremonitors;

const FRAC_SEC=1/24/3600;

type TCoreLoop = class(TObject)
  public
    constructor Create();
    destructor Destroy;

    procedure start;
    procedure tick;
    procedure stop;

    function getCoreMonitor : TCoreMonitor;

  private
    path_,
    logHeader_   : String;
    coremonitor_ : TCoreMonitor;

    function    launch(var thread : TCoreServiceThread; tname : String; var srv : TServerRecord) : Boolean;
    procedure   retrieveParamsAndServers;
    procedure   retrieveClients;
    procedure   transmitClient;
    procedure   receiveChannels;

    tick_,
    days_        : Longint;
end;

implementation

constructor TCoreLoop.Create();
begin
  inherited Create;
  path_ := extractFilePath(ParamStr(0));
  logHeader_ := 'gpucore> ';

  coremonitor_ := TCoreMonitor.Create();
  loadCoreObjects('gpucore');
end;

destructor TCoreLoop.Destroy;
begin
 conf.saveCoreConfiguration();
 discardCoreObjects;
 coremonitor_.Free;
 inherited Destroy;
end;

procedure TCoreLoop.start;
begin
  coremonitor_.coreStarted;
  logger.logCR; logger.logCR;
  logger.logCR; logger.logCR;
  logger.log(LVL_INFO, logHeader_+'********************');
  logger.log(LVL_INFO, logHeader_+'* Core launched ...*');
  logger.log(LVL_INFO, logHeader_+'********************');
  // main loop
  tick_ := 1;
  days_ := 0;
  retrieveParamsAndServers;
  retrieveClients;
  receiveChannels;
  transmitClient;
end;

procedure TCoreLoop.tick;
begin
      if (tick_ mod 60 = 0) then logger.log(LVL_DEBUG, logHeader_+'Running since '+FloatToStr(myGPUID.Uptime)+' days.');
      if (tick_ mod myConfID.receive_servers_each = 0) then retrieveParamsAndServers;
      if (tick_ mod myConfID.receive_nodes_each = 0) then retrieveClients;
      if (tick_ mod myConfID.transmit_node_each = 0) then transmitClient;
      if (tick_ mod myConfID.receive_channels_each = 0) then receiveChannels;
      if (tick_ mod 20 = 0) and lf_morefrequentupdates.exists then receiveChannels;

      Sleep(1000);

      Inc(tick_);
      myGPUID.Uptime := myGPUID.Uptime+FRAC_SEC;

      if (tick_>=86400) then
         begin
            tick_ := 0;
            Inc(days_);
         end;
      serviceman.clearFinishedThreads;
end;

procedure TCoreLoop.stop;
begin
  logger.log(LVL_INFO, logHeader_+'Core was running for '+FloatToStr(myGPUID.uptime)+' days.');
  myGPUID.TotalUptime:=myGPUID.TotalUptime+myGPUID.Uptime;
  myGPUID.Uptime := 0;
  logger.log(LVL_INFO, logHeader_+'Total uptime is '+FloatToStr(myGPUID.TotalUptime)+'.');
  coremonitor_.coreStopped;
end;

function TCoreLoop.getCoreMonitor : TCoreMonitor;
begin
  Result := coremonitor_;
end;

function    TCoreLoop.launch(var thread : TCoreServiceThread; tname : String; var srv : TServerRecord) : Boolean;
var slot : Longint;
begin
   Result := true;
   logger.log(LVL_DEBUG, logHeader_+tname+' started...');
   slot := serviceman.launch(thread);
   if slot=-1 then
         begin
           Result := false;
           logger.log(LVL_SEVERE, logHeader_+tname+' failed, core too busy!');
         end;

   logger.log(LVL_DEBUG, logHeader_+tname+' over.');
end;


procedure TCoreLoop.retrieveParamsAndServers;
var receiveparamthread  : TReceiveParamServiceThread;
    receiveserverthread : TReceiveServerServiceThread;
    srv                 : TServerRecord;
begin
   serverman.getSuperServer(srv);
   receiveparamthread  := servicefactory.createReceiveParamService(srv);
   if not launch(receiveparamthread, 'ReceiveParams', srv) then receiveparamthread.Free;

   receiveserverthread := servicefactory.createReceiveServerService(srv);
   if not launch(receiveserverthread, 'ReceiveServers', srv) then receiveserverthread.Free;
end;

procedure TCoreLoop.retrieveClients;
var receiveclientthread  : TReceiveClientServiceThread;
    srv                  : TServerRecord;
begin
   serverman.getServer(srv);
   receiveclientthread  := servicefactory.createReceiveClientService(srv);
   if not launch(receiveclientthread, 'ReceiveClients', srv) then receiveclientthread.Free;
end;

procedure TCoreLoop.transmitClient;
var transmitclientthread  : TTransmitClientServiceThread;
    srv                   : TServerRecord;
begin
   serverman.getDefaultServer(srv);
   transmitclientthread  := servicefactory.createTransmitClientService(srv);
   if not launch(transmitclientthread, 'TransmitClient', srv) then transmitclientthread.Free;
end;

procedure TCoreLoop.receiveChannels;
var receivechanthread     : TReceiveChannelServiceThread;
    srv                   : TServerRecord;
begin
   serverman.getDefaultServer(srv);
   receivechanthread  := servicefactory.createReceiveChannelService(srv, {srv.chatchannel}'Altos', 'CHAT');
   if not launch(receivechanthread, 'ReceiveChannels', srv) then receivechanthread.Free;
end;


end.