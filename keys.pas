///////////////////////////////////////////////////////////
//
//                          OTOMO
//               Radar + Assit for Interlude
//                by LanGhost (c) 2020-2021
//
///////////////////////////////////////////////////////////

unit Keys;

interface

uses
    MM, Classes, Helpers, MMAttack;

const
    KEY_MM_NEXT_TARGET_ALL = 1;
    KEY_MM_NEXT_TARGET_MM = 2;
    KEY_MM_NEXT_TARGET_BP = 3;
    KEY_MM_AUTO_ATTACK_RUN = 4;
    KEY_MM_NEXT_ATTACK_RANGE = 5;
    KEY_MM_NEXT_ATTACK_TYPE = 6;
    KEY_MM_NEXT_ROLE = 7;
    KEY_MM_IGNORE_WL = 8;
    KEY_MM_TARGET_FIND_AFTER_KILL = 9;
    KEY_MM_FAST_RES = 10;
    KEY_MM_SELF_NOOBLE = 11;
    KEY_MM_MOVE_TO_ASSISTER = 12;
    KEY_MM_CANCEL = 13;
    KEY_MM_ARCANE_CHAOS = 14;
    KEY_MM_CLEAR_ASSISTER = 15;
    KEY_MM_ADD_ASSISTER = 16;

type
    TKey = class
    public
        Key: integer;
        Code: integer;
    end;

    TKeyboard = class
    private
        Keys: TList;
    public
        procedure AddKey(k: integer; code: string);

        constructor Create();
        procedure KeysRead();
    end;

var
    Keyboard: TKeyboard;

implementation

///////////////////////////////////////////////////////////
//
//                    WINAPI FUNCTIONS
//
///////////////////////////////////////////////////////////
 
function GetAsyncKeyState(vKey: integer): integer; stdcall; external 'user32.dll';

///////////////////////////////////////////////////////////
//
//                      PUBLIC FUNCTIONS
//
///////////////////////////////////////////////////////////

constructor TKeyboard.Create();
begin
    inherited;
    self.Keys := TList.Create();
end;

procedure TKeyboard.AddKey(k: integer; code: string);
var
    newKey: TKey;
begin
    newKey := TKey.Create();
    newKey.Code := KeyToCode(code);
    newKey.Key := k;
    self.Keys.Add(Pointer(newKey));
end;

procedure TKeyboard.KeysRead();
var
    i: integer;
    key: integer;
begin
    for i := 0 to self.Keys.Count - 1 do
    begin
        if (GetAsyncKeyState(TKey(self.Keys[i]).Code) <> 0)
        then begin
            key := TKey(self.Keys[i]).Key;

            if (key = KEY_MM_NEXT_TARGET_ALL)
            then begin
                MysticMuse.SetTargetClass(ALL_CLASS);
                MysticMuse.FindTarget();
            end
            else if (key = KEY_MM_NEXT_TARGET_MM)
            then begin
                MysticMuse.SetTargetClass(MM_CLASS);
                MysticMuse.FindTarget();
            end
            else if (key = KEY_MM_NEXT_TARGET_BP)
            then begin
                MysticMuse.SetTargetClass(BP_CLASS);
                MysticMuse.FindTarget();
            end
            else if (key = KEY_MM_AUTO_ATTACK_RUN)
            then begin
                MysticMuse.SetAutoAttack(not MysticMuse.GetAutoAttack());
            end
            else if (key = KEY_MM_NEXT_ROLE)
            then begin
                if (MysticMuse.GetRole() = MM_ROLE_RADAR)
                then MysticMuse.SetRole(MM_ROLE_ASSIST)
                else MysticMuse.SetRole(MM_ROLE_RADAR);
            end
            else if (key = KEY_MM_NEXT_ATTACK_RANGE)
            then begin
                if (MysticMuse.GetAutoAttackRange() = MYSTIC_AUTO_ATTACK_RANGE_LONG)
                then MysticMuse.SetAutoAttackRange(MYSTIC_AUTO_ATTACK_RANGE_MILI)
                else MysticMuse.SetAutoAttackRange(MYSTIC_AUTO_ATTACK_RANGE_LONG);
            end
            else if (key = KEY_MM_NEXT_ATTACK_TYPE)
            then begin
                if (MysticMuse.GetAutoAttackRange() = MYSTIC_AUTO_ATTACK_RANGE_LONG)
                then begin
                    if (MysticMuse.GetAutoAttackType(MYSTIC_AUTO_ATTACK_RANGE_LONG) = MYSTIC_AUTO_ATTACK_SURRENDER)
                    then MysticMuse.SetAutoAttackType(MYSTIC_AUTO_ATTACK_RANGE_LONG, MYSTIC_AUTO_ATTACK_LIGHT)
                    else if (MysticMuse.GetAutoAttackType(MYSTIC_AUTO_ATTACK_RANGE_LONG) = MYSTIC_AUTO_ATTACK_LIGHT)
                    then MysticMuse.SetAutoAttackType(MYSTIC_AUTO_ATTACK_RANGE_LONG, MYSTIC_AUTO_ATTACK_ICE)
                    else if (MysticMuse.GetAutoAttackType(MYSTIC_AUTO_ATTACK_RANGE_LONG) = MYSTIC_AUTO_ATTACK_ICE)
                    then MysticMuse.SetAutoAttackType(MYSTIC_AUTO_ATTACK_RANGE_LONG, MYSTIC_AUTO_ATTACK_SOLAR)
                    else if (MysticMuse.GetAutoAttackType(MYSTIC_AUTO_ATTACK_RANGE_LONG) = MYSTIC_AUTO_ATTACK_SOLAR)
                    then MysticMuse.SetAutoAttackType(MYSTIC_AUTO_ATTACK_RANGE_LONG, MYSTIC_AUTO_ATTACK_SURRENDER);
                end
                else if (MysticMuse.GetAutoAttackRange() = MYSTIC_AUTO_ATTACK_RANGE_MILI)
                then begin
                    if (MysticMuse.GetAutoAttackType(MYSTIC_AUTO_ATTACK_RANGE_MILI) = MYSTIC_AUTO_ATTACK_FLARE)
                    then MysticMuse.SetAutoAttackType(MYSTIC_AUTO_ATTACK_RANGE_MILI, MYSTIC_AUTO_ATTACK_BOLT)
                    else MysticMuse.SetAutoAttackType(MYSTIC_AUTO_ATTACK_RANGE_MILI, MYSTIC_AUTO_ATTACK_FLARE);
                end;
            end
            else if (key = KEY_MM_IGNORE_WL)
            then begin
                MysticMuse.SetTargetIgnoreWl(not MysticMuse.GetTargetIgnoreWl());
            end
            else if (key = KEY_MM_TARGET_FIND_AFTER_KILL)
            then begin
                MysticMuse.SetFindAfterKill(not MysticMuse.GetFindAfterKill());
            end
            else if (key = KEY_MM_FAST_RES)
            then begin
                MysticMuse.SetFastResurrection(not MysticMuse.GetFastResurrection());
            end
            else if (key = KEY_MM_SELF_NOOBLE)
            then begin
                MysticMuse.SetSelfNoblBuff(not MysticMuse.GetSelfNoblBuff());
            end
            else if (key = KEY_MM_MOVE_TO_ASSISTER)
            then begin
                MysticMuse.SetMoveToAssister(not MysticMuse.GetMoveToAssister());
            end
            else if (key = KEY_MM_CANCEL)
            then begin
                MysticMuse.Cancel();
            end
            else if (key = KEY_MM_ARCANE_CHAOS)
            then begin
                MysticMuse.SetArcaneChaos(not MysticMuse.GetArcaneChaos());
            end
            else if (key = KEY_MM_CLEAR_ASSISTER)
            then begin
                MysticMuse.ClearAssisters();
            end
            else if (key = KEY_MM_ADD_ASSISTER)
            then begin
                MysticMuse.AddAssister(User.Target.Name());
            end;

            Delay(300);
            break;
        end;
    end;
end;

end.