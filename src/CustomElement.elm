port module CustomElement exposing (init, subscriptions, update, view)

--import Html.Attributes exposing (class, classList)
--import Html.Events exposing (onClick)

import Html exposing (Html, div, h3, text)
import Json.Decode exposing (Value, decodeValue)
import Json.Encode as Encode
import Json.Form
import Json.Form.Config exposing (Config)
import Json.Schema.Definitions
import Json.Value as JsonValue exposing (decoder)


type alias Model =
    { form : Json.Form.Model
    , config : Config
    , schema : Json.Schema.Definitions.Schema
    , editedValue : Maybe JsonValue.JsonValue
    }


init : Value -> ( Model, Cmd Msg )
init v =
    let
        schema =
            v
                |> decodeValue (Json.Decode.field "schema" Json.Schema.Definitions.decoder)
                |> Result.mapError Debug.log
                |> Result.withDefault Json.Schema.Definitions.blankSchema

        config =
            v
                |> decodeValue (Json.Decode.field "config" Json.Form.Config.decoder)
                |> Result.withDefault Json.Form.Config.defaultConfig

        value =
            v
                |> decodeValue (Json.Decode.field "value" JsonValue.decoder)
                |> Result.toMaybe
    in
    { form = Json.Form.init config schema value
    , editedValue = value
    , schema = schema
    , config = config
    }
        ! []


type Msg
    = JsonFormMsg Json.Form.Msg
    | ChangeValue Value
    | ChangeSchema Value
    | ChangeConfig Value


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        ChangeConfig v ->
            case v |> decodeValue Json.Form.Config.decoder of
                Ok config ->
                    { model
                        | config = config
                        , form = model.form |> Json.Form.updateConfig config
                    }
                        ! []

                Err _ ->
                    model ! []

        ChangeSchema v ->
            let
                schema =
                    v
                        |> decodeValue Json.Schema.Definitions.decoder
                        |> Result.withDefault Json.Schema.Definitions.blankSchema
            in
            { model
                | schema = schema
                , form = Json.Form.init model.config schema model.editedValue
            }
                ! []

        ChangeValue v ->
            let
                value =
                    v
                        |> decodeValue JsonValue.decoder
                        |> Result.toMaybe
            in
            { model
                | editedValue = value
                , form = Json.Form.init model.config model.schema value
            }
                ! []

        JsonFormMsg msg ->
            let
                ( ( m, cmd ), exMsg ) =
                    Json.Form.update msg model.form

                ( editedValue, exCmd ) =
                    case exMsg of
                        Json.Form.UpdateValue v isValid ->
                            ( v
                            , Encode.object
                                [ ( "value"
                                  , v
                                        |> Maybe.withDefault JsonValue.NullValue
                                        |> JsonValue.encode
                                  )
                                , ( "isValid", Encode.bool isValid )
                                ]
                                |> value
                            )

                        _ ->
                            ( model.editedValue, Cmd.none )
            in
            { model
                | form = m
                , editedValue = editedValue
            }
                ! [ cmd |> Cmd.map JsonFormMsg, exCmd ]


view : Model -> Html Msg
view model =
    model.form
        |> Json.Form.view
        |> Html.map JsonFormMsg


port valueChange : (Value -> msg) -> Sub msg


port value : Value -> Cmd msg


port schemaChange : (Value -> msg) -> Sub msg


port configChange : (Value -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ valueChange ChangeValue
        , schemaChange ChangeSchema
        , configChange ChangeConfig
        ]
