module Game.Servers.Processes.Models exposing (..)

import Dict
import Utils.Dict as DictUtils
import Game.Servers.Processes.Types.Shared exposing (..)
import Game.Servers.Processes.Types.Local as Local exposing (ProcessProp, ProcessState(..))
import Game.Servers.Processes.Types.Remote as Remote exposing (ProcessProp)


type ProcessProp
    = LocalProcess Local.ProcessProp
    | RemoteProcess Remote.ProcessProp


type alias Process =
    { id : ProcessID
    , prop : ProcessProp
    }


type alias Processes =
    Dict.Dict ProcessID Process


initialProcesses : Processes
initialProcesses =
    Dict.empty


{-| REVIEW: this doesn't look that useful
-}
getProcessID : Process -> ProcessID
getProcessID process =
    process.id


getProcessByID : ProcessID -> Processes -> Maybe Process
getProcessByID id processes =
    Dict.get id processes


processExists : ProcessID -> Processes -> Bool
processExists id processes =
    Dict.member id processes


addProcess : Process -> Processes -> Processes
addProcess process =
    Dict.insert process.id process


removeProcess : Processes -> Process -> Processes
removeProcess processes process =
    Dict.remove process.id processes


doLocalProcess : (Local.ProcessProp -> Local.ProcessProp) -> Processes -> Process -> Processes
doLocalProcess job processes process =
    case process.prop of
        LocalProcess prop ->
            let
                localProp_ =
                    job prop

                prop_ =
                    LocalProcess localProp_
            in
                DictUtils.safeUpdate process.id { process | prop = prop_ } processes

        _ ->
            processes


pauseProcess : Processes -> Process -> Processes
pauseProcess =
    doLocalProcess (\process -> { process | state = StatePaused })


resumeProcess : Processes -> Process -> Processes
resumeProcess =
    doLocalProcess (\process -> { process | state = StateRunning })


completeProcess : Processes -> Process -> Processes
completeProcess =
    doLocalProcess (\process -> { process | state = StateComplete })
