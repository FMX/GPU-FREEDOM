unit mainapp;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  openglspherecontrol, texturedrawingcontrol, lockfiles, loggers,
  coreconfigurations, dbtablemanagers, servermanagers;

type

  { TGPUMainApp }

  TGPUMainApp = class(TForm)
    openGLSphereControl : TOpenGLSphereControl;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OnAppIdle(Sender: TObject; var Done: Boolean);
  private
    path_,
    logHeader_ : String;
    lock_      : TLockFile;
    logger_    : TLogger;
    conf_      : TCoreConfiguration;
    tableman_  : TDbTableManager;
    sm_        : TServerManager;
  end;

var
  GPUMainApp: TGPUMainApp;

implementation

{ TGPUMainApp }

procedure TGPUMainApp.FormCreate(Sender: TObject);
begin
  path_ := extractFilePath(ParamStr(0));
  logHeader_ := 'gpugui> ';

  lock_     := TLockFile.Create(path_+PathDelim+'locks', 'guiapp.lock');
  logger_   := TLogger.Create(path_+PathDelim+'logs', 'guiapp.log', 'guiapp.old', LVL_DEBUG, 1024*1024);
  conf_     := TCoreConfiguration.Create(path_, 'coreapp.ini');
  conf_.loadConfiguration();
  tableman_ := TDbTableManager.Create(path_+PathDelim+'coreapp.db');
  tableman_.OpenAll;
  sm_          := TServerManager.Create(conf_, tableman_.getServerTable(), logger_);

  openGLSphereControl := TOpenGLSphereControl.Create(self);
  with OpenGLSphereControl do begin
    Name:='OpenGLSphereControl';
    Align:=alNone;
    Parent:=Self;
    Top := 0;
    Left := 0;
    Height := 360;
    Width := 360;
  end;
  //OpenGLSphereControl.setColors(eDrawingControl.getColors);

  Application.AddOnIdleHandler(@OnAppIdle);
end;

procedure TGPUMainApp.FormDestroy(Sender: TObject);
begin
  openGLSphereControl.Free;

  conf_.saveConfiguration();
  lock_.delete;

  sm_.Free;
  tableman_.CloseAll;
  tableman_.Free;
  conf_.Free;
  logger_.Free;
  lock_.Free;
end;

procedure TGPUMainApp.OnAppIdle(Sender: TObject; var Done: Boolean);
begin
  Done:=false;
  openGLSphereControl.Invalidate;
end;

initialization
  {$I mainapp.lrs}

end.

