///////////////////////////////////////////////////////////
//
//                          OTOMO
//               Radar + Assit for Interlude
//                by LanGhost (c) 2020-2021
//
///////////////////////////////////////////////////////////

unit MMTarget;

interface

uses
     Helpers;   

type
    TMysticTarget = class
    private
        IsFindAfterKill: boolean;
        IgnoreWl: boolean;
        TargetClass: integer;
        LastTargetName: string;
        PrevTarget: TL2Live;
        CurTarget: TL2Live;
    public
        procedure SetIgnoreWl(status: boolean);
        procedure SetFindAfterKill(status: boolean);
        procedure SetClass(cls: integer);

        procedure FindTarget();
        procedure FindTargetAfterKill();
        procedure Hold();
        procedure Save();
    end;

implementation

///////////////////////////////////////////////////////////
//
//                        PUBLIC VARS
//
///////////////////////////////////////////////////////////

procedure TMysticTarget.SetIgnoreWl(status: boolean);
begin
    if (status <> self.IgnoreWl)
    then begin
        if (status)
        then PrintBotMsg('Ignore warlord: ON')
        else PrintBotMsg('Ignore warlord: OFF');
    end;

    self.IgnoreWl := status;
end;

procedure TMysticTarget.SetFindAfterKill(status: boolean);
begin
    if (status <> self.IsFindAfterKill)
    then begin
        if (status)
        then PrintBotMsg('Find target after kill: ON')
        else PrintBotMsg('Find target after kill: OFF');
    end;

    self.IsFindAfterKill := status;
end;

procedure TMysticTarget.SetClass(cls: integer);
begin
    if (cls <> self.TargetClass)
    then PrintBotMsg('Target class: ' + ClassIDToStr(cls));

    self.TargetClass := cls;
end;

///////////////////////////////////////////////////////////
//
//                      PUBLIC FUNCTIONS
//
///////////////////////////////////////////////////////////

procedure TMysticTarget.FindTarget();
var
    i: integer;
    target: TL2Char;
begin
    for i := 0 to CharList.Count - 1 do
    begin
         target := CharList.Items(i);
         if (target.Name() <> self.LastTargetName) and (not target.Dead())
            and (target.ClanID() <> User.ClanID()) and (not target.IsMember())
        then begin
            if (not UserValid())
            then break;

            if (self.TargetClass <> ALL_CLASS)
            then begin
                // Find concrete class
                if (target.ClassID() = self.TargetClass)
                then begin
                    self.LastTargetName := target.Name();
                    Engine.SetTarget(target);
                    break;
                end;
            end
            else begin
                // Find all targets
                self.LastTargetName := target.Name();
                Engine.SetTarget(target);
                break;
            end;
        end;
    end;
end;

procedure TMysticTarget.FindTargetAfterKill();
var
    enemy: TL2Live;
    p1, p2: Pointer;
begin
    if (self.IsFindAfterKill)
    then begin
        Engine.WaitAction([laDie], p1, p2);
        enemy := TL2Live(p1);

        if (enemy.Name() <> User.Target.Name())
        then exit();

        self.FindTarget();
    end;
end;

procedure TMysticTarget.Hold();
var
    p1, p2: pointer;
    action: TL2Action;
    escBtn: boolean;
begin
    action := Engine.WaitAction([laUnTarget, laKey], p1, p2);
    if (action = laUnTarget)
    then begin
        if not (User.Target() = self.CurTarget) and (not escBtn)
        then begin
            delay(100);
            Engine.SetTarget(self.CurTarget); 
        end; 
        delay(100);
        escBtn := false;
    end;

    if (action = laKey) 
    then escBtn := (Integer(p1) = $1B);
end;

procedure TMysticTarget.Save();
var
    action: TL2Action;
    p1, p2: pointer;
    enemy: TL2Char;
begin
    action := engine.WaitAction([laTarget], p1, p2);
    if (action = laTarget)
    then begin
        if (User.Target() <> self.CurTarget) then
        begin
            self.PrevTarget := self.CurTarget;
            self.CurTarget := User.Target;
        end;
    end;

    if (self.IgnoreWl)
    then begin
        if (CharList.ByName(User.Target.Name(), enemy))
        then begin
            if (enemy.ClassID = WARLORD_CLASS)
            then Engine.SetTarget(self.PrevTarget);
        end;
    end;
end;

///////////////////////////////////////////////////////////
//
//                      PRIVATE FUNCTIONS
//
///////////////////////////////////////////////////////////


end.