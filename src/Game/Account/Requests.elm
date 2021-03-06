module Game.Account.Requests exposing (Response(..), receive)

import Game.Account.Requests.ServerIndex as ServerIndex
import Game.Account.Messages exposing (..)


type Response
    = ServerIndexResponse ServerIndex.Response
    | NoOpResponse


receive : RequestMsg -> Response
receive response =
    case response of
        ServerIndexRequest ( code, data ) ->
            data
                |> ServerIndex.receive code
                |> ServerIndexResponse

        LogoutRequest _ ->
            NoOpResponse
