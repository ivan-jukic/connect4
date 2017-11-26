module Main exposing (..)

import AnimationFrame
import Html exposing (Html, div, text)
import Html.Attributes exposing (width, height, style)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (vec3, Vec3)
import Time exposing (Time)
import WebGL exposing (Mesh, Shader)


{-|
-}
type Msg
    = NoOp
    | TimeFrame Time


{-|
-}
type alias Model =
    { t : Float
    , deltat : Float
    , sec : Int
    , fps : Int
    , fpsCount : Int
    }


initialModel : Model
initialModel =
    { t = 0
    , deltat = 0
    , sec = 0
    , fps = 60
    , fpsCount = 0
    }


{-|
-}
main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


{-|
-}
init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


{-|
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        TimeFrame elapsed ->
            let
                secTmp =
                    model.sec + (round elapsed)

                sec =
                    if secTmp < 1000 then secTmp else 0
            in
            ( { model
                | t = model.t + elapsed
                , deltat = elapsed
                , sec = sec
                , fps =
                    if sec == 0 then model.fpsCount else model.fps
                , fpsCount =
                    if sec == 0 then 0 else model.fpsCount + 1
                }
            , Cmd.none
            )


{-|
-}
subscriptions : Model -> Sub Msg
subscriptions model =
    AnimationFrame.diffs TimeFrame


{-|
-}
view : Model -> Html Msg
view model =
    div []
        [ div
            [ style
                [ ( "top", "0" )
                , ( "left", "0" )
                , ( "color", "#C00" )
                , ( "padding", "20px" )
                , ( "font-size", "18px" )
                , ( "font-weight", "bold" )
                , ( "position", "absolute" )
                , ( "font-family", "Courier New" )
                ]
            ]
            [ text ("FPS " ++ (toString model.fps)) ]
        , WebGL.toHtml
            [ width 800
            , height 600
            , style [ ( "display", "block" ) ]
            ]
            [ WebGL.entity
                vertexShader
                fragmentShader
                mesh
                { perspective = perspective (model.t / 1000) }
            ]
        ]


{-|
-}
perspective : Float -> Mat4
perspective t =
    Mat4.mul
        (Mat4.makePerspective 45 1 0.01 100)
        (Mat4.makeLookAt (vec3 (4 * cos t) 0 (4 * sin t)) (vec3 0 0 0) (vec3 0 1 0))


-- Mesh


{-|
-}
type alias Vertex =
    { position : Vec3
    , color : Vec3
    }


{-|
-}
mesh : Mesh Vertex
mesh =
    WebGL.triangles
        [ ( Vertex (vec3 0 0 0) (vec3 1 0 0)
          , Vertex (vec3 1 1 0) (vec3 0 1 0)
          , Vertex (vec3 1 -1 0) (vec3 0 0 1)
          )
        ]


-- Shaders


{-|
-}
type alias Uniforms =
    { perspective : Mat4 }


{-|
-}
vertexShader : Shader Vertex Uniforms { vcolor: Vec3 }
vertexShader =
    [glsl|

        attribute vec3 position;
        attribute vec3 color;
        uniform mat4 perspective;
        varying vec3 vcolor;

        void main () {
            gl_Position = perspective * vec4(position, 1.0);
            vcolor = color;
        }

    |]


{-|
-}
fragmentShader : Shader {} Uniforms { vcolor : Vec3 }
fragmentShader =
    [glsl|
    
        precision mediump float;
        varying vec3 vcolor;

        void main () {
            gl_FragColor = vec4(vcolor, 1.0);
        }

    |]
