module Main exposing (..)

import AnimationFrame
import Color exposing (Color)
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
                cubeMesh
                (uniforms (model.t / 5000))
            ]
        ]


{-|
-}
type alias Uniforms =
    { rotation : Mat4
    , perspective : Mat4
    , camera : Mat4
    , shade : Float
    }


uniforms : Float -> Uniforms
uniforms theta =
    { rotation =
        Mat4.mul
            (Mat4.makeRotate (3 * theta) (vec3 0 1 0))
            (Mat4.makeRotate (2 * theta) (vec3 1 0 0))
    , perspective = Mat4.makePerspective 45 1 0.01 100
    , camera = Mat4.makeLookAt (vec3 0 0 5) (vec3 0 0 0) (vec3 0 1 0)
    , shade = 0.8
    }


-- Mesh


{-|
-}
type alias Vertex =
    { color : Vec3
    , position : Vec3
    }


{-|
-}
cubeMesh : Mesh Vertex
cubeMesh =
    let
        rft =
            vec3 1 1 1

        lft =
            vec3 -1 1 1

        lbt =
            vec3 -1 -1 1

        rbt =
            vec3 1 -1 1

        rbb =
            vec3 1 -1 -1

        rfb =
            vec3 1 1 -1

        lfb =
            vec3 -1 1 -1

        lbb =
            vec3 -1 -1 -1
    in
    [ face Color.green rft rfb rbb rbt
    , face Color.blue rft rfb lfb lft
    , face Color.yellow rft lft lbt rbt
    , face Color.red rfb lfb lbb rbb
    , face Color.purple lft lfb lbb lbt
    , face Color.orange rbt rbb lbb lbt
    ]
    |> List.concat
    |> WebGL.triangles


face : Color -> Vec3 -> Vec3 -> Vec3 -> Vec3 -> List ( Vertex, Vertex, Vertex )
face rawColor a b c d =
    let
        color =
            let
                c =
                    Color.toRgb rawColor
            in
                vec3
                    (toFloat c.red / 255)
                    (toFloat c.green / 255)
                    (toFloat c.blue / 255)

        vertex position =
            Vertex color position
    in
    [ ( vertex a, vertex b, vertex c )
    , ( vertex c, vertex d, vertex a )
    ]


-- Shaders


{-|
-}
vertexShader : Shader Vertex Uniforms { vcolor: Vec3 }
vertexShader =
    [glsl|

        attribute vec3 position;
        attribute vec3 color;
        uniform mat4 perspective;
        uniform mat4 camera;
        uniform mat4 rotation;
        varying vec3 vcolor;

        void main () {
            gl_Position = perspective * camera * rotation * vec4(position, 1.0);
            vcolor = color;
        }

    |]


{-|
-}
fragmentShader : Shader {} Uniforms { vcolor : Vec3 }
fragmentShader =
    [glsl|
    
        precision mediump float;
        uniform float shade;
        varying vec3 vcolor;

        void main () {
            gl_FragColor = shade * vec4(vcolor, 1.0);
        }

    |]
