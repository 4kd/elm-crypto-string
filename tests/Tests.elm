module Tests exposing (all)

import Crypto.Strings exposing (decrypt)
import Crypto.Strings.BlockAes as Aes
import Crypto.Strings.Chaining as Chaining
import Crypto.Strings.Crypt as Crypt
import Crypto.Strings.Encoding as Encoding
import Crypto.Strings.Types exposing (..)
import Expect exposing (Expectation)
import Random exposing (Seed)
import Test exposing (..)


{-| This runs all of your tests.

Each line is for a different result type.

-}
all : Test
all =
    Test.concat <|
        List.concat
            [ List.map doTest stringData
            ]


passphrase : String
passphrase =
    "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"


log =
    Debug.log


{-| change to True to log JSON input & output results
-}
enableLogging : Bool
enableLogging =
    False


maybeLog : String -> a -> a
maybeLog label value =
    if enableLogging then
        log label value
    else
        value


expectResult : Result err a -> Result err a -> Expectation
expectResult sb was =
    case maybeLog "  result" was of
        Err err ->
            case sb of
                Err _ ->
                    Expect.true "You shouldn't ever see this." True

                Ok _ ->
                    Expect.false (toString err) True

        Ok wasv ->
            case sb of
                Err _ ->
                    Expect.false "Expected an error but didn't get one." True

                Ok sbv ->
                    Expect.equal sbv wasv


doTest : ( String, a, a ) -> Test
doTest ( name, was, sb ) =
    test name
        (\_ ->
            expectResult (Ok sb) (Ok was)
        )


doResultTest : ( String, Result String a, Result String a ) -> Test
doResultTest ( name, was, sb ) =
    test name
        (\_ ->
            expectResult sb was
        )


seed : Seed
seed =
    Random.initialSeed 0


encrypt : String -> String -> Result String String
encrypt passphrase plaintext =
    case Crypto.Strings.encrypt seed passphrase plaintext of
        Err msg ->
            Err msg

        Ok ( res, _ ) ->
            Ok res


decrypt : String -> String -> Result String String
decrypt passphrase ciphertext =
    Crypto.Strings.decrypt passphrase ciphertext


encryptDecrypt : String -> String -> Result String String
encryptDecrypt passphrase plaintext =
    case encrypt passphrase plaintext of
        Ok ciphertext ->
            decrypt passphrase ciphertext

        err ->
            err


{-| This tests that ECB chaining and Hex encoding work.
-}
ecbConfig : Config Aes.Key Chaining.EcbState randomState
ecbConfig =
    { encryption = Aes.encryption
    , keyEncoding = Encoding.foldedSha256KeyEncoding
    , chaining = Chaining.ecbChaining
    , encoding = Encoding.hexEncoding
    }


ecbEncrypt : String -> String -> Result String String
ecbEncrypt passphrase plaintext =
    case Crypt.expandKeyString ecbConfig passphrase of
        Err msg ->
            Err msg

        Ok key ->
            let
                ( res, _ ) =
                    Crypt.encrypt ecbConfig (Crypt.seedGenerator seed) key plaintext
            in
            Ok res


ecbDecrypt : String -> String -> Result String String
ecbDecrypt passphrase ciphertext =
    case Crypt.expandKeyString ecbConfig passphrase of
        Err msg ->
            Err msg

        Ok key ->
            Crypt.decrypt ecbConfig key ciphertext


ecbEncryptDecrypt : String -> String -> Result String String
ecbEncryptDecrypt passphrase plaintext =
    case ecbEncrypt passphrase plaintext of
        Ok ciphertext ->
            ecbDecrypt passphrase ciphertext

        err ->
            err


{-| Tests that return integers
-}
stringData : List ( String, Result String String, Result String String )
stringData =
    [ ( "encrypt-foo", encryptDecrypt passphrase "foo", Ok "foo" )
    , ( "encrypt-bar", ecbEncryptDecrypt passphrase "bar", Ok "bar" )
    ]
