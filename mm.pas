///////////////////////////////////////////////////////////
//
//                          OTOMO
//               Radar + Assit for Interlude
//                by LanGhost (c) 2020-2021
//
///////////////////////////////////////////////////////////

unit MM;

interface

uses
    MMAttack, MMTarget, Helpers, MMBuff, MMAssist;

const
    MM_ROLE_RADAR = 1;
    MM_ROLE_ASSIST = 2;

type
    TMysticMuse = class
    private
        Attack: TMysticAttack;
        Target: TMysticTarget;
        Buffer: TMysticBuff;
        Assister: TMysticAssist;

        Role: integer;
    public
        procedure SetRole(role: integer);
        procedure SetAutoAttackType(range: integer; atkType: integer);
        procedure SetTargetIgnoreWl(status: boolean);
        procedure SetFindAfterKill(status: boolean);
        procedure SetTargetClass(cls: integer);
        procedure SetCheckCancel(status: boolean);
        procedure SetFastResurrection(status: boolean);
        procedure SetCrystalBuffCheck(status: boolean);
        procedure SetSelfNoblBuff(status: boolean);
        procedure SetReskillDelay(del: integer);
        procedure AddIgnoreClan(clan: string);
        procedure SetAutoAttack(status: boolean);
        procedure SetAutoAttackRange(range: integer);
        procedure AddAssister(name: string);
        procedure SetArcaneChaos(status: boolean);
        procedure SetMoveToAssister(status: boolean);
        procedure ClearAssisters();
        function GetMoveToAssister(): boolean;
        function GetArcaneChaos(): boolean;
        function GetRole(): integer;
        function GetAutoAttack(): boolean;
        function GetAutoAttackRange(): integer;
        function GetAutoAttackType(range: integer): integer;
        function GetTargetIgnoreWl(): boolean;
        function GetFindAfterKill(): boolean;
        function GetTargetClass(): integer;
        function GetFastResurrection(): boolean;
        function GetCheckCancel(): boolean;
        function GetCrystalBuff(): boolean;
        function GetSelfNoblBuff(): boolean;

        constructor Create();
        procedure RunAutoAttack();
        procedure FindTarget();
        procedure FindTargetAfterKill();
        procedure TargetHold();
        procedure TargetSave();
        procedure AutoFlash();
        procedure SelfBuff();
        procedure AutoFlashPacket(data: pointer; size: word);
        procedure Reskill();
        procedure MoveToAssister();
        procedure Cancel();
        procedure AssistAttack();
        procedure AssistSpell();
        procedure AssistPacket(data: pointer; size: word);
    end;

var
    MysticMuse: TMysticMuse;

implementation

///////////////////////////////////////////////////////////
//
//                        PUBLIC VARS
//
///////////////////////////////////////////////////////////

procedure TMysticMuse.SetAutoAttack(status: boolean);
begin
    self.Attack.SetAttackStatus(status);
end;

function TMysticMuse.GetAutoAttack(): boolean;
begin
    result := self.Attack.GetAttackStatus();
end;

procedure TMysticMuse.SetAutoAttackRange(range: integer);
begin
    self.Attack.SetRange(range);
end;

function TMysticMuse.GetAutoAttackRange(): integer;
begin
    result := self.Attack.GetRange();
end;

procedure TMysticMuse.SetAutoAttackType(range: integer; atkType: integer);
begin
    self.Attack.SetType(range, atkType);
end;

function TMysticMuse.GetAutoAttackType(range: integer): integer;
begin
    result := self.Attack.GetType(range);
end;

procedure TMysticMuse.SetTargetIgnoreWl(status: boolean);
begin
    self.Target.SetIgnoreWl(status);
end;

procedure TMysticMuse.SetFindAfterKill(status: boolean);
begin
    self.Target.SetFindAfterKill(status);
end;

procedure TMysticMuse.SetTargetClass(cls: integer);
begin
    self.Target.SetClass(cls);
end;

procedure TMysticMuse.SetRole(role: integer);
begin
    if (role = MM_ROLE_RADAR)
    then self.Assister.SetAssistStatus(false)
    else if (role = MM_ROLE_ASSIST)
    then self.Assister.SetAssistStatus(true);

    if (role <> self.Role)
    then begin
        if (role = MM_ROLE_RADAR)
        then PrintBotMsg('Player role: RADAR')
        else if (role = MM_ROLE_ASSIST)
        then PrintBotMsg('Player role: ASSIST');
    end;

    self.Role := role;
end;

function TMysticMuse.GetRole(): integer;
begin
    result := self.Role;
end;

procedure TMysticMuse.SetCheckCancel(status: boolean);
begin
    self.Buffer.SetCheckCancel(status);
end;

procedure TMysticMuse.SetFastResurrection(status: boolean);
begin
    self.Buffer.SetFastRes(status);
end;

procedure TMysticMuse.SetCrystalBuffCheck(status: boolean);
begin
    self.Buffer.SetCrystal(status);
end;

procedure TMysticMuse.SetSelfNoblBuff(status: boolean);
begin
    self.Buffer.SetSelfNobl(status);
end;

procedure TMysticMuse.SetReskillDelay(del: integer);
begin
    self.Attack.SetReskillDelay(del);
end;

function TMysticMuse.GetTargetIgnoreWl(): boolean;
begin
    result := self.Target.GetIgnoreWl();
end;

function TMysticMuse.GetFindAfterKill(): boolean;
begin
    result := self.Target.GetFindAfterKill();
end;

function TMysticMuse.GetTargetClass(): integer;
begin
    result := self.Target.GetClass();
end;

function TMysticMuse.GetFastResurrection(): boolean;
begin
    result := self.Buffer.GetFastRes();
end;

function TMysticMuse.GetCheckCancel(): boolean;
begin
    result := self.Buffer.GetCheckCancel();
end;

function TMysticMuse.GetCrystalBuff(): boolean;
begin
    result := self.Buffer.GetCrystal();
end;

function TMysticMuse.GetSelfNoblBuff(): boolean;
begin
    result := self.Buffer.GetSelfNobl();
end;

procedure TMysticMuse.AddAssister(name: string);
begin
    self.Assister.AddAssister(name);
end;

procedure TMysticMuse.SetArcaneChaos(status: boolean);
begin
    self.Assister.SetArcaneChaos(status);
end;

function TMysticMuse.GetArcaneChaos(): boolean;
begin
    result := self.Assister.GetArcaneChaos();
end;

procedure TMysticMuse.SetMoveToAssister(status: boolean);
begin
    self.Assister.SetMoveToAssister(status);
end;

function TMysticMuse.GetMoveToAssister(): boolean;
begin
    result := self.Assister.GetMoveToAssister();
end;

procedure TMysticMuse.MoveToAssister();
begin
    if (self.Role = MM_ROLE_ASSIST)
    then self.Assister.MoveToAssister();
end;

procedure TMysticMuse.ClearAssisters();
begin
    self.Assister.ClearAssisters();
end;

///////////////////////////////////////////////////////////
//
//                      PUBLIC FUNCTIONS
//
///////////////////////////////////////////////////////////

constructor TMysticMuse.Create();
begin
    inherited;

    self.Attack := TMysticAttack.Create();
    self.Target := TMysticTarget.Create();
    self.Buffer := TMysticBuff.Create();
    self.Assister := TMysticAssist.Create();

    self.SetRole(MM_ROLE_RADAR);
    self.SetAutoAttack(false);
    self.SetAutoAttackRange(MYSTIC_AUTO_ATTACK_RANGE_LONG);
    self.SetAutoAttackType(MYSTIC_AUTO_ATTACK_RANGE_LONG, MYSTIC_AUTO_ATTACK_SURRENDER);
    self.SetAutoAttackType(MYSTIC_AUTO_ATTACK_RANGE_MILI, MYSTIC_AUTO_ATTACK_BOLT);
    self.SetTargetIgnoreWl(false);
    self.SetFindAfterKill(true);
    self.SetTargetClass(ALL_CLASS);
    self.Buffer.SetFastRes(false);
    self.Buffer.SetCheckCancel(true);
    self.Buffer.SetCrystal(false);
    self.Buffer.SetSelfNobl(true);
    self.Attack.SetReskillDelay(500);
    self.Assister.SetAssistStatus(false);
    self.Assister.SetArcaneChaos(true);
end;

procedure TMysticMuse.RunAutoAttack();
begin
    self.Attack.Attack();
end;

procedure TMysticMuse.AutoFlashPacket(data: pointer; size: word);
begin
    self.Attack.AutoFlashPacket(data, size);
end;

procedure TMysticMuse.AutoFlash();
begin
    self.Attack.AutoFlash();
end;

procedure TMysticMuse.FindTarget();
begin
    if (self.Role = MM_ROLE_RADAR)
    then self.Target.FindTarget();
end;

procedure TMysticMuse.FindTargetAfterKill();
begin
    if (self.Role = MM_ROLE_RADAR)
    then self.Target.FindTargetAfterKill();
end;

procedure TMysticMuse.TargetHold();
begin
    self.Target.Hold();
end;

procedure TMysticMuse.TargetSave();
begin
    self.Target.Save();
end;

procedure TMysticMuse.SelfBuff();
begin
    self.Buffer.SelfBuff(self.Role);
end;

procedure TMysticMuse.Reskill();
begin
    if (Role = MM_ROLE_RADAR)
    then self.Attack.Reskill();
end;

procedure TMysticMuse.AddIgnoreClan(clan: string);
begin
    PrintBotMsg('Add ignore clan: ' + clan);
    self.Attack.AddIgnoreClan(clan);
    self.Target.AddIgnoreClan(clan);
end;

procedure TMysticMuse.AssistPacket(data: pointer; size: word);
begin
    if (Role = MM_ROLE_ASSIST)
    then self.Assister.AssistPacket(data, size);
end;

procedure TMysticMuse.AssistSpell();
begin
    if (Role = MM_ROLE_ASSIST)
    then self.Assister.AssistSpell();
end;

procedure TMysticMuse.AssistAttack();
begin
    if (Role = MM_ROLE_ASSIST)
    then self.Assister.AssistAttack();
end;

procedure TMysticMuse.Cancel();
begin
    self.Attack.Cancel();
end;


end.